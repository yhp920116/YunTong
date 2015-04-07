
/* Vincent, GZ, 2012-03-07 */

#import "NgnSoundServiceEventArgs.h"

@implementation NgnSoundServiceEventArgs

@synthesize eventType;

-(NgnSoundServiceEventArgs*) initWithType:(NgnSoundServiceEventTypes_t)_eventType{
	if ((self = [super init])) {
        self->eventType = _eventType;
	}
	return self;
}

-(void)dealloc{
	
	[super dealloc];
}

@end
