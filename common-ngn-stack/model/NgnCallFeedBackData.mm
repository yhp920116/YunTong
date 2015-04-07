//
//  NgnCallFeedBack.m
//  ios-ngn-stack
//
//  Created by Sergio on 13-2-18.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//
#import "NgnCallFeedBackData.h"
#import "NgnEngine.h"

@implementation NgnCallFeedBackData
@synthesize myid;
@synthesize data;
@synthesize flag;

- (NgnCallFeedBackData *)initWithId:(int)_id andData:(NSString *)_data andFlag:(int)_flag
{
    if(self = [super init])
    {
        self->myid = _id;
        self->data = [_data retain];
        self->flag = _flag;
    }
    return self;
}

- (void)dealloc
{
    [data release];
    [super dealloc];
}

@end
