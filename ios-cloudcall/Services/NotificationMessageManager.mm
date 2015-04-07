//

#import "NotificationMessageManager.h"
#import "HttpRequest.h"
#import "CloudCall2AppDelegate.h"
#import "JSONKit.h"

@implementation NotifyMsgResponseStatusNotificationArgs

@synthesize success;
@synthesize errorcode;
@synthesize text;
@synthesize records;

-(NotifyMsgResponseStatusNotificationArgs*) initWithStatus:(BOOL)_success andErrorCode:(int)_errorcode andText:(NSString*)_text andRecords:(NSMutableArray*)_records {
    if ((self = [super init])) {
        self->success   = _success;
        self->errorcode = _errorcode;
        self->text      = [_text retain];
        self->records   = [_records retain];
	}
	return self;
}

-(void)dealloc {
    [text release];
    [records release];
    
    [super dealloc];
}
@end

@implementation NotificationMessageManager

#define GET_SYS_NOTIFY_INTERVAL 30*60

-(void)dealloc {
    [self stopTimer];
    
    [super dealloc];
}

#pragma mark -
#pragma mark HttpRequest API

- (void)responseWithSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo {
	if (data == nil)
        return;
    
    [[NgnEngine sharedInstance].configurationService setDoubleWithKey:GENERAL_LAST_GET_SYS_NOTIFY_TIME andValue:[[NSDate date] timeIntervalSince1970]];
    
    NSMutableDictionary *root = [data mutableObjectFromJSONData];    
    NSMutableArray* msglist = [root objectForKey:@"msg_list"];
    CCLog(@"msg_list=%@", msglist ? msglist : @"");
    if (msglist && [msglist count]) {
        NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
        
        NSMutableArray* records = [[NSMutableArray alloc] init];
        for (NSMutableDictionary* d in msglist) {
            NSString* msgid       = [d objectForKey:@"msg_id"];
            NSString* publishtime = [d objectForKey:@"publish_time"];
            NSString* msgbody     = [d objectForKey:@"msg_body"];
            CCLog(@"msg='%@', '%@', '%@'", msgid, publishtime, msgbody);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            NSDate *date = [dateFormatter dateFromString:publishtime];
            NSTimeInterval time = [date timeIntervalSince1970];
            CCLog(@"publictime=%f", time);
            [dateFormatter release];
            
            NgnSystemNotification* r = [[NgnSystemNotification alloc] initWithContent:msgbody andMyNumber:mynum andReceiveTime:time andRead:NO];
            [records addObject:r];
            [r release];
        }
        
        NotifyMsgResponseStatusNotificationArgs* nmrsna = [[[NotifyMsgResponseStatusNotificationArgs alloc] initWithStatus:YES andErrorCode:0 andText:@"" andRecords:records] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMsgResponseStatusNotification object:nmrsna];
        
        [records release];
    }
}

- (void)responseWithFailed:(NSError *)error userInfo:(NSDictionary *)userInfo {
    NotifyMsgResponseStatusNotificationArgs* nmrsna = [[[NotifyMsgResponseStatusNotificationArgs alloc] initWithStatus:NO andErrorCode:[error code] andText:[error localizedDescription] andRecords:nil] autorelease];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMsgResponseStatusNotification object:nmrsna];
}

- (void)sendRequest2Server:(NSData*)jsonData andUserInfo:(NSMutableDictionary*)userInfo{
    [[HttpRequest instance] addRequest:kSecretaryUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                         successTarget:self successAction:@selector(responseWithSucceeded:userInfo:)
                         failureTarget:self failureAction:@selector(responseWithFailed:userInfo:) userInfo:nil];
}

-(void)GetNotificationMessages {
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    //还没有登录前,不需要请求该消息
    if ([mynum isEqualToString:DEFAULT_IDENTITY_IMPI])
        return;
    
    
    NSDictionary *numdic = [NSDictionary dictionaryWithObjectsAndKeys: mynum, @"user_number", nil];
    NSArray* context = [NSArray arrayWithObject:numdic];
    NSData *jsonData = nil;
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @"query", @"oper_type", context, @"context", nil];
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            NSError *error;
            jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
        }
    } else {
        jsonData = [body JSONData];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    CCLog(@"GetNotificationMessages: body json data:%@", jsonString);
    [jsonString release];

    [self sendRequest2Server:jsonData andUserInfo:nil];
}

-(void) startTimer {
    if (!getTimer) {
        NSTimeInterval lasttime = [[NgnEngine sharedInstance].configurationService getDoubleWithKey:GENERAL_LAST_GET_SYS_NOTIFY_TIME];
        NSTimeInterval currtime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval intervalSinceNow = (currtime - lasttime >= GET_SYS_NOTIFY_INTERVAL) ? 0 : GET_SYS_NOTIFY_INTERVAL - (currtime - lasttime);
        CCLog(@"startTimer: %f", intervalSinceNow);
        getTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:intervalSinceNow] interval:GET_SYS_NOTIFY_INTERVAL
                                              target:self selector:@selector(GetNotificationMessages) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:getTimer forMode:NSRunLoopCommonModes];
    }
}

-(void) stopTimer{
    if (getTimer) {
		[getTimer invalidate];
		[getTimer release];
		getTimer = nil;
	}
}

-(void)Start {
    [self startTimer];
}

@end
