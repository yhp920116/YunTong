
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "sip/NgnSipSession.h"
#import "sip/NgnPresenceStatus.h"

class PublicationSession;
class ActionConfig;

@interface NgnPublicationSession : NgnSipSession {
	PublicationSession *_mSession;
	NSString *mEvent;
	NSString *mContentType;
}

@property(retain,getter=getContentType,setter=setContentType:) NSString* contentType;
@property(retain,getter=getEvent,setter=setEvent:) NSString* event;

+(NSData*) createPresenceContentWithEntityUri:(NSString*)entityUri andStatus:(NgnPresenceStatus_t)status  andNote:(NSString*)note;
+(NgnPublicationSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack 
												andToUri:(NSString*)toUri
												andEvent:(NSString*)event
												andContentType:(NSString*)contentType;
+(NgnPublicationSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack 
												andToUri:(NSString*)toUri;
+(NgnPublicationSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack;
+(NgnPublicationSession*) getSessionWithId:(long)sessionId;
+(BOOL) hasSessionWithId:(long)sessionId;
+(void) releaseSession:(NgnPublicationSession**) session;

-(BOOL)publishContent:(NSData*)content andEvent:(NSString*)event andContentType:(NSString*)contentType;
-(BOOL)publishContent:(NSData*)content;
-(BOOL)publishContent:(NSData*)content andActionConfig:(ActionConfig*)_config;
-(BOOL)unPublishWithConfig:(ActionConfig*)_config;
-(BOOL)unPublish;

-(void)setContentType:(NSString *)contentType;
-(NSString *)getContentType;
-(void)setEvent:(NSString *)event;
-(NSString *)getEvent;

@end
