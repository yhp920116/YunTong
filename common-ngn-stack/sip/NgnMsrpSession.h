
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "sip/NgnInviteSession.h"

@interface NgnMsrpSession : NgnInviteSession {

}

+(void) releaseSession: (NgnMsrpSession**) session;
+(NgnMsrpSession*) getSessionWithId: (long) sessionId;

@end
