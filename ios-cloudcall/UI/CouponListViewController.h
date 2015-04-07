//
//  CouponListViewController.h
//  CloudCall
//
//  Created by Sergio on 13-5-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouponListCell.h"
#import <CoreLocation/CoreLocation.h>
#import "MHLazyTableImages.h"
#import "CouponManager.h"
#import "MBProgressHUD.h"

@interface CouponListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MHLazyTableImagesDelegate, CouponManagerDelegate>
{
    
    UIButton *classifyBtn;
    
    NSMutableArray *couponArray;
    MHLazyTableImages *_lazyImages;
    NSArray *_entries;
	float longitude;
    float latitude;
    
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) NSMutableArray *couponArray;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *errorMsg;

@end
