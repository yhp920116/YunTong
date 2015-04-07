
#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

typedef enum AudioRouteTypes_e {
    AUDIO_ROUTE_SPEAKER,
    AUDIO_ROUTE_HEADPHONES,
    AUDIO_ROUTE_RECEIVER,
	/* to be completed */
} AudioRouteTypes_t;

@protocol INgnSoundService <INgnBaseService>

-(BOOL) setSpeakerEnabled:(BOOL)enabled;
-(BOOL) isSpeakerEnabled;
-(BOOL) playRingTone;
-(BOOL) stopRingTone;
-(BOOL) playRingBackTone;
-(BOOL) stopRingBackTone;
-(BOOL) playDtmf:(int)digit;
-(AudioRouteTypes_t) GetAudioRouteType;

#if TARGET_OS_IPHONE
-(BOOL) vibrate;
-(BOOL) playKeepAwakeSoundLooping: (BOOL)looping;
-(BOOL) stopKeepAwakeSound;
#endif /* TARGET_OS_IPHONE */

@end