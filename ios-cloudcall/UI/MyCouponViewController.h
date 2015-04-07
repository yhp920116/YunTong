//
//  CouponListViewController.h
//  CloudCall
//
//  Created by Sergio on 13-5-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouponListCell.h"
#import "MHLazyTableImages.h"
#import "CouponManager.h"
#import "CouponDetailViewController.h"

#define kTagDeleteCoupon 51

@interface MyCouponViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,MHLazyTableImagesDelegate,CouponManagerDelegate>
{
    NSMutableArray *couponArray;
    MHLazyTableImages *_lazyImages;
    NSArray *_entries;
	float longitude;
    float latitude;
    
    NSString *couponid;
}
@property (nonatomic, retain) NSMutableArray *couponArray;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *couponid;
@property (nonatomic, retain) IBOutlet UILabel *errorMsg;

- (void)setEntries:(NSArray *)entries;
@end
