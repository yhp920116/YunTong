
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#	import "iOSNgnConfig.h"
#elif TARGET_OS_MAC
#	import "OSXNgnConfig.h"
#endif

#import "sip/NgnSipPreferences.h"

#import "services/impl/NgnBaseService.h"
#import "services/INgnSipService.h"
#import "services/INgnConfigurationService.h"
#import "services/INgnInfoService.h"

class _NgnSipCallback;
@class NgnRegistrationSession;

@interface NgnSipService : NgnBaseService <INgnSipService>{
	_NgnSipCallback* _mSipCallback;
	NgnRegistrationSession* sipRegSession;
	NgnSipPreferences* sipPreferences;
	NgnBaseService<INgnConfigurationService>*mConfigurationService;
    NgnBaseService<INgnInfoService>*mInfoService;
	NgnSipStack* sipStack;
	NSString *sipDefaultIdentity;
    
@private
    BOOL registering;
}

@property(readonly) NgnRegistrationSession* sipRegSession;
@property(readonly) NgnSipPreferences* sipPreferences;
@property(readonly) NgnSipStack* sipStack;

@end
