//

#import <UIKit/UIKit.h>

#define kNotifyMsgResponseStatusNotification  @"NotifyMsgResponseStatus"

@interface NotifyMsgResponseStatusNotificationArgs : NSObject {
    BOOL success;
    int errorcode;
    NSString* text;
    NSMutableArray* records;
}

@property(readonly) BOOL success;
@property(readonly) int errorcode;
@property(readonly) NSString* text;
@property(readonly) NSMutableArray* records;

-(NotifyMsgResponseStatusNotificationArgs*) initWithStatus:(BOOL)success andErrorCode:(int)errorcode andText:(NSString*)text andRecords:(NSMutableArray*)records;

@end

@interface NotificationMessageManager : NSObject {
    NSTimer* getTimer;
}

-(void)sendRequest2Server:(NSData*)jsonData andUserInfo:(NSMutableDictionary*)userInfo;
-(void)Start;
-(void)GetNotificationMessages;

@end
