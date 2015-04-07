//
//  AreaOfPhoneNumber.m
//  CloudCall
//
//  Created by Sergio on 13-4-15.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AreaOfPhoneNumber.h"
#import "CloudCall2AppDelegate.h"
#import "RegexKitLite.h"

@implementation AreaOfPhoneNumber

- (AreaOfPhoneNumber *)initWithPhoneNumber:(NSString *)_phoneNumber;
{
    if ((self = [super init]))
    {
        NSString * newNum = [_phoneNumber phoneNumFormat];
        self->phoneNumber = [newNum retain];
	}
	return self;
}

- (FMDatabase *)getManageDB
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    NSString *dbPath = [path stringByAppendingPathComponent:kAreaOfPhoneNumberDB];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    return db;
}

- (NSString *)query
{
    NSString *result = @"";
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    //特殊电话
    if([phoneNumber hasPrefix:@"4"] || [phoneNumber hasPrefix:@"8"] || [phoneNumber hasPrefix:@"+"] || [phoneNumber hasPrefix:@"008"])
    {
        if ([phoneNumber hasPrefix:@"400"])
            result = @"400电话";
        else if ([phoneNumber hasPrefix:@"800"])
            result = @"800电话";
        else if([phoneNumber hasPrefix:@"+886"] || [phoneNumber hasPrefix:@"00886"])
            result = @"中国台湾";
        else if([phoneNumber hasPrefix:@"+852"] || [phoneNumber hasPrefix:@"00852"])
            result = @"中国香港";
        else if([phoneNumber hasPrefix:@"+853"] || [phoneNumber hasPrefix:@"00853"])
            result = @"中国澳门";
    }
    else if ([phoneNumber hasPrefix:@"0"] && [phoneNumber length] >= 3) //是否固话
    {
        int secondNum = [[self getSecondNumber] intValue];
        NSString *code;
        
        if (secondNum >= 3 && [phoneNumber length] >= 4)
            code = [self getTopFourNumber];
        else if(secondNum >= 3 && [phoneNumber length] == 3)
            code = nil;
        else
            code = [self getTopThreeNumber];
        
        if (code)
        {
            NSString *sql = [NSString stringWithFormat:@"select province,city from TB_TELAREA where code = %@",code];
            
            //CCLog(@"--- sql1: %@ ---",sql);
            
            FMResultSet *dbresult = [db executeQuery:sql];
            
            NSString *province,*city;
            if([dbresult next])
            {
                NSString *province = [dbresult stringForColumnIndex:0];
                NSString *city = [dbresult stringForColumnIndex:1];
                
                if ([province length] && [city length])
                {
                    if ([province isEqualToString:city])
                        city = @"";
                    
                    result = [NSString stringWithFormat:@"%@%@",province,city];
                }
            }
        }
    }
    else if(![phoneNumber hasPrefix:@"0"] && [phoneNumber length] >= 6) //手机
    {
        //根据号码前三位获取查询表名
        NSString *strTableName1 = [NSString stringWithFormat:@"TB_MOB%@F",[self getTopThreeNumber]];
        //NSString *strTableName2 = [NSString stringWithFormat:@"TB_MOB%@",[self getTopThreeNumber]];
        
        //根据号码前六位查询数据
        NSString *code1 = [self getNumberFromFourToSix];
        NSString *sqlToFindBySix = [NSString stringWithFormat:@"select areaid,shopid from %@ where code = '%@' LIMIT 1", strTableName1, code1];
        
        //CCLog(@"--- sql2: %@ ---",sqlToFindBySix);
        
        FMResultSet *dbresult1 = [db executeQuery:sqlToFindBySix];
        
        NSString *areaid = @"";
        NSString *shopid = @"";
        
        if ([dbresult1 next])
        {
            areaid = [dbresult1 stringForColumnIndex:0];
            shopid = [dbresult1 stringForColumnIndex:1];
        }
        else if([phoneNumber length] >= 7)
        {
            //根据号码前七位查询数据
            NSString *strTableName2 = [NSString stringWithFormat:@"TB_MOB%@",[self getTopThreeNumber]];
            NSString *code2 = [self getNumberFromFourToSeven];
            NSString *sqlToFindBySeven = [NSString stringWithFormat:@"select areaid,shopid from %@ where code = '%@' LIMIT 1", strTableName2, code2];
            
            //CCLog(@"--- sql3: %@ ---",sqlToFindBySeven);
            
            FMResultSet *dbresult2 = [db executeQuery:sqlToFindBySeven];
            
            if ([dbresult2 next])
            {
                areaid = [dbresult2 stringForColumnIndex:0];
                shopid = [dbresult2 stringForColumnIndex:1];
            }
        }
        
        
        if ([areaid length] && [shopid length])
        {
            NSString *sqlToFindAreaByAreaid = [NSString stringWithFormat:@"select province,city from TB_AREA where id = %@ LIMIT 1",areaid];
            NSString *sqlToFindAreaByShopid = [NSString stringWithFormat:@"select name from TB_SHOP where id = %@ LIMIT 1",shopid];
            
            //CCLog(@"--- sql4: %@ ---",sqlToFindAreaByAreaid);
            //CCLog(@"--- sql5: %@ ---",sqlToFindAreaByShopid);
            
            FMResultSet *areaResult = [db executeQuery:sqlToFindAreaByAreaid];
            FMResultSet *shopResult = [db executeQuery:sqlToFindAreaByShopid];
            
            if ([areaResult next] && [shopResult next]) {
                NSString *province = [areaResult stringForColumnIndex:0];
                NSString *city = [areaResult stringForColumnIndex:1];
                
                if ([province isEqualToString:city])
                    city = @"";
                
                NSString *shop = [shopResult stringForColumnIndex:0];
                result = [NSString stringWithFormat:@"%@%@%@",province,city,shop];
            }
        }
    }
    
    if ([db hadError])
    {
        //CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
    
    //CCLog(@"---result : %@---",result);
    
    return result;
}

- (NSString *)getSecondNumber
{
    return [phoneNumber substringWithRange:NSMakeRange(1, 1)];
}

- (NSString *)getTopThreeNumber
{
    return [phoneNumber substringWithRange:NSMakeRange(0, 3)];
}

- (NSString *)getTopFourNumber
{
    return [phoneNumber substringWithRange:NSMakeRange(0, 4)];
}

- (NSString *)getNumberFromFourToSix
{
    return [phoneNumber substringWithRange:NSMakeRange(3, 3)];
}

- (NSString *)getNumberFromFourToSeven
{
    return [phoneNumber substringWithRange:NSMakeRange(3, 4)];
}

- (NSString *)getAreaByPhoneNumber
{
    NSString *result = [self query];
    
    return result;
}

-(void) dealloc {
    [phoneNumber release];
    
    [super dealloc];
}

@end
