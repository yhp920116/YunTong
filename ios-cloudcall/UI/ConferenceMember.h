//
//  ConferenceMember.h
//  CloudCall
//
//  Created by CloudCall on 13-2-19.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectParticipantViewController.h"

typedef enum {
    CONF_MEMBER_STATUS_NONE,
    CONF_MEMBER_STATUS_TALKING,
    CONF_MEMBER_STATUS_QUIT,
    CONF_MEMBER_STATUS_RINGING,
    CONF_MEMBER_STATUS_CALLING
} CONF_MEMBER_STATUS;

@interface ConferenceMember : NSObject
{
    ParticipantInfo* participant;
    CONF_MEMBER_STATUS status;
}

-(ConferenceMember*) initWithParticipant:(ParticipantInfo*) pi andStatus:(CONF_MEMBER_STATUS) status;
+(NSString*) strConfMenberStatus:(CONF_MEMBER_STATUS)status;

@property(nonatomic,retain) ParticipantInfo *participant;
@property(readwrite) CONF_MEMBER_STATUS status;

@end
