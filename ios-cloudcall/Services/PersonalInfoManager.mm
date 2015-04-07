//
//  PersonalInfoManager.m
//  CloudCall
//
//  Created by Sergio on 13-4-18.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "PersonalInfoManager.h"
#import "../../ios-ngn-stack/iOSNgnStack.h"
#import "JSONKit.h"
#import "CloudCall2AppDelegate.h"

@implementation PersonalInfoManager

/**
 *	@brief	从服务器获取个人信息
 */
- (void)getPersonalInfoFromServer
{
    
    NSString *phoneNumber = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:phoneNumber, @"telnumber", nil];
    
    [[HttpRequest instance] addRequestWithEncrypt:kDownloadUserInfoUrl
                                        andMethod:@"POST"
                                       andContent:jsonDic
                                       andTimeout:10
                                         delegate:self
                                    successAction:@selector(getPersonalInfoSucceeded:)
                                    failureAction:@selector(getPersonalInfoFailed:)
                                         userInfo:nil];
}

/**
 *	@brief	获取成功
 *
 *	@param 	data 	请求json数据
 */
- (void)getPersonalInfoSucceeded:(NSData *)data
{  
    NSString *recvString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSString *aStr = [recvString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    CCLog(@"PersonalInfoManager getPersonalInfoSucceeded:%@", aStr);
    
    NSRange range = [aStr rangeOfString:@"name"];
    if (range.location != NSNotFound)
    {
        NSString *resultStr = [aStr stringByReplacingOccurrencesOfString:@"\"(null)\"" withString:@"\"\""];
        NSMutableDictionary *personalInfoDict = [resultStr mutableObjectFromJSONString];
        [self setPersonalInfo:personalInfoDict];
        
    }
}

/**
 *	@brief	请求错误处理方法
 *
 *	@param 	error 	错误信息
 */
- (void)getPersonalInfoFailed:(NSError *)error
{
    //error
}

/**
 *	@brief	将服务器获取到的个人信息写入本地
 *
 *	@param 	personalInfoDictFormServer 	服务器数据
 */
- (void)setPersonalInfo:(NSMutableDictionary *)personalInfoDictFormServer
{
    if ([personalInfoDictFormServer count] >= 1) {
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"telnumber"] forKey:ACCOUNT_LOCALNUM];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"name"] forKey:ACCOUNT_NAME];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"nickname"] forKey:ACCOUNT_NICKNAME];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"sex"] forKey:ACCOUNT_GENDER];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"birthday"] forKey:ACCOUNT_BIRTHDATE];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"qq"] forKey:ACCOUNT_QQ];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"email"] forKey:ACCOUNT_EMAIL];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"sb"] forKey:ACCOUNT_SINAWEIBO];
    }
    else
    {
        [[NgnEngine sharedInstance].infoService setInfoValue:@"" forKey:ACCOUNT_LOCALNUM];
    }
}

@end
