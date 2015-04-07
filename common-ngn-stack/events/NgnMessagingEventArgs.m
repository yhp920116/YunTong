
/* Vincent, GZ, 2012-03-07 */

#import "NgnMessagingEventArgs.h"

@implementation NgnMessagingEventArgs

@synthesize sessionId;
@synthesize eventType;
@synthesize sipPhrase;
@synthesize payload;
@synthesize callId;

-(NgnMessagingEventArgs*)initWithSessionId: (long)_sessionId andEventType: (NgnMessagingEventTypes_t)_eventType andPhrase: (NSString*)_phrase andPayload: (NSData*)_payload andCallId:(NSString*)_callid {
	if((self = [super init])){
		self->sessionId = _sessionId;
		self->eventType = _eventType;
		self->sipPhrase = [_phrase retain];
		self->payload = [_payload retain];
        self->callId = [_callid retain];
	}
	
	return self;
}

-(void)dealloc{
	[self->sipPhrase release];
	[self->payload release];
    [self->callId release];
	
	[super dealloc];
}

@end
