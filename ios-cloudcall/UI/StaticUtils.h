//
//  StaticUtils.h
//  CloudCall
//
//  Created by CloudCall on 13-8-9.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <Foundation/Foundation.h>
////////////手机sim卡判断是否已经安装时,需要的一些变量和方法////////////////
extern NSString* const kCTSMSMessageReceivedNotification;
extern NSString* const kCTSMSMessageReplaceReceivedNotification;
extern NSString* const kCTSIMSupportSIMStatusNotInserted;
extern NSString* const kCTSIMSupportSIMStatusReady;

id CTTelephonyCenterGetDefault(void);
void CTTelephonyCenterAddObserver(id,id,CFNotificationCallback,NSString*,void*,int);
void CTTelephonyCenterRemoveObserver(id,id,NSString*,void*);
int CTSMSMessageGetUnreadCount(void);

int CTSMSMessageGetRecordIdentifier(void * msg);
NSString * CTSIMSupportGetSIMStatus();
NSString * CTSIMSupportCopyMobileSubscriberIdentity();

id  CTSMSMessageCreate(void* unknow/*always 0*/,NSString* number,NSString* text);
void * CTSMSMessageCreateReply(void* unknow/*always 0*/,void * forwardTo,NSString* text);

void* CTSMSMessageSend(id server,id msg);

NSString *CTSMSMessageCopyAddress(void *, void *);
NSString *CTSMSMessageCopyText(void *, void *);

////////////////////////////////////////////////////////////////////////////


@interface StaticUtils : NSObject

+ (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size;

//获取时间格式
+ (NSString *)transformMessageViewDate:(NSString *)messageDate;
+ (NSString *)transformIMChatViewDate:(NSDate *)messageDate;
+ (BOOL)haveSimCard;

+ (void)encryptSetup;
@end
