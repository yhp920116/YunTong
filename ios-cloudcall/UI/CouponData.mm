//
//  CouponData.m
//  CloudCall
//
//  Created by CloudCall on 13-5-9.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "CouponData.h"

@implementation CouponData
@synthesize coupon_id;
@synthesize coupon_who;
@synthesize coupon_type_id;
@synthesize coupon_name;
@synthesize coupon_price;
@synthesize coupon_detail;
@synthesize coupon_thumbnail_url;
@synthesize coupon_image_url;
@synthesize coupon_validity;
@synthesize coupon_total;
@synthesize coupon_remain;
@synthesize coupon_classify;
@synthesize coupon_brand;
@synthesize province;
@synthesize city;
@synthesize shop_id;
@synthesize update_time;
@synthesize type;
@synthesize available;
@synthesize coupon_thumbnail_url_local;
@synthesize coupon_image_url_local;
@synthesize need2Update;

- (CouponData*) initWithId:(NSString *)_coupon_id
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
{
    if ((self = [super init])) {
        self.coupon_id = _coupon_id;
        self.coupon_type_id = _coupon_type_id;
        self.coupon_who = _coupon_who;
        self.coupon_name = _coupon_name;
        self.coupon_price = _coupon_price;
        self.coupon_detail = _coupon_detail;
        self.coupon_thumbnail_url = _thumbnail_url;
        self.coupon_image_url = _coupon_image_url;
        self.coupon_validity = _coupon_validity;
        self.coupon_total = _coupon_total;
        self.coupon_remain = _coupon_remain;
        self.coupon_classify = _coupon_classify;
        self.coupon_brand = _coupon_brand;
        self.province = _province;
        self.city = _city;
        self.shop_id = _shop_id;
        self.update_time = _update_time;
        self.type = _type;
        self.available = _available;
        self.coupon_thumbnail_url_local = _thumbnail_url_local;
        self.coupon_image_url_local = _image_url_local;
	}
	return self;
}

-(void) dealloc {
    [coupon_id release];
    [coupon_type_id release];
    [coupon_name release];
    [coupon_price release];
    [coupon_detail release];
    [coupon_thumbnail_url release];
    [coupon_image_url release];
    [coupon_validity release];
    [coupon_total release];
    [coupon_remain release];
    [coupon_classify release];
    [coupon_brand release];
    [province release];
    [city release];
    [shop_id release];
    [update_time release];
    [type release];
    [coupon_thumbnail_url_local release];
    [coupon_image_url_local release];
    
    [super dealloc];
}

@end
