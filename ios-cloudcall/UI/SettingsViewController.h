/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "iOSNgnStack.h"
#import <iAd/iAd.h>
#import "CTBannerView.h"

#import <immobSDK/immobView.h>

#define kCloudCallAppID @"CloudCallAppID"

@interface SettingsViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate, ADBannerViewDelegate>
{
    UITableView    *tableView;
    
    UITableViewCell *cellCheckUpdate;
    
    UITableViewCell *cellSyncContacts;
    UILabel         *labelSyncContacts;
    UISwitch        *syncContacts;
    
    UITableViewCell *cellUse3G;
    UILabel         *labelUse3G;
    UISwitch        *use3G;
    
    UITableViewCell *cellDialTone;
    UILabel         *labelDialTone;
    UISwitch        *dialTone;
    
    UITableViewCell *cellCloudCallRate;
    UITableViewCell *cellCloudCallType;
    UITableViewCell *cellDeactivate;
    UITableViewCell *cellUseWizard;
    UITableViewCell *cellAbout;
    UITableViewCell *cellAppStorePraise;
    UITableViewCell *cellHelp;
    MBProgressHUD *HUD;
@private
    ADBannerView *iadbanner;
    immobView *lmbanner;
    CTBannerView* ctbanner;
    UIButton *buttonAd;
    
    UIAlertView *alertProcess;
    BOOL alertShow;
      
    NSString* lastMsgCallId;
    
    NSString* versionUrl;  
    
    UITableViewCell *cellSelected;
    
    BOOL needToReloadData;
}

@property(nonatomic,retain) IBOutlet UITableView        *tableView;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellCheckUpdate;
@property(nonatomic,retain) IBOutlet UITableViewCell    *cellUseWizard;
@property(nonatomic,retain) IBOutlet UITableViewCell    *cellAbout;
@property(nonatomic,retain) IBOutlet UITableViewCell    *cellAppStorePraise;
@property(nonatomic,retain) IBOutlet UITableViewCell    *cellHelp;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellSyncContacts;
@property(nonatomic,retain) IBOutlet UILabel            *labelSyncContacts;
@property(nonatomic,retain) IBOutlet UISwitch           *syncContacts;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellUse3G;
@property(nonatomic,retain) IBOutlet UILabel            *labelUse3G;
@property(nonatomic,retain) IBOutlet UISwitch           *use3G;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellDialTone;
@property(nonatomic,retain) IBOutlet UILabel            *labelDialTone;
@property(nonatomic,retain) IBOutlet UISwitch           *dialTone;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellCloudCallRate;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellCloudCallType;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellDeactivate;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellGetPassword;


@property(nonatomic,retain) IBOutlet UIButton           *buttonAd;

- (void)hideHUD;
- (IBAction) onButtonClick: (id)sender;
- (IBAction) onSwitchChanged: (id) sender;

@end
