//

#import "CallFeedbackManager.h"
#import "HttpRequest.h"
#import "CloudCall2AppDelegate.h"
#import "JSONKit.h"
#import "CCGTMBase64.h"
#import "NgnEngine.h"

static const int g_commit_attmpt_seconds = 120;

@implementation CallFeedbackData

@synthesize clgnum;
@synthesize cldnum;
@synthesize duration;
@synthesize type;
@synthesize calltime;
@synthesize conntiontime;
@synthesize calltype;
@synthesize nettype;
@synthesize quality;
@synthesize context;

-(CallFeedbackData*) initWithCallingNum:(NSString*)_clgnum andCalledNum:(NSString*)_cldnum andDuration:(int)_duration andType:(int)_type andCallTime:(NSTimeInterval)_calltime andConnTime:(NSTimeInterval)_conntiontime andCallType:(int)_calltype andNetType:(NSString*)_nettype {
    if((self = [super init])){
        self->clgnum = [_clgnum retain];
        self->cldnum = [_cldnum retain];
        self->duration = _duration;
        self->type = _type;
        self->calltime = _calltime;
        self->conntiontime = _conntiontime;
        self->calltype = _calltype;
        self->nettype = [_nettype retain];
    }
	return self;
}

- (void)dealloc {
    [clgnum release];
    [cldnum release];
    [nettype release];
    [context release];
    
    [super dealloc];
}

@end

@interface CallFeedbackManager (Private)

-(void) startTimer;
-(void) stopTimer;

-(void) commitTimerCallback;
-(void) commitCallFeedbackSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo;
-(void) commitCallFeedbackFailed:(NSError *)error userInfo:(NSDictionary *)userInfo;
-(void) commit2Server:(NgnCallFeedBackData*)jsonData;
@end

@implementation CallFeedbackManager (Private)


-(void) startTimer {
    if (!commitTimer) {
        commitTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:20] interval:g_commit_attmpt_seconds
                                                 target:self selector:@selector(commitTimerCallback) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:commitTimer forMode:NSRunLoopCommonModes];
    }
}

-(void) stopTimer{
    if(commitTimer) {
		[commitTimer invalidate];
		[commitTimer release];
		commitTimer = nil;
	}
}

+(NSData*) buildCallFeedbackJsonData:(CallFeedbackData*)feedbackdata {
    NSString* strDuration = [NSString stringWithFormat:@"%d", feedbackdata.duration];
    NSString* strCallType = [NSString stringWithFormat:@"%d", feedbackdata.calltype];
    NSString* strQuality  = [NSString stringWithFormat:@"%d", feedbackdata.quality];
    NSString* strType     = [NSString stringWithFormat:@"%d", feedbackdata.type];

    NSString *strCallTime = @"";
    if (NSDate *date = [NSDate dateWithTimeIntervalSince1970:feedbackdata.calltime]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
        strCallTime = [dateFormatter stringFromDate:date];
        [dateFormatter release];
    }

    NSString *strConnTime = @"";
    if (NSDate *date = [NSDate dateWithTimeIntervalSince1970:feedbackdata.conntiontime]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
        strConnTime = [dateFormatter stringFromDate:date];
        [dateFormatter release];
    }

    NSDateFormatter *zoneFormatter = [[[NSDateFormatter alloc] init] autorelease];
    zoneFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    [zoneFormatter setDateFormat:@"z"];
    NSString *timeZone = [zoneFormatter stringFromDate:[NSDate date]];

    NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:
                             feedbackdata.clgnum,  @"clgnum",
                             feedbackdata.cldnum,  @"cldnum",
                             strDuration,          @"duration",
                             strType,              @"type",
                             timeZone,             @"timezone",
                             strCallTime,          @"calltime",
                             strConnTime,          @"conntiontime",
                             strCallType,          @"calltype",
                             feedbackdata.nettype, @"nettype",
                             strQuality,           @"quality",
                             feedbackdata.context, @"context", nil];
    NSData *jsonData = nil;
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:content]) {
            NSError *error;
            jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];
            NSString* callFeedBackJson = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
            CCLog(@"SendCallFeedback jsondata:%@", callFeedBackJson);
        }
    } else {
        jsonData = [content JSONData];
    }

    return jsonData;
}

-(void)commitTimerCallback {
	CCLog(@"CallFeedbackManager commitTimerCallback, count=%d", [callfeedbacks count]);
    if (0 == [callfeedbacks count])
    {
        [self stopTimer];
        return;
    }
    NSArray *values = [callfeedbacks allValues];
    if ([values count] != 0) {
        [self commit2Server:[values objectAtIndex:0]];
    }
}


-(void) commitCallFeedbackSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo{
    if (committingnum)
        committingnum--;

    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableDictionary *root = [aStr mutableObjectFromJSONString];
    NSString* result = [root objectForKey:@"result"];
    NSString* text   = [root objectForKey:@"text"];
    CCLog(@"CallFeedbackManager rechargeSucceeded result='%@', text='%@'", result?result:@"", text?text:@"");
    
    BOOL succ = NO;
    if (result) {
        succ = [result isEqualToString:@"success"];
        
        NgnCallFeedBackData* ngncfd = [userInfo objectForKey:@"feedbackrecord"];
        if (ngncfd) {
            CCLog(@"commitCallFeedbackFailed jsondata:%@", ngncfd.data);
            
            if (succ) {
                NSString* myid = [NSString stringWithFormat:@"%d", ngncfd.myid];
                [callfeedbacks removeObjectForKey:myid];
                
                [[NgnEngine sharedInstance].storageService deleteCallFeedBack:ngncfd.myid];
            }
        }
    }
    
    if (succ == NO && [callfeedbacks count]) {
        [self startTimer];
    }

    
    [aStr release];
}

-(void) commitCallFeedbackFailed:(NSError *)error userInfo:(NSDictionary *)userInfo{
    if (committingnum)
        committingnum--;
    
    if ([callfeedbacks count]) {
        [self startTimer];
    }
}

- (void) commit2Server:(NgnCallFeedBackData *)ngncfd {
    if (ngncfd.data && [ngncfd.data length]) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
        [userInfo setObject:ngncfd forKey:@"feedbackrecord"];
        NSData* bodydata = [ngncfd.data dataUsingEncoding:NSUTF8StringEncoding];
        [[HttpRequest instance] addRequest:kCallFeedbackUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:bodydata andTimeout:10
                             successTarget:self successAction:@selector(commitCallFeedbackSucceeded:userInfo:)
                             failureTarget:self failureAction:@selector(commitCallFeedbackFailed:userInfo:) userInfo:userInfo];
        [userInfo release];
        committingnum++;
    }
}

@end

@implementation CallFeedbackManager

-(void) start:(NSString*)_mynum{
    if (mynum) {
        [mynum release];
        mynum = nil;
    }
    mynum = [_mynum retain];
    
    // Load records
    if (callfeedbacks == nil) {
        callfeedbacks = [[NSMutableDictionary alloc] init];
        
        NSMutableArray* array = [[NSMutableArray alloc] init];
        [[NgnEngine sharedInstance].storageService dbLoadCallFeedBack:array];
        
        for (NgnCallFeedBackData* r in array) {
            NSString* myid = [NSString stringWithFormat:@"%d", r.myid];
            [callfeedbacks setObject:r forKey:myid];
        }
        CCLog(@"CallFeedbackManager LoadIapRecords: count=%d", [callfeedbacks count]);
        
        [array release];
    }
    
    if (callfeedbacks && [callfeedbacks count])
        [self startTimer];
}

-(void) stop{
    if (mynum) {
        [mynum release];
        mynum = nil;
    }

    if(commitTimer){
		[commitTimer invalidate];
		[commitTimer release];
		commitTimer = nil;
	}
    
    if (callfeedbacks) {
        [callfeedbacks release];
        callfeedbacks = nil;
    }
}

- (void)commit:(CallFeedbackData*)feedbackdata{
    NSData* jsonData = [CallFeedbackManager buildCallFeedbackJsonData:feedbackdata];
    NSString* strJson = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    int cfdid = [[NgnEngine sharedInstance].storageService addCallFeedBack:strJson];
    
    NgnCallFeedBackData* ngncfd = [[NgnCallFeedBackData alloc] initWithId:cfdid andData:strJson andFlag:-1];
    NSString* myid = [NSString stringWithFormat:@"%d", ngncfd.myid];
    [callfeedbacks setObject:ngncfd forKey:myid];
    [self commit2Server:ngncfd];
    [ngncfd release];
}

-(void)dealloc {
    [self stop];
    
    [super dealloc];
}

@end
