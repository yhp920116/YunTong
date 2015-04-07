
/* Vincent, GZ, 2012-07-10 */


#import "NgnSystemNotification.h"
//#import "NgnEngine.h"

@implementation NgnSystemNotification

@synthesize myid;
@synthesize mynumber;
@synthesize content;
@synthesize receivetime;
@synthesize read;
@synthesize opaque;


-(NgnSystemNotification*) initWithId: (long long)_id andMyNumber:(NSString*)_mynumber andContent: (NSString*)_content andReceiveTime: (double)_receivetime andRead: (BOOL)_read {
	if((self = [super init])){
		self->myid = _id;
        self->mynumber = [_mynumber retain];
		self->content = [_content retain];
		self->receivetime = _receivetime;
        self->read = _read;
	}
	return self;
}

-(NgnSystemNotification*) initWithContent: (NSString*)_content andMyNumber:(NSString*)_mynumber andReceiveTime: (double)_receivetime andRead: (BOOL)_read {
	return [self initWithId:0 andMyNumber:_mynumber andContent:_content andReceiveTime:_receivetime andRead:_read];
}

-(NSComparisonResult)compareSysNotificationByReceiveTime:(NgnSystemNotification *)otherNotify{
	return self.receivetime > otherNotify.receivetime;
}

-(void)dealloc{
    [mynumber release];
	[content release];
	[opaque release];
	
	[super dealloc];
}

@end

