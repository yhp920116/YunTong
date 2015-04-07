
/* Vincent, GZ, 2012-03-07 */

#import "NgnNetworkService.h"
#import "NgnStringUtils.h"
#import "NgnNetworkEventArgs.h"
#import "NgnNotificationCenter.h"

#import <netinet/in.h> /* sockaddr_in */

#define kReachabilityHostName @"google.com"

#undef TAG
#define kTAG @"NgnNetworkService///: "
#define TAG kTAG


@interface NgnNetworkService(Private)
-(BOOL) startListening;
-(BOOL) stopListening;
-(void) setNetworkReachability:(NgnNetworkReachability_t)reachability_;
-(void) setNetworkType:(NgnNetworkType_t)networkType_;
@end


static NgnNetworkReachability_t NgnConvertFlagsToReachability(SCNetworkConnectionFlags flags)
{
	NgnNetworkReachability_t reachability = NetworkReachability_None;
	
	if(flags & kSCNetworkFlagsTransientConnection) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_TransientConnection);
	if(flags & kSCNetworkFlagsReachable) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_Reachable);
	if(flags & kSCNetworkFlagsConnectionRequired) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_ConnectionRequired);
	if(flags & kSCNetworkFlagsConnectionAutomatic) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_ConnectionAutomatic);
	if(flags & kSCNetworkFlagsInterventionRequired) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_InterventionRequired);
	if(flags & kSCNetworkFlagsIsLocalAddress) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_IsLocalAddress);
	if(flags & kSCNetworkFlagsIsDirect) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_IsDirect);
	
	return reachability;
}

static NgnNetworkType_t NgnConvertFlagsToNetworkType(SCNetworkConnectionFlags flags){
	
	NgnNetworkType_t networkType = NetworkType_None;
#if TARGET_OS_IPHONE
	if(flags & kSCNetworkReachabilityFlagsIsWWAN)
	{
		networkType = (NgnNetworkType_t) (networkType | NetworkType_3G); // Ok, this is not true but iOS don't provide suchinformation
	}
	else
#endif /* TARGET_OS_IPHONE */
	{
		networkType = (NgnNetworkType_t) (networkType | NetworkType_WLAN);
	}
	
	return networkType;
}

static void NgnNetworkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NgnNetworkService *self_ = (NgnNetworkService*)info;
	
	[self_ setNetworkReachability:NgnConvertFlagsToReachability(flags)];
	[self_ setNetworkType:NgnConvertFlagsToNetworkType(flags)];
	
	/* raise event */
	NgnNetworkEventArgs *eargs = [[[NgnNetworkEventArgs alloc] initWithType:NETWORK_EVENT_STATE_CHANGED] autorelease];
	[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnNetworkEventArgs_Name object:eargs];
	
	[pool release];
}

//
// private implementation
//

@implementation NgnNetworkService(Private)

-(BOOL) startListening{
	if([self stopListening]){
		Boolean ok;
		int err = 0;
#if 0 /* SCNetworkReachabilityCreateWithName won't returns the rigth flags imediately. We need to wait for the callback. */
		mReachability = SCNetworkReachabilityCreateWithName(NULL, [NgnStringUtils toCString:self.reachabilityHostName]);
#else
		struct sockaddr_in fakeAddress;
		bzero(&fakeAddress, sizeof(fakeAddress));
		fakeAddress.sin_len = sizeof(fakeAddress);
		fakeAddress.sin_family = AF_INET;
		
		mReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &fakeAddress);
#endif
		if (mReachability == NULL) {
			err = SCError();
		}
		
		// Set our callback and install on the runloop.
		if (err == 0) {
			ok = SCNetworkReachabilitySetCallback(mReachability, NgnNetworkReachabilityCallback, &mReachabilityContext);
			if (! ok) {
				err = SCError();
			}
		}
		if (err == 0) {
			ok = SCNetworkReachabilityScheduleWithRunLoop(mReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
			if (! ok) {
				err = SCError();
			}
		}
		
		if (err == 0) {
			SCNetworkConnectionFlags flags = 0;
			ok = SCNetworkReachabilityGetFlags(mReachability, &flags);
			
			if (ok) {
				[self setNetworkReachability:NgnConvertFlagsToReachability(flags)];
				[self setNetworkType:NgnConvertFlagsToNetworkType(flags)];
			} else {
				[self setNetworkReachability:NetworkReachability_None];
				[self setNetworkType:NetworkType_None];
				err = SCError();
			}
		}
		return (err == 0);
	}
	return NO;
}

-(BOOL) stopListening{
	if(mReachability){
		(void) SCNetworkReachabilityUnscheduleFromRunLoop(
													  mReachability,
													  CFRunLoopGetCurrent(),
													  kCFRunLoopDefaultMode
													  );
		CFRelease(mReachability), mReachability = NULL;
	}
	return YES;
}

-(void) setNetworkReachability:(NgnNetworkReachability_t)reachability_{
	mNetworkReachability = reachability_;
}

-(void) setNetworkType:(NgnNetworkType_t)networkType_{
	mNetworkType = networkType_;
}

@end



//
// default implementation
//

@implementation NgnNetworkService

-(NgnNetworkService*)init{
	if((self = [super init])){
		mNetworkType = NetworkType_None;
		mNetworkReachability = NetworkReachability_None;
		NSString* hostName = kReachabilityHostName;
		mReachabilityHostName = [hostName retain];
		
		mReachabilityContext.version         = 0;
		mReachabilityContext.info            = self;
		mReachabilityContext.retain          = NULL;
		mReachabilityContext.release         = NULL;
		mReachabilityContext.copyDescription = NULL;
		
	}
	return self;
}

//
// IBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	
	// reset current values
	mNetworkType = NetworkType_None;
	mNetworkReachability = NetworkReachability_None;
	
	mStarted = [self startListening];
	
	return mStarted;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	return YES;
}

//
// INgnNetworkService
//

-(NSString*)getReachabilityHostName{
	return mReachabilityHostName;
}

-(void)setReachabilityHostName:(NSString*)hostName{
	[mReachabilityHostName release];
	mReachabilityHostName = [hostName retain];
	
	if(mStarted && mReachabilityHostName){
		[self startListening];
	}
}

-(NgnNetworkType_t) getNetworkType{
	return mNetworkType;
}

-(NSString*) getNetworkTypeName:(NgnNetworkType_t)type{
	switch(type) {
        case NetworkType_None: break;
        case NetworkType_WLAN: return @"WiFi";
        case NetworkType_2G: return @"2G";
        case NetworkType_EDGE: return @"EDGE";
        case NetworkType_3G: return @"3G";
        case NetworkType_4G: return @"4G";
        case NetworkType_WWAN: break;
    }  
    return @"Unknown";
}

-(NgnNetworkReachability_t) getReachability{
	return mNetworkReachability;
}

-(BOOL) isReachable{
	return (mNetworkReachability & NetworkReachability_Reachable)
#if TARGET_OS_MAC || TARGET_IPHONE_SIMULATOR
	&& !(mNetworkReachability & NetworkReachability_ConnectionRequired)
#endif
	;
}

-(void)dealloc{
	[self stopListening];
	
	[mReachabilityHostName release];
	
	[super dealloc];
}

@end
