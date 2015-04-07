
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

typedef enum NgnPhoneNumberType_e
{
	NgnPhoneNumberType_Unknown,
	NgnPhoneNumberType_Number,
	NgnPhoneNumberType_Email
}
NgnPhoneNumberType_t;

@interface NgnPhoneNumber : NSObject {
@protected
	NSString* number;
	NSString* description;
	NgnPhoneNumberType_t type;
    
@private
	// to be used for any purpose (e.g. category)
	id opaque;
}

@property(readonly) NSString* number;
@property(readonly) BOOL emailAddress;
@property(readonly) NgnPhoneNumberType_t type;
@property(readonly) NSString* description;
@property(readwrite, retain, nonatomic) id opaque;

-(NgnPhoneNumber*) initWithNumber:(NSString*)_number andDescription:(NSString*)_desciption andType:(NgnPhoneNumberType_t)type;
-(NgnPhoneNumber*) initWithNumber:(NSString*)_number andDescription:(NSString*)_desciption;

@end
