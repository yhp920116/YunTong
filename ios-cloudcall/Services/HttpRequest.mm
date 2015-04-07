//

#import "HttpRequest.h"
#import "CloudCall2AppDelegate.h"
#import "CloudCallJSONSerialization.h"

@implementation httpEncrptRequest

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

    CCLog(@"%@, %@ %@", [aRequest responseString], [aRequest url] ,[aRequest.error userInfo]);
    NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[aRequest responseString]];
    
    // 失败
    if ([[result objectForKey:@"code"] integerValue] == 500 || [[result objectForKey:@"code"] integerValue] == 404)
    {
        if ([[self completionDelegate] respondsToSelector:[self failureSelector]])
        {
            [[self completionDelegate] performSelector:[self failureSelector] withObject:[aRequest responseData] withObject:aRequest.userInfo];
            
            //            [[self completionDelegate] performSelectorOnMainThread:[self failureSelector]
            //                                                        withObject:self
            //                                                     waitUntilDone:NO];
        }
    }
    else
    {
        if ([[self completionDelegate] respondsToSelector:[self successSelector]])
        {
            [[self completionDelegate] performSelector:[self successSelector] withObject:[aRequest responseData] withObject:aRequest.userInfo];
            //            [[self completionDelegate] performSelectorOnMainThread:[self successSelector]
            //                                                        withObject:self
            //                                                     waitUntilDone:NO];
        }
    }
    httpEncrptRequest *theRequest = (httpEncrptRequest *)aRequest;
    [[[HttpRequest instance] requestArrs] removeObject:theRequest];
    
}

// 失败
- (void) requestFailed:(ASIHTTPRequest *) aRequest
{
    NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[aRequest responseString]];
    if ([[[[aRequest error] userInfo] objectForKey:NSLocalizedDescriptionKey] isEqualToString:@"The request timed out"])
    {
        CCLog(@"请求超时:url= %@", [aRequest url]);
    }
    else
    {
        CCLog(@"请求失败:code= %d, url = %@ userInfo = %@", [[result objectForKey:@"code"] integerValue], [aRequest url],[aRequest.error userInfo]);
    }
    
    
    if ([[self completionDelegate] respondsToSelector:[self failureSelector]])
    {
        [[self completionDelegate] performSelector:[self failureSelector] withObject:[aRequest responseData] withObject:[[aRequest error] userInfo]];
            
    }

    httpEncrptRequest *theRequest = (httpEncrptRequest *)aRequest;
    [[[HttpRequest instance] requestArrs] removeObject:theRequest];
    
}

@end


@interface RequestInfo : NSObject {
    id successTarget;
    SEL successAction;
    id failureTarget;
    SEL failureAction;
    NSDictionary *userInfo;
    
    BOOL active;
    BOOL serverIsError;       //404\500错误

    NSMutableData *data;
}

@property (nonatomic, retain) id successTarget;
@property (nonatomic, assign) SEL successAction;
@property (nonatomic, retain) id failureTarget;
@property (nonatomic, assign) SEL failureAction;
@property (nonatomic, retain) NSDictionary *userInfo;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL serverIsError;
@property (nonatomic, retain) NSMutableData *data;

- (id)init;

@end


@implementation RequestInfo

@synthesize successTarget;
@synthesize successAction;
@synthesize failureTarget;
@synthesize failureAction;
@synthesize userInfo;
@synthesize active;
@synthesize data;
@synthesize serverIsError;

- (id)init
{
    if (self = [super init])
    {
        data = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [data release];
    [userInfo release];
    [super dealloc];
}

@end

@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@interface HttpRequest(Private)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

@end

@implementation HttpRequest(Private)

/////////////////////////////////////////////////////////
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response {
    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:connection]];
    [request.data setLength:0];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;    
    //判断服务器是否返回404
    if ((([httpResponse statusCode]/100) != 2)) {
        CCLog(@"HttpRequest connection didReceiveResponse:%d andUrl:%@", [httpResponse statusCode], [httpResponse URL]);
        
        request.serverIsError = YES;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"Connect error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        if ([error code] == 404 || [error code] == 500) {
//            RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:connection]];
        }
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {    
    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:connection]];
    request.active = NO;
    --activeRequestsCount;
    
    if (request.serverIsError == NO)
    {
        [request.successTarget performSelector:request.successAction withObject:request.data withObject:request.userInfo];
    }
    else
    {
        [request.failureTarget performSelector:request.failureAction withObject:request.data withObject:request.userInfo];
    }
    [requests removeObjectForKey:[NSValue valueWithNonretainedObject:connection]];

    [self connectionEnded];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    CCLog(@"HttpRequest connection didFailWithError: %@, %p", error, connection);    
    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:connection]];
    request.active = NO;
    --activeRequestsCount;
    if (request.failureTarget != nil)
        [request.failureTarget performSelector:request.failureAction withObject:error withObject:request.userInfo];
    [requests removeObjectForKey:[NSValue valueWithNonretainedObject:connection]];
    [self connectionEnded];
}

//处理数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:connection]];
    [request.data appendData:data];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return NO;
}

//下面两段是重点，要服务器端单项HTTPS验证，iOS客户端忽略证书验证。
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    //CCLog(@"HttpRequest didReceiveAuthenticationChallenge %@ %zd", [[challenge protectionSpace] authenticationMethod], (ssize_t) [challenge previousFailureCount]);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [[challenge sender] useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge: challenge];
    }
}
@end

@implementation HttpRequest


@synthesize concurrentRequestsLimit;

+ (HttpRequest *)instance
{
    static HttpRequest *x = nil;
    if (x == nil)
        x = [[HttpRequest alloc] init];
    return x;
}

- (id)init
{
    if (self = [super init])
    {
        concurrentRequestsLimit = 8;
        requests = [[NSMutableDictionary alloc] init];
        queue = [[NSMutableArray alloc] init];
        self.requestArrs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllRequests];
    [_requestArrs release];
    [requests release];
    [queue release];
    [super dealloc];
}

- (void)startRequest:(NSURLConnection *)con
{
    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:con]];
    request.active = YES;
    ++activeRequestsCount;
    [con start];
}

- (void)stopRequest:(NSURLConnection *)con
{
    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:con]];
    request.active = NO;
    --activeRequestsCount;
    [con cancel];
}

- (void)queueRequest:(NSURLConnection *)con
{
    [queue addObject:con];
}

- (NSURLConnection *)dequeueRequest
{
    NSURLConnection *con = [[queue objectAtIndex:0] retain];
    [queue removeObjectAtIndex:0];
    return [con autorelease];
}

- (void)connectionEnded
{
    if (activeRequestsCount < concurrentRequestsLimit && [queue count] > 0)
        [self startRequest:[self dequeueRequest]];
}

#pragma mark Public
//同步的http请求

- (NSData *)sendRequestSyncWithEncrypt:(NSString *)url andMethod:(NSString *)method andContent:(NSMutableDictionary*)content andTimeout:(int)seconds andTarget:(id)target andSuccessSelector:(SEL)successSel andFailureSelector:(SEL)failureSel
{
    /////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////
    if (content == nil)
    {
        content = [NSMutableDictionary dictionaryWithObject:[self getRequestHeaderWithEncrypt] forKey:@"http_headers"];
    }
    else
    {
        [content setObject:[self getRequestHeaderWithEncrypt] forKey:@"http_headers"];
    }
//    CCLog(@"HttpSendContent = %@",content);
    
    //[request setValue:@"AppleWebKit/533.18.1 (KHTML, like Gecko) Version/5.0.2 Safari/533.18.5" forHTTPHeaderField:@"User-Agent"];
    ///////////////////////////
    
    httpEncrptRequest *request = [httpEncrptRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSData* jsonBody = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];

    [self.requestArrs addObject:request];
    [request EncryptData:jsonBody];
    [request addData:jsonBody forKey:@"param"];
    
//    [request setUserInfo:userInfo];
    [request setTimeOutSeconds:10];
    if (target) {
        [request setCompletionDelegate:target];
        [request setSuccessSelector:successSel];
        [request setFailureSelector:failureSel];
    }
    [request startSynchronous];
    
    // 发送同步请求, data就是返回的数据
//    NSURLResponse *response = nil;
    NSData *data = [request responseData];
    if (data == nil || [data length]==0)
    {
        NSDictionary *result = (NSDictionary *)[CloudCallJSONSerialization JsonStringToObject:[request responseString]];
        if ([[[[request error] userInfo] objectForKey:NSLocalizedDescriptionKey] isEqualToString:@"The request timed out"])
        {
            CCLog(@"请求超时:url= %@", [request url]);
        }
        else
        {
            CCLog(@"请求失败:code= %d,\n url = %@\n userInfo = %@", [[result objectForKey:@"code"] integerValue], [request url],[request.error userInfo]);
        }
        
        return nil;
    }
    


    return data;
}

//同步的http请求
- (NSData *)sendRequestSync:(NSString *)url andMethod:(NSString *)method andHeaderFields:(NSMutableArray *)headerFields andContent:(NSData*)content andTimeout:(int)seconds
{
    /////////////////////////////////////////////////////////////////////////////////
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:seconds];
    [NSMutableURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[[NSURL URLWithString:url] host]];
    //设置请求方式
    [request setHTTPMethod:method];
    //添加用户会话id
    //需要使用application/x-www-form-urlencoded才能在POST方式下传参数
    if (NSOrderedSame == [method caseInsensitiveCompare:@"POST"])
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    ///////////////////////////
    if (headerFields != nil)
    {
        for (NSArray* a in headerFields) {
            if ([a count] == 2) {
                NSString* value = [a objectAtIndex:0];
                NSString* name  = [a objectAtIndex:1];
                //CCLog(@"%@, %@", value, name);
                if (value && name)
                    [request setValue:value forHTTPHeaderField:name];
            }
        }
    }

    //[request setValue:@"AppleWebKit/533.18.1 (KHTML, like Gecko) Version/5.0.2 Safari/533.18.5" forHTTPHeaderField:@"User-Agent"];
    ///////////////////////////
    
    // 设置Content-Length
    if (content && [content length]) {
        [request setValue:[NSString stringWithFormat:@"%d", [content length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:content];
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    
    // 发送同步请求, data就是返回的数据
    NSError *error = nil;
    NSURLResponse *response = nil;

    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (data == nil) {
        CCLog(@"send request failed: %@", error);
        return nil;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    //判断服务器是否返回404
    if ((([httpResponse statusCode]/100) != 2)) {
        CCLog(@"HttpRequest sync connection didReceiveResponse:%d andUrl:%@", [httpResponse statusCode], [httpResponse URL]);
        return nil;
    }
    
    return data;
}

//异步http请求
- (void)addRequestWithEncrypt:(NSString *)url andMethod:(NSString*)method andContent:(NSMutableDictionary*)content andTimeout:(int)seconds
                  delegate:(id)_delegate successAction:(SEL)successAction failureAction:(SEL)failureAction
                       userInfo:(NSDictionary *)userInfo
{
    /////////////////////////////////////////////////////////////////////////////////
    if (content == nil)
    {
        content = [NSMutableDictionary dictionaryWithObject:[self getRequestHeaderWithEncrypt] forKey:@"http_headers"];
    }
    else
    {
        [content setObject:[self getRequestHeaderWithEncrypt] forKey:@"http_headers"];
    }
    
    httpEncrptRequest *request = [httpEncrptRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSData* jsonBody = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];

    [self.requestArrs addObject:request];
    [request EncryptData:jsonBody];
    [request addData:jsonBody forKey:@"param"];
    
    [request setUserInfo:userInfo];
    [request setTimeOutSeconds:10];
    if (_delegate) {
        [request setCompletionDelegate:_delegate];
        [request setSuccessSelector:successAction];
        [request setFailureSelector:failureAction];
    }
    [request startAsynchronous];
}

//异步http请求
- (NSURLConnection *)addRequest:(NSString *)url andMethod:(NSString*)method andHeaderFields:(NSMutableArray*)headerFields andContent:(NSData*)content andTimeout:(int)seconds
                  successTarget:(id)successTarget successAction:(SEL)successAction
                  failureTarget:(id)failureTarget failureAction:(SEL)failureAction
                       userInfo:(NSDictionary *)userInfo
{
    /////////////////////////////////////////////////////////////////////////////////
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:seconds];
    
    //设置请求方式
    [request setHTTPMethod:method];
    //添加用户会话id
    //需要使用application/x-www-form-urlencoded才能在POST方式下传参数
    if (NSOrderedSame == [method caseInsensitiveCompare:@"POST"])
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    ///////////////////////////
    if (headerFields != nil)
    {
        for (NSArray* a in headerFields) {
            if ([a count] == 2) {
                NSString* value = [a objectAtIndex:0];
                NSString* name  = [a objectAtIndex:1];
                //CCLog(@"%@, %@", value, name);
                if (value && name)
                    [request setValue:value forHTTPHeaderField:name];
            }
        }
    }
    //[request setValue:@"AppleWebKit/533.18.1 (KHTML, like Gecko) Version/5.0.2 Safari/533.18.5" forHTTPHeaderField:@"User-Agent"];
    ///////////////////////////
    
    // 设置Content-Length
    if (content && [content length]) {
        [request setValue:[NSString stringWithFormat:@"%d", [content length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:content];
    }

    /////////////////////////////////////////////////////////////////////////////////

    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [con scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    if (con == nil)
        return nil;
    
    RequestInfo* reqInfo = [[RequestInfo alloc] init];
    if (successTarget) {
        reqInfo.successTarget = successTarget;
        reqInfo.successAction = successAction;
    }

    if (failureTarget) {
        reqInfo.failureTarget = failureTarget;
        reqInfo.failureAction = failureAction;
    }

    reqInfo.userInfo = userInfo;
    reqInfo.serverIsError = NO;
    [requests setObject:reqInfo forKey:[NSValue valueWithNonretainedObject:con]];
    [reqInfo release];
    if (activeRequestsCount < concurrentRequestsLimit)
        [self startRequest:con];
    else
        [self queueRequest:con];
    return [con autorelease];
}

- (void)cancelRequest:(NSURLConnection *)con
{
    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:con]];
    if (request == nil)
        return;
    if (request.active)
        [self stopRequest:con];
    else
        [queue removeObject:con];
    [requests removeObjectForKey:[NSValue valueWithNonretainedObject:con]];
}

- (void)cancelAllRequests
{
    for (NSURLConnection *con in requests)
    {
        RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:con]];
        if (request.active)
            [self stopRequest:con];
    }
    [requests removeAllObjects];
    [queue removeAllObjects];
}

#pragma mark - clearDelegatesAndCancel

- (void)clearDelegatesAndCancel
{
    for (httpEncrptRequest *request in self.requestArrs) {
        [request clearDelegatesAndCancel];
    }
}

#pragma mark
#pragma mark get HttpRequest header
/**
 *	@brief	设置请求头部信息
 */
- (NSMutableDictionary *)getRequestHeaderWithEncrypt
{
    NSString* mac = [NgnDeviceInfo2 uniqueGlobalDeviceIdentifier];
    
    //获取市场ID
    int mtype = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_MAKET_TYPE];
    NSString* maketType = [NSString stringWithFormat:@"%d",mtype];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSString* strLang = currentLanguage;
    if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        strLang = @"CN";
    }
    
    //https头部信息
    NSMutableDictionary *httpHeader = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         AppKeyIdForBill, @"appkey",
                                         @"IOS", @"devicetype",
                                         mac, @"deviceid",
                                         [NgnSipStack platform], @"devicename",
                                         mac, @"mac",
                                         maketType, @"marketid",
                                         [[UIDevice currentDevice] systemVersion], @"osversion",
                                         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"appversion",
                                         @"1", @"protocol",
                                         [[NgnEngine sharedInstance].configurationService getStringWithKey:SECURITY_DEVICE_TOKEN], @"token",
                                         strLang, @"language", nil];
    
//    NSMutableArray *httpsHeader = [[[NSMutableArray alloc] init] autorelease];
//    [httpsHeader addObject:[NSArray arrayWithObjects: AppKeyIdForBill, @"appkey", nil]];
//    [httpsHeader addObject:[NSArray arrayWithObjects: @"IOS", @"devicetype", nil]];
//    [httpsHeader addObject:[NSArray arrayWithObjects: mac, @"deviceid", nil]];
//    [httpsHeader addObject:[NSArray arrayWithObjects: [NgnSipStack platform], @"devicename", nil]];
//    [httpsHeader addObject:[NSArray arrayWithObjects: mac, @"mac", nil]];
//    [httpsHeader addObject:[NSArray arrayWithObjects: maketType, @"marketid", nil]];
//    [httpsHeader addObject:[NSArray arrayWithObjects: [[UIDevice currentDevice] systemVersion], @"osversion", nil]];
//    [httpsHeader addObject:[NSArray arrayWithObjects: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"appversion", nil]];
//    [httpsHeader addObject:[NSArray arrayWithObjects: @"1", @"protocol", nil]];
//    [httpsHeader addObject:[NSArray arrayWithObjects: [[NgnEngine sharedInstance].configurationService getStringWithKey:SECURITY_DEVICE_TOKEN], @"token", nil]];
//    [httpsHeader addObject:[NSArray arrayWithObjects: strLang, @"language", nil]];
    
    return httpHeader;
}

- (NSMutableArray *)getRequestHeader
{
    NSString* mac = [NgnDeviceInfo2 uniqueGlobalDeviceIdentifier];
    
    //获取市场ID
    int mtype = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_MAKET_TYPE];
    NSString* maketType = [NSString stringWithFormat:@"%d",mtype];
    
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
@end
