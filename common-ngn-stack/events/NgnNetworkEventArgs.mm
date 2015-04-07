
/* Vincent, GZ, 2012-03-07 */

#import "NgnNetworkEventArgs.h"

@implementation NgnNetworkEventArgs

@synthesize eventType;

-(NgnNetworkEventArgs*) initWithType:(NgnNetworkEventTypes_t)eventType{
	if((self = [super init])){
		
	}
	return self;
}

-(void)dealloc{
	
	[super dealloc];
}

@end
