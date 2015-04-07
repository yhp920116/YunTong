
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "sip/NgnSipSession.h"
#import "model/NgnHistoryEvent.h"
#import "model/NgnDeviceInfo.h"
#import "media/NgnMediaType.h"

class MediaSessionMgr;

typedef enum InviteState_e{
	INVITE_STATE_NONE,
	INVITE_STATE_INCOMING,
	INVITE_STATE_INPROGRESS,
	INVITE_STATE_REMOTE_RINGING,
	INVITE_STATE_EARLY_MEDIA,
	INVITE_STATE_INCALL,
	INVITE_STATE_TERMINATING,
	INVITE_STATE_TERMINATED,
}
InviteState_t;

@interface NgnInviteSession : NgnSipSession {
	NgnMediaType_t mMediaType;
    InviteState_t mState;
	BOOL mRemoteHold;
    BOOL mLocalHold;
	BOOL mEventAdded;
	BOOL mEventIncoming;
	BOOL mDidConnect;
	NgnDeviceInfo* mRemoteDeviceInfo;
	
	
	const MediaSessionMgr* _mMediaSessionMgr;
}

@property(readonly,getter=getMediaType) NgnMediaType_t mediaType;
@property(readwrite,getter=getState,setter=setState:) InviteState_t state;
@property(readonly) BOOL active;
@property(readonly,getter=getHistoryEvent) NgnHistoryEvent* historyEvent;
@property(readonly,getter=getRemotePartyDisplayName) NSString* remotePartyDisplayName;
@property(readonly,getter=getRemoteDeviceInfo) NgnDeviceInfo* remoteDeviceInfo;

-(NgnInviteSession*) initWithSipStack: (NgnSipStack *)sipStack;
-(NgnMediaType_t)getMediaType;
-(void) setMediaType:(NgnMediaType_t)mediaType; // should only be called by the NgnSipService
-(InviteState_t) getState;
-(void) setState:(InviteState_t)newState;
-(BOOL) isActive;
-(BOOL) isLocalHeld;
-(void) setLocalHold:(BOOL)held;
-(BOOL) isRemoteHeld;
-(void) setRemoteHold:(BOOL)held;
-(NgnHistoryEvent*) getHistoryEvent;
-(NSString*)getRemotePartyDisplayName;
-(NgnDeviceInfo*)getRemoteDeviceInfo;
-(const MediaSessionMgr*)getMediaSessionMgr;

-(BOOL) sendInfoWithContentData:(NSData*)content contentType:(NSString*)ctype;
-(BOOL) sendInfoWithContentString:(NSString*)content contentType:(NSString*)ctype;

@end
