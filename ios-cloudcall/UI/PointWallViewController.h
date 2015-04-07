//
//  PointWallViewController.h
//  CloudCall
//
//  Created by CloudCall on 13-4-1.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <immobSDK/immobView.h>
#import "MBProgressHUD.h"
#import "DianRuAdWall.h"

enum {
    kPointWall_91DianJin = 1,
    kPointWall_LiMei,
    kPointWall_DianRu
};


@interface PointWallViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, immobViewDelegate, DianRuAdWallDelegate>
{
    int lm_score;
    int dianru_score;
    int maxExchangePoints;
    UITableView    *tableView;
    
    BOOL maxIntegralExchange;
    BOOL show91Only;
    NSMutableArray *aplist;
    
    MBProgressHUD *HUD;
@private
    
    NSString* lastMsgCallId;
}

@property (nonatomic,retain) IBOutlet UIView *tipView;
@property (nonatomic,retain) IBOutlet UILabel *tipText;
@property (nonatomic,retain) IBOutlet UIButton *btnCloseTip;
@property (nonatomic,retain) NSMutableArray *aplist;

@property(nonatomic,retain) IBOutlet UITableView        *tableView;
@property (nonatomic, retain) immobView *lm_AdWall;

- (void)hideHUD;
- (void)LiMeiRecommendedSoftware;
@end
