
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"
#import "media/NgnMediaType.h"

#define kNgnFavoriteEventArgs_Name @"NgnFavoriteEventArgs_Name"

typedef enum NgnFavoriteEventTypes_e {
	FAVORITE_ITEM_ADDED,
	FAVORITE_ITEM_REMOVED,
	FAVORITE_ITEM_UPDATED,
	FAVORITE_ITEM_MOVED,
	
	FAVORITE_RESET,
}
NgnFavoriteEventTypes_t;

@interface NgnFavoriteEventArgs : NgnEventArgs {
	long long favoriteId;
	NgnFavoriteEventTypes_t eventType;
	NgnMediaType_t mediaType;
}

-(NgnFavoriteEventArgs*) initWithType: (NgnFavoriteEventTypes_t)type andMediaType: (NgnMediaType_t) mediaType;
-(NgnFavoriteEventArgs*) initWithFavoriteId: (long long)favoriteId andEventType:(NgnFavoriteEventTypes_t)type andMediaType: (NgnMediaType_t) mediaType;

@property(readonly) long long favoriteId;
@property(readonly) NgnFavoriteEventTypes_t eventType;
@property(readonly) NgnMediaType_t mediaType;

@end
