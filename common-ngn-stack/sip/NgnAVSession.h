
#import <Foundation/Foundation.h>

#import "services/INgnConfigurationService.h"
#import "services/impl/NgnBaseService.h"
#import "sip/NgnInviteSession.h"
#import "model/NgnHistoryAVCallEvent.h"
#import "media/NgnVideoView.h"

#import "media/NgnProxyVideoConsumer.h"
#if TARGET_OS_IPHONE
#	import "iOSProxyVideoProducer.h"
#elif TARGET_OS_MAC
#	import "OSXProxyVideoProducer.h"
#endif

#undef NgnAVSessionMutableArray
#undef NgnAVSessionArray
#define NgnAVSessionMutableArray	NSMutableArray
#define NgnAVSessionArray	NSArray

class CallSession;
class SipMessage;
class ActionConfig;

struct NgnCodecInfoDef {
	NgnCodecInfoDef() : name(0), rate(0) {}
    const char*   name;
    unsigned long rate;
};

@interface NgnAVSession : NgnInviteSession {
	CallSession* _mSession;
	NgnHistoryAVCallEvent* mEvent;
	
	BOOL mMute;
	BOOL mSpeakerOn;
    
    CALL_OUT_MODE mMode;
	
	BOOL mConsumersAndProducersInitialzed;
	NgnProxyVideoConsumer* mVideoConsumer;
	NgnProxyVideoProducer* mVideoProducer;
}

@property(readonly) CALL_OUT_MODE mMode;

-(BOOL) makeCall: (NSString*) validUri;
-(BOOL) makeVideoSharingCall: (NSString*) validUri;
-(BOOL) updateSession: (NgnMediaType_t)mediaType;
-(BOOL) getSessionCodec: (NgnCodecInfoDef*) codec;
-(BOOL) acceptCallWithConfig: (ActionConfig*)config;
-(BOOL) acceptCall;
-(BOOL) hangUpCallWithConfig: (ActionConfig*)config;
-(BOOL) hangUpCall;
-(BOOL) holdCallWithConfig: (ActionConfig*)config;
-(BOOL) holdCall;
-(BOOL) resumeCallWithConfig: (ActionConfig*)config;
-(BOOL) resumeCall;
-(BOOL) toggleHoldResumeWithConfig: (ActionConfig*)config;
-(BOOL) toggleHoldResume;
-(BOOL) sendDTMF: (int) digit;
-(BOOL) setFlipEncodedVideo: (BOOL) flip;
-(BOOL) setFlipDecodedVideo: (BOOL) flip;
#if TARGET_OS_IPHONE
-(BOOL) setRemoteVideoDisplay: (UIImageView*)display;
-(BOOL) setLocalVideoDisplay: (UIView*)display;
-(BOOL) setOrientation: (AVCaptureVideoOrientation)orientation;
-(BOOL) toggleCamera;
-(BOOL) setMute: (BOOL)mute;
-(BOOL) isMuted;
-(BOOL) setSpeakerEnabled: (BOOL)speakerOn;
-(BOOL) isSpeakerEnabled;
#elif TARGET_OS_MAC
-(BOOL) setRemoteVideoDisplay:(NSObject<NgnVideoView>*)display;
-(BOOL) setLocalVideoDisplay: (QTCaptureView*)display;
#endif

+(NgnAVSession*) takeIncomingSessionWithSipStack: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (twrap_media_type_t) mediaType andSipMessage: (const SipMessage*) sipMessage;
+(NgnAVSession*) createOutgoingSessionWithSipStack: (NgnSipStack*) sipStack andMediaType: (NgnMediaType_t) mediaType andCalloutMode:(CALL_OUT_MODE)mode;
+(void) releaseSession: (NgnAVSession**) session;
+(NgnAVSession*) getSessionWithId: (long) sessionId;
+(NgnAVSession*) getSessionWithPredicate: (NSPredicate*) predicate;
+(BOOL) hasSessionWithId:(long) sessionId;
+(BOOL) hasActiveSession;
+(NgnAVSession*) getFirstActiveCallAndNot:(long) sessionId;
+(int) getNumberOfActiveCalls:(BOOL) countOnHold;
+(NgnAVSession*) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andCalloutMode:(CALL_OUT_MODE)mode;
+(NgnAVSession*) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andCalloutMode:(CALL_OUT_MODE)mode;


@end
