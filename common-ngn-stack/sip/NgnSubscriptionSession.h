
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "sip/NgnSipSession.h"
#import "media/NgnEventPackageType.h"

class SubscriptionSession;

@interface NgnSubscriptionSession : NgnSipSession {
	SubscriptionSession *_mSession;
	NgnEventPackageType_t mPackage;
}

-(BOOL)subscribe;
-(BOOL)unSubscribe;

+(NgnSubscriptionSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack andToUri:(NSString*)toUri andPackage:(NgnEventPackageType_t)package;
+(NgnSubscriptionSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack andPackage:(NgnEventPackageType_t)package;
+(NgnSubscriptionSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack;
+(NgnSubscriptionSession*) getSessionWithId: (long)sessionId;
+(BOOL) hasSessionWithId:(long)sessionId;
+(void) releaseSession:(NgnSubscriptionSession**)session;

@property(readonly) NgnEventPackageType_t eventPackage;

@end
