
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#	import <UIKit/UIKit.h>
#endif

@interface NgnStringUtils : NSObject {

}

+(const NSString*)emptyValue;
+(const NSString*)nullValue;
+(BOOL)isNullOrEmpty:(NSString*)string;
+(BOOL)contains:(NSString*) string subString:(NSString*)subStr;
+(NSString*) toNSString: (const char*)cstring;
+(const char*) toCString: (NSString*)nsstring;
#if TARGET_OS_IPHONE
+(UIColor*) colorFromRGBValue: (int)rgbvalue;
#endif

+(void) EncryptString:(char*) str andLength:(int)len;
+(void) DecryptString:(char*) str andLength:(int)len;

@end
