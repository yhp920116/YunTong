
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

#if TARGET_OS_IPHONE
#	import <AVFoundation/AVAudioPlayer.h>
#	import "iOSNgnConfig.h"
#elif TARGET_OS_MAC
#	import "OSXNgnConfig.h"
#endif

#import "services/impl/NgnBaseService.h"
#import "services/INgnSoundService.h"

@interface NgnSoundService : NgnBaseService <INgnSoundService>{
@private
	SystemSoundID dtmfLastSoundId;
#if TARGET_OS_IPHONE
	AVAudioPlayer  *playerRingBackTone;
	AVAudioPlayer  *playerRingTone;
	AVAudioPlayer  *playerEvent;
	AVAudioPlayer  *playerConn;
	AVAudioPlayer  *playerKeepAwake;
	AVAudioPlayer  *playerDTMF;
#elif TARGET_OS_MAC
	NSSound *soundRingBackTone;
	NSSound *soundRingTone;
	NSSound *soundEvent;
	NSSound *soundConn;
#endif
	
	BOOL speakerOn;
}

@end
