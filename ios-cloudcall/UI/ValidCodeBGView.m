//
//  ValidCodeBGView.m
//  CloudCall
//
//  Created by Sergio on 13-1-24.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import "ValidCodeBGView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ValidCodeBGView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)sharePoints:(NSMutableArray *)arrayPoint
{
    array=arrayPoint;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor]CGColor]);
    for(int cout = 0; cout <array.count ; cout++)
    {
        CGPoint point1 =  [[array objectAtIndex:cout]CGPointValue];
        CGPoint point2 = [[array objectAtIndex:cout+1]CGPointValue];
        CGContextMoveToPoint(context, point1.x, point1.y);
        CGContextAddLineToPoint(context,point2.x,point2.y);
        CGContextStrokePath(context);
        cout ++;
        
    }
    
}


@end
