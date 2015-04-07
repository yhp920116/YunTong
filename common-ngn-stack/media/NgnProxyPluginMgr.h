

/* Vincent, GZ, 2012-03-07 */

#if TARGET_OS_IPHONE
#	import <Foundation/Foundation.h>
#endif

#import "NgnProxyPlugin.h"

@interface NgnProxyPluginMgr : NSObject {
	
}

+(int)initialize;
+(NgnProxyPlugin*)getProxyPluginWithId: (uint64_t)id;

@end

