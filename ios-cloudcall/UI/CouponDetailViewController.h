//
//  CouponDetailViewController.h
//  CloudCall
//
//  Created by Sergio on 13-5-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouponManager.h"

#define kTagUseTheCoupon 52

@interface CouponDetailViewController : UIViewController<CouponManagerDelegate>
{
    NSString *couponid;
    NSString *coupontypeid;
    NSString *picUrl;
    NSString *localUrl;
    NSString *couponTitle;
    NSString *price;
    NSString *detail;
    
    UIImageView *imgViewPic;
    UILabel *lblTitle;
    UILabel *lblPrice;
    UITextView *txtViewDetail;
    BOOL showRightToolBtn;
    BOOL showImgViewPicHidden;
    BOOL isFromGainCouponPage;
}

@property (nonatomic,retain) NSString *couponid;
@property (nonatomic,retain) NSString *coupontypeid;
@property (nonatomic,retain) NSString *picUrl;
@property (nonatomic,retain) NSString *localUrl;
@property (nonatomic,retain) NSString *couponTitle;
@property (nonatomic,retain) NSString *price;
@property (nonatomic,retain) NSString *detail;
@property (nonatomic,retain) IBOutlet UIImageView *imgViewPic;
@property (nonatomic,retain) IBOutlet UIImageView *imgViewPicHidden;
@property (nonatomic,retain) IBOutlet UILabel *lblTitle;
@property (nonatomic,retain) IBOutlet UILabel *lblPrice;
@property (nonatomic,retain) IBOutlet UITextView *txtViewDetail;
@property (nonatomic,assign) BOOL showRightToolBtn;
@property (nonatomic,assign) BOOL showImgViewPicHidden;
@property (nonatomic,assign) BOOL isFromGainCouponPage;
@end
