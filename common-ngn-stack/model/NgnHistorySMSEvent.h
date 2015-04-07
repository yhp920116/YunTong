
/* Vincent, GZ, 2012-03-07 */

#import "model/NgnHistoryEvent.h"

@interface NgnHistorySMSEvent : NgnHistoryEvent {
	NSData* content;
	NSString* contentAsString;
}

@property(readwrite,retain) NSData* content;
@property(readonly,getter=getContentAsString) NSString* contentAsString;

-(NgnHistorySMSEvent*) initWithStatus:(HistoryEventStatus_t)status andRemoteParty:(NSString*)remoteParty;
-(NgnHistorySMSEvent*) initWithStatus:(HistoryEventStatus_t)status andRemoteParty:(NSString*)remoteParty andContent:(NSData*)content;
-(NSString*)getContentAsString;

@end
