
/* Vincent, GZ, 2012-03-07 */

#if TARGET_OS_IPHONE
#	import <AVFoundation/AVFoundation.h>
#elif TARGET_OS_MAC
#	import <Cocoa/Cocoa.h>
#endif

@protocol NgnVideoView<NSObject>

-(void)setCurrentImage:(CGImageRef)imageRef;

@end