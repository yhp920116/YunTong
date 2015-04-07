
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"

#define kNgnSoundServiceEventArgs_Name @"NgnSoundServiceEventArgs_Name"

typedef enum NgnSoundServiceEventTypes_e {
    SOUND_SERVICE_EVENT_AUDIO_ROUTE_SPEAKER,
    SOUND_SERVICE_EVENT_AUDIO_ROUTE_HEADPHONES,
    SOUND_SERVICE_EVENT_AUDIO_ROUTE_RECEIVER,
	/* to be completed */
}
NgnSoundServiceEventTypes_t;

@interface NgnSoundServiceEventArgs : NgnEventArgs {
	NgnSoundServiceEventTypes_t eventType;
}

-(NgnSoundServiceEventArgs*) initWithType:(NgnSoundServiceEventTypes_t)eventType;

@property(readonly) NgnSoundServiceEventTypes_t eventType;

@end
