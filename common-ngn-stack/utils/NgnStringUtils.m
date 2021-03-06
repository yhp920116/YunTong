
/* Vincent, GZ, 2012-03-07 */

#import "NgnStringUtils.h"
#import "encryption.h"

#undef kStringEmpty
#define kStringEmpty	@""

@implementation NgnStringUtils

+(const NSString*)emptyValue{
	return kStringEmpty;
}

+(const NSString*)nullValue{
	return @"(null)";
}

+(BOOL)isNullOrEmpty:(NSString*)string{
	return string == nil || string==(id)[NSNull null] || [string isEqualToString: kStringEmpty];
}

+(BOOL)contains:(NSString*) string subString:(NSString*)subStr{
	return [string rangeOfString:subStr].location != NSNotFound;
}

+(NSString*) toNSString: (const char*)cstring{
	return cstring ? [NSString stringWithCString:cstring encoding: NSUTF8StringEncoding] : nil;
}

+(const char*) toCString: (NSString*)nsstring{
	return [nsstring UTF8String];
}

#if TARGET_OS_IPHONE
+(UIColor*) colorFromRGBValue: (int)rgbvalue{
	return [UIColor colorWithRed: ((float)((rgbvalue & 0xFF0000) >> 16))/255.0
					green: ((float)((rgbvalue & 0xFF00) >> 8))/255.0
					blue: ((float)(rgbvalue & 0xFF))/255.0 alpha:1.0];
}
#endif

+(void) EncryptString:(char*) str andLength:(int)len {
    EncryptPacket(str, len);
}

+(void) DecryptString:(char*) str andLength:(int)len {
    DecryptPacket(str, len);
}

@end
