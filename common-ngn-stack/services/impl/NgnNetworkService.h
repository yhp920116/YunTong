
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#include <CoreFoundation/CoreFoundation.h>
#include <SystemConfiguration/SystemConfiguration.h>

#if TARGET_OS_IPHONE
#	import "iOSNgnConfig.h"
#elif TARGET_OS_MAC
#	import "OSXNgnConfig.h"
#endif

#import "services/impl/NgnBaseService.h"
#import "services/INgnNetworkService.h"

@interface NgnNetworkService : NgnBaseService <INgnNetworkService>{
@private
	BOOL mStarted;
	SCNetworkReachabilityRef        mReachability;
	SCNetworkReachabilityContext    mReachabilityContext;
	NgnNetworkType_t mNetworkType;
	NSString *mReachabilityHostName;
	NgnNetworkReachability_t mNetworkReachability;
}

@end
