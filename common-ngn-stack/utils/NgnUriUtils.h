
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

@interface NgnUriUtils : NSObject {

}


+(NSString*) getDisplayName:(NSString*)uri;
+(NSString*) getUserName: (NSString*)validUri;
+(BOOL) isValidSipUri: (NSString*)uri;
+(NSString*) makeValidSipUri: (NSString*)uri;
+(NSString*) getValidPhoneNumber: (NSString*)uri;

@end
