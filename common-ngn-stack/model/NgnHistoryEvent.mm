
/* Vincent, GZ, 2012-03-07 */

#import "NgnHistoryEvent.h"
#import "NgnHistoryAVCallEvent.h"
#import "NgnHistorySMSEvent.h"
#import "NgnUriUtils.h"
#import "NgnContact.h"
#import "NgnEngine.h"
#import "NgnStringUtils.h"
#import "NSString+Code.h"

@implementation NgnHistoryEvent

@synthesize id;
@synthesize mediaType;
@synthesize start;
@synthesize end;
@synthesize seen;
@synthesize status;
@synthesize remoteParty;
@synthesize calloutmode;

-(NgnHistoryEvent*) initWithMediaType:(NgnMediaType_t)_mediaType andRemoteParty:(NSString*)_remoteParty andCalloutMode:(CALL_OUT_MODE)_mode{
	if((self = [super init])){
		self.mediaType = _mediaType;
		self.remoteParty = _remoteParty;
		
		self.start = [[NSDate date] timeIntervalSince1970];
		self.end = self.start;
		self.status = HistoryEventStatus_Missed;
        self.calloutmode = _mode;
	}
	return self;
}

-(NSString*)remotePartyDisplayName{
	if(self->remotePartyDisplayName != nil)
        [self->remotePartyDisplayName release];
    NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:self.remoteParty];
    if(contact && contact.displayName){
        self->remotePartyDisplayName = [contact.displayName retain];
    }
    else if(self.remoteParty){
        self->remotePartyDisplayName = [self.remoteParty retain];
    }
    else {
        self->remotePartyDisplayName = [@"(null)" retain];
    }
	return self->remotePartyDisplayName;
}

-(NSString*)remoteNumType{
	if (self->remoteNumType != nil)
        [self->remoteNumType release];
    //NSLog(@"remoteNumType %@\n", self.remoteParty);
    NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:self.remoteParty];
    if (contact) {
        for (NgnPhoneNumber*phoneNumber in contact.phoneNumbers) {            
            if (phoneNumber && phoneNumber.number) {                
                NSString* tmpPhoneNum = [phoneNumber.number phoneNumFormat];
            
                if ([tmpPhoneNum isEqualToString:self.remoteParty]) {
                    self->remoteNumType = [phoneNumber.description retain];            
                    return self->remoteNumType;
                }
            }
        }
    }
	return [@"" retain];;
}

-(void)setRemotePartyWithValidUri:(NSString *)uri{
	[self->remoteParty release];
#if 1
    NSString* rnum = [NgnUriUtils getUserName:uri];
    if (rnum) {
        if (HistoryEventStatus_Outgoing == status) {
            NSString* nrnum = [rnum substringFromIndex:2];
            self->remoteParty = [nrnum retain];
        } else {
            self->remoteParty = [rnum retain];
        }
    } else {
        self->remoteParty = [uri retain];
    }
#else
	if(!(self->remoteParty = [[NgnUriUtils getUserName:uri] retain])){
		self->remoteParty = [uri retain];
	}
#endif
}

- (NSComparisonResult)compare:(NgnHistoryEvent *)otherEvent{
	long long diff = self.id - otherEvent.id;
	return diff==0 ? NSOrderedSame : (diff > 0 ? NSOrderedAscending : NSOrderedDescending);
}

-(NSComparisonResult)compareHistoryEventByDateASC:(NgnHistoryEvent *)otherEvent{
	NSTimeInterval diff = self.start - otherEvent.start;
	return diff==0 ? NSOrderedSame : (diff > 0 ? NSOrderedAscending : NSOrderedDescending);
}

-(NSComparisonResult)compareHistoryEventByDateDESC:(NgnHistoryEvent *)otherEvent{
	NSTimeInterval diff = self.start - otherEvent.start;
	return diff==0 ? NSOrderedSame : (diff > 0 ? NSOrderedDescending : NSOrderedAscending);
}

+(NgnHistoryAVCallEvent*) createAudioVideoEventWithRemoteParty:(NSString*)_remoteParty andVideo:(BOOL)video andCalloutMode:(CALL_OUT_MODE)mode{
	NgnHistoryAVCallEvent* event = [[[NgnHistoryAVCallEvent alloc] init:video withRemoteParty:_remoteParty andCalloutMode:mode] autorelease];
	return event;
}

+(NgnHistorySMSEvent*) createSMSEventWithStatus: (HistoryEventStatus_t) _status andRemoteParty:(NSString*)_remoteParty{
	return [NgnHistoryEvent createSMSEventWithStatus:_status andRemoteParty:_remoteParty andContent:nil];
}

+(NgnHistorySMSEvent*) createSMSEventWithStatus: (HistoryEventStatus_t) _status andRemoteParty:(NSString*)_remoteParty andContent: (NSData*)_content{
    
    NSString* tmprp = [_remoteParty phoneNumFormat];
    
	NgnHistorySMSEvent* event = [[[NgnHistorySMSEvent alloc] initWithStatus:_status andRemoteParty:tmprp andContent:_content] autorelease];
	return event;
}

-(void)dealloc{
	[self->remoteParty release];
	[self->remotePartyDisplayName release];
	
	[super dealloc];
}

@end
