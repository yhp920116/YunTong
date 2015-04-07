/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"
#import <iAd/iAd.h>
#import "UMUFPBannerView.h"
#import <DianJinOfferPlatform/DianJinOfferBanner.h>
#import <immobSDK/immobView.h>
#import "BannerViewContainer.h"

@interface AccountViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate, ADBannerViewDelegate, BannerViewContainer> {
    UITableView    *tableView;
    UILabel        *labelTitle;
    
    UITableViewCell *cellMyNumber;
    UILabel    *labelMyNum;  
    UILabel    *myNum;
    UIButton    *buttonDeactivate;
    
    UITableViewCell *cellConnStatus;
    UILabel    *labelConnStatus;  
    UILabel    *connStatus;
    UIButton    *buttonLogin;
    
    UITableViewCell *cellNetStatus;
    UILabel    *labelNetStatus;  
    UILabel    *netStatus;
    
    UITableViewCell *cellSyncContacts;
    UILabel         *labelSyncContacts;  
    UISwitch        *syncContacts;
    
    UITableViewCell *cellUse3G;
    UILabel         *labelUse3G;  
    UISwitch        *use3G;
    
    UITableViewCell *cellDialTone;
    UILabel         *labelDialTone;  
    UISwitch        *dialTone;
    
    UITableViewCell *cellSendLog;
    UIButton *buttonSendLog;
    
    UITableViewCell *cellVersion;
    UILabel    *labelVersion;  
    UILabel    *version;
    
    UITableViewCell *cellCopyright;
    UILabel    *labelCopyright;
    
    NgnBaseService<INgnLogService>* mLogService;
    
@private
    ADBannerView *iadbanner;
    UMUFPBannerView *umbanner;
    DianJinOfferBanner *djbanner;    
    immobView *lmbanner;
    UIButton *buttonAd;
}

@property(nonatomic,retain) IBOutlet UITableView        *tableView;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellMyNumber;
@property(nonatomic,retain) IBOutlet UILabel            *labelMyNum;  
@property(nonatomic,retain) IBOutlet UILabel            *myNum;
@property(nonatomic,retain) IBOutlet UIButton           *buttonDeactivate;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellConnStatus;
@property(nonatomic,retain) IBOutlet UILabel            *labelConnStatus;  
@property(nonatomic,retain) IBOutlet UILabel            *connStatus;
@property(nonatomic,retain) IBOutlet UIButton           *buttonLogin;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellNetStatus;
@property(nonatomic,retain) IBOutlet UILabel            *labelNetStatus;  
@property(nonatomic,retain) IBOutlet UILabel            *netStatus;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellSyncContacts;
@property(nonatomic,retain) IBOutlet UILabel            *labelSyncContacts;  
@property(nonatomic,retain) IBOutlet UISwitch           *syncContacts;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellUse3G;
@property(nonatomic,retain) IBOutlet UILabel            *labelUse3G;  
@property(nonatomic,retain) IBOutlet UISwitch           *use3G;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellDialTone;
@property(nonatomic,retain) IBOutlet UILabel            *labelDialTone;  
@property(nonatomic,retain) IBOutlet UISwitch           *dialTone;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellSendLog;
@property(nonatomic,retain) IBOutlet UIButton           *buttonSendLog;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellVersion;
@property(nonatomic,retain) IBOutlet UILabel            *labelVersion;  
@property(nonatomic,retain) IBOutlet UILabel            *version;

@property(nonatomic,retain) IBOutlet UITableViewCell    *cellCopyright;
@property(nonatomic,retain) IBOutlet UILabel            *labelCopyright;

@property(nonatomic,retain) IBOutlet UIButton            *buttonAd;

- (IBAction) onButtonClick: (id)sender;

- (IBAction) onSwitchChanged: (id) sender;

@end
