//
//  MoreViewController.h
//  CloudCall
//
//  Created by CloudCall on 13-4-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"
#import <iAd/iAd.h>

#import "CTBannerView.h"
#import "MoreViewCell.h"

#import "BaiduMobAdView.h"
#import <immobSDK/immobView.h>
#import "BannerViewContainer.h"

//icon类
@interface ItemsData : NSObject
{
    BOOL enable;
    BOOL need2Update;
    int index;

    NSString *iconUrl;
    NSString *title;
    NSString *url;
    NSString *update_time;
}
@property (nonatomic, retain) NSString *iconUrl;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *update_time;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) BOOL need2Update;
@property (nonatomic, assign) int index;

- (id) initWithTitle:(NSString *)_title withIconUrl:(NSString *)_iconUrl withUrl:(NSString *)_url withEnable:(BOOL)_enable withIndex:(NSInteger)_index withUpdateTime:(NSString *)_update_time;
@end



@interface MoreViewController : UIViewController <UIAlertViewDelegate, ADBannerViewDelegate, BannerViewContainer, MoreViewCellDelegate>
{
    UIView         *viewToolbar;
    UIToolbar      *toolbar;
    UILabel        *labelTitle;

    UIView *rHeaderView;
    UIImageView *photo;
    UILabel *name;
    UIImageView *vipLevel;
    UILabel *phoneNum;
    UIButton *personalInfBtn;
    UIButton *rechargeBtn;
    
    UIButton* barButtonSetting;
    
    UIView *viewGetCloudCallPoint;
    UILabel *labelGetCloudCallPoint;
    UIButton *wenHaoBtn;
    UIView *viewPracticalFunction;
    UILabel *labelPracticalFunction;
    
    NSMutableArray *tempItemsArray;
    UIScrollView *scrollView;
@private
    ADBannerView *iadbanner;

    immobView *lmbanner;
    CTBannerView* ctbanner;
    BaiduMobAdView *bdbanner;
    
    UIButton *buttonAd;

    UIAlertView *alertProcess;
    BOOL alertShow;

    NSString* lastMsgCallId;

    NSString* versionUrl;

    BOOL showAllFeature;
    BOOL showInAppPurchase;
}

@property (nonatomic, retain) NSMutableArray *tempItemsArray;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView             *viewToolbar;
@property (nonatomic, retain) IBOutlet UIToolbar          *toolbar;
@property (nonatomic, retain) IBOutlet UILabel            *labelTitle;

@property (nonatomic, retain) IBOutlet UIView *rHeaderView;
@property (nonatomic, retain) IBOutlet UIImageView *photo;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UIImageView *vipLevel;
@property (nonatomic, retain) IBOutlet UILabel *phoneNum;
@property (nonatomic, retain) IBOutlet UIButton *personalInfBtn;
@property (nonatomic, retain) IBOutlet UIButton *rechargeBtn;

@property (nonatomic, retain) IBOutlet UIView *viewGetCloudCallPoint;
@property (nonatomic, retain) IBOutlet UIView *viewPracticalFunction;
@property (nonatomic, retain) IBOutlet UILabel *labelGetCloudCallPoint;
@property (nonatomic, retain) IBOutlet UILabel *labelPracticalFunction;
@property (nonatomic, retain) IBOutlet UIButton *wenHaoBtn;

@property(nonatomic,retain) IBOutlet UIButton           *buttonAd;

@property(nonatomic,retain) IBOutlet UIButton* barButtonSetting;
- (IBAction) onButtonToolBarItemClick: (id)sender;
- (IBAction) onButtonClick: (id)sender;
- (void)buttonClickCallBack:(NSInteger)index;

- (void)updateView;
- (void)SignInRemindCallBack;
@end
