
#import "NgnDeviceInfo.h"


@implementation NgnDeviceInfo

@synthesize orientation;
@synthesize lang;
@synthesize country;
@synthesize date;

-(NgnDeviceInfo*)init{
	if(self = [super init]){
		self.orientation = NgnDeviceInfo_Orientation_Portrait;// for backward compatibility
	}
	return self;
}

-(void)dealloc
{
	[lang release];
	[country release];
	[date release];
	
	[super dealloc];
}

@end
