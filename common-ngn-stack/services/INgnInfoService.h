//
//  INgnInfoService.h
//  ios-ngn-stack
//
//  Created by Dan on 14-1-10.
//  Copyright (c) 2014年 SkyBroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INgnBaseService.h"
#import "services/impl/InfoService/Information.h"

@protocol INgnInfoService <INgnBaseService>

@required
- (void)saveContext;
- (Information *)getInfo;

@optional
- (void)setInfoValue:(id)value forKey:(NSString *)key;
- (id)getInfoValueForkey:(NSString *)key;
- (void)setInfoValueWithEncrypt:(NSString *)value forKey:(NSString *)key;
- (NSString *)getInfoValueForkeyWithDecrypt:(NSString *)key;
@end
