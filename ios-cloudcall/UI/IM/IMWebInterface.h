//
//  WebInterface.h
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

#define kSDHM_SYS_TIMEOUT        15

// 登录
extern NSString *SendMsgSuccessfulNotification;
extern NSString *SendMsgFailureNotification;

extern NSString *LoadFriendsSuccessful;
extern NSString *LoadFriendsFailure;

extern NSString *LoadGroupListSuccessful;
extern NSString *LoadGroupListFailure;

@interface IMRequest : ASIFormDataRequest <ASIHTTPRequestDelegate>

@property (nonatomic, assign) SEL successSelector;
@property (nonatomic, assign) SEL failureSelector;
@property (nonatomic, assign) NSObject *completionDelegate;

@end

@interface IMWebInterface : NSObject <ASIProgressDelegate>

+ (IMWebInterface *) sharedInstance;

// 发送消息
- (void) sendChatMessageRequest:(NSString *) from to:(NSString *) to message:(NSString *) message type:(NSString *) type andMsgID:(NSString *)msgid;

// 发送图片/语音
- (void) sendChatMediaResourceRequest:(NSString *) from to:(NSString *) to data:(NSData *) fileData fileType:(NSString *) fileType type:(NSString *)type andMsgID:(NSString *)msgid andAudioTime:(NSString *)audioTime;

- (void) sendChatMediaResourceRequest:(NSString *) from to:(NSString *) to data:(NSData *) fileData fileType:(NSString *) fileType type:(NSString *)type andMsgID:(NSString *)msgid andAudioTime:(NSString *)audioTime andProcessView:(UIProgressView *)progressView;

// 消息已读取
- (void) sendReadChatMessageRequest:(NSString *) messageId;

// 删除消息
- (void) sendDeleteChatMessageRequest:(NSString *) messageId;

// 获取好友列表   (已经不使用)
//- (void) sendLoadFriendListRequest:(NSString *) userName;

// 获取群组列表
- (void) sendLoadGroupListRequest:(NSString *) userName;

@end
