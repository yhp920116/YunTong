
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"

typedef enum NgnMessagingEventTypes_e {
	MESSAGING_EVENT_CONNECTING,
	MESSAGING_EVENT_CONNECTED,
	MESSAGING_EVENT_TERMINATING,
	MESSAGING_EVENT_TERMINATED,
	
	MESSAGING_EVENT_INCOMING,
    MESSAGING_EVENT_OUTGOING,
    MESSAGING_EVENT_SUCCESS,
    MESSAGING_EVENT_FAILURE
}
NgnMessagingEventTypes_t;

#define kNgnMessagingEventArgs_Name @"NgnMessagingEventArgs_Name"

#define kExtraMessagingEventArgsCode @"code"
#define kExtraMessagingEventArgsFrom @"from" // For backward compatibility do not remove
#define kExtraMessagingEventArgsFromUri kExtraMessagingEventArgsFrom
#define kExtraMessagingEventArgsFromUserName @"username"
#define kExtraMessagingEventArgsFromDisplayname @"displayname"
#define kExtraMessagingEventArgsDate @"date"
#define kExtraMessagingEventArgsContentType @"contentType"
#define kExtraMessagingEventArgsContentTransferEncoding @"contentTransferEncoding"

@interface NgnMessagingEventArgs : NgnEventArgs {
	long sessionId;
	NgnMessagingEventTypes_t eventType;
    NSString* sipPhrase;
    NSData* payload;
    NSString* callId;
}

@property(readonly) long sessionId;
@property(readonly) NgnMessagingEventTypes_t eventType;
@property(readonly) NSString* sipPhrase;
@property(readonly) NSData* payload;
@property(readonly) NSString* callId;

-(NgnMessagingEventArgs*)initWithSessionId: (long)sessionId andEventType: (NgnMessagingEventTypes_t)eventType andPhrase: (NSString*)phrase andPayload: (NSData*)payload andCallId:(NSString*)callid;

@end

