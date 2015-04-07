
/* Vincent, GZ, 2012-03-07 */

#import "NgnRegistrationEventArgs.h"

@implementation NgnRegistrationEventArgs

@synthesize sessionId;
@synthesize eventType;
@synthesize sipCode;
@synthesize sipPhrase;
@synthesize subServ;

-(NgnRegistrationEventArgs*)initWithSessionId: (long)sId andEventType: (NgnRegistrationEventTypes_t)type andSipCode: (short)code andSipPhrase: (NSString*)phrase andSubServ:(NSString *)_subServ{
	if((self = [super init])){
		self->sessionId = sId;
        self->eventType = type;
        self->sipCode = code;
        self->sipPhrase = [phrase retain];
        self->subServ = [_subServ retain];
	}
	return self;
}

-(void)dealloc{
	[self->sipPhrase release];
	[super dealloc];
}

@end
