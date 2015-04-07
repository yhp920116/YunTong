
#if TARGET_OS_IPHONE

#import "iOSNgnConfig.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface NgnCamera : NSObject {
	
}

#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
+ (AVCaptureDevice *)frontFacingCamera;
+ (AVCaptureDevice *)backCamera;
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */

+ (BOOL) setPreview: (UIView*)preview;

@end

#endif /* TARGET_OS_IPHONE */
