
/* Vincent, GZ, 2012-03-07 */

#import "NgnHistoryAVCallEvent.h"

@implementation NgnHistoryAVCallEvent

-(NgnHistoryAVCallEvent*) init: (BOOL) withVideoType withRemoteParty:(NSString*)_remoteParty andCalloutMode:(CALL_OUT_MODE)_mode{
	if((self = (NgnHistoryAVCallEvent*)[super initWithMediaType: withVideoType ? MediaType_AudioVideo : MediaType_Audio andRemoteParty:_remoteParty andCalloutMode:_mode])){
	}
	return self;
}

-(void)dealloc{
	
	[super dealloc];
}

@end
