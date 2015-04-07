//
//  AutoRegisterViewController.h
//  CloudCall
//
//  Created by Dan on 14-1-7.
//  Copyright (c) 2014年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginManager.h"
#import "ValidCodeBGView.h"
#import "ValidationViewController.h"

typedef NS_ENUM(NSInteger,Register_type) {
    Automatic_Register,
    Manual_Register,
    Get_Back_Password,
    Change_Password
};

typedef NS_ENUM(NSInteger, Registration_process){
    Phone_Verification,
    Password_Setting,
    Password_Resetting,
    Registration_Completed,
    Password_Updated
};

@interface ToRegisterViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>
{
    UIButton *nextBtn;
    UIButton *getCodeInVoiceBtn;
    UIButton *getCodeInSMSBtn;
    
    int         getcodeSeconds;
    NSTimer     *GetCodeAgainTimer;
    
    NSString    *userNumber;
    NSString    *userPwd;
    NSString    *verifyCode;
    
    PlatformInfo *platformInfo;

}
@property (nonatomic) Register_type registerType;
@property (nonatomic) Registration_process registrationProcess;


@property (retain, nonatomic) IBOutlet UIView *registrationProcessView;
@property (retain, nonatomic) IBOutlet UIButton *phoneVerificationBtn;
@property (retain, nonatomic) IBOutlet UIButton *passwordSettingBtn;
@property (retain, nonatomic) IBOutlet UIButton *completedBtn;

@property (retain, nonatomic) PlatformInfo *platformInfo;

/* Password Setting Control*/
@property (retain, nonatomic) IBOutlet UIControl *PWSettingControl;
@property (retain, nonatomic) IBOutlet UITextField *PWField;
@property (retain, nonatomic) IBOutlet UITextField *PWComfirmationField;
@property (retain, nonatomic) IBOutlet UIButton *submitCodeBtn;
@property (retain, nonatomic) IBOutlet UILabel *oneLabel;
@property (retain, nonatomic) IBOutlet UILabel *twoLabel;
@property (retain, nonatomic) IBOutlet UILabel *tipLabel;

/* Password Reset Control*/

@property (retain, nonatomic) IBOutlet UIScrollView *PWResetScrollView;
@property (retain, nonatomic) IBOutlet UITextField *currPwdField;
@property (retain, nonatomic) IBOutlet UITextField *theNewPwdFiled;
@property (retain, nonatomic) IBOutlet UITextField *theNewPwdComfirmationField;
@property (retain, nonatomic) IBOutlet UIButton *resetPwdBtn;
@property (retain, nonatomic) IBOutlet UILabel *lableOne;
@property (retain, nonatomic) IBOutlet UILabel *lableTwo;
@property (retain, nonatomic) IBOutlet UILabel *lableThree;
@property (retain, nonatomic) IBOutlet UITextField *validCodeField;
@property (retain, nonatomic) IBOutlet ValidCodeBGView *validCodeBGView;
@property (retain, nonatomic) IBOutlet UILabel *label2;
@property (retain, nonatomic) IBOutlet UILabel *label1;
@property (retain, nonatomic) IBOutlet UILabel *label3;
@property (retain, nonatomic) IBOutlet UILabel *label4;

/* Registration Completed Control*/

@property (retain, nonatomic) IBOutlet UIControl *completedControl;
@property (retain, nonatomic) IBOutlet UILabel *congratulationLabel;
@property (retain, nonatomic) IBOutlet UILabel *accountNumLabel;

/* ManualRegisterControl*/
@property (retain, nonatomic) IBOutlet UIControl   *manualRegisterControl;
@property (retain, nonatomic) IBOutlet UITextField *inputField;

@property (retain, nonatomic) IBOutlet UILabel     *tipsLabel;

@property (retain, nonatomic) IBOutlet UIButton *nextBtn;
@property (retain, nonatomic) IBOutlet UIButton *getCodeInVoiceBtn;
@property (retain, nonatomic) IBOutlet UIButton *getCodeInSMSBtn;
@property (retain, nonatomic) IBOutlet UILabel *leftLabel;
@property (retain, nonatomic) NSString    *userNumber;
@property (retain, nonatomic) NSString    *userPwd;
@property (retain, nonatomic) NSString    *verifyCode;

@property (retain, nonatomic) IBOutlet UILabel *getCodeTipsLabel;
@end
