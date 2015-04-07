/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import "LoginManager.h"


@interface PlatformInfo : NSObject
{
    NSString *platform;
    NSString *smsid;
    NSString *remark;
@public
    int tryTime;
    int retryTimes;
    int interval;
}
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *smsid;
@property (nonatomic, copy) NSString *remark;

@end

@interface ValidationViewController : UIViewController <UIAlertViewDelegate,UITextFieldDelegate> {
    UIImageView* imageViewPhoneNum;
    UITextField *textEditPhoneNum;
    
    UIImageView* imageViewCode;
    UITextField *textEditCode;
    
    UIButton    *buttonLogin;
    
    UIControl   *ValidationChildControl;
    NSString    *phoneNum;
    BOOL        isLogOut;
    MBProgressHUD *HUD;
    PlatformInfo *platformInfo;
    
@private
    
    NSString    *accessCode;
//    BOOL        listeningCode;

    int         state;

//    int         getcodeSeconds;
//    NSTimer     *GetCodeAgainTimer;
    
    UIToolbar* keyboardToolbar;
    
    UITextField* currEditing;
    NSString     *oldContent;
}
@property (nonatomic, assign) BOOL isLogOut;
@property(nonatomic,retain) IBOutlet UIImageView     *imageViewPhoneNum;
@property(nonatomic,retain) IBOutlet UITextField     *textEditPhoneNum;

@property(nonatomic,retain) IBOutlet UIImageView     *imageViewCode;
@property(nonatomic,retain) IBOutlet UITextField     *textEditCode;

@property(nonatomic,retain) IBOutlet UIButton        *buttonLogin;

@property(nonatomic,retain) IBOutlet UIControl       *ValidationChildControl;

@property (retain, nonatomic) IBOutlet UIButton *buttonForget;
@property (retain, nonatomic) IBOutlet UIButton *buttonRegister;
@property (retain, nonatomic) IBOutlet UIView *middleLine;

@property (nonatomic, retain) PlatformInfo *platformInfo;

- (IBAction) backgroundTap:(id)sender;
- (IBAction) onbuttonClick: (id)sender;

//- (void) getDataFromConfig;
- (void)hideHUD;

@end
