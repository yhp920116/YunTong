
#import "NgnAVSession.h"
#import "NgnConfigurationEntry.h"
#import "NgnEngine.h"
#import "NgnStringUtils.h"
#import "NgnUriUtils.h"
#import "NgnProxyPluginMgr.h"

#import "SipSession.h"
#import "SipMessage.h"
#import "MediaSessionMgr.h"
#import "ProxyConsumer.h"
#import "ProxyProducer.h"

#undef kSessions
#define kSessions [NgnAVSession getAllSessions]

//
// private implementation
//

@interface NgnAVSession (Private)
+(NSMutableDictionary*) getAllSessions;
+(NgnAVSession*) makeCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andMediaType: (NgnMediaType_t)mType andCalloutMode:(CALL_OUT_MODE)mode;
-(NgnAVSession*) internalInit: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (NgnMediaType_t) mediaType andState: (InviteState_t) callState andCalloutMode:(CALL_OUT_MODE)mode;
-(BOOL)initializeConsumersAndProducers;
-(BOOL) setFlipVideo: (BOOL) flip forConsumer: (BOOL)consumer_;
@end

@implementation NgnAVSession (Private)

+(NSMutableDictionary*) getAllSessions{
	static NSMutableDictionary* sessions = nil;
	if(sessions == nil){
		sessions = [[NSMutableDictionary alloc] init];
	}
	return sessions;
}

+(NgnAVSession*) makeCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andMediaType: (NgnMediaType_t)mType andCalloutMode:(CALL_OUT_MODE)mode{
    if (!sipStack){
        TSK_DEBUG_ERROR("makeCallWithRemoteParty sipstack not ready");
        return nil;
    }
    NSString* prefix = nil;
    switch (mode) {
        case CALL_OUT_MODE_NONE:
            break;
        case CALL_OUT_MODE_INNER:
            prefix = @"92";
            break;
        case CALL_OUT_MODE_LNAD:
            prefix = @"93";
            break;
        case CALL_OUT_MODE_CALL_BACK:
            prefix = @"95";
            break;
        default:
            break;
    }
    NSString* nrnum = prefix ? [prefix stringByAppendingString:remoteUri] : remoteUri;
	NSString* validUri = [NgnUriUtils makeValidSipUri:nrnum];//[NgnUriUtils makeValidSipUri: remoteUri];
	if (validUri)
    {
		NgnAVSession* avSession = [NgnAVSession createOutgoingSessionWithSipStack: sipStack andMediaType: mType andCalloutMode:mode];
		if(avSession){
            NgnLog(@"makeCallWithRemoteParty=%@", validUri);

			if(![avSession makeCall: [NgnUriUtils makeValidSipUri:validUri]]){
				[NgnAVSession releaseSession:&avSession];
			}
		}
		return avSession;
	}
	return nil;
}

-(NgnAVSession*) internalInit: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (NgnMediaType_t) mediaType_ andState: (InviteState_t) callState andCalloutMode:(CALL_OUT_MODE)mode{
	if((self = (NgnAVSession*)[super initWithSipStack: sipStack])){
		mMediaType = mediaType_;
		mSpeakerOn = isVideoType(mMediaType);
		mMute = NO;
        mMode = mode;
		if(session && *session){
			_mSession = *session, *session = tsk_null;
		}
		else {
			_mSession = new CallSession(sipStack._stack);
		}
		// commons
		[super initialize];
		// History event
		mEvent = [[NgnHistoryEvent createAudioVideoEventWithRemoteParty:nil andVideo:isVideoType(mMediaType) andCalloutMode:mode] retain];
		// SigComp
		[super setSigCompId: [sipStack getSigCompId]];
        // Session timers
		if([[NgnEngine sharedInstance].configurationService getBoolWithKey:QOS_USE_SESSION_TIMERS]){
			int timeout = [[NgnEngine sharedInstance].configurationService getIntWithKey:QOS_SIP_CALLS_TIMEOUT];
			NSString* refresher = [[NgnEngine sharedInstance].configurationService getStringWithKey:QOS_REFRESHER];
			_mSession->setSessionTimer((unsigned)timeout, [NgnStringUtils toCString:refresher]);
		}
        // Precondition (FIXME)
		// mSession.setQoS(tmedia_qos_stype_t.valueOf(mConfigurationService
		//										   .getString(NgnConfigurationEntry.QOS_PRECOND_TYPE,
		//													  NgnConfigurationEntry.DEFAULT_QOS_PRECOND_TYPE)),
		//				tmedia_qos_strength_t.valueOf(mConfigurationService.getString(NgnConfigurationEntry.QOS_PRECOND_STRENGTH,
		//																			  NgnConfigurationEntry.DEFAULT_QOS_PRECOND_STRENGTH)));
		
		/* 3GPP TS 24.173
		 *
		 * 5.1 IMS communication service identifier
		 * URN used to define the ICSI for the IMS Multimedia Telephony Communication Service: urn:urn-7:3gpp-service.ims.icsi.mmtel. 
		 * The URN is registered at http://www.3gpp.com/Uniform-Resource-Name-URN-list.html.
		 * Summary of the URN: This URN indicates that the device supports the IMS Multimedia Telephony Communication Service.
		 *
		 * Contact: <sip:impu@skybroad.hk;gr=urn:uuid:xxx;comp=sigcomp>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel"
		 * Accept-Contact: *;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel"
		 * P-Preferred-Service: urn:urn-7:3gpp-service.ims.icsi.mmtel
		 */
		[super addCapsWithName: @"+g.3gpp.icsi-ref" andValue: @"\"urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel\""];
		[super addHeaderWithName: @"Accept-Contact" andValue: @"*;+g.3gpp.icsi-ref=\"urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel\""];
		[super addHeaderWithName:@"P-Preferred-Service" andValue: @"urn:urn-7:3gpp-service.ims.icsi.mmtel"];
		
		[super setState:callState];
	}
	return self;
}

-(BOOL) setFlipVideo: (BOOL) flip forConsumer: (BOOL)consumer_{
	const MediaSessionMgr* _mediaMgr = [super getMediaSessionMgr];
	if(_mediaMgr){
		if(consumer_){
			const_cast<MediaSessionMgr*>(_mediaMgr)->consumerSetInt32(twrap_media_video, "flip", flip ? 1 : 0);
		}
		else{
			const_cast<MediaSessionMgr*>(_mediaMgr)->producerSetInt32(twrap_media_video, "flip", flip ? 1 : 0);
		}
		return YES;
	}
	else {
		TSK_DEBUG_ERROR("Failed to find session manager");
		return NO;
	}
}
  
-(BOOL)initializeConsumersAndProducers{
	if(mConsumersAndProducersInitialzed || !isVideoType(self.mediaType)){
		return YES;
	}
	const MediaSessionMgr* _mediaMgr = [super getMediaSessionMgr];
	if(_mediaMgr){
		const ProxyPlugin* _videoConsumer = _mediaMgr->findProxyPluginConsumer(twrap_media_video);
		if(_videoConsumer){
			[mVideoConsumer release];
			mVideoConsumer = (NgnProxyVideoConsumer*)[[NgnProxyPluginMgr getProxyPluginWithId: _videoConsumer->getId()] retain];
			_videoConsumer = tsk_null;
		}
		else {
			TSK_DEBUG_ERROR("Failed to find video consumer");
		}

		const ProxyPlugin* _videoProducer = _mediaMgr->findProxyPluginProducer(twrap_media_video);
		if(_videoProducer){
			[mVideoProducer release];
			mVideoProducer = (NgnProxyVideoProducer*)[[NgnProxyPluginMgr getProxyPluginWithId: _videoProducer->getId()] retain];
			_videoProducer = tsk_null;
		}
		else {
			TSK_DEBUG_ERROR("Failed to find video producer");
		}
		mConsumersAndProducersInitialzed = YES;
		return YES;
	}
	TSK_DEBUG_ERROR("Cannot find media session manager");
	return NO;
}
  
@end



//
//	default implementation
//

@implementation NgnAVSession
@synthesize mMode;

-(void)dealloc{
	if(_mSession){
		delete _mSession;
	}
	
#if TARGET_OS_IPHONE
	[mVideoConsumer release];
	[mVideoProducer release];
#endif
	[mEvent release];
	
	[super dealloc];
}

-(BOOL) makeCall: (NSString*) validUri{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return NO;
	}
	
	BOOL ret;
	
	mOutgoing = YES;
	[super setToUri: validUri];
	
	if(mEvent){
		[mEvent setRemotePartyWithValidUri:validUri];      
	}
	
	// FIXME: Set bandwidth
	ActionConfig* _config = new ActionConfig();
	// String level = mConfigurationService.getString(NgnConfigurationEntry.QOS_PRECOND_BANDWIDTH,
	//											   NgnConfigurationEntry.DEFAULT_QOS_PRECOND_BANDWIDTH);
	// tmedia_bandwidth_level_t bl = getBandwidthLevel(level);
	// config.setMediaInt(twrap_media_type_t.twrap_media_audiovideo, "bandwidth-level", bl.swigValue());
	
	switch (super.mediaType){
		case MediaType_AudioVideo:
		case MediaType_Video:
			ret = _mSession->callAudioVideo([NgnStringUtils toCString:validUri], _config);
			break;
		case MediaType_Audio:
		default:
			ret = _mSession->callAudio([NgnStringUtils toCString:validUri], _config);
			break;
	}
	if(_config){
		delete _config, _config = tsk_null;
	}
	
	return ret;
}

-(BOOL) makeVideoSharingCall: (NSString*) validUri{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return NO;
	}
	
	mOutgoing = YES;
	[super setToUri:validUri];
	
	if(mEvent){
		[mEvent setRemotePartyWithValidUri:validUri];
	}
	
	return _mSession->callVideo([NgnStringUtils toCString:validUri]);
}

-(BOOL) updateSession: (NgnMediaType_t)mediaType_{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return NO;
	}
	
	if(isVideoType(mediaType_)){
		return _mSession->callAudioVideo([NgnStringUtils toCString:self.toUri]);
	}
	else {
		return _mSession->callAudio([NgnStringUtils toCString:self.toUri]);
	}
}

-(BOOL) acceptCallWithConfig: (ActionConfig*)config{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return NO;
	}
	return _mSession->accept(config);
}

-(BOOL) acceptCall{
	return [self acceptCallWithConfig: nil];
}

-(BOOL) hangUpCallWithConfig: (ActionConfig*)config{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return NO;
	}
	if([self isConnected]){
		return _mSession->hangup(config);
	}
	else {
		return _mSession->reject(config);
	}
}

-(BOOL) hangUpCall{
	return [self hangUpCallWithConfig: nil];
}

-(BOOL) holdCallWithConfig: (ActionConfig*)config{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return NO;
	}
	return _mSession->hold(config);
}

-(BOOL) holdCall{
	return [self holdCallWithConfig: nil];
}

-(BOOL) resumeCallWithConfig: (ActionConfig*)config{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return NO;
	}
	return _mSession->resume(config);
}

-(BOOL) resumeCall{
	return [self resumeCallWithConfig: nil];
}

-(BOOL) toggleHoldResumeWithConfig: (ActionConfig*)config{
	if([self isLocalHeld]){
		return [self resumeCallWithConfig:config];
	}
	return [self holdCallWithConfig:config];
}

-(BOOL) toggleHoldResume{
	return [self toggleHoldResumeWithConfig:nil];
}

-(void) setState: (InviteState_t)newState{
	if(mState == newState){
		return;
	}
	
	[super setState: newState];
	
	switch(newState){
		case INVITE_STATE_INCOMING:
		{
			[self initializeConsumersAndProducers];
			break;
		}
			
		case INVITE_STATE_INPROGRESS:
		{
			[self initializeConsumersAndProducers];
			break;
		}
			
		case INVITE_STATE_INCALL:
		{
			[self initializeConsumersAndProducers];
			break;
		}

		case INVITE_STATE_NONE:
		case INVITE_STATE_REMOTE_RINGING:
		case INVITE_STATE_EARLY_MEDIA:
		case INVITE_STATE_TERMINATING:
		case INVITE_STATE_TERMINATED:
		{
			break;
		}
	}
}

// override from InviteSession
-(void) setMediaType:(NgnMediaType_t)mediaType_{
	if(mediaType_ != mMediaType){
		mConsumersAndProducersInitialzed = NO;//force refresh
	}
	[super setMediaType:mediaType_];
	[self initializeConsumersAndProducers];
}

-(BOOL) sendDTMF: (int) digit{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return NO;
	}
	return _mSession->sendDTMF(digit);
}

-(BOOL) setFlipEncodedVideo: (BOOL) flip{
	return [self setFlipVideo:flip forConsumer:NO];
}

-(BOOL) setFlipDecodedVideo: (BOOL) flip{
	return [self setFlipVideo:flip forConsumer:YES];
}

#if TARGET_OS_IPHONE
-(BOOL) setRemoteVideoDisplay: (UIImageView*)display{
	if(mVideoConsumer){
		[mVideoConsumer setDisplay: display];
		return YES;
	}
	return NO;
}

-(BOOL) setLocalVideoDisplay: (UIView*)display{
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	if(mVideoProducer){
		[mVideoProducer setPreview: display];
		return YES;
	}
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */
	return NO;
}

-(BOOL) setOrientation: (AVCaptureVideoOrientation)orientation{
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	// alert the codecs
	switch (orientation) {
		case AVCaptureVideoOrientationPortrait: [self setFlipEncodedVideo:NO]; break;
		case AVCaptureVideoOrientationPortraitUpsideDown: [self setFlipEncodedVideo:NO]; break;
		case AVCaptureVideoOrientationLandscapeLeft: [self setFlipEncodedVideo:NO]; break;
		case AVCaptureVideoOrientationLandscapeRight: [self setFlipEncodedVideo:YES]; break;
	}
	// alert the producer
	if(mVideoProducer){
		[mVideoProducer setOrientation: orientation];
		return YES;
	}
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */
	return NO;
}

-(BOOL) toggleCamera{
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	if(mVideoProducer){
		[mVideoProducer toggleCamera];
		return YES;
	}
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */
	return NO;
}

#elif TARGET_OS_MAC

-(BOOL) setRemoteVideoDisplay:(NSObject<NgnVideoView>*)display{
	if(mVideoConsumer){
		[mVideoConsumer setDisplay: display];
		return YES;
	}
	return NO;
}

-(BOOL) setLocalVideoDisplay:(QTCaptureView*)display{
	if(mVideoProducer){
		[mVideoProducer setPreview:display];
		return YES;
	}
	return NO;
}

#endif

-(BOOL) setMute: (BOOL)mute{
	const MediaSessionMgr* _mediaMgr = [super getMediaSessionMgr];
	if(_mediaMgr){
		if(const_cast<MediaSessionMgr*>(_mediaMgr)->producerSetInt32(twrap_media_audio, "mute", mute ? 1 : 0)){
			mMute = mute;
			return YES;
		}
	}
	TSK_DEBUG_ERROR("Failed to mute/unmute the session");
	return NO;
}

-(BOOL) isMuted{
	return mMute;
}

-(BOOL) setSpeakerEnabled: (BOOL)speakerOn{
	mSpeakerOn = speakerOn;
	return YES;
}

-(BOOL) isSpeakerEnabled{
	return mSpeakerOn;
}

+(NgnAVSession*) takeIncomingSessionWithSipStack: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (twrap_media_type_t) mediaType andSipMessage: (const SipMessage*) sipMessage{
	NgnMediaType_t media;
	
	@synchronized (kSessions){
		switch (mediaType){
			case twrap_media_audio:
				media = MediaType_Audio;
				break;
			case twrap_media_video:
				media = MediaType_Video;
				break;
			case twrap_media_audiovideo:
				media = MediaType_AudioVideo;
				break;
			default:
				return nil;
		}
		NgnAVSession* avSession = [[[NgnAVSession alloc] internalInit: sipStack 
													   andCallSession: session 
													   andMediaType: media 
													   andState: INVITE_STATE_INCOMING
                                                           andCalloutMode:CALL_OUT_MODE_NONE] autorelease];
		if(avSession){
			if (sipMessage){
				char* _fHeaderValue = const_cast<SipMessage*>(sipMessage)->getSipHeaderValue("f");
				[avSession setRemotePartyUri: [NgnStringUtils toNSString: _fHeaderValue]];
				TSK_FREE(_fHeaderValue);
			}
			[kSessions setObject: avSession forKey:[avSession getIdAsNumber]];
			return avSession;
		}
	}
	return nil;
}

+(NgnAVSession*) createOutgoingSessionWithSipStack: (NgnSipStack*) sipStack andMediaType: (NgnMediaType_t) media andCalloutMode:(CALL_OUT_MODE)mode{
	NgnAVSession* avSession;
	@synchronized (kSessions){
		avSession = [[[NgnAVSession alloc] internalInit:sipStack andCallSession:tsk_null andMediaType:media andState:INVITE_STATE_INPROGRESS andCalloutMode:mode] autorelease];
		if(avSession){
			[kSessions setObject:avSession forKey:[avSession getIdAsNumber]];
		}
	}
	return avSession;
}

+(void) releaseSession: (NgnAVSession**) session{
	@synchronized (kSessions){
		if (session && *session){
			if([(*session) retainCount] == 1){
				[kSessions removeObjectForKey:[*session getIdAsNumber]];
			}
			else {
				[(*session) release];
			}
			*session = nil;
		}
	}
}

+(NgnAVSession*) getSessionWithId: (long) sessionId{
	NgnAVSession* avSession;
	@synchronized(kSessions){
		avSession = [kSessions objectForKey:[NSNumber numberWithLong:sessionId]];
	}
	return avSession;
}

+(NgnAVSession*) getSessionWithPredicate: (NSPredicate*) predicate{
	@synchronized(kSessions){
		NSArray* values = [kSessions allValues];
		for(NgnAVSession* value in values){
			if([predicate evaluateWithObject:value]){
				return value;
			}
		}
	}
	return nil;
}

+(BOOL) hasSessionWithId:(long) sessionId{
	return [NgnAVSession getSessionWithId:sessionId] != nil;
}

+(BOOL) hasActiveSession{
	@synchronized (kSessions){
		NSArray* values = [kSessions allValues];
		for(NgnAVSession* value in values){
			if([value isActive]){
				return YES;
			}
		}
	}
	return NO;
}

-(BOOL) getSessionCodec: (NgnCodecInfoDef*) codec{
    BOOL r = NO;
    const MediaSessionMgr* _mediaMgr = [super getMediaSessionMgr];
    if (_mediaMgr) {
        MediaSessionMgr::codecInfoDef c;
        r = _mediaMgr->getSessionCodec(c) ? YES : NO;
        if (r && codec) {
            codec->name = c.name;
            codec->rate = c.rate;
        }
    }
    return r;
}

+(NgnAVSession*) getFirstActiveCallAndNot:(long) sessionId{
	@synchronized (kSessions){
		NSArray* values = [kSessions allValues];
		for(NgnAVSession* value in values){
			if(value.id != sessionId && [value isActive] && ![value isLocalHeld] && ![value isRemoteHeld]){
				return value;
			}
		}
	}
	return nil;
}

+(int) getNumberOfActiveCalls:(BOOL) countOnHold{
	int number = 0;
	@synchronized (kSessions){
		NSArray* values = [kSessions allValues];
		for(NgnAVSession* value in values){
			if([value isActive] && (countOnHold || (![value isLocalHeld] && ![value isRemoteHeld]))){
				++number;
			}
		}
	}
	return number;
}

+(NgnAVSession*) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andCalloutMode:(CALL_OUT_MODE)mode{
   
    NSString * tempuri = [remoteUri stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString * newUri = [tempuri stringByReplacingOccurrencesOfString:@"+86" withString:@""];

	return [NgnAVSession makeCallWithRemoteParty:newUri andSipStack: sipStack andMediaType:MediaType_Audio andCalloutMode:mode];
}

+(NgnAVSession*) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andCalloutMode:(CALL_OUT_MODE)mode{
    NgnLog(@"NGNAvSession makeAudioVideoCallWithRemoteParty=%@", remoteUri);
    NSString * tempuri = [remoteUri stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString * newUri = [tempuri stringByReplacingOccurrencesOfString:@"+" withString:@""];
	return [NgnAVSession makeCallWithRemoteParty:newUri andSipStack: sipStack andMediaType:MediaType_AudioVideo andCalloutMode:mode];
}

// @Override
-(SipSession*)getSession{
	return _mSession;
}

// @Override
-(NgnHistoryEvent*) getHistoryEvent{
	return mEvent;
}

@end
