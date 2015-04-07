//
//  CouponManager.h
//  CloudCall
//
//  Created by CloudCall on 13-5-9.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CloudCall2AppDelegate.h"
#import "FMDB/FMDatabase.h"
#import "../UI/CouponData.h"

#define kDownloadCouponList         @"DownloadCouponList"
#define kDownloadCollectCoupons     @"DownloadCollectCoupons"
#define kDeleteCollectCoupons       @"DeleteCollectCoupons"
#define kUpdateCollectCoupons       @"UpdateCollectCoupons"

#define kDBLoadAllCouponsData       @"all"

@protocol CouponManagerDelegate <NSObject>

- (void)shouldContinueAfterGetCouponsDataFromNet:(NSMutableDictionary *)userInfo;
@end

@interface CouponManager : NSObject
{
    NSString* directory;
    NSString* filename;
}

@property (nonatomic, retain) id<CouponManagerDelegate> delegate;

- (CouponManager*) initWithDirectory:(NSString*)_directory andListFileName:(NSString*)filename;

+ (NSMutableArray*)LoadCouponsDataFromFile:(NSString*)filepath;
+ (void)SaveCouponsDataToDB:(NSString*)filepath andAdArray:(NSMutableArray*)adData;
- (void)recvRespFromServerSucceeded:(NSData *)data userInfo:(NSMutableDictionary *)userInfo;
- (void)recvRespFromServerFailed:(NSError *)error userInfo:(NSDictionary *)userInfo;
- (void)sendRequest2Server:(NSData *)jsonData andType:(NSString *)reqType;

- (NSString *)getDocumentPath;
- (FMDatabase *)getManageDB;
- (NSMutableArray *)dbLoadCouponData:(NSString *)coupon_who;
- (CouponData *)dbLoadCouponDataByCouponId:(NSString *)coupon_id andWho:(NSString *)_who;
- (void)dbDeleteACouponData:(NSString *)coupon_id andWho:(NSString *)_who;
- (void)dbUpdateCouponData:(NSString *)column andValue:(NSString *)value andCouponID:(NSString *)couponid;
- (NSString *)dbLoadColumnData:(NSString *)which_column ByColumn:(NSString *)bycolumn AndValue:(NSString *)value;
- (void)dbUpdateCouponDataAfterUsed:(NSString *)couponid;
@end
