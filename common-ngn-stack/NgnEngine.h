

#import <Foundation/Foundation.h>

#import "services/impl/NgnBaseService.h"

#import "services/INgnSipService.h"
#import "services/INgnConfigurationService.h"
#import "services/INgnContactService.h"
#import "services/INgnHttpClientService.h"
#import "services/INgnHistoryService.h"
#import "services/INgnSoundService.h"
#import "services/INgnNetworkService.h"
#import "services/INgnStorageService.h"
#import "services/INgnLogService.h"
#import "services/INgnInfoService.h"

#import "services/impl/NgnInfoService.h"

@interface NgnEngine : NSObject {
#if TARGET_OS_IPHONE
@private
	NSTimer		*keepAwakeTimer;
#endif /* TARGET_OS_IPHONE */
@protected
	BOOL mStarted;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	NgnBaseService<INgnContactService>* mContactService;
	NgnBaseService<INgnHttpClientService>* mHttpClientService;
	NgnBaseService<INgnHistoryService>* mHistoryService;
	NgnBaseService<INgnSoundService>* mSoundService;
	NgnBaseService<INgnNetworkService>* mNetworkService;
	NgnBaseService<INgnStorageService>* mStorageService;
    NgnBaseService<INgnLogService>* mLogService;
    //add by Dan
    NgnBaseService<INgnInfoService>* mInfoService;
}

@property(readonly, getter=getSipService) NgnBaseService<INgnSipService>* sipService;
@property(readonly, getter=getConfigurationService) NgnBaseService<INgnConfigurationService>* configurationService;
@property(readonly, getter=getContactService) NgnBaseService<INgnContactService>* contactService;
@property(readonly, getter=getHttpClientService) NgnBaseService<INgnHttpClientService>* httpClientService;
@property(readonly, getter=getHistoryService) NgnBaseService<INgnHistoryService>* historyService;
@property(readonly, getter=getSoundService) NgnBaseService<INgnSoundService>* soundService;
@property(readonly, getter=getNetworkService) NgnBaseService<INgnNetworkService>* networkService;
@property(readonly, getter=getStorageService) NgnBaseService<INgnStorageService>* storageService;
@property(readonly, getter=getLogService) NgnBaseService<INgnLogService>* logService;

@property(readonly, getter=getInfoService) NgnBaseService<INgnInfoService> *infoService;

-(BOOL)start;
-(BOOL)stop;
-(NgnBaseService<INgnSipService>*)getSipService;
-(NgnBaseService<INgnConfigurationService>*)getConfigurationService;
-(NgnBaseService<INgnContactService>*)getContactService;
-(NgnBaseService<INgnHttpClientService>*) getHttpClientService;
-(NgnBaseService<INgnHistoryService>*)getHistoryService;
-(NgnBaseService<INgnSoundService>* )getSoundService;
-(NgnBaseService<INgnNetworkService>*)getNetworkService;
-(NgnBaseService<INgnStorageService>*)getStorageService;
-(NgnBaseService<INgnLogService>*)getLogService;
-(NgnBaseService<INgnInfoService>*)getInfoService;

#if TARGET_OS_IPHONE
-(BOOL) startKeepAwake;
-(BOOL) stopKeepAwake;
#endif /* TARGET_OS_IPHONE */

+(void)initialize;
+(NgnEngine*)getInstance __attribute__ ((deprecated)); // Replaced by "+(NgnEngine*)sharedInstance"
+(NgnEngine*)sharedInstance;

// log functions
//- (void)Msg:(NSString *)format, ...;
- (void)Msg:(NSString *)str;

@end
