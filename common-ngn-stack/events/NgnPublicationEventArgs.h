
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"

#define kNgnPublicationEventArgs_Name @"NgnPublicationEventArgs_Name"

typedef enum NgnPublicationEventTypes_e {
	PUBLICATION_OK,
	PUBLICATION_NOK,
	PUBLICATION_INPROGRESS,
    UNPUBLICATION_OK,
    UNPUBLICATION_NOK,
    UNPUBLICATION_INPROGRESS
}
NgnPublicationEventTypes_t;

@interface NgnPublicationEventArgs : NgnEventArgs {
	long sessionId;
	NgnPublicationEventTypes_t eventType;
	short sipCode;
    NSString *sipPhrase;
}

-(NgnPublicationEventArgs*) initWithSessionId:(long)sessionId 
									andEventType:(NgnPublicationEventTypes_t)eventType 
									andSipCode:(short)sipCode
									andSipPhrase:(NSString*)sipPhrase;


@property(readonly) long sessionId;
@property(readonly) NgnPublicationEventTypes_t eventType;
@property(readonly) short sipCode;
@property(readonly) NSString* sipPhrase;

@end
