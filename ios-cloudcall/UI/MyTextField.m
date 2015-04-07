//
//  MyTextField.m
//  CloudCall
//
//  Created by Dan on 14-1-21.
//  Copyright (c) 2014年 CloudTech. All rights reserved.
//

#import "MyTextField.h"

@implementation MyTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 0, 3.5);
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [[UIColor colorWithRed:130./255. green:140./255. blue:150./255. alpha:1] setFill];
    [[self placeholder] drawInRect:rect withFont:[UIFont systemFontOfSize:12.0f]];
}

@end
