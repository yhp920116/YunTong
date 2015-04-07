
/* Vincent, GZ, 2012-03-07 */

#import "model/NgnHistoryEvent.h"

@interface NgnHistoryAVCallEvent : NgnHistoryEvent {
	
}

-(NgnHistoryAVCallEvent*) init:(BOOL)withVideoType withRemoteParty:(NSString*)remoteParty andCalloutMode:(CALL_OUT_MODE)mode;

@end
