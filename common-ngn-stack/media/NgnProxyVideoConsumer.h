
/* Vincent, GZ, 2012-03-07 */


#if TARGET_OS_IPHONE
#	import <UIKit/UIKit.h>
#	import <AVFoundation/AVFoundation.h>
#elif TARGET_OS_MAC
#	import "NgnVideoView.h"
#	import <Cocoa/Cocoa.h>
#	import <QuartzCore/CoreVideo.h>
#	import <QuartzCore/CIContext.h>
#endif

#import "NgnProxyPlugin.h"

class ProxyVideoConsumer;
class _NgnProxyVideoConsumerCallback;

@interface NgnProxyVideoConsumer : NgnProxyPlugin {
	_NgnProxyVideoConsumerCallback* _mCallback;
	const ProxyVideoConsumer * _mConsumer;
	
	uint8_t* _mBufferPtr;
	size_t _mBufferSize;
	
	int mWidth;
	int mHeight;
	int mFps;
	BOOL mFlip;
	
	CGContextRef mBitmapContext;
	
#if TARGET_OS_IPHONE
	UIImageView* mDisplay;
#elif TARGET_OS_MAC
	NSObject<NgnVideoView>* mDisplay;
#endif
}

-(NgnProxyVideoConsumer*) initWithId: (uint64_t)identifier andConsumer:(const ProxyVideoConsumer *)_consumer;

#if TARGET_OS_IPHONE
-(void) setDisplay: (UIImageView*)display;
#elif TARGET_OS_MAC
-(void) setDisplay: (NSObject<NgnVideoView>*)display;
#endif

@end
