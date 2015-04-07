//
//  CCSqliteHelper.m
//  CloudCall
//
//  Created by Sergio on 13-8-14.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "CCSqliteHelper.h"

#pragma mark - Model

#pragma mark - IMServerConfigInfo
@implementation IMServerConfigInfo
@synthesize address;
@synthesize xmpp_port;
@synthesize http_port;
@synthesize enable;

- (IMServerConfigInfo *)initWithAddress:(NSString *)_address andXmppPort:(int)_xmppport andHttpPort:(int)_httpport andEnable:(int)_enable
{
    if (self = [super init])
    {
        self.address = _address;
        self.xmpp_port = _xmppport;
        self.http_port = _httpport;
        self.enable = _enable;
    }
    
    return self;
}

- (void)dealloc
{
    [address release];
    [super dealloc];
}

@end

#pragma mark - DBManager
@implementation CCSqliteHelper
/**
 *	@brief	获取Document路径
 */
- (NSString *)getDocumentDirectoryPath
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [pathArray objectAtIndex:0];
    
    return documentPath;
}

/**
 *	@brief	获取Caches路径
 */
- (NSString *)getCachesDirectoryPath
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = [pathArray objectAtIndex:0];
    
    return cachesPath;
}

/**
 *	@brief	获取DataBase.db
 */
- (FMDatabase *)getFMDBOfDefault
{
    NSString *dbPath = [[self getDocumentDirectoryPath] stringByAppendingPathComponent:kDefaultDB];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    return db;
}

#pragma mark - IMServerConfigInfo
/**
 *	@brief	创建服务器配置信息表
 */
- (void)createIMServerConfigInfoTable
{
    // 创建消息记录表
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@ (%@ text, %@ integer, %@ integer, %@ integer)", kIMServerConfigInfoTable, kIMServerConfigInfoColAddress, kIMServerConfigInfoColXmppPort, kIMServerConfigInfoColHttpPort, kIMServerConfigInfoColEnable];
    
    FMDatabase *db = [self getFMDBOfDefault];
    
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    [db executeUpdate:createTableSql];
    
    if ([db hadError])
    {
        NSLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	删除IM服务器配置表所有信息
 */
- (void)deleteAllRecordFromIMServerConfigInfo
{
    FMDatabase *db = [self getFMDBOfDefault];
    if (![db open]) {
        NSLog(@"Open database failed");
    }
    
    NSString *delSql = [NSString stringWithFormat:@"delete from %@", kIMServerConfigInfoTable];
    
    BOOL success = [db executeUpdate:delSql];
    
    if (!success || [db hadError])
    {
        NSLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	增加服务器信息
 *
 *	@param 	imServerInfoArray 	服务器列表
 */
- (void)addIMServerInfo:(NSMutableArray *)imServerInfoArray
{
    FMDatabase *db = [self getFMDBOfDefault];
    if (![db open]) {
        NSLog(@"Open database failed");
    }
    
    //批量add
    for (IMServerConfigInfo *imServerInfo in imServerInfoArray)
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"insert into %@ values('%@', %d, %d, %d)", kIMServerConfigInfoTable, imServerInfo.address, imServerInfo.xmpp_port, imServerInfo.http_port, imServerInfo.enable];
        
        [db executeUpdate:sql];
        [sql release];
    }
    
    if ([db hadError])
    {
        NSLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

@end
