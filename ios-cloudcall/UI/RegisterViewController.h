//
//  RegisterViewController.h
//  CloudCall
//
//  Created by Dan on 14-1-6.
//  Copyright (c) 2014年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "ValidationViewController.h"

@interface RegisterViewController : UIViewController<MFMessageComposeViewControllerDelegate, MBProgressHUDDelegate>
{
    int haveRetryTimes;
    
    PlatformInfo *platformInfo;
    BOOL haveGetPhoneNum;
    MBProgressHUD *HUD;
    BOOL _readTerms;

}
@property (retain, nonatomic) IBOutlet UIButton *autoRegister;
@property (retain, nonatomic) IBOutlet UIButton *manualRegister;
@property (retain, nonatomic) IBOutlet UILabel *tips;

@property (retain, nonatomic) IBOutlet UIControl   *tipsControl;
@property (retain, nonatomic) IBOutlet UIButton *checkBox;
@property (retain, nonatomic) IBOutlet UILabel *middleLabel;
@property (retain, nonatomic) IBOutlet UIButton *termsOfService;

@property (nonatomic, retain) PlatformInfo *platformInfo;

@end
