//
//  SlotMachineViewController.h
//  CloudCall
//
//  Created by Sergio on 13-3-4.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"
#import "WEPopoverController.h"
#import "CloudCall2AppDelegate.h"
#import "JHTickerView.h"
#import "MBProgressHUD.h"
#import "SSCheckBoxView.h"
#import "SelectTableViewController.h"
#import "ZCSlotMachine.h"

#define kSlotMachineAdsInfoFileName @"ccslotmachineadsfile.plist"

#define kKeyGetSlotMachineResult @"kKeyGetSlotMachineResult"
#define kKeyDownloadAds @"kKeyDownloadAds"
#define kKeyGetSlotMachineInitData @"kKeyGetSlotMachineInitData"

//AlertType
#define kAlertTypeSlotMachineNetWorkErr 0
#define kAlertTypeSlotMachineLoadingPrize 1
#define kAlertTypeSlotMachineBetMoreThanBalance 2
#define kAlertTypeSlotMachineSelectBet 3
#define kAlertTypeSlotMachineResultNoResp 4

@interface SlotMachineViewController : UIViewController<UIAlertViewDelegate, SelectTableViewDelegate, ZCSlotMachineDelegate, ZCSlotMachineDataSource>
{
    ZCSlotMachine *_slotMachine;
    BOOL isAllowToShake;
    BOOL isFinishUpdateAds;
    
    NSMutableArray *column;

    NSTimer *timer;
    
    int ROUNDCOUNT;

    NSArray *wheelArray;
    
    UITextField *bet;
    UITextField *gain;
    UITextField *remindPoint;
    BOOL canShowRollingSubtitle;
    JHTickerView *rollingView;
    NSString *subtitle;
    
    BOOL connectionfinish;
    BOOL isNetWorkError;
    BOOL isShowError;
    BOOL initSlotMachineImg;
    
    int gainPoints;
    int balance;
    int awardsname;
    int adsCount;
    int flagBigPrize;
    NSString *bigPrizeText;
    
    NSMutableArray *slotmachineAdsInfo;
    NSMutableArray *pointListArray;
    
    AVAudioPlayer *player;
    NSString *shareString;
    NSMutableArray *betBefore;
    NSMutableArray *betAffer;
    
    MBProgressHUD *HUD;
    
    SSCheckBoxView *cbNeverPrompt;
    SSCheckBoxView *cbRead;
    UIWindow *alertLevelWindow;
}

@property (nonatomic,retain) NSMutableArray *column;
@property (nonatomic,retain) NSArray *wheelArray;
@property (nonatomic,retain) IBOutlet UIView *pointsView;
@property (nonatomic,retain) IBOutlet UILabel *lblBet;
@property (nonatomic,retain) IBOutlet UITextField *bet;
@property (nonatomic,retain) IBOutlet UILabel *lblGain;
@property (nonatomic,retain) IBOutlet UITextField *gain;
@property (nonatomic,retain) IBOutlet UILabel *lblRemindPoint;
@property (nonatomic,retain) IBOutlet UITextField *remindPoint;
@property (nonatomic,assign) int balance;

@property (nonatomic,retain) IBOutlet UIView *btnView;
@property (nonatomic,retain) IBOutlet UIButton *btnBet;
@property (nonatomic,retain) IBOutlet UIButton *btnGo;
@property (nonatomic,retain) IBOutlet UIButton *btnGameRules;
@property (nonatomic,retain) IBOutlet UIButton *btnSendWeibo;

@property (nonatomic,assign) BOOL canShowRollingSubtitle;
@property (nonatomic,retain) NSString *subtitle;

@property (nonatomic,retain) NSMutableArray *slotmachineAdsInfo;
@property (nonatomic,retain) NSMutableArray *pointListArray;
@property (nonatomic,retain) NSString *bigPrizeText;

@property (nonatomic,retain) WEPopoverController *popoverController;

@property (nonatomic,retain) NSString *shareString;
- (IBAction)onBtnClick:(id)sender;

@property (nonatomic,retain) IBOutlet UILabel *lblShowResult;

@end
