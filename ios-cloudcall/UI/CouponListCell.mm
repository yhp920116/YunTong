//
//  CouponListCell.m
//  CloudCall
//
//  Created by Sergio on 13-5-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "CouponListCell.h"

@implementation CouponListCell
@synthesize couponImage;
@synthesize couponTitle;
@synthesize couponLimitDate;
@synthesize couponPrice;
@synthesize couponOwnNumber;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCoupon:(CouponData *)_conpon
{
    //self.couponImage.image = [];
    self.couponTitle.text = _conpon.coupon_name;
    self.couponLimitDate.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Date of expiry", @"Date of expiry"), _conpon.coupon_validity];
    if (_conpon.available)
        self.couponPrice.text = [NSString stringWithFormat:@"￥%@", _conpon.coupon_price];
    else
    {
        self.couponPrice.text = NSLocalizedString(@"Used", @"Used");
        [self.couponPrice setFont:[UIFont systemFontOfSize:16]];
        [self.couponPrice setTextColor:[UIColor grayColor]];
    }
}

- (void)dealloc
{
    [couponImage release];
    [couponTitle release];
    [couponLimitDate release];
    [couponPrice release];
    [couponOwnNumber release];
    
    [super dealloc];
}

@end