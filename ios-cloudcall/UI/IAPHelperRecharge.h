//
//  InAppWeiCallIAPHelper.h
//  WeiCall
//
//  Created by guobiao chen on 12-4-16.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import "IAPHelper.h"

@interface IAPHelperRecharge : IAPHelper

+(IAPHelperRecharge *)sharedInstance;
-(void)requestProducts:(NSSet*)productIdentifiers;


@end
