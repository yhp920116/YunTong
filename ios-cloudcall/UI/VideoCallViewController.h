/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>

#import "CallViewController.h"

@interface VideoCallViewController : CallViewController {
	UIImageView *imageViewRemoteVideo;
	UIView *viewLocalVideo;
    
    UILabel *labelPrompt;
	
	UIView *viewTop;
	UILabel *labelRemoteParty;
	UILabel *labelStatus;
	
	UIView *viewToolbar;
	UIButton *buttonToolBarMute;
	UIButton *buttonToolBarEnd;
	UIButton *buttonToolBarToggle;
	UIButton *buttonToolBarVideo;
	
	UIView *viewPickHangUp;
	UIButton *buttonPick;
	UIButton *buttonHangUp;
	
	NgnAVSession* videoSession;
	BOOL sendingVideo;
}

@property (retain, nonatomic) IBOutlet UIImageView* imageViewRemoteVideo;
@property (retain, nonatomic) IBOutlet UIView* viewLocalVideo;

@property (retain, nonatomic) IBOutlet UILabel* labelPrompt;

@property (retain, nonatomic) IBOutlet UIView* viewTop;
@property (retain, nonatomic) IBOutlet UILabel *labelRemoteParty;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;

@property (retain, nonatomic) IBOutlet UIView* viewToolbar;
@property (retain, nonatomic) IBOutlet UIButton *buttonToolBarMute;
@property (retain, nonatomic) IBOutlet UIButton *buttonToolBarEnd;
@property (retain, nonatomic) IBOutlet UIButton *buttonToolBarToggle;
@property (retain, nonatomic) IBOutlet UIButton *buttonToolBarVideo;

@property (retain, nonatomic) IBOutlet UIView *viewPickHangUp;
@property (retain, nonatomic) IBOutlet UIButton *buttonPick;
@property (retain, nonatomic) IBOutlet UIButton *buttonHangUp;

- (IBAction) onButtonClick: (id)sender;

@end
