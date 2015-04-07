
/* Vincent, GZ, 2012-03-07 */

#import "NgnSoundService.h"

#if TARGET_OS_IPHONE
#import <AVFoundation/AVFoundation.h>
#elif TARGET_OS_MAC
#endif
#import "NgnSoundServiceEventArgs.h"
#import "NgnNotificationCenter.h"

#undef TAG
#define kTAG @"NgnSoundService///: "
#define TAG kTAG

//
// private implementation
//
@interface NgnSoundService(Private)
#if TARGET_OS_IPHONE
+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path;
#elif TARGET_OS_MAC
+(NSSound*) initSoundWithPath:(NSString*)path;
#endif
@end

@implementation NgnSoundService(Private)

#if TARGET_OS_IPHONE
+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path{
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], path]];
		
	NSError *error;
	AVAudioPlayer *player = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] autorelease];
	if (player == nil){
		NgnLog(@"Failed to create audio player(%@): %@", path, error);
	}
	
	return player;
}
#elif TARGET_OS_MAC
+(NSSound*) initSoundWithPath:(NSString*)path
{
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], path]];
	NSSound *sound = [[[NSSound alloc] initWithContentsOfURL:url byReference:NO] autorelease];
	return sound;
}
#endif

@end

//
// default implementation
//
@implementation NgnSoundService

static const char* AudioTypeStr(AudioRouteTypes_t t) {
    switch (t) {
        case AUDIO_ROUTE_SPEAKER:    return "Speaker";
        case AUDIO_ROUTE_RECEIVER:   return "Receiver";
        case AUDIO_ROUTE_HEADPHONES: return "Headphones";
        default: return "Unknown";
    }
}

-(AudioRouteTypes_t) GetAudioRouteType {
    UInt32 propertySize = sizeof(CFStringRef);
    //AudioSessionInitialize(NULL, NULL, NULL, NULL);
    CFStringRef state = nil;
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
    
    NSString* str = (NSString *)state;
    NSRange range = [str rangeOfString: @"Speaker"];
    NgnLog(@"GetAudioRouteType %@ %d", str, range.length);
    if (range.length > 0) {
        CFRelease(state);
        return AUDIO_ROUTE_SPEAKER;
    } else {        
        range = [str rangeOfString: @"Headphones"];
        if (range.length > 0) {
            CFRelease(state);
            return AUDIO_ROUTE_HEADPHONES;
        }
    }
    CFRelease(state);
    return AUDIO_ROUTE_RECEIVER;
}

static void audioRouteChangeListenerCallback (void* inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void* inPropertyValue)
{
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) {
        return;
    }
    
    NgnSoundService* auServ = (NgnSoundService*)inUserData;
    AudioRouteTypes_t audiotype = [auServ GetAudioRouteType];
    NgnLog(@"  ********  AudioService CallBack eventtype %s", AudioTypeStr(audiotype));
    NgnSoundServiceEventTypes_t eventtype = SOUND_SERVICE_EVENT_AUDIO_ROUTE_SPEAKER;
    switch (audiotype) {
        case AUDIO_ROUTE_SPEAKER:
            eventtype = SOUND_SERVICE_EVENT_AUDIO_ROUTE_SPEAKER;
            break;
        case AUDIO_ROUTE_HEADPHONES:
            eventtype = SOUND_SERVICE_EVENT_AUDIO_ROUTE_HEADPHONES;
            break;
        case AUDIO_ROUTE_RECEIVER:
            eventtype = SOUND_SERVICE_EVENT_AUDIO_ROUTE_RECEIVER;
            break;            
    }
    /* raise event */ 
    NgnSoundServiceEventArgs *eargs = [[[NgnSoundServiceEventArgs alloc] initWithType:eventtype] autorelease];
    //NgnLog(@"raise SoundService Event %d, %d", eargs.eventType, audiotype);
	[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnSoundServiceEventArgs_Name object:eargs];    
}

-(NgnSoundService*)init{
	if((self = [super init])){
        //////////////////////////////////////////////
        //AudioSessionInitialize(NULL, NULL, NULL, NULL);
        OSStatus lStatus = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, self);
        if (lStatus) {
            NgnNSLog(TAG, @"cannot register route change handler [%ld]", lStatus);
        }
        //////////////////////////////////////////////
	}
	return self;
}

-(void)dealloc{
	
	if(dtmfLastSoundId){
		AudioServicesDisposeSystemSoundID(dtmfLastSoundId);
		dtmfLastSoundId = 0;
	}
#if TARGET_OS_IPHONE
#define RELEASE_PLAYER(player) \
	if(player){ \
		if(player.playing){ \
			[player stop]; \
		} \
		[player release]; \
        player = nil; \
	}
	RELEASE_PLAYER(playerKeepAwake);
	RELEASE_PLAYER(playerRingBackTone);
	RELEASE_PLAYER(playerRingTone);
	RELEASE_PLAYER(playerEvent);
	RELEASE_PLAYER(playerConn);
	RELEASE_PLAYER(playerDTMF);
	
#undef RELEASE_PLAYER
	
	
#elif TARGET_OS_MAC
	
#define RELEASE_SOUND(sound) \
	if(sound){ \
		if([sound isPlaying]){ \
			[sound stop]; \
		} \
		[sound release]; \
        sound = nil; \
	}

	RELEASE_SOUND(soundRingBackTone);
	RELEASE_SOUND(soundRingTone);
	RELEASE_SOUND(soundEvent);
	RELEASE_SOUND(soundConn);
				  
#undef RELEASE_SOUND
	   
#endif
	
	[super dealloc];
}

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	return YES;
}


//
// INgnSoundService
//

-(BOOL) setSpeakerEnabled:(BOOL)enabled{
    NgnLog(@"setSpeakerEnabled %d", enabled);
#if TARGET_OS_IPHONE
	UInt32 audioRouteOverride = enabled ? kAudioSessionOverrideAudioRoute_Speaker : kAudioSessionOverrideAudioRoute_None;
	if(AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride),&audioRouteOverride) == 0){
        //NgnLog(@"setSpeakerEnabled enabled");
		speakerOn = enabled;
		return YES;
	}
	return NO;
#else
	return NO;
#endif
}

-(BOOL) isSpeakerEnabled{
	return speakerOn;
}

-(BOOL) playRingTone{
#if TARGET_OS_IPHONE
	if(!playerRingTone){
		playerRingTone = [[NgnSoundService initPlayerWithPath:@"ringtone.mp3"] retain];
	}
	if(playerRingTone){
		playerRingTone.numberOfLoops = -1;
		[playerRingTone play];
		return YES;
	}
#elif TARGET_OS_MAC
	if(!soundRingTone){
		soundRingTone = [[NgnSoundService initSoundWithPath:@"ringtone.mp3"] retain];
	}
	if(soundRingTone){
		[soundRingTone setLoops:YES];
		[soundRingTone play];
		return YES;
	}
#endif
	return NO;
}

-(BOOL) stopRingTone{
#if TARGET_OS_IPHONE
	if(playerRingTone && playerRingTone.playing){
		[playerRingTone stop];
	}
#elif TARGET_OS_MAC
	if(soundRingTone && [soundRingTone isPlaying]){
		[soundRingTone stop];
	}
#endif
	return YES;
}

-(BOOL) playRingBackTone{
#if TARGET_OS_IPHONE
	if(!playerRingBackTone){
		playerRingBackTone = [[NgnSoundService initPlayerWithPath:@"ringbacktone.wav"] retain];
	}
	if(playerRingBackTone){
		playerRingBackTone.numberOfLoops = -1;
		[playerRingBackTone play];
		return YES;
	}
#elif TARGET_OS_MAC
	if(!soundRingBackTone){
		soundRingBackTone = [[NgnSoundService initSoundWithPath:@"ringbacktone.wav"] retain];
	}
	if(soundRingBackTone){
		[soundRingBackTone setLoops:YES];
		[soundRingBackTone play];
		return YES;
	}
#endif
	return NO;
}

-(BOOL) stopRingBackTone{
#if TARGET_OS_IPHONE
	if(playerRingBackTone && playerRingBackTone.playing){
		[playerRingBackTone stop];
	}
#elif TARGET_OS_MAC
	if(soundRingBackTone && [soundRingBackTone isPlaying]){
		[soundRingBackTone stop];
	}
#endif
	return YES;
}

-(BOOL) playDtmf:(int)digit{
	NSString* code = nil;
	BOOL ok = NO;
	switch(digit){
		case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9: code = [NSString stringWithFormat:@"%i", digit]; break; 
		case 10: code = @"star"; break;
		case 11: code = @"pound"; break;
		default: code = @"0";
	}
	
	CFURLRef soundUrlRef = (CFURLRef)[[[[NSBundle mainBundle] URLForResource:[@"dtmf-" stringByAppendingString:code]
															   withExtension:@"wav"] retain] autorelease];

#if 0	//using systemsound
    if(dtmfLastSoundId){
		AudioServicesDisposeSystemSoundID(dtmfLastSoundId);
		dtmfLastSoundId = 0;
	}
	
    if(soundUrlRef && AudioServicesCreateSystemSoundID(soundUrlRef, &dtmfLastSoundId) == 0){
		AudioServicesPlaySystemSound(dtmfLastSoundId);
		ok = YES;
	}
	
	if(soundUrlRef){
		CFRelease(soundUrlRef);
	}
#else   //using audio player
	NSURL *url = (NSURL*)soundUrlRef;
    NSError *error;

    if (!playerDTMF) {
        //playerDTMF = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] retain];
        playerDTMF = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];

	    if (playerDTMF == nil) {
            NgnLog(@"Failed to create audio player(%d)", digit);
            return false;
	    }
        
        playerDTMF.numberOfLoops = 1;
        playerDTMF.volume = .80;    //按键音量 , 不需要太大
		[playerDTMF play];
        
        //[playerDTMF release];
	} else {
		if (playerDTMF.playing) {
            [playerDTMF stop];
        }
        
        [playerDTMF initWithContentsOfURL:url error:&error];
		playerDTMF.numberOfLoops = 1;
        playerDTMF.volume = .80;    //按键音量 , 不需要太大
		[playerDTMF play];
	}

#endif
	return ok;
}

#if TARGET_OS_IPHONE

-(BOOL) vibrate{
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
	return YES;
}

-(BOOL) playKeepAwakeSoundLooping: (BOOL)looping{
	
	if(!playerKeepAwake){
		playerKeepAwake = [[NgnSoundService initPlayerWithPath:@"keepawake.wav"] retain];
	}
	if(playerKeepAwake){
		UInt32 doSetProperty = TRUE;
		[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
		AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
		
		playerKeepAwake.numberOfLoops = looping ? -1 : +1;
		[playerKeepAwake play];
		return YES;
	}
	return NO;
}

-(BOOL) stopKeepAwakeSound{
	if(playerKeepAwake/* && playerKeepAwake.playing*/){
		UInt32 doSetProperty = FALSE;
		[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
		AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
		
		[playerKeepAwake stop];
	}
	return YES;
}

#endif /* TARGET_OS_IPHONE */

@end
