//
//  UIBubbleHeaderTableViewCell.m
//  UIBubbleTableViewExample
//
//  Created by Александр Баринов on 10/7/12.
//  Copyright (c) 2012 Stex Group. All rights reserved.
//

#import "UIBubbleHeaderTableViewCell.h"
#import "StaticUtils.h"

@interface UIBubbleHeaderTableViewCell ()

@property (nonatomic, retain) UILabel *label;

@end

@implementation UIBubbleHeaderTableViewCell

@synthesize label = _label;
@synthesize date = _date;

+ (CGFloat)height
{
    return 26.0;
}

- (void)setDate:(NSDate *)value
{
    self.backgroundColor = [UIColor clearColor];
    NSString *text = [StaticUtils transformIMChatViewDate:value];
    
    if (self.label)
    {
        self.label.text = text;
        return;
    }
    
    UIFont *font = [UIFont systemFontOfSize:12];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(220, 100) lineBreakMode:NSLineBreakByWordWrapping];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.label = [[[UILabel alloc] initWithFrame:CGRectMake((320-size.width+10)/2, 4, size.width+10, 22)] autorelease];
    self.label.text = text;
    self.label.font = font;
    self.label.textAlignment = NSTextAlignmentCenter;
//    self.label.shadowOffset = CGSizeMake(0, 1);
//    self.label.shadowColor = [UIColor grayColor];
    self.label.textColor = [UIColor whiteColor];
    self.label.backgroundColor = [UIColor clearColor];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.label.frame];
    imageView.image = [[UIImage imageNamed:@"time_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    [self addSubview:imageView];
    [imageView release];
    
    [self addSubview:self.label];
}

- (void)dealloc
{
    [_label release];
    [super dealloc];
}

@end
