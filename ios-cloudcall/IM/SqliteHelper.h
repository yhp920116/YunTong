//
//  SqliteHelper.h
//  BossCircleCM
//
//  Created by tenglong zhan on 12-11-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define kDatabaseName @"ChatDataBase.sqlite"

/////////
#define KMessageHistoryTableName                @"Message_History"
#define KMessageHistoryTableColMsgId            @"MessageId"
#define KMessageHistoryTableColSender           @"Sender"
#define KMessageHistoryTableColReceiver         @"Receiver"
#define KMessageHistoryTableColMsg              @"Message"
#define KMessageHistoryTableColMediaURL         @"MediaURL"
#define KMessageHistoryTableColOrgMediaURL      @"OrgMediaURL"
#define KMessageHistoryTableColAudioDuration    @"AudioDuration"
#define KMessageHistoryTableColImage            @"Image"
#define KMessageHistoryTableColMsgType          @"MessageType"
#define KMessageHistoryTableColFileType         @"FileType"
#define KMessageHistoryTableColCreateTime       @"CreateTime"
#define KMessageHistoryTableColStatus           @"Status"
#define KMessageHistoryTableColSendStatus       @"SendStatus"
#define KMessageHistoryTableColServerMsgId      @"ServerMsgId"
#define KMessageHistoryTableColMsgReadStatus    @"MsgReadStatus"

////////
#define KFriendsTableName            @"Friends_Talking"
#define KFriendsTableColNumber       @"Number"
#define KFriendsTableColLastTime     @"LastTime"
#define KFriendsTableColLastMsg      @"LastMessage"
#define KFriendsTableColLastMsgType  @"LastMsgType"
#define KFriendsTableColLastFileType @"LastFileType"
#define KFriendsTableColMsgHisID     @"MsgHisID"

typedef enum
{
    IMSendStatusSendSucc = 0,   //已发送完成
    IMSendStatusSending,        //发送中
    IMSendStatusSendFail        //发送失败
}IMSendStatus;

typedef enum
{
    IMMsgReadStatusOfRead= 0,   //已读
    IMMsgReadStatusOfUnRead     //未读
}IMMsgReadStatus;

@interface IMFriendInfo : NSObject
{
    int32_t myid;
    NSString* number;
    NSString* time;
    NSString* message;
    int msgType;
    int fileType;
    
    NSObject* contact;
    int unreadnum;
    NSString* msghisid;
}

@property(readonly) int32_t myid;
@property(retain, nonatomic) NSString* number;
@property(retain, nonatomic) NSString* time;
@property(retain, nonatomic) NSString* message;
@property(readonly) int msgType;
@property(readonly) int fileType;
@property(retain, nonatomic) NSObject* contact;
@property(readwrite) int unreadnum;
@property(retain, nonatomic) NSString* msghisid;

-(IMFriendInfo*)initWithID:(int32_t)_id andNumber:(NSString*)num andTime:(NSString*)_time andMessage:(NSString*)msg andMsgType:(int)msgtype andFileType:(int)filetype andMsgHisID:(NSString *)_msghisid;

@end

@interface IMMsgHistory : NSObject
{
    int32_t     myid;
    NSString    *MessageId;
    NSString    *Sender;
    NSString    *Receiver;
    NSString    *Message;
    NSString    *MediaURL;
    NSString    *OrgMediaURL;
    int    AudioDuration;
    NSData      *Image;
    int         MessageType;
    int         FileType;
    NSString*   CreateTime;
    int         Status;
    IMSendStatus SendStatus;
    NSString*  ServerMsgId;
    IMMsgReadStatus MsgReadStatus;
}

@property(readonly) int32_t myid;
@property(nonatomic, retain) NSString       *MessageId;
@property(nonatomic, retain) NSString       *Sender;
@property(nonatomic, retain) NSString       *Receiver;
@property(nonatomic, retain) NSString       *Message;
@property(nonatomic, retain) NSString       *MediaURL;
@property(nonatomic, retain) NSString       *OrgMediaURL;
@property(nonatomic, assign) int            AudioDuration;
@property(nonatomic, retain) NSData         *Image;
@property(nonatomic, assign) int            MessageType;
@property(nonatomic, assign) int            FileType;
@property(nonatomic, retain) NSString*      CreateTime;
@property(nonatomic, assign) int            Status;
@property(nonatomic, assign) IMSendStatus   SendStatus;
@property(nonatomic, retain) NSString       *ServerMsgId;
@property(nonatomic, assign) IMMsgReadStatus   MsgReadStatus;

- (IMMsgHistory*)initWithID:(int32_t)_id andMessageId:(NSString*)_msgId andSender:(NSString *)_sender andReceiver:(NSString*)_receiver andMessage:(NSString*)_msg andMediaURL:(NSString *)_mediaURL andOrgMediaURL:(NSString *)_orgMediaURL andAudioDuration:(int)_audioDuration andImage:(NSData *)_image andMsgType:(int)msgtype andFileType:(int)filetype andCreateTime:(NSString *)_createTime andStatus:(int)_status andSendStatus:(IMSendStatus)_sendStatus andServerMsgId:(NSString*)_serverMsgId andMsgReadStatus:(IMMsgReadStatus)_msgReadStatus;

@end


@interface SqliteHelper : NSObject
{
    sqlite3 *bossCircleDatabase;
}

//创建数据库
-(void)createDatabase;
//关闭数据库连接
-(void)closeDatabase;
//创建表
-(void)createTable:(NSString *)sql;

- (BOOL)selectFriendsRecords:(NSMutableArray*)friendArray;
-(BOOL) deleteFriendWithUserId:(NSString *) userId;

// 插入数据至消息记录
-(BOOL)insertDataToChatInfoTable:(NSDictionary *)messageDictionary imageData:(NSData *) imageData;
// 查询消息记录
- (NSMutableArray *)selectMessageRecordFromUser:(NSString *) userName andRccordNumber:(int)_number;
// 根据消息ID查询消息记录
- (IMMsgHistory *)selectMessageRecordFromByMessageID:(NSString *) msgid;
// 更新数据
- (BOOL) updateUnReadMsgByUserId:(NSString *) userId;

// 更新发送状态
- (BOOL)updateMessageSendStatusByMsgID:(NSString *)msgID andSendStatus:(IMSendStatus)sendStatus andServerMsgId:(NSString *)serverMsgID;

// 查找未阅读的消息
- (NSInteger) selectUnReadCount:(NSString *) userId;

- (NSInteger) selectAllUnReadCountByReceiver:(NSString *) userId;

-(BOOL) deleteChatDataWithMsgId:(NSString *) MsgId andUserId:(NSString *) userId;
-(BOOL) deleteChatDataWithUserId:(NSString *) userId;

//统计该用户所有历史消息
- (NSInteger)selectCountAllMessageRecordByUser:(NSString *)userName;

//查询语音消息是否已读
- (BOOL)selectMsgReadStatusByMsgId:(NSString *)msgId;

// 更新语音是否已读消息
- (BOOL)updateMsgReadStatusByMsgId:(NSString *)msgId andIMMsgReadStatus:(IMMsgReadStatus)msgReadStatus;
@end
