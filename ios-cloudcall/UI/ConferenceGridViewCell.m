//
//  ConferenceGridViewCell.m
//  CloudCall
//
//  Created by CloudCall on 13-1-29.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import "ConferenceGridViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ConferenceGridViewCell
@synthesize headPortrait;
@synthesize name;
@synthesize phoneNumber;
@synthesize buttonAction;
@synthesize selectedImage;
@synthesize callingStatus;

@synthesize number;
@synthesize buttonIsAdd;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"ConferenceGridViewCell" owner:self options:nil];
		
        UIView *viewCell = [views objectAtIndex:0];
        viewCell.layer.masksToBounds = YES;
//        viewCell.layer.cornerRadius = 4;
        viewCell.layer.borderWidth = 1;
        viewCell.layer.borderColor = [UIColor lightGrayColor].CGColor;

        [self addSubview:viewCell];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) SetDelegate:(UIViewController<ConferenceGridViewCellDelegate> *)_delegate {
    delegate = _delegate;
}

- (IBAction) onButtonClick: (id)sender{
    if (sender == buttonAction) {
        if (delegate) {
            [delegate shouldContinueAfterParticipantCellClick:number andIsAdd:buttonIsAdd];
        }
    }
}

- (void)dealloc
{
    [super dealloc];
    
    [headPortrait release];
    [name release];
    [phoneNumber release];
    [callingStatus release];
    [selectedImage release];
    [callingStatus release];
    
    [number release];
}
@end
