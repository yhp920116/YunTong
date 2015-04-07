//
//  SqliteHelper.m
//  BossCircleCM
//
//  Created by tenglong zhan on 12-11-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SqliteHelper.h"
#import "CloudCall2AppDelegate.h"

#import <sqlite3.h>

@implementation IMFriendInfo

@synthesize myid;
@synthesize number;
@synthesize time;
@synthesize message;
@synthesize msgType;
@synthesize fileType;
@synthesize contact;
@synthesize unreadnum;
@synthesize msghisid;

-(IMFriendInfo*)initWithID:(int32_t)_id andNumber:(NSString*)num andTime:(NSString*)_time andMessage:(NSString*)msg andMsgType:(int)msgtype andFileType:(int)filetype andMsgHisID:(NSString*)_msghisid;
{
	if ((self = [super init])){
        self->myid    = _id;
        self.number  = num;
        self.time    = _time;
        self.message = msg;
        self->msgType = msgtype;
        self->fileType = filetype;
        self.msghisid = _msghisid;
    }
    return self;
}

-(void)dealloc
{
    [number release];
    [time release];
    [message release];
    [contact release];
    [msghisid release];
    
    [super dealloc];
}

@end

@implementation IMMsgHistory
@synthesize myid;
@synthesize MessageId;
@synthesize Sender;
@synthesize Receiver;
@synthesize Message;
@synthesize MediaURL;
@synthesize OrgMediaURL;
@synthesize AudioDuration;
@synthesize Image;
@synthesize MessageType;
@synthesize FileType;
@synthesize CreateTime;
@synthesize Status;
@synthesize SendStatus;
@synthesize ServerMsgId;
@synthesize MsgReadStatus;

- (IMMsgHistory*)initWithID:(int32_t)_id andMessageId:(NSString*)_msgId andSender:(NSString *)_sender andReceiver:(NSString*)_receiver andMessage:(NSString*)_msg andMediaURL:(NSString *)_mediaURL andOrgMediaURL:(NSString *)_orgMediaURL andAudioDuration:(int)_audioDuration andImage:(NSData *)_image andMsgType:(int)msgtype andFileType:(int)filetype andCreateTime:(NSString *)_createTime andStatus:(int)_status andSendStatus:(IMSendStatus)_sendStatus andServerMsgId:(NSString*)_serverMsgId andMsgReadStatus:(IMMsgReadStatus)_msgReadStatus
{
    if (self = [super init])
    {
        self->myid = _id;
        self.MessageId = _msgId;
        self.Sender = _sender;
        self.Receiver = _receiver;
        self.Message = _msg;
        self.MediaURL = _mediaURL;
        self.OrgMediaURL = _orgMediaURL;
        self.AudioDuration = _audioDuration;
        self.Image = _image;
        self.MessageType = msgtype;
        self.FileType = filetype;
        self.CreateTime = _createTime;
        self.Status = _status;
        self.SendStatus = _sendStatus;
        self.ServerMsgId = _serverMsgId;
        self.MsgReadStatus = _msgReadStatus;
    }
    return self;
}

- (void)dealloc
{
    [MessageId release];
    [Sender release];
    [Receiver release];
    [Message release];
    [MediaURL release];
    [OrgMediaURL release];
    [Image release];
    [CreateTime release];
    [ServerMsgId release];
    
    [super dealloc];
}

@end

@implementation SqliteHelper

-(void)createDatabase
{
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [path objectAtIndex:0];
    NSString *dataBaseDir = [NSString stringWithFormat:@"%@/DataBase/%@", document, username];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dataBaseDir isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:dataBaseDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *databasePath = [dataBaseDir stringByAppendingPathComponent:kDatabaseName];
    
    if(sqlite3_open([databasePath UTF8String], &bossCircleDatabase) != SQLITE_OK)
    {
        //sqlite3_close(bossCircleDatabase);
        NSLog(@"打开数据库失败！ %@", dataBaseDir);
    }
}

-(void)closeDatabase
{
    sqlite3_close(bossCircleDatabase);
}

-(void)createTable:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(bossCircleDatabase, [sql UTF8String], nil, nil, &err) != SQLITE_OK) {
        //sqlite3_close(bossCircleDatabase);
        NSLog(@"创建表失败！");
    }
}

#pragma mark
#pragma mark Friend_Talking
-(BOOL)updateFriendLastTimebyUserId:(NSString *)usernum andLastTime:(NSString*)time andLastMsg:(NSString*)msg andLastMsgType:(int)msgtype andLastFileType:(int)filetype andMsgHisID:(NSString *)_msgHisID
{
    if (!usernum)
        return NO;
    
    BOOL exist = NO;    
    
    NSString *selectSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@='%@'", KFriendsTableName, KFriendsTableColNumber, usernum];
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(bossCircleDatabase, [selectSql UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int count = sqlite3_column_int(stmt, 0);
            if (count) {
                exist = YES;
                break;
            }
        }        
        
        // Finalize and close database.
        sqlite3_finalize(stmt);
    }
    else
    {
        NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        //sqlite3_close(bossCircleDatabase);
        return NO;
    }
    
    if (exist) {
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@='%@', %@='%@', %@=%d, %@=%d, %@='%@' where %@='%@'", KFriendsTableName, KFriendsTableColLastTime, time,
                               KFriendsTableColLastMsg, msg, KFriendsTableColLastMsgType, msgtype, KFriendsTableColLastFileType, filetype, KFriendsTableColMsgHisID, _msgHisID, KFriendsTableColNumber, usernum];
        
        char *err;
        if (sqlite3_exec(bossCircleDatabase, [updateSql UTF8String], nil, nil, &err) != SQLITE_OK)
        {
            //sqlite3_close(bossCircleDatabase);
            NSLog(@"updateFriendLastTimebyUserId failed!");
            return NO;
        }
    } else {
        NSString* sqlString = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@,%@,%@) VALUES(?,?,?,?,?,?)", KFriendsTableName,
                               KFriendsTableColNumber, KFriendsTableColLastTime, KFriendsTableColLastMsg, KFriendsTableColLastMsg, KFriendsTableColLastFileType, KFriendsTableColMsgHisID];
        const char* sqliteQuery = [sqlString UTF8String];
        sqlite3_stmt* statement;
        
        if( sqlite3_prepare_v2(bossCircleDatabase, sqliteQuery, -1, &statement, NULL) == SQLITE_OK )
        {
            sqlite3_bind_text(statement, 1, [usernum UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [time UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [msg UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 4, msgtype);
            sqlite3_bind_int(statement, 5, filetype);
            sqlite3_bind_text(statement, 6, [_msgHisID UTF8String], -1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) != SQLITE_DONE)
            {
                NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        }
    }
    
    return YES;
}

//////////////////////////////////////////////////////////////////////
- (BOOL)selectFriendsRecords:(NSMutableArray*)friendArray
{
    [friendArray removeAllObjects];
    
    sqlite3_stmt *stmt;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC", KFriendsTableName, KFriendsTableColLastTime];
    if(sqlite3_prepare_v2(bossCircleDatabase, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            // ID
            int32_t _id = sqlite3_column_int(stmt, 0);
            // UserNumber
            NSString *userNumber = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
            // LastTime
            NSString *lastTime = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
            // LastMessage
            NSString *message = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
            // LastMsgType
            NSInteger msgType = sqlite3_column_int(stmt, 4);            
            // LastFileType
            NSInteger fileType = sqlite3_column_int(stmt, 5);
            // MsgHisID
            char *charMsgHisID = (char *)sqlite3_column_text(stmt, 6);
            NSString *msgHisID = [[NSString alloc] initWithUTF8String:charMsgHisID];
            
            IMFriendInfo* imfriend = [[[IMFriendInfo alloc] initWithID:_id andNumber:userNumber andTime:lastTime andMessage:message andMsgType:msgType andFileType:fileType andMsgHisID:msgHisID] autorelease];
            [friendArray addObject:imfriend];
            [msgHisID release];
            
            [pool release];
            
        }
        
        // Finalize and close database.
        sqlite3_finalize(stmt);
    }
    else
    {
        
        NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        //sqlite3_close(bossCircleDatabase);
        return NO;
    }
    
    return YES;
}

// 查找消息ID为_msgHisID的好友列表信息
- (NSInteger)selectCountFromFriendByMsgHisID:(NSString *)_msgHisID
{
    NSInteger count = 0;
    
    NSString *selectSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = \"%@\"", KFriendsTableName, KFriendsTableColMsgHisID, _msgHisID];
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(bossCircleDatabase, [selectSql UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            count = sqlite3_column_int(stmt, 0);
        }
        
        // Finalize and close database.
        sqlite3_finalize(stmt);
    }
    else
    {
        CCLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        //sqlite3_close(bossCircleDatabase);
        return 0;
    }
    
    return count;
}

-(BOOL) deleteFriendWithUserId:(NSString *) userId {
    NSString* sqlStatement = [NSString stringWithFormat:@"delete from %@ where %@='%@'", KFriendsTableName, KFriendsTableColNumber, userId];
    char *err;
    if (sqlite3_exec(bossCircleDatabase, [sqlStatement UTF8String], nil, nil, &err) != SQLITE_OK) {
        NSLog(@"deleteFriendWithUserId failed! %s", err);
        return NO;
    }
    
    [self deleteChatDataWithUserId:userId];
	return YES;
}

-(BOOL)deleteFriendRecordByMsgHisID:(NSString *)msgHisId
{
    NSString* sqlStatement = [NSString stringWithFormat:@"delete from %@ where %@='%@'", KFriendsTableName, KFriendsTableColMsgHisID, msgHisId];
    char *err;
    if (sqlite3_exec(bossCircleDatabase, [sqlStatement UTF8String], nil, nil, &err) != SQLITE_OK) {
        NSLog(@"deleteFriendWithUserId failed! %s", err);
        return NO;
    }
	return YES;
}

//////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Message_History
-(BOOL)insertDataToChatInfoTable:(NSDictionary *) messageDictionary imageData:(NSData *) imageData
{
    if (!messageDictionary)
        return NO;
    
    NSString *messageId = [messageDictionary objectForKey:KMessageHistoryTableColMsgId];
    NSString *messageSender = [messageDictionary objectForKey:KMessageHistoryTableColSender];
    NSString *messageReceiver = [messageDictionary objectForKey:KMessageHistoryTableColReceiver];
    NSString *message = [messageDictionary objectForKey:KMessageHistoryTableColMsg];
    NSString *mediaURL = [messageDictionary objectForKey:KMessageHistoryTableColMediaURL];
    NSString *orgmediaURL = [messageDictionary objectForKey:KMessageHistoryTableColOrgMediaURL];
    NSInteger audioDuration = [[messageDictionary objectForKey:KMessageHistoryTableColAudioDuration] integerValue];
    NSInteger messageType = [[messageDictionary objectForKey:KMessageHistoryTableColMsgType] integerValue];
    NSInteger fileType = [[messageDictionary objectForKey:KMessageHistoryTableColFileType] integerValue];
    NSString *createTime = [messageDictionary objectForKey:KMessageHistoryTableColCreateTime];
    NSInteger messageStatus = [[messageDictionary objectForKey:KMessageHistoryTableColStatus] integerValue];
    NSInteger messageSendStatus = [[messageDictionary objectForKey:KMessageHistoryTableColSendStatus] integerValue];
    NSString* serverMsgId = [messageDictionary objectForKey:KMessageHistoryTableColServerMsgId];
    NSInteger msgReadStatus = [[messageDictionary objectForKey:KMessageHistoryTableColMsgReadStatus] integerValue];
    
    NSString* sqlString = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", KMessageHistoryTableName,
                           KMessageHistoryTableColMsgId, KMessageHistoryTableColSender, KMessageHistoryTableColReceiver, KMessageHistoryTableColMsg, KMessageHistoryTableColMediaURL, KMessageHistoryTableColOrgMediaURL, KMessageHistoryTableColAudioDuration, KMessageHistoryTableColImage, KMessageHistoryTableColMsgType, KMessageHistoryTableColFileType, KMessageHistoryTableColCreateTime, KMessageHistoryTableColStatus,KMessageHistoryTableColSendStatus, KMessageHistoryTableColServerMsgId, KMessageHistoryTableColMsgReadStatus];
    const char* sqliteQuery = [sqlString UTF8String];
    sqlite3_stmt* statement;
    
    if( sqlite3_prepare_v2(bossCircleDatabase, sqliteQuery, -1, &statement, NULL) == SQLITE_OK )
    {
        sqlite3_bind_text(statement, 1, [messageId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [messageSender UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [messageReceiver UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [message UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [mediaURL UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [orgmediaURL UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 7, audioDuration);
        if (imageData != nil)
        {
            sqlite3_bind_blob(statement, 8, [imageData bytes], [imageData length], SQLITE_TRANSIENT);
        }
        sqlite3_bind_int(statement, 9, messageType);
        sqlite3_bind_int(statement, 10, fileType);
        sqlite3_bind_text(statement, 11, [createTime UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 12, messageStatus);
        sqlite3_bind_int(statement, 13, messageSendStatus);
        sqlite3_bind_text(statement, 14, [serverMsgId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 15, msgReadStatus);
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
    }
    else
    {
        NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
    }
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];
    if ([messageSender isEqualToString:username])
        [self updateFriendLastTimebyUserId:messageReceiver andLastTime:createTime andLastMsg:message andLastMsgType:messageType andLastFileType:fileType andMsgHisID:messageId];
    else
        [self updateFriendLastTimebyUserId:messageSender andLastTime:createTime andLastMsg:message andLastMsgType:messageType andLastFileType:fileType andMsgHisID:messageId];
    
    return YES;
}

- (NSMutableArray *)selectMessageRecordFromUser:(NSString *) userName andRccordNumber:(int)_number
{
    IMMsgHistory *msgHistory = nil;
    NSMutableArray *resultArray = nil;
    sqlite3_stmt *stmt;
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];

    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE (%@=\"%@\" and %@=\"%@\") or (%@=\"%@\" and %@=\"%@\") order by %@ desc limit %d",
                     KMessageHistoryTableName, KMessageHistoryTableColSender, userName, KMessageHistoryTableColReceiver,
                     username, KMessageHistoryTableColReceiver, userName,
                     KMessageHistoryTableColSender, username, KMessageHistoryTableColCreateTime, _number];
    if(sqlite3_prepare_v2(bossCircleDatabase, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        resultArray = [[[NSMutableArray alloc] init] autorelease];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            // ID
            NSString *ID = [NSString stringWithFormat:@"%d",sqlite3_column_int(stmt, 0)];
            // MessageId
            char *msgId = (char *)sqlite3_column_text(stmt, 1);
            NSString *messageId = [[NSString alloc] initWithUTF8String:msgId];
            // Sender
            char *msgSender = (char *)sqlite3_column_text(stmt, 2);
            NSString *messageSender = [[NSString alloc] initWithUTF8String:msgSender];
            // Receiver
            char *msgReceiver = (char *)sqlite3_column_text(stmt, 3);
            NSString *messageReceiver = [[NSString alloc] initWithUTF8String:msgReceiver];
            // Message
            char *msgText = (char *)sqlite3_column_text(stmt, 4);
            NSString *messageText = [[NSString alloc] initWithUTF8String:msgText];
            // MediaURL
            char *msgMediaURL = (char *)sqlite3_column_text(stmt, 5);
            NSString *mediaURL = [[NSString alloc] initWithUTF8String:msgMediaURL];
            // OrgMediaURL
            char *msgOrgMediaURL = (char *)sqlite3_column_text(stmt, 6);
            NSString *orgmediaURL = [[NSString alloc] initWithUTF8String:msgOrgMediaURL];
            //audioDuration
            NSInteger audioDuration = sqlite3_column_int(stmt, 7);
            // Image
//            int length = sqlite3_column_bytes(stmt, 8);
//            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(stmt, 6) length:length];
            // MessageType
            NSInteger messageType = sqlite3_column_int(stmt, 9);
            // FileType
            NSInteger fileType = sqlite3_column_int(stmt, 10);
            // CreateTime
            char *msgCreateTime = (char *)sqlite3_column_text(stmt, 11);
            NSString *createTime = [[NSString alloc] initWithUTF8String:msgCreateTime];
            // Status
            NSInteger messageStatus = sqlite3_column_int(stmt, 12);
            
            // SendStatus
            NSInteger messageSendStatus = sqlite3_column_int(stmt, 13);
            
            // ServerMsgId
            char *servmsgid = (char *)sqlite3_column_text(stmt, 14);
            NSString *ServerMsgId = [[NSString alloc] initWithUTF8String:servmsgid];
            
            // IMMsgReadStatus
            NSInteger msgReadStatus = sqlite3_column_int(stmt, 15);
            
            msgHistory = [[IMMsgHistory alloc] initWithID:(int32_t)ID andMessageId:messageId andSender:messageSender andReceiver:messageReceiver andMessage:messageText andMediaURL:mediaURL andOrgMediaURL:orgmediaURL andAudioDuration:audioDuration andImage:nil andMsgType:messageType andFileType:fileType andCreateTime:createTime andStatus:messageStatus andSendStatus:(IMSendStatus)messageSendStatus andServerMsgId:ServerMsgId andMsgReadStatus:(IMMsgReadStatus)msgReadStatus];
            
            //添加到数组中
            [resultArray addObject:msgHistory];
            [messageId release];
            [messageSender release];
            [messageReceiver release];
            [messageText release];
            [mediaURL release];
            [orgmediaURL release];
            [createTime release];
            [ServerMsgId release];
            
            [msgHistory release];
            
        }
        
        // Finalize and close database.
        sqlite3_finalize(stmt);
    }
    else
    {        
        NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        //sqlite3_close(bossCircleDatabase);
        return nil;
    }
    
    NSLog(@"%@", [resultArray description]);
    
    return resultArray;
}

- (IMMsgHistory *)selectMessageRecordFromByMessageID:(NSString *) msgid
{
    IMMsgHistory *msgHistory = nil;
    sqlite3_stmt *stmt;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",
                     KMessageHistoryTableName, KMessageHistoryTableColMsgId, msgid];
    if(sqlite3_prepare_v2(bossCircleDatabase, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            // ID
            int32_t myid = sqlite3_column_int(stmt, 0);
            // MessageId
            char *msgId = (char *)sqlite3_column_text(stmt, 1);
            NSString *messageId = [[NSString alloc] initWithUTF8String:msgId];
            // Sender
            char *msgSender = (char *)sqlite3_column_text(stmt, 2);
            NSString *messageSender = [[NSString alloc] initWithUTF8String:msgSender];
            // Receiver
            char *msgReceiver = (char *)sqlite3_column_text(stmt, 3);
            NSString *messageReceiver = [[NSString alloc] initWithUTF8String:msgReceiver];
            // Message
            char *msgText = (char *)sqlite3_column_text(stmt, 4);
            NSString *messageText = [[NSString alloc] initWithUTF8String:msgText];
            // MediaURL
            char *msgMediaURL = (char *)sqlite3_column_text(stmt, 5);
            NSString *mediaURL = [[NSString alloc] initWithUTF8String:msgMediaURL];
            // OrgMediaURL
            char *msgOrgMediaURL = (char *)sqlite3_column_text(stmt, 6);
            NSString *orgmediaURL = msgOrgMediaURL?[[NSString alloc] initWithUTF8String:msgOrgMediaURL]:@"";
            //audioDuration
            int audioDuration = sqlite3_column_int(stmt, 7);
            // Image
            //            int length = sqlite3_column_bytes(stmt, 8);
            //            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(stmt, 6) length:length];
            // MessageType
            int messageType = sqlite3_column_int(stmt, 9);
            // FileType
            int fileType = sqlite3_column_int(stmt, 10);
            // CreateTime
            char *msgCreateTime = (char *)sqlite3_column_text(stmt, 11);
            NSString *createTime = [[NSString alloc] initWithUTF8String:msgCreateTime];
            // Status
            int messageStatus = sqlite3_column_int(stmt, 12);
            
            // SendStatus
            IMSendStatus msgSendStatus = (IMSendStatus)sqlite3_column_int(stmt, 13);
            
            // ServerMsgId
            char *servmsgid = (char *)sqlite3_column_text(stmt, 14);
            NSString *ServerMsgId = [[NSString alloc] initWithUTF8String:servmsgid];
            
            // IMMsgReadStatus
            NSInteger msgReadStatus = sqlite3_column_int(stmt, 15);
            
            msgHistory = [[[IMMsgHistory alloc] initWithID:myid andMessageId:messageId andSender:messageSender andReceiver:messageReceiver andMessage:messageText andMediaURL:mediaURL andOrgMediaURL:orgmediaURL andAudioDuration:audioDuration andImage:nil andMsgType:messageType andFileType:fileType andCreateTime:createTime andStatus:messageStatus andSendStatus:msgSendStatus andServerMsgId:ServerMsgId andMsgReadStatus:(IMMsgReadStatus)msgReadStatus] autorelease];
            
            [messageId release];
            [messageSender release];
            [messageReceiver release];
            [messageText release];
            [mediaURL release];
            [orgmediaURL release];
            [createTime release];
            [ServerMsgId release];
        }
        
        // Finalize and close database.
        sqlite3_finalize(stmt);
    }
    else
    {
        
        NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        //sqlite3_close(bossCircleDatabase);
        return nil;
    }
    
    return msgHistory;
}

- (IMMsgHistory *)selectMessageRecordByUserID:(NSString *)userid
{
    IMMsgHistory *msgHistory = nil;
    sqlite3_stmt *stmt;
    
    NSString *myAccountID = [[CloudCall2AppDelegate sharedInstance] getUserName];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE (%@ = \"%@\" and %@ = \"%@\") or (%@ = \"%@\" and %@ = \"%@\") order by %@ desc limit 1", KMessageHistoryTableName, KMessageHistoryTableColSender, myAccountID, KMessageHistoryTableColReceiver, userid, KMessageHistoryTableColReceiver, myAccountID, KMessageHistoryTableColSender, userid, KMessageHistoryTableColCreateTime];
    if(sqlite3_prepare_v2(bossCircleDatabase, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            // ID
            int32_t myid = sqlite3_column_int(stmt, 0);
            // MessageId
            char *msgId = (char *)sqlite3_column_text(stmt, 1);
            NSString *messageId = [[NSString alloc] initWithUTF8String:msgId];
            // Sender
            char *msgSender = (char *)sqlite3_column_text(stmt, 2);
            NSString *messageSender = [[NSString alloc] initWithUTF8String:msgSender];
            // Receiver
            char *msgReceiver = (char *)sqlite3_column_text(stmt, 3);
            NSString *messageReceiver = [[NSString alloc] initWithUTF8String:msgReceiver];
            // Message
            char *msgText = (char *)sqlite3_column_text(stmt, 4);
            NSString *messageText = [[NSString alloc] initWithUTF8String:msgText];
            // MediaURL
            char *msgMediaURL = (char *)sqlite3_column_text(stmt, 5);
            NSString *mediaURL = [[NSString alloc] initWithUTF8String:msgMediaURL];
            // OrgMediaURL
            char *msgOrgMediaURL = (char *)sqlite3_column_text(stmt, 6);
            NSString *orgmediaURL = msgOrgMediaURL?[[NSString alloc] initWithUTF8String:msgOrgMediaURL]:@"";
            //audioDuration
            int audioDuration = sqlite3_column_int(stmt, 7);
            // Image
            //            int length = sqlite3_column_bytes(stmt, 8);
            //            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(stmt, 6) length:length];
            // MessageType
            int messageType = sqlite3_column_int(stmt, 9);
            // FileType
            int fileType = sqlite3_column_int(stmt, 10);
            // CreateTime
            char *msgCreateTime = (char *)sqlite3_column_text(stmt, 11);
            NSString *createTime = [[NSString alloc] initWithUTF8String:msgCreateTime];
            // Status
            int messageStatus = sqlite3_column_int(stmt, 12);
            
            // SendStatus
            IMSendStatus msgSendStatus = (IMSendStatus)sqlite3_column_int(stmt, 13);
            
            // ServerMsgId
            char *servmsgid = (char *)sqlite3_column_text(stmt, 14);
            NSString *ServerMsgId = servmsgid?[[NSString alloc] initWithUTF8String:servmsgid]:@"";
            
            // IMMsgReadStatus
            NSInteger msgReadStatus = sqlite3_column_int(stmt, 15);
            
            msgHistory = [[[IMMsgHistory alloc] initWithID:myid andMessageId:messageId andSender:messageSender andReceiver:messageReceiver andMessage:messageText andMediaURL:mediaURL andOrgMediaURL:orgmediaURL andAudioDuration:audioDuration andImage:nil andMsgType:messageType andFileType:fileType andCreateTime:createTime andStatus:messageStatus andSendStatus:msgSendStatus andServerMsgId:ServerMsgId andMsgReadStatus:(IMMsgReadStatus)msgReadStatus] autorelease];
            
            [messageId release];
            [messageSender release];
            [messageReceiver release];
            [messageText release];
            [mediaURL release];
            [orgmediaURL release];
            [createTime release];
            [ServerMsgId release];
        }
        
        // Finalize and close database.
        sqlite3_finalize(stmt);
    }
    else
    {
        
        NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        //sqlite3_close(bossCircleDatabase);
        return nil;
    }
    
    return msgHistory;
}

// 更新数据
- (BOOL) updateUnReadMsgByUserId:(NSString *) userId
{
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];

    NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@=1 where %@=\"%@\" and %@=\"%@\"", KMessageHistoryTableName, KMessageHistoryTableColStatus,
                           KMessageHistoryTableColSender, userId, KMessageHistoryTableColReceiver, username];

    char *err;
    if (sqlite3_exec(bossCircleDatabase, [updateSql UTF8String], nil, nil, &err) != SQLITE_OK)
    {
        //sqlite3_close(bossCircleDatabase);
        NSLog(@"修改数据失败！ %s", err);
        return NO;
    }
    
    return YES;
}

/**
 *	@brief	更新发送状态
 *
 *	@param 	msgID 	消息ID
 *	@param 	sendStatus 	发送状态
 *
 *	@return	返回是否更新成功
 */
- (BOOL)updateMessageSendStatusByMsgID:(NSString *)msgID andSendStatus:(IMSendStatus)sendStatus andServerMsgId:(NSString *)serverMsgID
{
    NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@=%d, %@='%@' where %@=\"%@\"", KMessageHistoryTableName, KMessageHistoryTableColSendStatus, sendStatus, KMessageHistoryTableColServerMsgId, serverMsgID, KMessageHistoryTableColMsgId, msgID];
    
    char *err;
    if (sqlite3_exec(bossCircleDatabase, [updateSql UTF8String], nil, nil, &err) != SQLITE_OK)
    {
        //sqlite3_close(bossCircleDatabase);
        NSLog(@"修改数据失败！ %s", err);
        return NO;
    }
    
    return YES;
}

// 查找未阅读的消息
- (NSInteger) selectUnReadCount:(NSString *) userId
{
    NSInteger unReadMsgCount = 0;
    // Status: 0 - UnRead, 1 - Read
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];

    NSString *selectSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@=\"%@\" and %@=0 and %@=\"%@\" order by %@ asc", KMessageHistoryTableName,
                           KMessageHistoryTableColSender, userId, KMessageHistoryTableColStatus, KMessageHistoryTableColReceiver, username, KMessageHistoryTableColMsgId];
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(bossCircleDatabase, [selectSql UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            unReadMsgCount = sqlite3_column_int(stmt, 0);
        }
        
        // Finalize and close database.
        sqlite3_finalize(stmt);
    }
    else
    {
        NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        //sqlite3_close(bossCircleDatabase);
        return 0;
    }

    return unReadMsgCount;
}

- (NSInteger) selectAllUnReadCountByReceiver:(NSString *) userId
{
    NSInteger unReadMsgCount = 0;
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];

    // Status: 0 - UnRead, 1 - Read
    NSString *selectSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@=\"%@\" and %@=0 and %@=\"%@\"", KMessageHistoryTableName,
                           KMessageHistoryTableColReceiver, userId, KMessageHistoryTableColStatus, KMessageHistoryTableColReceiver, username];
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(bossCircleDatabase, [selectSql UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            unReadMsgCount = sqlite3_column_int(stmt, 0);
        }
        
        // Finalize and close database.
        sqlite3_finalize(stmt);
    }
    else
    {
        NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        //sqlite3_close(bossCircleDatabase);
        return 0;
    }
    
    return unReadMsgCount;
}

- (BOOL)deleteChatDataWithMsgId:(NSString *)msgId andUserId:(NSString *)userId
{
    NSString* sqlStatement = [NSString stringWithFormat:@"delete from %@ where %@='%@' and (%@='%@' or %@='%@')", KMessageHistoryTableName, KMessageHistoryTableColMsgId, msgId, KMessageHistoryTableColSender, userId, KMessageHistoryTableColReceiver, userId];
    char *delErr;
    if (sqlite3_exec(bossCircleDatabase, [sqlStatement UTF8String], nil, nil, &delErr) != SQLITE_OK) {
        NSLog(@"deleteChatDataWithUserId failed! %s", delErr);
        return NO;
    }
    
    int countMsgId = [self selectCountFromFriendByMsgHisID:msgId];
    
    if (countMsgId)
    {
        //如果有最后一条消息,更新为上一条最新数据
        IMMsgHistory *msgHistory = [self selectMessageRecordByUserID:userId];
        
        if (msgHistory && msgHistory != nil)
        {
            NSString *myAccount = [[CloudCall2AppDelegate sharedInstance] getUserName];
            if ([msgHistory.Sender isEqualToString:myAccount])
                [self updateFriendLastTimebyUserId:msgHistory.Receiver andLastTime:msgHistory.CreateTime andLastMsg:msgHistory.Message andLastMsgType:msgHistory.MessageType andLastFileType:msgHistory.FileType andMsgHisID:msgHistory.MessageId];
            else
                [self updateFriendLastTimebyUserId:msgHistory.Sender andLastTime:msgHistory.CreateTime andLastMsg:msgHistory.Message andLastMsgType:msgHistory.MessageType andLastFileType:msgHistory.FileType andMsgHisID:msgHistory.MessageId];
        }
        else
        {
            //如果没有上一条消息,删除Friend_Talking的记录
            [self deleteFriendRecordByMsgHisID:msgId];
        }
    }
    
	return YES;
}


-(BOOL) deleteChatDataWithUserId:(NSString *) userId {
    NSString* sqlStatement = [NSString stringWithFormat:@"delete from %@ where %@='%@' or %@='%@'", KMessageHistoryTableName, KMessageHistoryTableColSender, userId, KMessageHistoryTableColReceiver, userId];
    char *err;
    if (sqlite3_exec(bossCircleDatabase, [sqlStatement UTF8String], nil, nil, &err) != SQLITE_OK) {
        NSLog(@"deleteChatDataWithUserId failed! %s", err);
        return NO;
    }
	return YES;
}

- (NSInteger)selectCountAllMessageRecordByUser:(NSString *)userName
{
    NSInteger allMsgCount = 0;
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];
    
    // Status: 0 - UnRead, 1 - Read
    NSString *selectSql = [NSString stringWithFormat:@"SELECT count(*) FROM %@ WHERE (%@=\"%@\" and %@=\"%@\") or (%@=\"%@\" and %@=\"%@\")",
                     KMessageHistoryTableName, KMessageHistoryTableColSender, userName, KMessageHistoryTableColReceiver,
                     username, KMessageHistoryTableColReceiver, userName, KMessageHistoryTableColSender, username];
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(bossCircleDatabase, [selectSql UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            allMsgCount = sqlite3_column_int(stmt, 0);
        }
        
        // Finalize and close database.
        sqlite3_finalize(stmt);
    }
    else
    {
        NSLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        //sqlite3_close(bossCircleDatabase);
        return 0;
    }
    
    return allMsgCount;
}

- (BOOL)selectMsgReadStatusByMsgId:(NSString *)msgId
{
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@ = '%@'", KMessageHistoryTableColMsgReadStatus, KMessageHistoryTableName, KMessageHistoryTableColMsgId, msgId];
    
    NSInteger readStatus = 0;
    
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(bossCircleDatabase, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            readStatus = sqlite3_column_int(stmt, 0);
        }
        
        // Finalize and close database.
        sqlite3_finalize(stmt);
    }
    else
    {
        CCLog(@"%s",sqlite3_errmsg(bossCircleDatabase));
        //sqlite3_close(bossCircleDatabase);
        return YES;
    }
    
    if (readStatus == 0)
        return YES;
    else
        return NO;
}

// 更新语音是否已读消息
- (BOOL)updateMsgReadStatusByMsgId:(NSString *)msgId andIMMsgReadStatus:(IMMsgReadStatus)msgReadStatus
{
    NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ = %d where %@ = '%@'", KMessageHistoryTableName, KMessageHistoryTableColMsgReadStatus, msgReadStatus, KMessageHistoryTableColMsgId, msgId];
    
    char *err;
    if (sqlite3_exec(bossCircleDatabase, [updateSql UTF8String], nil, nil, &err) != SQLITE_OK)
    {
        //sqlite3_close(bossCircleDatabase);
        NSLog(@"修改数据失败！ %s", err);
        return NO;
    }
    
    return YES;
}

@end
