
#import <Foundation/Foundation.h>

typedef enum NgnDeviceInfo_Orientation_e
{
	NgnDeviceInfo_Orientation_Portrait,
	NgnDeviceInfo_Orientation_Landscape
}
NgnDeviceInfo_Orientation_t;

@interface NgnDeviceInfo : NSObject {
	NgnDeviceInfo_Orientation_t orientation;
	NSString* lang;
	NSString* country;
	NSDate* date;
}

@property(readwrite, nonatomic) NgnDeviceInfo_Orientation_t orientation;
@property(readwrite, retain, nonatomic) NSString* lang;
@property(readwrite, retain, nonatomic) NSString* country;
@property(readwrite, retain, nonatomic) NSDate* date;

@end

