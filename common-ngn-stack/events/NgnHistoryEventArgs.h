
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"
#import "media/NgnMediaType.h"

typedef enum NgnHistoryEventTypes_e {
	HISTORY_EVENT_ITEM_ADDED,
	HISTORY_EVENT_ITEM_REMOVED,
	HISTORY_EVENT_ITEM_UPDATED,
	HISTORY_EVENT_ITEM_MOVED,
	
	HISTORY_EVENT_RESET,
}
NgnHistoryEventTypes_t;

#define kNgnHistoryEventArgs_Name @"NgnHistoryEventArgs_Name"

@interface NgnHistoryEventArgs : NgnEventArgs {
	long long eventId;
	NgnHistoryEventTypes_t eventType;
	NgnMediaType_t mediaType;
}

@property(readonly) long long eventId;
@property(readonly) NgnHistoryEventTypes_t eventType;
@property(readwrite) NgnMediaType_t mediaType;

-(NgnHistoryEventArgs*)initWithEventId: (long long)eventId andEventType: (NgnHistoryEventTypes_t)eventType;
-(NgnHistoryEventArgs*)initWithEventType: (NgnHistoryEventTypes_t)eventType;

@end
