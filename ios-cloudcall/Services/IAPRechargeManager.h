//

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"

typedef enum {
    RechargeStatusConnectServerFailed = 10, // 连接计费服务器失败
    RechargeStatusInvalidCard = 101, // 无效的充值卡（重发）
    RechargeStatusInvalidCardOrPassword = 102,
    RechargeStatusCardIncludingIllegalChar = 103,
    RechargeStatusIllegalOperation = 104,
    RechargeStatusNotCloudCallUser = 105,
    RechargeStatusExecutionFailed = 106,  // 计费服务器执行失败
    RechargeStatusAppSotreFaild = 107     // 苹果商店执行失败
}RechargeStatusDef;

#define kRechargeStatusNotification  @"RechargeStatus"
@interface IAPRechargeStatusNotificationArgs : NSObject {
    BOOL success;
    RechargeStatusDef errorcode;
    NSString *purchasedId;
    NSString *productId;
}

@property(readonly) BOOL success;
@property(readonly) RechargeStatusDef errorcode;
@property(readonly) NSString *purchasedId;
@property(readonly) NSString *productId;

-(IAPRechargeStatusNotificationArgs*) initWithStatus:(BOOL)success andErrorCode:(RechargeStatusDef)errorcode andPurchasedID:(NSString*)purchasedID andProductID:(NSString*)productId;

@end

@interface IAPRechargeManager : NSObject {
    NSString*       mynum;
    NSTimer*        rechargeTimer;
    NSMutableDictionary* recharges;
    int rechargingnum;
    
    NSMutableArray* products;
}

@property(nonatomic, assign) NSMutableArray* products;

-(void) start:(NSString*)mynum;
-(void) stop;

-(void) updateAfterValidation:(NSString*)mynum;

-(void) recharge:(NgnIAPRecord*)iapRecord;

@end
