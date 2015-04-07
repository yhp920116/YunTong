
/* Vincent, GZ, 2012-03-07 */

#import "NgnSipPreferences.h"
#import "NgnStringUtils.h"

@implementation NgnSipPreferences

@synthesize presence;
@synthesize xcap;
@synthesize presenceRLS;
@synthesize presencePub;
@synthesize presenceSub;
@synthesize mwi;
@synthesize impi;
@synthesize impu;
@synthesize pcscfHost;
@synthesize pcscfPort;
@synthesize transport;
@synthesize ipVersion;
@synthesize ipsecSecAgree;
@synthesize localIp;
@synthesize hackAoR;
@synthesize deviceToken;

-(NSString*)realm{
	return self->realm;
}

-(void) setRealm:(NSString*)value {
	[self->realm release], self->realm = nil;
	if(value){
		if([NgnStringUtils contains:value subString:@":"]){
			self->realm = [[@"sip:" stringByAppendingString:value] retain];
		}
		else{
			self->realm = [value retain];
		}
	}
}

-(void)dealloc{
	[self->impi dealloc];
	[self->impu dealloc];
	[self->realm dealloc];
	[self->pcscfHost dealloc];
	[self->transport dealloc];
	[self->ipVersion dealloc];
	[self->localIp dealloc];
    [self->deviceToken dealloc];
	[super dealloc];
}

@end
