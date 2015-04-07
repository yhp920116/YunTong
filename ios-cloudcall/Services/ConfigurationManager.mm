//

#import "ConfigurationManager.h"
#import "HttpRequest.h"
#import "CloudCall2AppDelegate.h"

@interface ConfigurationManager(Private)

-(void)sendGetConfigRequest;
@end

@implementation ConfigurationManager(Private)

-(void)httpRequestSucceeded:(NSData *)data {
    if (data == nil || [data length] == 0)
        return;
    
    NSString* strCfg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    CCLog(@"ConfigurationManager didReceiveData:\n%@\n", strCfg);
    NSString* filepath = [directory stringByAppendingPathComponent:filename];
    [ConfigurationManager SaveToFile:filepath andData:strCfg];
    [strCfg release];
    
    NSString* serv = [cfgservers objectAtIndex:currSerIndex];
    [succTarget performSelector:succAction withObject:serv];
}

-(void)httpRequestFailed:(NSError *)error {
    int cindex = currSerIndex;
    currSerIndex++;
    [self sendGetConfigRequest];
    
    if (currSerIndex >= [cfgservers count]) {
        NSString* serv = [cfgservers objectAtIndex:cindex];
        [failTarget performSelector:failAction withObject:serv];
    }
}

-(void)sendGetConfigRequest {
    if (currSerIndex < [cfgservers count]) {
        if (NSString* currserv = [cfgservers objectAtIndex:currSerIndex]) {
            [[HttpRequest instance] addRequestWithEncrypt:kGetSIPserverConfigURL andMethod:@"GET" andContent:nil andTimeout:8
                                 delegate:self successAction:@selector(httpRequestSucceeded:)
                                failureAction:@selector(httpRequestFailed:) userInfo:nil];
        }
    }
}

@end

@implementation ConfigurationManager

-(ConfigurationManager*) initWithServers:(NSArray*)_cfgservs andDirectory:(NSString*)_directory andCfgFileName:(NSString*)_filename {
    if ((self = [super init])) {
        self->cfgservers = [_cfgservs retain];        
        self->directory = [_directory retain];
        self->filename = [_filename retain];
	}
	return self;
}

-(void) dealloc {
    [cfgservers release];
    [directory release];
    [filename release];
    
    [cfgservers release];
    
    [super dealloc];
}

+(NSString*)LoadFromFile:(NSString*)filepath{
    NSError *error;
    
    // 读文件
    NSString* strcfg = [[[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error] autorelease];
    CCLog(@"ConfigurationManager LoadFromFile:\n%@\n", strcfg);
    return strcfg;
}

+(void)SaveToFile:(NSString*)filepath andData:(NSString*)strcfg {
    if (!filepath || !strcfg)
        return;
        
    CCLog(@"ConfigurationManager SaveConfigFile:\n%@\n", strcfg);
    
    // 创建数据缓冲
    NSMutableData *writer = [[NSMutableData alloc] init];
    
    // 将字符串添加到缓冲中
    [writer appendData:[strcfg dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 将缓冲的数据写入到文件中
    [writer writeToFile:filepath atomically:YES];
    
    [writer release];
}

- (void)getConfigFromServer:(id)_successTarget successAction:(SEL)_successAction failureTarget:(id)_failureTarget failureAction:(SEL)_failureAction{
    currSerIndex = 0;
    succTarget = _successTarget;
    succAction = _successAction;
    failTarget = _failureTarget;
    failAction =_failureAction;
    
    [self sendGetConfigRequest];
}

@end
