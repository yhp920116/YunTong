
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"
#import "media/NgnEventPackageType.h"

#define kNgnSubscriptionEventArgs_Name @"NgnSubscriptionEventArgs_Name"

typedef enum NgnSubscriptionEventTypes_e {
	SUBSCRIPTION_OK,
	SUBSCRIPTION_NOK,
	SUBSCRIPTION_INPROGRESS,
	UNSUBSCRIPTION_OK,
	UNSUBSCRIPTION_NOK,
	UNSUBSCRIPTION_INPROGRESS,
	INCOMING_NOTIFY
}
NgnSubscriptionEventTypes_t;

@interface NgnSubscriptionEventArgs : NgnEventArgs {
	long sessionId;
	NgnSubscriptionEventTypes_t eventType;
	short sipCode;
    NSString *sipPhrase;
    NSData  *content;
    NSString *contentType;
    NgnEventPackageType_t eventPackage;
}

-(NgnSubscriptionEventArgs*) initWithSessionId:(long)sessionId 
		andEventType:(NgnSubscriptionEventTypes_t)eventType 
		andSipCode:(short)sipCode
		andSipPhrase:(NSString*)sipPhrase 
		andContent:(NSData*)content 
		andContentType:(NSString*)contentType 
		andEventPackage:(NgnEventPackageType_t)eventPackage;

-(NgnSubscriptionEventArgs*) initWithSessionId:(long)sessionId 
		andEventType:(NgnSubscriptionEventTypes_t)eventType 
		andSipCode:(short)sipCode
		andSipPhrase:(NSString*)sipPhrase 
		andEventPackage:(NgnEventPackageType_t)eventPackage;

@property(readonly) long sessionId;
@property(readonly) NgnSubscriptionEventTypes_t eventType;
@property(readonly) short sipCode;
@property(readonly) NSString* sipPhrase;
@property(readonly) NSData  *content;
@property(readonly) NSString *contentType;
@property(readonly) NgnEventPackageType_t eventPackage;

@end
