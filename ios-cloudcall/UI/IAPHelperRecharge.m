//
//  InAppWeiCallIAPHelper.m
//  WeiCall
//
//  Created by guobiao chen on 12-4-16.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import "IAPHelperRecharge.h"

static IAPHelperRecharge *_sharedInstace;

@implementation IAPHelperRecharge

+(IAPHelperRecharge *)sharedInstance{
    if (_sharedInstace != nil)
        return _sharedInstace;
    _sharedInstace = [[IAPHelperRecharge alloc] init];
    [_sharedInstace SetObserver];
    return _sharedInstace;
}

-(id)init{
    return self;
}

-(void)initProduct{
//
//    NSSet *productIdentifiers=[NSSet setWithObjects:
//                               @"TestConRate1",
//                               @"TestUnConRate2",
//                               nil];
#if 0
    NSSet *productIdentifiers=[NSSet setWithObjects:
                                   @"cloudtechcloudcalliosrate1",
                                   nil];
    if (self = [super initWithProductIdentifiers:productIdentifiers]) {
    }
#else
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"RechargeId" ofType:@"plist"];
#if TARGET_OS_IPHONE
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"cc"];
#endif
    NSString *path = [documentsDir stringByAppendingPathComponent:@"RechargeIds.plist"];
    //CCLog(@"initProduct: path=%@", path);
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!dict)
        return;
    NSArray *array = [dict objectForKey:@"ProductID"];
    if (!array)
        return;
    //CCLog(@"initProduct: count=%d", [array count]);
//    for (NSString* str in array) {
//        CCLog(@"initProduct: %@", str);
//    }
    NSSet *productIdentifiers = [NSSet setWithArray:array];
    [self initWithProductIdentifiers:productIdentifiers];
    //if (self = [super initWithProductIdentifiers:productIdentifiers]) {
    
    //}
#endif
}


-(void)requestProducts:(NSSet*)productIdentifiers {
    [self initWithProductIdentifiers:productIdentifiers];
    [super requestProducts];
}


@end
