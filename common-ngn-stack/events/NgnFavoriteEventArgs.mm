
/* Vincent, GZ, 2012-03-07 */


#import "NgnFavoriteEventArgs.h"


@implementation NgnFavoriteEventArgs

@synthesize eventType;
@synthesize mediaType;
@synthesize favoriteId;

-(NgnFavoriteEventArgs*) initWithFavoriteId: (long long)favoriteId_ andEventType:(NgnFavoriteEventTypes_t)eventType_ andMediaType: (NgnMediaType_t) mediaType_{
	if((self = [super init])){
		self->favoriteId = favoriteId_;
		self->eventType = eventType_;
		self->mediaType = mediaType_;
	}
	return self;
}

-(NgnFavoriteEventArgs*) initWithType: (NgnFavoriteEventTypes_t)eventType_ andMediaType: (NgnMediaType_t) mediaType_{
	return [self initWithFavoriteId:0 andEventType:eventType_  andMediaType:mediaType_];
}

-(void)dealloc{
	[super dealloc];
}

@end
