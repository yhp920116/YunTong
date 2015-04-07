
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#	import "iOSNgnConfig.h"
#elif TARGET_OS_MAC
#	import "OSXNgnConfig.h"
#endif

#import "services/impl/NgnBaseService.h"
#import "services/INgnConfigurationService.h"

@interface NgnConfigurationService : NgnBaseService<INgnConfigurationService> {
@protected
	NSUserDefaults* defaults;
}

@end
