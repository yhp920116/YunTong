//
//  Information.h
//  CloudCall
//
//  Created by Dan on 14-1-17.
//  Copyright (c) 2014年 CloudTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Information : NSManagedObject

@property (nonatomic, retain) NSString * account_birthdate;
@property (nonatomic, retain) NSString * account_email;
@property (nonatomic, retain) NSString * account_gender;
@property (nonatomic, retain) NSNumber * account_level;
@property (nonatomic, retain) NSString * account_localnum;
@property (nonatomic, retain) NSString * account_name;
@property (nonatomic, retain) NSString * account_nickname;
@property (nonatomic, retain) NSString * account_qq;
@property (nonatomic, retain) NSString * account_referee;
@property (nonatomic, retain) NSString * account_sinaweibo;
@property (nonatomic, retain) NSString * identity_display_name;
@property (nonatomic, retain) NSString * identity_impi;
@property (nonatomic, retain) NSString * identity_impu;
@property (nonatomic, retain) NSString * identity_password;
@property (nonatomic, retain) NSData * account_thumbnail;

@end
