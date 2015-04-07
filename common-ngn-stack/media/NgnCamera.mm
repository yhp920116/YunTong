
#if TARGET_OS_IPHONE

#import "NgnCamera.h"

#undef TAG
#define kTAG @"NgnCamera///: "
#define TAG kTAG

//
//	Private
//
@interface NgnCamera (Private)

#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
+ (AVCaptureDevice *)cameraAtPosition:(AVCaptureDevicePosition)position;
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */

@end /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */

@implementation NgnCamera (Private)

#if NGN_PRODUCER_HAS_VIDEO_CAPTURE

+ (AVCaptureDevice *)cameraAtPosition:(AVCaptureDevicePosition)position{
	NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras){
        if (device.position == position){
            return device;
        }
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */

@end


//
//	Default implementation
//
@implementation NgnCamera

#if NGN_PRODUCER_HAS_VIDEO_CAPTURE

+ (AVCaptureDevice *)frontFacingCamera{
	return [NgnCamera cameraAtPosition:AVCaptureDevicePositionFront];
}

+ (AVCaptureDevice *)backCamera{
	return [NgnCamera cameraAtPosition:AVCaptureDevicePositionBack];
}

#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */

+ (BOOL) setPreview: (UIView*)preview{
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	static UIView* sPreview = nil;
	static AVCaptureSession* sCaptureSession = nil;
	
	if(preview == nil){
		// stop preview
		if(sCaptureSession && [sCaptureSession isRunning]){
			[sCaptureSession stopRunning];
		}
		// remove all sublayers
		if(sPreview){
			for(CALayer *ly in sPreview.layer.sublayers){
				if([ly isKindOfClass: [AVCaptureVideoPreviewLayer class]]){
					[ly removeFromSuperlayer];
					break;
				}
			}
		}
		return YES;
	}
	
	if(!sCaptureSession){
		NSError *error = nil;
		AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice: [NgnCamera frontFacingCamera] error:&error];
		if (!videoInput){
			NgnNSLog(TAG,@"Failed to get video input: %@", error);
			return NO;
		}
		
		sCaptureSession = [[AVCaptureSession alloc] init];
		[sCaptureSession addInput:videoInput];
	}
	
	// start capture if not already done or view did changed
	if(sPreview != preview || ![sCaptureSession isRunning]){
		[sPreview release];
		sPreview = [preview retain];

		
		AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: sCaptureSession];
		previewLayer.frame = sPreview.bounds;
		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		if(previewLayer.orientationSupported){
			switch ([UIDevice currentDevice].orientation) {
				case UIInterfaceOrientationPortrait: previewLayer.orientation = AVCaptureVideoOrientationPortrait; break;
				case UIInterfaceOrientationPortraitUpsideDown: previewLayer.orientation = AVCaptureVideoOrientationPortraitUpsideDown; break;
				case UIInterfaceOrientationLandscapeLeft: previewLayer.orientation = AVCaptureVideoOrientationLandscapeLeft; break;
				case UIInterfaceOrientationLandscapeRight: previewLayer.orientation = AVCaptureVideoOrientationLandscapeRight; break;
                case UIDeviceOrientationFaceUp: break;
                case UIDeviceOrientationFaceDown: break;
                default: break;
			}
		}
			
		[sPreview.layer addSublayer: previewLayer];
		[sCaptureSession startRunning];
	}
	
	return YES;
#else
	return NO;
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */
}

@end


#endif /* TARGET_OS_IPHONE */
