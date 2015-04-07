
#import "NgnEngine.h"

#import "NgnSipService.h"
#import "NgnConfigurationService.h"
#import "NgnContactService.h"
#import "NgnHttpClientService.h"
#import "NgnHistoryService.h"
#import "NgnSoundService.h"
#import "NgnNetworkService.h"
#import "NgnStorageService.h"
#import "NgnProxyPluginMgr.h"
#import "NgnLogService.h"
#import "NgnInfoService.h"

#undef TAG
#define kTAG @"NgnEngine///: "
#define TAG kTAG

//
//	private implementation
//

@interface NgnEngine(Private)
-(void)dummyCoCoaThread;
#if TARGET_OS_IPHONE
-(void)keepAwakeCallback;
#endif
@end

@implementation NgnEngine(Private)

-(void)dummyCoCoaThread {
	NgnNSLog(TAG, @"dummyCoCoaThread()");
}

#if TARGET_OS_IPHONE
-(void)keepAwakeCallback{
	[self.soundService playKeepAwakeSoundLooping:NO];
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
//									YES
//#else
//									NO
//#endif
									
	NgnLog(@"keepAwakeCallback");
}
#endif

@end


//
//	default implementation
//
@implementation NgnEngine

-(NgnEngine*)init{
	if((self = [super init])){
		[NgnEngine initialize];
	}
	return self;
}

-(void)dealloc{
	[self stop];
	
	[mSipService release];
	[mConfigurationService release];
	[mContactService release];
    //added by Dan
    [mHttpClientService release];
    [mHistoryService release];
    [mNetworkService release];
    [mSoundService release];
    [mStorageService release];
    [mLogService release];
    [mInfoService release];
	
	[super dealloc];
}

-(BOOL)start{
	if(mStarted){
		return YES;
	}
	BOOL bSuccess = YES;
	
	/* http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSAutoreleasePool_Class/Reference/Reference.html
	 Note: If you are creating secondary threads using the POSIX thread APIs instead of NSThread objects, you cannot use Cocoa, including NSAutoreleasePool, unless Cocoa is in multithreading mode.
	 Cocoa enters multithreading mode only after detaching its first NSThread object.
	 To use Cocoa on secondary POSIX threads, your application must first detach at least one NSThread object, which can immediately exit.
	 You can test whether Cocoa is in multithreading mode with the NSThread class method isMultiThreaded.
	 */
	[NSThread detachNewThreadSelector:@selector(dummyCoCoaThread) toTarget:self withObject:nil];
	if([NSThread isMultiThreaded]){
		NgnNSLog(TAG, @"Working in multithreaded mode :)");
	}
	else{
		NgnNSLog(TAG, @"NOT working in multithreaded mode :(");
	}
	
	// Order is important
    //bSuccess &= [self.logService start]; // Added by Vincent for record log into a file.
	bSuccess &= [self.configurationService start];
	bSuccess &= [self.networkService start];
	bSuccess &= [self.storageService start];
//	bSuccess &= [self.contactService start];
	bSuccess &= [self.sipService start];
	bSuccess &= [self.httpClientService start];
	bSuccess &= [self.historyService start];
	bSuccess &= [self.soundService start];
    bSuccess &= [self.infoService start]; //Added by Dan for Core Data
	
	mStarted = YES;
	return bSuccess;
}

-(BOOL)stop{
	if(!mStarted){
		return YES;
	}
	
	BOOL bSuccess = YES;
	
	// Order is important	
	bSuccess &= [self.sipService stop];
	bSuccess &= [self.contactService stop];
	bSuccess &= [self.configurationService stop];
	bSuccess &= [self.httpClientService stop];
	bSuccess &= [self.historyService stop];
	bSuccess &= [self.soundService stop];
	bSuccess &= [self.networkService stop];
	bSuccess &= [self.storageService stop];
    bSuccess &= [self.infoService stop];
	//bSuccess &= [self.logService stop];
	
	mStarted = NO;
	return bSuccess;
}

-(NgnBaseService<INgnSipService>*)getSipService{
	if(mSipService == nil){
		mSipService = [[NgnSipService alloc] init];
	}
	return mSipService;
}

-(NgnBaseService<INgnConfigurationService>*)getConfigurationService{
	if(mConfigurationService == nil){
		mConfigurationService = [[NgnConfigurationService alloc] init];
	}
	return mConfigurationService;
}

-(NgnBaseService<INgnContactService>*)getContactService{
	if(mContactService == nil){
		mContactService = [[NgnContactService alloc] init];
	}
	return mContactService;
}

-(NgnBaseService<INgnHttpClientService>*) getHttpClientService{
	if(mHttpClientService == nil){
		mHttpClientService = [[NgnHttpClientService alloc] init];
	}
	return mHttpClientService;
}

-(NgnBaseService<INgnHistoryService>*)getHistoryService{
	if(mHistoryService == nil){
		mHistoryService = [[NgnHistoryService alloc] init];
	}
	return mHistoryService;
}

-(NgnBaseService<INgnSoundService>* )getSoundService{
	if(mSoundService == nil){
		mSoundService = [[NgnSoundService alloc] init];
	}
	return mSoundService;
}

-(NgnBaseService<INgnNetworkService>*)getNetworkService{
	if(mNetworkService == nil){
		mNetworkService = [[NgnNetworkService alloc] init];
	}
	return mNetworkService;
}

-(NgnBaseService<INgnStorageService>*)getStorageService{
	if(mStorageService == nil){
		mStorageService = [[NgnStorageService alloc] init];
	}
	return mStorageService;
}

-(NgnBaseService<INgnLogService>*)getLogService{
	if(mLogService == nil){
		mLogService = [[NgnLogService alloc] init];
	}
	return mLogService;
}

//add by Dan
-(NgnBaseService<INgnInfoService>*)getInfoService{
    if (mInfoService == nil) {
        mInfoService = [[NgnInfoService alloc] init];
    }
    return mInfoService;
}


#if TARGET_OS_IPHONE

-(BOOL) startKeepAwake{
	if(!keepAwakeTimer){
//这个判断对于云通来说是多余的,因为我们要求使用的都是iOS4.3以上的系统,idoubs这么做是为了兼容iOS4.0及以下的系统
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
//		BOOL iOS4Plus = YES;
//#else
//		BOOL iOS4Plus = NO;
//#endif
		// the iOS4 device will sleep after 10seconds of inactivity
		// On iOS4, playing the sound each 10seconds doesn't work as the system will imediately frozen  
		// if you stop playing the sound. The only solution is to play it in loop. This is why
		// the 'repeats' parameter is equal to 'NO'.
		keepAwakeTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0]
													interval:180.f
													target:self
													selector:@selector(keepAwakeCallback)
													userInfo:nil
												   repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:keepAwakeTimer forMode:NSRunLoopCommonModes];
        //run below ios 4.0- 
//        if()
//        {
//            [keepAwakeTimer release];
//			keepAwakeTimer = nil;
//		}
	}
	return YES;
}

-(BOOL) stopKeepAwake{
	if(keepAwakeTimer){
		[keepAwakeTimer invalidate];
		// already released
		keepAwakeTimer = nil;
	}
	[self.soundService stopKeepAwakeSound];
	return YES;
}

#endif /* TARGET_OS_IPHONE */

+(void)initialize{
	static BOOL sMediaLayerInitialized = NO;
	
	if(!sMediaLayerInitialized){
		sMediaLayerInitialized = ([NgnProxyPluginMgr initialize] == 0);
	}
}

+(NgnEngine*) getInstance{
	return [NgnEngine sharedInstance];
}

+(NgnEngine*) sharedInstance{
	static NgnEngine* sInstance = nil;
	
	if(sInstance == nil){
		sInstance = [[NgnEngine alloc] init];
	}
	return sInstance;
}

- (void)Msg:(NSString *)str {
    if (!mLogService || !str) 
        return;
    [[self getLogService] addLog:str];
}
/*- (void) Msg:(NSString *)format, ... {
    if (!mLogService || !format) return;
    
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    [[self getLogService] addLog:str];
    [str release];
    va_end(args);
}*/

@end
