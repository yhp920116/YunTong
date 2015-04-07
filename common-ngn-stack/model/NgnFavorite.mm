
/* Vincent, GZ, 2012-03-07 */


#import "NgnFavorite.h"
#import "NgnEngine.h"

@implementation NgnFavorite

@synthesize myid;
@synthesize number;
@synthesize mediaType;
@synthesize opaque;

-(NgnFavorite*) initWithId: (long long) id_ andNumber: (NSString*)number_ andMediaType: (NgnMediaType_t)mediatype_{
	if((self = [super init])){
		self->myid = id_;
		self->number = [number_ retain];
		self->mediaType = mediatype_;
		self->contactAlreadyChecked = NO;
	}
	return self;
}

-(NgnFavorite*) initWithNumber: (NSString*)number_ andMediaType: (NgnMediaType_t)mediatype_{
	return [self initWithId:0 andNumber:number_ andMediaType:mediatype_];
}

-(NgnContact *)contact{
	if(!self->contactAlreadyChecked && self->contact == nil){
		self->contactAlreadyChecked = YES;
		self->contact = [[[NgnEngine sharedInstance].contactService getContactByPhoneNumber: self.number] retain];
	}
	return self->contact;
}

-(NSString*)displayName{
	return self.contact ? self.contact.displayName : self.number;
}

-(NSComparisonResult)compareFavoriteByDisplayName:(NgnFavorite *)otherFavorite{
	return [self.displayName compare: otherFavorite.displayName];
}

-(void)dealloc{
	[number release];
	[contact release];
	[opaque release];
	
	[super dealloc];
}

@end

