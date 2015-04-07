/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "ParticipantCell.h"

@implementation ParticipantCell

@synthesize labelName;
@synthesize labelNumber;
@synthesize labelStatus;
@synthesize buttonAction;
@synthesize number;
@synthesize buttonIsAdd;

-(NSString *)reuseIdentifier{
	return kParticipantCellIdentifier;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {    
    [super setSelected:selected animated:animated];    
    // Configure the view for the selected state.
}

- (void)dealloc {
	[labelName release];
    [labelNumber release];
    [labelStatus release];
    [number release];
	
    [super dealloc];
}

-(void) SetDelegate:(UIViewController<ParticipantCellDelegate> *)_delegate {
    delegate = _delegate;
}

- (IBAction) onButtonClick: (id)sender{
    if (sender == buttonAction) {
        if (delegate) {
            [delegate shouldContinueAfterParticipantCellClick:number andIsAdd:buttonIsAdd];
        }
    }
}

@end
