
/* Vincent, GZ, 2012-07-10 */


#import "NgnConferenceFavorite.h"

@implementation NgnConferenceFavorite

@synthesize myid;
@synthesize mynumber;
@synthesize name;
@synthesize uuid;
@synthesize type;
@synthesize updatetime;
@synthesize status;

@synthesize opaque;

-(NgnConferenceFavorite*) initWithId: (long long)_id andMyNumber:(NSString *)_mynumber andName: (NSString*)_name andUuid: (NSString *)_uuid
                             andType: (ConfTypeDef)_type andUpdateTime:(NSTimeInterval)time andStatus:(ConfEditStatusDef)_status
{
	if((self = [super init])){
		self->myid = _id;
        self->mynumber   = [_mynumber retain];
		self->name       = [_name retain];
		self->uuid       = [_uuid retain];
        self->type       = _type;
        self->updatetime = time;        
        self->status     = _status;
	}
	return self;
}

-(NgnConferenceFavorite*) initWithMynumber:(NSString *)_mynumber andName:(NSString *)_name andUuid:(NSString *)_uuid
                                   andType:(ConfTypeDef)_type andUpdateTime:(NSTimeInterval)time andStatus:(ConfEditStatusDef)_status 
{
    return [self initWithId:0 andMyNumber:_mynumber andName:_name andUuid:_uuid andType:_type andUpdateTime:time andStatus:_status];
}

-(void)dealloc{
    [mynumber release];
	[name release];
    [uuid release];
	[opaque release];
	
	[super dealloc];
}

@end

