
/* Vincent, GZ, 2012-03-07 */

#import "NgnSubscriptionEventArgs.h"


@implementation NgnSubscriptionEventArgs

@synthesize sessionId;
@synthesize eventType;
@synthesize sipCode;
@synthesize sipPhrase;
@synthesize content;
@synthesize contentType;
@synthesize eventPackage;

-(NgnSubscriptionEventArgs*) initWithSessionId:(long)sessionId_
								  andEventType:(NgnSubscriptionEventTypes_t)eventType_
									andSipCode:(short)sipCode_
								  andSipPhrase:(NSString*)sipPhrase_
									andContent:(NSData*)content_ 
								andContentType:(NSString*)contentType_
							   andEventPackage:(NgnEventPackageType_t)eventPackage_
{
	if((self = [super init])){
		self->sessionId = sessionId_;
		self->eventType = eventType_;
		self->sipCode = sipCode_;
		self->sipPhrase = [sipPhrase_ retain];
		self->content = [content_ retain];
		self->contentType = [contentType_ retain];
		self->eventPackage = eventPackage_;
	}
	return self;
}

-(NgnSubscriptionEventArgs*) initWithSessionId:(long)sessionId_
								  andEventType:(NgnSubscriptionEventTypes_t)eventType_
									andSipCode:(short)sipCode_
								  andSipPhrase:(NSString*)sipPhrase_
							   andEventPackage:(NgnEventPackageType_t)eventPackage_
{
	return [self initWithSessionId:sessionId_ 
					  andEventType:eventType_ 
					andSipCode:sipCode_ 
					  andSipPhrase:sipPhrase 
						andContent:nil 
					andContentType:nil
				   andEventPackage:eventPackage_];
}

-(void)dealloc{
	[self->sipPhrase release];
    [self->content release];
    [self->contentType release];
	
	[super dealloc];
}

@end
