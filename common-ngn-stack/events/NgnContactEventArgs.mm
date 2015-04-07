
#import "NgnContactEventArgs.h"


@implementation NgnContactEventArgs

@synthesize eventType;

-(NgnContactEventArgs*) initWithType: (NgnContactEventTypes_t)eventType_{
	if((self = [super init])){
		self->eventType = eventType_;
	}
	return self;
}


-(void)dealloc{
	[super dealloc];
}

@end
