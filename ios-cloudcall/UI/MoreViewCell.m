//
//  MoreViewCell.m
//  CloudCall
//
//  Created by CloudCall on 13-1-29.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import "MoreViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MoreViewCell
@synthesize labelName;
@synthesize buttonAction;

- (id)initWithFrame:(CGRect)frame withButtonTag:(NSInteger)tag withBtnNormalImage:(UIImage *)imageNormal withBtnPressImage:(UIImage *)imagePress withLabelName:(NSString *)name
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.buttonAction = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonAction.frame = CGRectMake(10, 0, 50, 50);
        buttonAction.tag = tag;
        if (imageNormal)
            [buttonAction setImage:imageNormal forState:UIControlStateNormal];
        if (imagePress)
            [buttonAction setImage:imagePress forState:UIControlStateHighlighted];
        [buttonAction addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonAction];
        
        self.labelName = [[[UILabel alloc] initWithFrame:CGRectMake(2, 53, 66, 28)] autorelease];
        [labelName setTextAlignment:NSTextAlignmentCenter];
        labelName.font = [UIFont systemFontOfSize:11.0f];
        labelName.lineBreakMode = UILineBreakModeCharacterWrap;
        labelName.numberOfLines = 0;
        labelName.text = name;
        labelName.backgroundColor = [UIColor clearColor];
        [self addSubview:labelName];
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

-(void) SetDelegate:(UIViewController<MoreViewCellDelegate> *)_delegate {
    delegate = _delegate;
}

- (IBAction) onButtonClick: (id)sender{
    UIButton *Btn = (UIButton *)sender;
    if (delegate) {
        [delegate buttonClickCallBack:Btn.tag];
    }
}

- (void)dealloc
{
    [super dealloc];
    
    [labelName release];
    [buttonAction release];

}
@end
