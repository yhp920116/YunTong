
/* Vincent, GZ, 2012-03-07 */

#import "NgnHistorySMSEvent.h"

@implementation NgnHistorySMSEvent

@synthesize content;

-(NgnHistorySMSEvent*) initWithStatus:(HistoryEventStatus_t) _status andRemoteParty:(NSString*)_remoteParty{
	return [self initWithStatus: _status andRemoteParty: _remoteParty andContent: nil];
}

-(NgnHistorySMSEvent*) initWithStatus:(HistoryEventStatus_t) _status andRemoteParty:(NSString*)_remoteParty andContent:(NSData*)_content{
	if((self = (NgnHistorySMSEvent*)[super initWithMediaType:MediaType_SMS andRemoteParty: _remoteParty andCalloutMode:CALL_OUT_MODE_NONE])){
		self.status = _status;
		self.content = _content;
	}
	return self;
}

-(NSString*)getContentAsString{
	if(!contentAsString && content){
		contentAsString = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
	}
	return contentAsString;
}

-(void)dealloc{
	[content release];
	[contentAsString release];
	
	[super dealloc];
}

@end
