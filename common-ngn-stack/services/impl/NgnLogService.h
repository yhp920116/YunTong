
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#	import "iOSNgnConfig.h"
#elif TARGET_OS_MAC
#	import "OSXNgnConfig.h"
#endif

#import "services/impl/NgnBaseService.h"
#import "services/INgnLogService.h"

@interface NgnLogService : NgnBaseService <INgnLogService>

@end
