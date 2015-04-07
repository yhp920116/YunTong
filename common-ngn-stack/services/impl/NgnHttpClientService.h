
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#	import "iOSNgnConfig.h"
#elif TARGET_OS_MAC
#	import "OSXNgnConfig.h"
#endif

#import "NgnEngine.h"

@interface NgnHttpClientService : NgnBaseService <INgnHttpClientService>{

}

@end
