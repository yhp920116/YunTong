
/* Vincent, GZ, 2012-03-07 */

#import "media/NgnMediaType.h"

typedef	NSMutableArray NgnHistoryEventMutableArray;
typedef NSArray	NgnHistoryEventArray;
typedef	NSMutableDictionary NgnHistoryEventMutableDictionary;
typedef	NSDictionary NgnHistoryEventDictionary;

@class NgnHistoryAVCallEvent;
@class NgnHistorySMSEvent;

typedef enum HistoryEventStatus_e{
	HistoryEventStatus_Outgoing = 0x01<<0,
	HistoryEventStatus_Incoming = 0x01<<1,
	HistoryEventStatus_Missed = 0x01<<2,
	HistoryEventStatus_Failed = 0x01<<3,
	
	HistoryEventStatus_All = (HistoryEventStatus_Outgoing | HistoryEventStatus_Incoming | HistoryEventStatus_Missed | HistoryEventStatus_Failed)
}
HistoryEventStatus_t;

enum CALL_OUT_MODE {
    CALL_OUT_MODE_NONE,
    CALL_OUT_MODE_INNER, // 云通好友通话
    CALL_OUT_MODE_LNAD, // 直拨
    CALL_OUT_MODE_CALL_BACK // 回拨
};

@interface NgnHistoryEvent : NSObject {
	long long id;
	NgnMediaType_t mediaType;
	NSTimeInterval start;
	NSTimeInterval end;
	NSString* remoteParty;
	NSString* remotePartyDisplayName;
    NSString* remoteNumType;
	BOOL seen;
	HistoryEventStatus_t status;
    CALL_OUT_MODE cloudcallmode;
}

@property(readwrite)long long id;
@property(readwrite)NgnMediaType_t mediaType;
@property(readwrite)NSTimeInterval start;
@property(readwrite)NSTimeInterval end;
@property(readonly)NSString* remotePartyDisplayName;
@property(readwrite,retain)NSString* remoteParty;
@property(readwrite)BOOL seen;
@property(readwrite)HistoryEventStatus_t status;
@property(readwrite)CALL_OUT_MODE calloutmode;
@property(readonly)NSString* remoteNumType;

-(NgnHistoryEvent*) initWithMediaType: (NgnMediaType_t)type andRemoteParty:(NSString*)remoteParty andCalloutMode:(CALL_OUT_MODE)mode;
-(void) setRemotePartyWithValidUri:(NSString *)uri;
-(NSComparisonResult)compare:(NgnHistoryEvent *)otherEvent;
-(NSComparisonResult)compareHistoryEventByDateASC:(NgnHistoryEvent *)otherEvent;
-(NSComparisonResult)compareHistoryEventByDateDESC:(NgnHistoryEvent *)otherEvent;

+(NgnHistoryAVCallEvent*)createAudioVideoEventWithRemoteParty: (NSString*)remoteParty andVideo:(BOOL)video andCalloutMode:(CALL_OUT_MODE)mode;
+(NgnHistorySMSEvent*)createSMSEventWithStatus:(HistoryEventStatus_t) status andRemoteParty:(NSString*)remoteParty;
+(NgnHistorySMSEvent*)createSMSEventWithStatus:(HistoryEventStatus_t) status andRemoteParty:(NSString*)remoteParty andContent:(NSData*)content;

@end
