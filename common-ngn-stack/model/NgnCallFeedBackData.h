//
//  NgnCallFeedBack.h
//  ios-ngn-stack
//
//  Created by Sergio on 13-2-18.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//
#if TARGET_OS_IPHONE
#	import <Foundation/Foundation.h>
#elif TARGET_OS_MAC
#endif

@interface NgnCallFeedBackData : NSObject
{
    int myid;
    NSString *data;
    int flag;
}

@property(readwrite) int myid;
@property(readonly) NSString *data;
@property(readonly) int flag;

- (NgnCallFeedBackData *)initWithId:(int)id andData:(NSString *)data andFlag:(int)flag;
@end
