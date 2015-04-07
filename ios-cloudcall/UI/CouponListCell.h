//
//  CouponListCell.h
//  CloudCall
//
//  Created by Sergio on 13-5-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouponData.h"

@interface CouponListCell : UITableViewCell
{
    UIImageView *couponImage;
    UILabel *couponTitle;
    UILabel *couponLimitDate;
    UILabel *couponPrice;
    UILabel *couponOwnNumber;
}

@property (nonatomic,retain) IBOutlet UIImageView *couponImage;
@property (nonatomic,retain) IBOutlet UILabel *couponTitle;
@property (nonatomic,retain) IBOutlet UILabel *couponLimitDate;
@property (nonatomic,retain) IBOutlet UILabel *couponPrice;
@property (nonatomic,retain) IBOutlet UILabel *couponOwnNumber;

- (void)setCoupon:(CouponData *)_conpon;
@end
