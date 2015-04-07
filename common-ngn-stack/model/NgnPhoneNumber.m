
/* Vincent, GZ, 2012-03-07 */

#import "NgnPhoneNumber.h"

@implementation NgnPhoneNumber

@synthesize number;
@synthesize description;
@synthesize opaque;
@synthesize type;

-(NgnPhoneNumber*) initWithNumber:(NSString*)number_ andDescription:(NSString*)desciption_ andType:(NgnPhoneNumberType_t)type_ {
	if((self = [super init])){
		self->number = [number_ retain];
		self->description = [desciption_ retain];
		self->type = type_;
	}
	return self;
}

-(NgnPhoneNumber*) initWithNumber:(NSString*)number_ andDescription:(NSString*)desciption_ {
	return [self initWithNumber:number_ andDescription:desciption_ andType:NgnPhoneNumberType_Number];
}

-(BOOL) emailAddress{
	return (self->type == NgnPhoneNumberType_Email);
}

-(void)dealloc{
	[self->number release];
	[self->description release];
	
	[self->opaque release];
	
	[super dealloc];
}

@end
