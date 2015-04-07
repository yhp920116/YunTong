//
//  ToolsView.m
//  CloudCall
//
//  Created by Sergio on 13-7-22.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "ToolsView.h"

@implementation ToolsView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"im_toolview_bg.png"]]];
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
- (void)loadToolsView
{
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageButton setFrame:CGRectMake(10, 8, 51, 51)];
    imageButton.tag = 1121;
    [imageButton setBackgroundImage:[UIImage imageNamed:@"btn_imimage_up.png"] forState:UIControlStateNormal];
    [imageButton setBackgroundImage:[UIImage imageNamed:@"btn_imimage_down.png"] forState:UIControlStateHighlighted];
    [imageButton setTitle:@"图片" forState:UIControlStateNormal];
    imageButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [imageButton setTitleEdgeInsets:UIEdgeInsetsMake(54, 0, -16, 0)];
    [imageButton addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneButton setFrame:CGRectMake(75, 8, 51, 51)];
    phoneButton.tag = 1122;
    [phoneButton setBackgroundImage:[UIImage imageNamed:@"btn_imphone_up.png"] forState:UIControlStateNormal];
    [phoneButton setBackgroundImage:[UIImage imageNamed:@"btn_imphone_down.png"] forState:UIControlStateHighlighted];
    [phoneButton setTitle:@"免费电话" forState:UIControlStateNormal];
    phoneButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [phoneButton setTitleEdgeInsets:UIEdgeInsetsMake(54, 0, -16, 0)];
    [phoneButton addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:imageButton];
    [self addSubview:phoneButton];
}

- (void)onButtonClick:(UIButton *)button
{
    ToolsViewButtonType btnType  = ToolsViewButtonTypeImage;
    
    if (button.tag == 1121)             //图片按钮
        btnType = ToolsViewButtonTypeImage;
    else if(button.tag == 1122)         //电话按钮
        btnType = ToolsViewButtonTypePhone;
    
    if ([delegate respondsToSelector:@selector(selectedTools:)])
        [delegate selectedTools:btnType];
}

@end
