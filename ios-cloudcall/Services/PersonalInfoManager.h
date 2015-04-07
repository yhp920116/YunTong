//
//  PersonalInfoManager.h
//  CloudCall
//
//  Created by Sergio on 13-4-18.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequest.h"

@interface PersonalInfoManager : NSObject

- (void)getPersonalInfoFromServer;
- (void)getPersonalInfoSucceeded:(NSData *)data;
- (void)getPersonalInfoFailed:(NSError *)error;
- (void)setPersonalInfo:(NSMutableDictionary *)personalInfoDictFormServer;

@end
