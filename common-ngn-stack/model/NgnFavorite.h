
#if TARGET_OS_IPHONE
#	import <Foundation/Foundation.h>
#elif TARGET_OS_MAC
#endif

#import "media/NgnMediaType.h"
#import "model/NgnContact.h"

typedef struct FavoriteMediaEntry_s {
	NSString* description;
	NgnMediaType_t mediaType;
}
FavoriteMediaEntry_t;

static const FavoriteMediaEntry_t kFavoriteMediaEntries[3] = { 
	{ NSLocalizedString(@"Voice Call", @"Voice Call"), MediaType_Audio},
	{ NSLocalizedString(@"Video Call", @"Video Call"), MediaType_AudioVideo}, 
	{ NSLocalizedString(@"Text Message", @"Text Message"), MediaType_SMS}, 
};

@interface NgnFavorite : NSObject {
	long long myid;
	NSString *number;
	NgnMediaType_t mediaType;
	
	BOOL contactAlreadyChecked;
	NgnContact* contact;
	
@private
	// to be used for any purpose (e.g. category)
	id opaque;
}

-(NgnFavorite*) initWithId: (long long)id andNumber: (NSString*)number andMediaType: (NgnMediaType_t)mediatype;
-(NgnFavorite*) initWithNumber: (NSString*)number andMediaType: (NgnMediaType_t)mediatype;
-(NSComparisonResult)compareFavoriteByDisplayName:(NgnFavorite *)otherFavorite;

@property(readwrite) long long myid;
@property(readonly) NSString *number;
@property(readonly) NgnMediaType_t mediaType;

@property(readonly) NgnContact *contact;
@property(readonly) NSString *displayName;

@property(readwrite, retain, nonatomic) id opaque;

@end