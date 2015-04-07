//
//  CCSqliteHelper.h
//  CloudCall
//
//  Created by Sergio on 13-8-14.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

#pragma mark - Model

#pragma mark - IMServerConfigInfo
#define kIMServerConfigInfoTable        @"IMServerConfigInfo"
#define kIMServerConfigInfoColAddress   @"address"
#define kIMServerConfigInfoColXmppPort  @"xmpp_port"
#define kIMServerConfigInfoColHttpPort  @"http_port"
#define kIMServerConfigInfoColEnable    @"enable"

@interface IMServerConfigInfo : NSObject
{
    NSString *address;
    int xmpp_port;
    int http_port;
    int enable;
}

@property (nonatomic, retain) NSString *address;
@property (nonatomic, assign) int xmpp_port;
@property (nonatomic, assign) int http_port;
@property (nonatomic, assign) int enable;

- (IMServerConfigInfo *)initWithAddress:(NSString *)_address andXmppPort:(int)_xmppport andHttpPort:(int)_httpport andEnable:(int)_enable;

@end

@interface CCSqliteHelper : NSObject
//Common
- (NSString *)getDocumentDirectoryPath;
- (NSString *)getCachesDirectoryPath;
- (FMDatabase *)getFMDBOfDefault;

#pragma mark - IMServerConfigInfo
- (void)createIMServerConfigInfoTable;
- (void)deleteAllRecordFromIMServerConfigInfo;
- (void)addIMServerInfo:(NSMutableArray *)imServerInfoArray;

@end
