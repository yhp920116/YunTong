//
//  ConferenceMember.m
//  CloudCall
//
//  Created by CloudCall on 13-2-19.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import "ConferenceMember.h"

@implementation ConferenceMember

@synthesize participant;
@synthesize status;

+(NSString*) strConfMenberStatus:(CONF_MEMBER_STATUS)status{
    switch (status) {
        case CONF_MEMBER_STATUS_NONE:    return @"";
        case CONF_MEMBER_STATUS_RINGING: return NSLocalizedString(@"Ringing", @"Ringing");
        case CONF_MEMBER_STATUS_QUIT:    return NSLocalizedString(@"Quit", @"Quit");
        case CONF_MEMBER_STATUS_TALKING: return NSLocalizedString(@"Talking", @"Talking");
        case CONF_MEMBER_STATUS_CALLING: return NSLocalizedString(@"Calling", @"Calling");
    }
    return @"";
}

-(ConferenceMember*) initWithParticipant:(ParticipantInfo*) _pi  andStatus:(CONF_MEMBER_STATUS) _status {
    if ((self = [super init])) {
		self->participant = [_pi retain];
		self->status = _status;
	}
	return self;
}

-(void)dealloc{
	[participant release];
    
	[super dealloc];
}


@end
