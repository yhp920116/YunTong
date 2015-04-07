
/* Vincent, GZ, 2012-03-07 */

#import "NgnPublicationEventArgs.h"


@implementation NgnPublicationEventArgs

@synthesize sessionId;
@synthesize eventType;
@synthesize sipCode;
@synthesize sipPhrase;

-(NgnPublicationEventArgs*) initWithSessionId:(long)sessionId_
								 andEventType:(NgnPublicationEventTypes_t)eventType_
								   andSipCode:(short)sipCode_
								 andSipPhrase:(NSString*)sipPhrase_
{
	if((self = [super init])){
		self->sessionId = sessionId_;
		self->eventType = eventType_;
		self->sipCode = sipCode_;
		self->sipPhrase = [sipPhrase_ retain];
	}
	return self;
}

-(void)dealloc{
	[sipPhrase release];
	
	[super dealloc];
}

@end
