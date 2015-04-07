
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"

#define kNgnNetworkEventArgs_Name @"NgnNetworkEventArgs_Name"

typedef enum NgnNetworkEventTypes_e {
	NETWORK_EVENT_STATE_CHANGED, /* reachability or/and network type */
	/* to be completed */
}
NgnNetworkEventTypes_t;

@interface NgnNetworkEventArgs : NgnEventArgs {
	NgnNetworkEventTypes_t eventType;
}

-(NgnNetworkEventArgs*) initWithType:(NgnNetworkEventTypes_t)eventType;

@property(readonly) NgnNetworkEventTypes_t eventType;

@end
