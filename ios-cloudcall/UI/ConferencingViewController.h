//
//  ConferencingViewController.h
//  CloudCall
//
//  Created by CloudCall on 13-2-20.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConferenceViewController.h"
#import "ConferenceGridViewCell.h"

//ParticipantCellDelegate
@interface ConferencingViewController : ConferenceViewController<ConferenceGridViewCellDelegate>
{
    int participantsTalkingCount;
@private
    NSMutableArray* participantsCall;
    CONF_MEMBER_STATUS mynumstatus;

    UIAlertView *alertProcess;
    BOOL alertShow;
    unsigned int confId;
    CTCallCenter *callcenter;
    
    CFSocketRef _socket;
    CGFloat viewoffset;
    CGFloat viewKeysHeight;
    
    CellPhoneCallState cpcallstate;
}

@property (nonatomic, retain) NSMutableArray* participantsCall;

- (void)updateTitleText;
- (void)back;

@end
