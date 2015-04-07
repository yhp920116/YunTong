
#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"

#define kNgnContactEventArgs_Name @"NgnContactEventArgs_Name"

typedef enum NgnContactEventTypes_e {
	CONTACT_RESET_ALL,
    CONTACT_SYNC_UPDATE,
}
NgnContactEventTypes_t;

@interface NgnContactEventArgs : NgnEventArgs {
	NgnContactEventTypes_t eventType;
}

-(NgnContactEventArgs*) initWithType: (NgnContactEventTypes_t)eventType;

@property(readonly) NgnContactEventTypes_t eventType;

@end
