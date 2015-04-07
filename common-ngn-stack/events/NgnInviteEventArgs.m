
/* Vincent, GZ, 2012-03-07 */

#import "NgnInviteEventArgs.h"

@implementation NgnInviteEventArgs

@synthesize sessionId;
@synthesize eventType;
@synthesize mediaType;
@synthesize sipPhrase;
@synthesize sipCode;

-(NgnInviteEventArgs*)initWithSessionId:(long)sessionId_
							andEvenType:(NgnInviteEventTypes_t)eventType_ 
						   andMediaType:(NgnMediaType_t)mediaType_ 
						   andSipPhrase:(NSString*)sipPhrase_
{
	return [self initWithSessionId:sessionId_
				andEvenType:eventType_
			   andMediaType:mediaType_
			   andSipPhrase:sipPhrase_
				 andSipCode:0];
}
-(NgnInviteEventArgs*)initWithSessionId:(long)sessionId_ 
							andEvenType:(NgnInviteEventTypes_t)eventType_ 
						   andMediaType:(NgnMediaType_t)mediaType_ 
						   andSipPhrase:(NSString*)sipPhrase_
							 andSipCode:(short)sipCode_
{
	if((self = [super init])){
		self->sessionId = sessionId_;
		self->eventType = eventType_;
		self->mediaType = mediaType_;
        self->sipPhrase = [sipPhrase_ retain];
		self->sipCode = sipCode_;
	}
	return self;
}


-(void)dealloc{
	[sipPhrase release];
	
	[super dealloc];
}

@end
