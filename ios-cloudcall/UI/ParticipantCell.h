/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kParticipantCellIdentifier
#define kParticipantCellIdentifier	@"ParticipantCellIdentifier"

@protocol ParticipantCellDelegate <NSObject>
-(void) shouldContinueAfterParticipantCellClick:(NSString*)number andIsAdd:(BOOL)add;
@end

@interface ParticipantCell : UITableViewCell {
	UILabel *labelName;
	UILabel *labelNumber;
	UILabel *labelStatus;
    UIButton *buttonAction;
    
    BOOL buttonIsAdd;
    
    NSString* number;
    
    UIViewController<ParticipantCellDelegate> *delegate;
}

@property (retain, nonatomic) IBOutlet UILabel *labelName;
@property (retain, nonatomic) IBOutlet UILabel *labelNumber;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UIButton *buttonAction;

@property (nonatomic, retain) NSString* number;
@property (readwrite) BOOL buttonIsAdd;

@property(nonatomic, readonly, copy) NSString  *reuseIdentifier;
    
-(void) SetDelegate:(UIViewController<ParticipantCellDelegate> *)_delegate;

- (IBAction) onButtonClick: (id)sender;

@end
