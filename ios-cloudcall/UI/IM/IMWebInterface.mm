//

#import "IMWebInterface.h"
#import "ASIFormDataRequest.h"
#import "RecorderManager.h"
#import "CloudCall2AppDelegate.h"
#import "SqliteHelper.h"
#import "CloudCallJSONSerialization.h"

// 发送消息通知
NSString *SendMsgSuccessfulNotification = @"SendMsgSuccessfulNotification";
NSString *SendMsgFailureNotification = @"SendMsgFailureNotification";

NSString *LoadFriendsSuccessful = @"LoadFriendsSuccessful";
NSString *LoadFriendsFailure = @"LoadFriendsFailure";

NSString *LoadGroupListSuccessful = @"LoadGroupListSuccessful";
NSString *LoadGroupListFailure = @"LoadGroupListFailure";

@implementation IMRequest

- (void) setCompletionDelegate:(ASIHTTPRequest *)completionDelegate
{
    if (_completionDelegate != completionDelegate)
    {
        _completionDelegate = completionDelegate;
    }
    
    if (_completionDelegate != nil)
    {
        [self setDelegate:self];
    }
    else
    {
        [self cancel];
    }
}

// 成功
- (void) requestFinished:(ASIHTTPRequest *) aRequest
{
    NSLog(@"%@", [aRequest responseString]);
    NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[aRequest responseString]];
    
    // 失败
    if ([[result objectForKey:@"code"] integerValue] == 500)
    {
        if ([[self completionDelegate] respondsToSelector:[self failureSelector]])
        {
            [[self completionDelegate] performSelectorOnMainThread:[self failureSelector]
                                                        withObject:self
                                                     waitUntilDone:NO];
        }
    }
    else
    {
        if ([[self completionDelegate] respondsToSelector:[self successSelector]])
        {
            [[self completionDelegate] performSelectorOnMainThread:[self successSelector]
                                                        withObject:self
                                                     waitUntilDone:NO];
        }
    }
}

// 失败
- (void) requestFailed:(ASIHTTPRequest *) aRequest
{
    if ([[[[aRequest error] userInfo] objectForKey:NSLocalizedDescriptionKey] isEqualToString:@"The request timed out"])
    {
        NSLog(@"请求超时");
    }
    else
    {
        NSLog(@"请求失败");
    }
    
    if ([[self completionDelegate] respondsToSelector:[self failureSelector]])
    {
        [[self completionDelegate] performSelectorOnMainThread:[self failureSelector]
                                                    withObject:self
                                                 waitUntilDone:NO];
    }
}

@end

@implementation IMWebInterface

+ (IMWebInterface *) sharedInstance
{
    static IMWebInterface *sharedInstance = nil;
    
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

#pragma mark - 发送请求部分
/*
 * 发送文字信息
 *@param from:发送者
 *@param to:接受者
 *@param message:文本内容
 */
- (void) sendChatMessageRequest:(NSString *) from to:(NSString *) to message:(NSString *) message type:(NSString *)type andMsgID:(NSString *)msgid
{
    NSString *imserver_addr = [[NgnEngine sharedInstance].configurationService getStringWithKey:GENERAL_IMSERVER_ADDR];
    int imserver_port_http = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_IMSERVER_PORT_HTTP];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msgid forKey:@"msgid"];
    
    IMRequest *request = [IMRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/imserver/notification.do?action=send", imserver_addr, imserver_port_http]]];
    
#if IMEncrypt_HTTP_Enable
    NSError *error;    
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:from, @"sender", to, @"receiver",  message, @"message", type, @"type", nil];
    NSData* jsonBody = nil;
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            jsonBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
            NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
            CCLog(@"sendChatMessageRequest: %@", json);
        }
    } else {
        jsonBody = [body JSONData];
        
        NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
        CCLog(@"sendChatMessageRequest: %@", json);
    }
    [request EncryptData:jsonBody];
    [request addData:jsonBody forKey:@"param"];    
#else
    [request addPostValue:from forKey:@"sender"];
    [request addPostValue:to forKey:@"receiver"];
    [request addPostValue:message forKey:@"message"];
    [request addPostValue:type forKey:@"type"];
#endif
    
    [request setUserInfo:userInfo];
    [request setTimeOutSeconds:10];
    [request setCompletionDelegate:self];
    [request setSuccessSelector:@selector(onSendMsgSuccessful:)];
    [request setFailureSelector:@selector(onSendMsgFailure:)];
    [request startAsynchronous];
}

/*
 * 发送图片/语音信息
 *@param from:发送者
 *@param to:接收者
 *@param data:文件流
 *@param fileType:文件类型 1:图片 2:语音
 */
- (void) sendChatMediaResourceRequest:(NSString *) from to:(NSString *) to data:(NSData *) fileData fileType:(NSString *) fileType type:(NSString *)type andMsgID:(NSString *)msgid andAudioTime:(NSString *)audioTime
{
    NSString *imserver_addr = [[NgnEngine sharedInstance].configurationService getStringWithKey:GENERAL_IMSERVER_ADDR];
    int imserver_port_http = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_IMSERVER_PORT_HTTP];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msgid forKey:@"msgid"];
    
    IMRequest *request = [IMRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/imserver/notification.do?action=send", imserver_addr, imserver_port_http]]];
    
#if IMEncrypt_HTTP_Enable
    NSError *error;
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:from, @"sender", to, @"receiver", fileType, @"fileType", type, @"type", audioTime, @"duration", nil];
    NSData* jsonBody = nil;
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            jsonBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
            NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
            CCLog(@"sendChatMediaResourceRequest: %@", json);
        }
    } else {
        jsonBody = [body JSONData];
        
        NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
        CCLog(@"sendChatMediaResourceRequest: %@", json);
    }
    [request EncryptData:jsonBody];
    [request addData:jsonBody forKey:@"param"];
    [request addData:fileData forKey:@"file"];
#else
    [request addPostValue:from forKey:@"sender"];
    [request addPostValue:to forKey:@"receiver"];
    [request addData:fileData forKey:@"file"];
    [request addPostValue:fileType forKey:@"fileType"];
    [request addPostValue:type forKey:@"type"];
    [request addPostValue:audioTime forKey:@"duration"];
#endif    

    [request setUserInfo:userInfo];
    [request setTimeOutSeconds:600];
    [request setCompletionDelegate:self];
    [request setUploadProgressDelegate:self];
    [request setShowAccurateProgress:YES];
    [request setSuccessSelector:@selector(onSendMediaResourceSuccessful:)];
    [request setFailureSelector:@selector(onSendMediaResourceFailure:)];
    [request startAsynchronous];
}

/*
 * 发送图片/语音信息
 *@param from:发送者
 *@param to:接收者
 *@param data:文件流
 *@param fileType:文件类型 1:图片 2:语音
 */
- (void) sendChatMediaResourceRequest:(NSString *) from to:(NSString *) to data:(NSData *) fileData fileType:(NSString *) fileType type:(NSString *)type andMsgID:(NSString *)msgid andAudioTime:(NSString *)audioTime andProcessView:(UIProgressView *)progressView
{
    NSString *imserver_addr = [[NgnEngine sharedInstance].configurationService getStringWithKey:GENERAL_IMSERVER_ADDR];
    int imserver_port_http = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_IMSERVER_PORT_HTTP];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msgid forKey:@"msgid"];
    
    IMRequest *request = [IMRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/imserver/notification.do?action=send", imserver_addr, imserver_port_http]]];
    
#if IMEncrypt_HTTP_Enable
    NSError *error;
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:from, @"sender", to, @"receiver", fileType, @"fileType", type, @"type", audioTime, @"duration", nil];
    NSData* jsonBody = nil;
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            jsonBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
            NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
            CCLog(@"sendChatMediaResourceRequest: %@", json);
        }
    } else {
        jsonBody = [body JSONData];
        
        NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
        CCLog(@"sendChatMediaResourceRequest: %@", json);
    }
    [request EncryptData:jsonBody];
    [request addData:jsonBody forKey:@"param"];
    [request addData:fileData forKey:@"file"];
#else
    [request addPostValue:from forKey:@"sender"];
    [request addPostValue:to forKey:@"receiver"];
    [request addData:fileData forKey:@"file"];
    [request addPostValue:fileType forKey:@"fileType"];
    [request addPostValue:type forKey:@"type"];
    [request addPostValue:audioTime forKey:@"duration"];
#endif
    
    [request setUserInfo:userInfo];
    [request setTimeOutSeconds:600];
    [request setCompletionDelegate:self];
    [request setUploadProgressDelegate:progressView];
    [request setShowAccurateProgress:YES];
    [request setSuccessSelector:@selector(onSendMediaResourceSuccessful:)];
    [request setFailureSelector:@selector(onSendMediaResourceFailure:)];
    [request startAsynchronous];
}

/*
 * 发送消息已读取请求
 *  - 将消息状态置为已读
 *@param messageId:消息Id（若需要读取多个消息，消息id可以用逗号(,)分隔。）。
 */
- (void) sendReadChatMessageRequest:(NSString *) messageId
{
    NSString *imserver_addr = [[NgnEngine sharedInstance].configurationService getStringWithKey:GENERAL_IMSERVER_ADDR];
    int imserver_port_http = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_IMSERVER_PORT_HTTP];
    
    IMRequest *request = [IMRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/imserver/notification.do?action=read", imserver_addr, imserver_port_http]]];

    [request addPostValue:messageId forKey:@"id"];
    [request setCompletionDelegate:self];
    [request setSuccessSelector:@selector(onReadMessageSuccessful:)];
    [request setFailureSelector:@selector(onReadMessageFailure:)];
    [request startAsynchronous];
}

/*
 * 发送删除消息请求
 *@param messageId:消息Id
 */
- (void) sendDeleteChatMessageRequest:(NSString *) messageId
{
    NSString *imserver_addr = [[NgnEngine sharedInstance].configurationService getStringWithKey:GENERAL_IMSERVER_ADDR];
    int imserver_port_http = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_IMSERVER_PORT_HTTP];
    
    IMRequest *request = [IMRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/imserver/notification.do?action=delete", imserver_addr, imserver_port_http]]];
    
    [request addPostValue:messageId forKey:@"id"];
    [request setCompletionDelegate:self];
    [request setSuccessSelector:@selector(onDeleteMessageSuccessful:)];
    [request setFailureSelector:@selector(onDeleteMessageFailure:)];
    [request startAsynchronous];
}

// 获取群组列表
- (void) sendLoadGroupListRequest:(NSString *) userName
{
    NSString *imserver_addr = [[NgnEngine sharedInstance].configurationService getStringWithKey:GENERAL_IMSERVER_ADDR];
    int imserver_port_http = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_IMSERVER_PORT_HTTP];
    
    IMRequest *request = [IMRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/imserver/group.do?action=list", imserver_addr, imserver_port_http]]];

#if IMEncrypt_HTTP_Enable
    NSError *error;
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:userName, @"account", nil];
    NSData* jsonBody = nil;
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            jsonBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
            NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
            CCLog(@"sendLoadGroupListRequest: %@", json);
        }
    } else {
        jsonBody = [body JSONData];
        
        NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
        CCLog(@"sendLoadGroupListRequest: %@", json);
    }
    [request EncryptData:jsonBody];
    [request addData:jsonBody forKey:@"param"];
#else
    [request addPostValue:userName forKey:@"account"];
#endif
    
    [request setCompletionDelegate:self];
    [request setSuccessSelector:@selector(onLoadGroupListSuccessful:)];
    [request setFailureSelector:@selector(onLoadGroupListFailure:)];
    [request startAsynchronous];
}

/*
 * 获取好友列表成功
 */
- (void) onLoadGroupListSuccessful:(ASIFormDataRequest *) request
{
    NSArray *result = (NSArray *)[CloudCallJSONSerialization JsonStringToObject:[request responseString]];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoadGroupListSuccessful object:result];
}

- (void) onLoadGroupListFailure:(ASIFormDataRequest *) request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LoadGroupListFailure object:nil];
}

/*
 * 发送文字信息成功
 */
- (void) onSendMsgSuccessful:(ASIFormDataRequest *) request
{
    NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[request responseString]];
    
    NSLog(@"%@", [result description]);
    
    //更新消息状态
    NSString* serverMsgId = [result objectForKey:@"id"];
    [self updateMsgSendStatus:[request userInfo] andSendStatus:IMSendStatusSendSucc andServerMsgId:serverMsgId];    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SendMsgSuccessfulNotification object:nil];
}

/*
 * 发送文字信息失败
 */
- (void) onSendMsgFailure:(IMRequest *) request
{
    NSLog(@"发送文字信息失败");
    
    //更新消息状态
    [self updateMsgSendStatus:[request userInfo] andSendStatus:IMSendStatusSendFail andServerMsgId:@""];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SendMsgFailureNotification object:nil];
}

/*
 * 发送多媒体文件成功
 */
- (void) onSendMediaResourceSuccessful:(IMRequest *) request
{
    NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[request responseString]];
    
    NSLog(@"%@", [result description]);
    
    //更新消息状态
    NSString* serverMsgId = [result objectForKey:@"id"];
    [self updateMsgSendStatus:[request userInfo] andSendStatus:IMSendStatusSendSucc andServerMsgId:serverMsgId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SendMsgSuccessfulNotification object:nil];
}

/*
 * 发送多媒体文件失败
 */
- (void) onSendMediaResourceFailure:(IMRequest *) request
{
    NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[request responseString]];
    
    //更新消息状态
    [self updateMsgSendStatus:[request userInfo] andSendStatus:IMSendStatusSendFail andServerMsgId:@""];
    
    NSLog(@"%@", [result description]);
    [[NSNotificationCenter defaultCenter] postNotificationName:SendMsgFailureNotification object:nil];
}

/*
 * 阅读消息成功
 */
- (void) onReadMessageSuccessful:(IMRequest *) request
{
    NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[request responseString]];
    NSLog(@"%@", [result description]);
}

/*
 * 阅读消息失败
 */
- (void) onReadMessageFailure:(IMRequest *) request
{
    NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[request responseString]];
    NSLog(@"%@", [result description]);
}

/*
 * 删除消息成功
 */
- (void) onDeleteMessageSuccessful:(IMRequest *) request
{
    NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[request responseString]];
    NSLog(@"%@", [result description]);
}

/*
 * 删除消息失败
 */
- (void) onDeleteMessageFailure:(IMRequest *) request
{
    NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[request responseString]];
    NSLog(@"%@", [result description]);    
}

#pragma mark -
#pragma mark ASIProgressDelegate
- (void)setProgress:(float)newProgress
{
    //CCLog(@"------newProgress: %f%%------",newProgress);
}

#pragma mark -
#pragma mark 消息发送状态更新
- (void)updateMsgSendStatus:(NSDictionary *)userInfo andSendStatus:(IMSendStatus)sendStatus andServerMsgId:(NSString*)serverMsgId
{
    NSString *msgid = [userInfo objectForKey:@"msgid"];
    if(msgid)
    {
        //更新消息状态
        SqliteHelper *helper = [[SqliteHelper alloc] init];
        [helper createDatabase];
        [helper updateMessageSendStatusByMsgID:msgid andSendStatus:sendStatus andServerMsgId:serverMsgId];
        [helper closeDatabase];
        [helper release];
    }
}

@end
