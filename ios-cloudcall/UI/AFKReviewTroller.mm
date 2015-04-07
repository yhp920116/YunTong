//
//  AFKReviewTroller.m
//  AFKReviewTroller
//
//  Created by Marco Tabini on 11-02-06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AFKReviewTroller.h"
#import "iOSNgnStack.h"
#import "JSONKit.h"

#define kAFKReviewTrollerRunCountDefault @"kCloudCallRunCountDefault"

@implementation AFKReviewTroller

#pragma mark
#pragma mark NSObject Method
+ (void) load {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        
    int numberOfExecutions = [standardDefaults integerForKey:kAFKReviewTrollerRunCountDefault] + 1;
    
    NSString *oldVersion = [[NgnEngine sharedInstance].configurationService getStringWithKey:kCloudCallVersion];
    NSString *currVersion = CloudCallVersion;
    
    if (![oldVersion isEqualToString:currVersion])
    {
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:@"isNeverPromptAppraise" andValue:NO];
        [[NgnEngine sharedInstance].configurationService setStringWithKey:kCloudCallVersion andValue:currVersion];
    }
    
    [[[AFKReviewTroller alloc] initWithNumberOfExecutions:numberOfExecutions] performSelector:@selector(setup) withObject:Nil afterDelay:1.0];
    
    [standardDefaults setInteger:numberOfExecutions forKey:kAFKReviewTrollerRunCountDefault];
    [standardDefaults synchronize];

    [pool release];
}


+ (int) numberOfExecutions {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kAFKReviewTrollerRunCountDefault];
}


- (id) initWithNumberOfExecutions:(int) executionCount {
    if ((self = [super init])) {
        numberOfExecutions = executionCount;
    }
    
    return self;
}


- (void) setup
{
    NSDictionary *bundleDictionary = [[NSBundle mainBundle] infoDictionary];
    
    //是否显示好评向导,appstore审核时隐藏用
    BOOL showAwardPraise = NO;//[[CloudCall2AppDelegate sharedInstance] ShowAllFeatures];
    
    //是否允许弹出,永久
    BOOL isNeverPromptAppraise = [[NgnEngine sharedInstance].configurationService getBoolWithKey:@"isNeverPromptAppraise"];
    
    //上一次弹出时间
    NSString *strLastDate = [[NgnEngine sharedInstance].configurationService getStringWithKey:kCloudCallAppriseLastDate];
    
    //当前时间
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strNowDate = [dateFormatter stringFromDate:nowDate];
    [dateFormatter release];
    
    NSString *telnumber = [[CloudCall2AppDelegate sharedInstance] getUserName];
    
    //启动次数大于%d次且当天允许弹出
    if (showAwardPraise && [[CloudCall2AppDelegate sharedInstance] MarkCode] == CLIENT_FOR_AS_APP_STORE && numberOfExecutions >= [[bundleDictionary objectForKey:kCloudCallRunCount] intValue] && !isNeverPromptAppraise && ![strLastDate isEqualToString:strNowDate] && [telnumber length])
    {
        NSString *title = NSLocalizedString(@"Award Praise", @"Award Praise");
        NSString *message = NSLocalizedString(@"Award Praise Content", @"Award Praise Content");
        
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:title 
                                                             message:message 
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"No longer remind", @"No longer remind")
                                                   otherButtonTitles:NSLocalizedString(@"Positive effect", @"Positive effect"),NSLocalizedString(@"Cruel refused", @"Cruel refused"), Nil]
                                  autorelease];
        [alertView show];
    }
}

#pragma mark
#pragma mark Private Methods
+ (void)sendPraiseDataToServer
{
    NSString *telnumber = [[CloudCall2AppDelegate sharedInstance] getUserName];
    
    NSError *error;
    
    //设置充值数据
    NSDictionary *context = [NSDictionary dictionaryWithObject:telnumber forKey:@"user_number"];
    NSArray *contextArray = [NSArray arrayWithObject:context];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:@"praise", @"oper_type", contextArray, @"context", nil];
    NSData* jsonBody = nil;
    if (SystemVersion >= 5.0)
    {
        if([NSJSONSerialization isValidJSONObject:body])
        {
            jsonBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
            NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
            CCLog(@"sendPraiseDataToServer-->%@",json);
        }
    }
    else
    {
        jsonBody = [body JSONData];
        
        NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
        CCLog(@"sendPraiseDataToServer-->%@",json);
    }
    
    [self postAwardPraiseDataToServer:kPraiseUrl andData:jsonBody];
}

#pragma mark
#pragma mark HttpRequestDelegate
/**
 *	@brief	向服务器请求数据
 *
 *	@param 	url 	请求url
 */
+ (void)postAwardPraiseDataToServer:(NSString*)strUrl andData:(NSData *)jsonData
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
	[userInfo setObject:@"postAwardPraiseDataToServer" forKey:@"msgtype"];
    [[HttpRequest instance] addRequest:strUrl andMethod:@"POST" andHeaderFields:[self getRequestHeader] andContent:jsonData andTimeout:8
                         successTarget:self successAction:@selector(postAwardPraiseDataToServerSucceeded:userInfo:)
                         failureTarget:self failureAction:@selector(postAwardPraiseDataToServerFailed:userInfo:) userInfo:userInfo];
    [userInfo release];
}

/**
 *	@brief	设置请求头部信息
 */
+ (NSMutableArray *)getRequestHeader
{
    NSString* mac = [NgnDeviceInfo2 uniqueGlobalDeviceIdentifier];
    
    //获取市场ID
    int mtype = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_MAKET_TYPE];
    NSString* maketType = [NSString stringWithCString:getMarketName(mtype) encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSString* strLang = currentLanguage;
    if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        strLang = @"CN";
    }
    
    //https头部信息
    NSMutableArray *httpsHeader = [[[NSMutableArray alloc] init] autorelease];
    [httpsHeader addObject:[NSArray arrayWithObjects: AppKeyIdForBill, @"appkey", nil]];
    [httpsHeader addObject:[NSArray arrayWithObjects: @"IOS", @"devicetype", nil]];
    [httpsHeader addObject:[NSArray arrayWithObjects: mac, @"deviceid", nil]];
    [httpsHeader addObject:[NSArray arrayWithObjects: [NgnSipStack platform], @"devicename", nil]];
    [httpsHeader addObject:[NSArray arrayWithObjects: mac, @"mac", nil]];
    [httpsHeader addObject:[NSArray arrayWithObjects: maketType, @"marketid", nil]];
    [httpsHeader addObject:[NSArray arrayWithObjects: [[UIDevice currentDevice] systemVersion], @"osversion", nil]];
    [httpsHeader addObject:[NSArray arrayWithObjects: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"appversion", nil]];
    [httpsHeader addObject:[NSArray arrayWithObjects: @"1", @"protocol", nil]];
    [httpsHeader addObject:[NSArray arrayWithObjects: [[NgnEngine sharedInstance].configurationService getStringWithKey:SECURITY_DEVICE_TOKEN], @"token", nil]];
    [httpsHeader addObject:[NSArray arrayWithObjects: strLang, @"language", nil]];
    
    return httpsHeader;
}

/**
 *	@brief	请求回调函数
 *
 *	@param 	data 	返回数据
 *	@param 	userInfo 	相关信息
 */
+ (void)postAwardPraiseDataToServerSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo
{
    //不用处理,只需发送到服务器即可
//    NSString *recvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSString *aStr = [recvString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    CCLog(@"postAwardPraiseDataToServerSucceeded:%@", aStr);
}

/**
 *	@brief	https请求返回错误
 *
 *	@param 	error 	错误消息
 *	@param 	key     请求key
 */
+ (void)postAwardPraiseDataToServerFailed:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (error) {
        //错误的处理办法
        
    }
}

#pragma mark
#pragma mark alertview delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        //不再提醒
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:@"isNeverPromptAppraise" andValue:YES];
        [[NgnEngine sharedInstance].configurationService setStringWithKey:kCloudCallVersion andValue:CloudCallVersion];
    }
    else if (buttonIndex == 1)
    {
        [AFKReviewTroller sendPraiseDataToServer];
        //appstore评分
        int appId = [[[[NSBundle mainBundle] infoDictionary] objectForKey:kCloudCallAppID] intValue];
        
        //不再提醒
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:@"isNeverPromptAppraise" andValue:YES];
        [[NgnEngine sharedInstance].configurationService setStringWithKey:kCloudCallVersion andValue:CloudCallVersion];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",appId]];
        [[UIApplication sharedApplication] openURL:url];
        
    }
    else
    {
        //残忍拒绝
        NSDate *nowDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *strNowDate = [dateFormatter stringFromDate:nowDate];
        
        [[NgnEngine sharedInstance].configurationService setStringWithKey:kCloudCallAppriseLastDate andValue:strNowDate];
        [[NgnEngine sharedInstance].configurationService setStringWithKey:kCloudCallVersion andValue:CloudCallVersion];
        
        [dateFormatter release];
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self release];
}
@end
