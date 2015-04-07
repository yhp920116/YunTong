//
//  CouponData.h
//  CloudCall
//
//  Created by CloudCall on 13-5-9.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponData : NSObject
{
    NSString *coupon_id;
    NSString *coupon_who;
    NSString *coupon_type_id;
    NSString *coupon_name;
    NSString *coupon_price;
    NSString *coupon_detail;
    NSString *coupon_thumbnail_url;
    NSString *coupon_image_url;
    NSString *coupon_validity;
    NSString *coupon_total;
    NSString *coupon_remain;
    NSString *coupon_classify;
    NSString *coupon_brand;
    NSString *province;
    NSString *city;
    NSString *shop_id;
    NSString *update_time;
    NSString *coupon_type;
    BOOL available;
    NSString *coupon_thumbnail_url_local;
    NSString *coupon_image_url_local;
    
    BOOL need2Update;
}
@property(nonatomic, retain) NSString *coupon_id;
@property(nonatomic, retain) NSString *coupon_who;
@property(nonatomic, retain) NSString *coupon_type_id;
@property(nonatomic, retain) NSString *coupon_name;
@property(nonatomic, retain) NSString *coupon_price;
@property(nonatomic, retain) NSString *coupon_detail;
@property(nonatomic, retain) NSString *coupon_thumbnail_url;
@property(nonatomic, retain) NSString *coupon_image_url;
@property(nonatomic, retain) NSString *coupon_validity;
@property(nonatomic, retain) NSString *coupon_total;
@property(nonatomic, retain) NSString *coupon_remain;
@property(nonatomic, retain) NSString *coupon_classify;
@property(nonatomic, retain) NSString *coupon_brand;
@property(nonatomic, retain) NSString *province;
@property(nonatomic, retain) NSString *city;
@property(nonatomic, retain) NSString *shop_id;
@property(nonatomic, retain) NSString *update_time;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, assign) BOOL available;
@property(nonatomic, retain) NSString *coupon_thumbnail_url_local;
@property(nonatomic, retain) NSString *coupon_image_url_local;
@property(readwrite) BOOL need2Update;

- (CouponData*)initWithId:(NSString *)_coupon_id
                andTypeId:(NSString *)_coupon_type_id
                   andWho:(NSString *)_coupon_who
                  andName:(NSString *)_coupon_name
                 andPrice:(NSString *)_coupon_price
                andDetail:(NSString *)_coupon_detail
          andThumbNailUrl:(NSString *)_thumbnail_url
              andImageUrl:(NSString *)_coupon_image_url
              andValidity:(NSString *)_coupon_validity
                 andTotal:(NSString *)_coupon_total
                andRemain:(NSString *)_coupon_remain
              andClassify:(NSString *)_coupon_classify
                 andBrand:(NSString *)_coupon_brand
              andProvince:(NSString *)_province
                  andCity:(NSString *)_city
                andShopId:(NSString *)_shop_id
            andUpdateTime:(NSString *)_update_time
                  andType:(NSString *)_type
             andAvailable:(BOOL)_available
          andThumbNailUrlLocal:(NSString *)_thumbnail_url_local
              andImageUrlLocal:(NSString *)_image_url_local;

@end
