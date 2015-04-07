//
//  ProductInfoViewController.h
//  WeiCall
//
//  Created by guobiao chen on 12-4-16.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface IAPRechargeViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView *tableView;
    MBProgressHUD *_hud;
    UITableViewCell *cardRechargeCell;
    
@private
    UIAlertView *alert;
    
    NSString *productTitle;
    NSString *productPurchaseid;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *cardRechargeCell;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (retain) MBProgressHUD *hud;

- (void)showHud;
- (void)hideHud;
- (IBAction)cardRecharge:(id)sender;

@end
