//
//  AreaOfPhoneNumber.h
//  CloudCall
//
//  Created by Sergio on 13-4-15.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDB/FMDatabase.h"

@interface AreaOfPhoneNumber : NSObject
{
    NSString *phoneNumber;
}

- (AreaOfPhoneNumber *)initWithPhoneNumber:(NSString *)_phoneNumber;
- (NSString *)getAreaByPhoneNumber;
@end
