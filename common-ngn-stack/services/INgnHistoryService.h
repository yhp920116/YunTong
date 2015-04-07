
#import <Foundation/Foundation.h>

#import "services/INgnBaseService.h"
#import "model/NgnHistoryEvent.h"
#import "media/NgnMediaType.h"

@protocol INgnHistoryService <INgnBaseService>

-(BOOL) load;
-(BOOL) isLoading;
-(BOOL) addEvent: (NgnHistoryEvent*) event;
-(BOOL) updateEvent: (NgnHistoryEvent*) event;
-(BOOL) deleteEvent: (NgnHistoryEvent*) event;
-(BOOL) deleteEventAtIndex: (int) location;
-(BOOL) deleteEventWithId: (long long) eventId;
-(BOOL) deleteEvents: (NgnMediaType_t) mediaType;
-(BOOL) deleteEvents: (NgnMediaType_t) mediaType withRemoteParty: (NSString*)remoteParty;
-(BOOL) deleteEventsArray: (NSArray*) events;
-(BOOL) clear;
-(NgnHistoryEventDictionary*) events;

@end