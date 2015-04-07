
/* Vincent, GZ, 2012-03-07 */

#import "NgnHistoryEventArgs.h"


@implementation NgnHistoryEventArgs

@synthesize eventId;
@synthesize eventType;
@synthesize mediaType;

-(NgnHistoryEventArgs*)initWithEventId: (long long)_eventId andEventType: (NgnHistoryEventTypes_t)_eventType{
	if((self = [super init])){
		self->eventId = _eventId;
		self->eventType = _eventType;
		self->mediaType = MediaType_None;
	}
	
	return self;
}

-(NgnHistoryEventArgs*)initWithEventType: (NgnHistoryEventTypes_t)_eventType{
	return [self initWithEventId: 0 andEventType: _eventType];
}

-(void)dealloc{
	[super dealloc];
}

@end
