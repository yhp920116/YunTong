//
//  AutoRegisterViewController.m
//  CloudCall
//
//  Created by Dan on 14-1-7.
//  Copyright (c) 2014年 CloudTech. All rights reserved.
//

#import "ToRegisterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "HttpRequest.h"
#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"



#define kGetCodeReasonRegister  @"register"
#define kGetCodeReasonRenew     @"renew"

#define kGetCodeTypeSMS         @"sms"
#define kGetCodeTypeVoice       @"voice"

#define BACK_TAG 888

@interface ToRegisterViewController ()
{
    NSMutableArray *_pointArray;
    int _number;
    NSMutableString *_strValidCode;
}

@end

@implementation ToRegisterViewController (KeyboardNotifications)

-(void) keyboardWillHide:(NSNotification *)note{
	[self keyboardNotificationWithNote:note willShow:NO];
}

-(void) keyboardWillShow:(NSNotification *)note{
	[self keyboardNotificationWithNote:note willShow:YES];
}

-(void) keyboardNotificationWithNote:(NSNotification *)note willShow: (BOOL)showing{
    if (showing)
    {
       
    }
    else {
        
    }
}


@end

@implementation ToRegisterViewController
@synthesize getCodeInSMSBtn;
@synthesize getCodeInVoiceBtn;
@synthesize nextBtn;
@synthesize userNumber;
@synthesize userPwd;
@synthesize verifyCode;
@synthesize platformInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - viewMethod

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*    
     1.使用setNavigationBarHidden:会导致左右滑动出现莫名bug
     2.使用setNavigationBarHidden:会导致NavigationBar实际消失，即按照xib的frame排列
     3.不使用setNavigationBarHidden，则xib的frame载NavigationBar以下按照frame排列
    */
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
//    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+44, self.view.frame.size.width, self.view.frame.size.height)];
//    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialProcessControl];
    
    self.PWSettingControl.frame = CGRectMake(35, self.registrationProcessView.frame.origin.y+60, 250, 128);
    self.completedControl.frame = CGRectMake(35, self.registrationProcessView.frame.origin.y+60, 250, 108);

    self.manualRegisterControl.frame = CGRectMake(35, self.registrationProcessView.frame.origin.y+60, 250, 194);
    self.PWResetScrollView.frame = CGRectMake(35, self.registrationProcessView.frame.origin.y+60, 250, 222);

    if (IS_SCREEN_35_INCH || IS_IPAD) {
        self.PWResetScrollView.contentSize = CGSizeMake(250, 312);
    }
    self.getCodeTipsLabel.text = self.platformInfo.remark;

    if (self.registerType == Automatic_Register)
    {
        
        [self.view addSubview:self.PWSettingControl];
        [self.view addSubview:self.completedControl];
        
        self.title = NSLocalizedString(@"AutoRegister", @"AutoRegister");
        [self.phoneVerificationBtn setTitle:NSLocalizedString(@"Phone Verification", @"Phone Verification") forState:UIControlStateNormal];
        [self.passwordSettingBtn setTitle:NSLocalizedString(@"Set Password", @"Set Password") forState:UIControlStateNormal];
        [self.completedBtn setTitle:NSLocalizedString(@"Registration Completed", @"Registration Completed") forState:UIControlStateNormal];
        
    }
    else if (self.registerType == Manual_Register)
    {
        [self.view addSubview:self.PWSettingControl];
        [self.view addSubview:self.completedControl];
        [self.view addSubview:self.manualRegisterControl];
        
        self.title = NSLocalizedString(@"ManualRegister", @"ManualRegister");
        self.nextBtn.hidden = YES;
        self.getCodeInSMSBtn.frame = CGRectMake(getCodeInSMSBtn.frame.origin.x, getCodeInSMSBtn.frame.origin.y-40, getCodeInSMSBtn.frame.size.width, getCodeInSMSBtn.frame.size.height);
        self.getCodeInVoiceBtn.frame = CGRectMake(getCodeInVoiceBtn.frame.origin.x, getCodeInVoiceBtn.frame.origin.y-40, getCodeInVoiceBtn.frame.size.width, getCodeInVoiceBtn.frame.size.height);
        
        [self.getCodeInVoiceBtn setTitle:NSLocalizedString(@"Listen Code", @"Listen Code") forState:UIControlStateNormal];
        [self.getCodeInSMSBtn setTitle:NSLocalizedString(@"Get Code", @"Get Code") forState:UIControlStateNormal];
        
        [self.nextBtn setTitle:NSLocalizedString(@"Next", @"Next") forState:UIControlStateNormal];
        [self.phoneVerificationBtn setTitle:NSLocalizedString(@"Phone Verification", @"Phone Verification") forState:UIControlStateNormal];
        [self.passwordSettingBtn setTitle:NSLocalizedString(@"Set Password", @"Set Password") forState:UIControlStateNormal];
        [self.completedBtn setTitle:NSLocalizedString(@"Registration Completed", @"Registration Completed") forState:UIControlStateNormal];
    }
    else if (self.registerType == Get_Back_Password)
    {
        [self.view addSubview:self.PWSettingControl];
        [self.view addSubview:self.completedControl];
        [self.view addSubview:self.manualRegisterControl];
        
        self.title = NSLocalizedString(@"GetPassword", @"GetPassword");
        
        self.nextBtn.hidden = YES;
        self.getCodeInSMSBtn.frame = CGRectMake(getCodeInSMSBtn.frame.origin.x, getCodeInSMSBtn.frame.origin.y-40, getCodeInSMSBtn.frame.size.width, getCodeInSMSBtn.frame.size.height);
        self.getCodeInVoiceBtn.frame = CGRectMake(getCodeInVoiceBtn.frame.origin.x, getCodeInVoiceBtn.frame.origin.y-40, getCodeInVoiceBtn.frame.size.width, getCodeInVoiceBtn.frame.size.height);
        
        [self.getCodeInVoiceBtn setTitle:NSLocalizedString(@"Listen Code", @"Listen Code") forState:UIControlStateNormal];
        [self.getCodeInSMSBtn setTitle:NSLocalizedString(@"Get Code", @"Get Code") forState:UIControlStateNormal];
        
        [self.phoneVerificationBtn setTitle:NSLocalizedString(@"Phone Verification", @"Phone Verification") forState:UIControlStateNormal];
        [self.passwordSettingBtn setTitle:NSLocalizedString(@"Reset Password", @"Reset Password") forState:UIControlStateNormal];
        [self.completedBtn setTitle:NSLocalizedString(@"Password Updated", @"Password Updated") forState:UIControlStateNormal];
    }
    else //Change_Password
    {
        [self.view addSubview:self.PWResetScrollView];
        [self.view addSubview:self.completedControl];
        
        //if registerType is Change_Password then catch user phonenum from CoreData
        self.title = NSLocalizedString(@"Reset Password", @"Reset Password");
        self.userNumber = [[CloudCall2AppDelegate sharedInstance] getUserName];
                
        [self.phoneVerificationBtn setTitle:NSLocalizedString(@"Phone Verification", @"Phone Verification") forState:UIControlStateNormal];
        [self.passwordSettingBtn setTitle:NSLocalizedString(@"Reset Password", @"Reset Password") forState:UIControlStateNormal];
        [self.completedBtn setTitle:NSLocalizedString(@"Password Updated", @"Password Updated") forState:UIControlStateNormal];

    }
    

    UIButton *barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [barButtonItemBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [barButtonItemBack addTarget:self action:@selector(backBtnClick:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:barButtonItemBack] autorelease];
    
    
    [self setViewState:self.registrationProcess];
    
}

#pragma mark - initialProcessControl
- (void)initialProcessControl
{
    if (SystemVersion >=7.) {
        /*
         1.如果UINavigationController使用的是系统的默认（即没有装载图片），则xib里面的控件按照的是原本的Frame值来排列
         2.如果给UINavigationController设置NavigationBar的背景图片，则xib里面的控制则是在NavigationBar底下排列
         */
        
        if ([[UIDevice currentDevice].model isEqualToString:@"iPhone Simulator"]) {
            [self.registrationProcessView setFrame:CGRectMake(self.registrationProcessView.frame.origin.x, self.registrationProcessView.frame.origin.y+44+20, self.registrationProcessView.frame.size.width, self.registrationProcessView.frame.size.height)];
        }
        else
        {
            [self.registrationProcessView setFrame:CGRectMake(self.registrationProcessView.frame.origin.x, self.registrationProcessView.frame.origin.y, self.registrationProcessView.frame.size.width, self.registrationProcessView.frame.size.height)];
        }
        
    }
    
    self.registrationProcessView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.registrationProcessView.layer.shadowOffset = CGSizeMake(0, 0.3);
    self.registrationProcessView.layer.shadowOpacity = 0.5;
    self.registrationProcessView.layer.shadowRadius = 0.5;
}

#pragma mark - setViewState

- (void)setViewState:(Registration_process)process
{
    [self.registrationProcessView setHidden:NO];
    
    if (process == Phone_Verification)
    {
        [self.phoneVerificationBtn setTitleColor:[UIColor colorWithRed:0.5020 green:0.6510 blue:0.3176 alpha:1] forState:UIControlStateNormal];
        [self.passwordSettingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.completedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.manualRegisterControl setHidden:NO];
        [self.PWSettingControl setHidden:YES];
        [self.completedControl setHidden:YES];
        
        /* 手机验证的第一步是无需出现重新获取验证码的button */
        [self.getCodeInVoiceBtn setHidden:NO];
        [self.getCodeInSMSBtn setHidden:NO];
         
        
        [self.inputField setKeyboardType:UIKeyboardTypeNumberPad];
        [self.inputField setPlaceholder:NSLocalizedString(@"Please input your cell phone number", @"Please input your cell phone number")];
        [self.nextBtn setTitle:NSLocalizedString(@"Next", @"Next") forState:UIControlStateNormal];
        [self.leftLabel setText:NSLocalizedString(@"Cellphone No.", "Cellphone No.")];
        
    
        
    }
    else if (process == Password_Setting)
    {
        [self.phoneVerificationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.passwordSettingBtn setTitleColor:[UIColor colorWithRed:0.5020 green:0.6510 blue:0.3176 alpha:1] forState:UIControlStateNormal];
        [self.completedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        if (self.registerType != Automatic_Register) {
            [self.manualRegisterControl setHidden:YES];
        }
        
        [self.PWSettingControl setHidden:NO];
        [self.completedControl setHidden:YES];
        
        [self.PWField setSecureTextEntry:YES];
        [self.PWComfirmationField setSecureTextEntry:YES];
        [self.PWField setPlaceholder:NSLocalizedString(@"Please enter your password", @"Please enter your password")];
        [self.PWComfirmationField setPlaceholder:NSLocalizedString(@"Please enter your password again", @"Please enter your password agin")];
        [self.submitCodeBtn setTitle:NSLocalizedString(@"Submit Code", @"Submit Code") forState:UIControlStateNormal];
        [self.oneLabel setText:NSLocalizedString(@"Set Password", @"Set Password")];
        [self.twoLabel setText:NSLocalizedString(@"Input Again", @"Input Again")];
        
        
    }
    else if (process == Password_Resetting) //Only when user logined,would the process be Password_Resetting.
    {
        [self.phoneVerificationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.passwordSettingBtn setTitleColor:[UIColor colorWithRed:0.5020 green:0.6510 blue:0.3176 alpha:1] forState:UIControlStateNormal];
        [self.completedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.PWResetScrollView setHidden:NO];
        [self.completedControl setHidden:YES];
        
        [self.currPwdField setSecureTextEntry:YES];
        [self.theNewPwdFiled setSecureTextEntry:YES];
        [self.theNewPwdComfirmationField setSecureTextEntry:YES];
        [self.currPwdField setPlaceholder:NSLocalizedString(@"Please enter your old password", @"Please enter your old password")];
        [self.theNewPwdFiled setPlaceholder:NSLocalizedString(@"Please enter your new password", @"Please enter your new password")];
        [self.theNewPwdComfirmationField setPlaceholder:NSLocalizedString(@"Please enter your password again", @"Please enter your password agin")];
        
        self.currPwdField.delegate = self;
        self.theNewPwdFiled.delegate = self;
        self.theNewPwdComfirmationField.delegate = self;
        self.validCodeField.delegate = self;
        
        [self.lableOne setText:NSLocalizedString(@"Old Password", @"Old Password")];
        [self.lableTwo setText:NSLocalizedString(@"Set New Password", @"Set New Password")];
        [self.lableThree setText:NSLocalizedString(@"Input Again", @"Input Again")];
        [self.resetPwdBtn setTitle:NSLocalizedString(@"Submit Code", @"Submit Code") forState:UIControlStateNormal];
        
        //validCode
        [self.validCodeBGView setBackgroundColor:[self getRandomColor]];
        
        self.validCodeBGView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeValidCode:)];
        [self.validCodeBGView addGestureRecognizer:singleTap];
        
        _pointArray = [[NSMutableArray alloc] initWithCapacity:6];
        
        [self changeValidCode:nil];
        

        if (IS_SCREEN_35_INCH || IS_IPAD)
        {
            [self.PWResetScrollView setFrame:CGRectMake(self.PWResetScrollView.frame.origin.x, self.registrationProcessView.frame.origin.y+44+40+20, self.PWResetScrollView.frame.size.width, self.PWResetScrollView.frame.size.height)];
        }
        else
        {
            [self.PWResetScrollView setFrame:CGRectMake(self.PWResetScrollView.frame.origin.x, self.registrationProcessView.frame.origin.y+20, self.PWResetScrollView.frame.size.width, self.PWResetScrollView.frame.size.height)];
        }        
        
    }
    
    else if (process == Registration_Completed)
    {
        [self.phoneVerificationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.passwordSettingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.completedBtn setTitleColor:[UIColor colorWithRed:0.5020 green:0.6510 blue:0.3176 alpha:1] forState:UIControlStateNormal];
        
        if (self.registerType != Automatic_Register) {
            [self.manualRegisterControl setHidden:YES];

        }
        [self.PWSettingControl setHidden:YES];
        [self.completedControl setHidden:NO];
        
        
        //显示手机号码
        self.accountNumLabel.text = [NSString stringWithFormat:@"%@%@", self.accountNumLabel.text, self.userNumber];
        self.navigationItem.hidesBackButton =YES;
        
    }
    else if (process == Password_Updated)
    {
        [self.phoneVerificationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.passwordSettingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.completedBtn setTitleColor:[UIColor colorWithRed:0.5020 green:0.6510 blue:0.3176 alpha:1] forState:UIControlStateNormal];
        
        if (self.registerType == Get_Back_Password) {
            [self.manualRegisterControl setHidden:YES];
            [self.PWSettingControl setHidden:YES];
            [self.completedControl setHidden:NO];
        }
        
        if (self.registerType == Change_Password) {
            [self.completedControl setHidden:NO];
            [self.PWResetScrollView setHidden:YES];
            
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.labelText = @"重新登录中..";
            [self.view addSubview:hud];
            [hud showAnimated:YES whileExecutingBlock:^{
                [self userAutoLogin];
            } completionBlock:^{
                [hud removeFromSuperview];
                [hud release];
            }];
            
        }
        
        self.congratulationLabel.text = @"恭喜你修改密码成功！";

        //显示手机号码
        self.accountNumLabel.text = [NSString stringWithFormat:@"%@%@", self.accountNumLabel.text, self.userNumber];
        self.navigationItem.hidesBackButton =YES;
    }
}

- (void)userAutoLogin
{
    //先注销
    CloudCall2AppDelegate *appDelegate = [CloudCall2AppDelegate sharedInstance];
    
    [[HttpRequest instance] clearDelegatesAndCancel];
    
    [[NgnEngine sharedInstance].sipService stopStackSynchronously];
    
    [[NgnEngine sharedInstance].contactService dbClearWeiCallUsers];
    
    [[NgnEngine sharedInstance].configurationService setStringWithKey:ACCOUNT_REFEREE andValue:DEFAULT_ACCOUNT_REFEREE];
    
    [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:DEFAULT_GENERAL_ACCESS_CONTACTS_LIST];
    
    [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:self.userNumber forKey:IDENTITY_IMPI];
    [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:self.userPwd forKey:IDENTITY_PASSWORD];
    appDelegate.username = DEFAULT_IDENTITY_IMPI;
    appDelegate.password = DEFAULT_IDENTITY_PASSWORD;
    
    //xmpp go off line and disconnect
    [appDelegate disConnect];
    [[NgnEngine sharedInstance].configurationService setBoolWithKey:@"click_reload_once" andValue:NO];
    
    
    //Auto login while registerType is Change_Password
    LoginManager *loginManager = [LoginManager shareInstance];
    [loginManager httpLoginUserNum:self.userNumber UserPwd:self.userPwd HttpLoginSuccessBlock:^{
        
    } HttpLoginFailedBlock:^{
        
        //自动登录失败
        [[HttpRequest instance] clearDelegatesAndCancel];

        [[NgnEngine sharedInstance].sipService stopStackSynchronously];
        
        [[NgnEngine sharedInstance].contactService dbClearWeiCallUsers];
        
        [[NgnEngine sharedInstance].configurationService setStringWithKey:ACCOUNT_REFEREE andValue:DEFAULT_ACCOUNT_REFEREE];
        
        [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:DEFAULT_GENERAL_ACCESS_CONTACTS_LIST];
        
        [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:DEFAULT_IDENTITY_IMPI forKey:IDENTITY_IMPI];
        [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:DEFAULT_IDENTITY_PASSWORD forKey:IDENTITY_PASSWORD];
        appDelegate.username = DEFAULT_IDENTITY_IMPI;
        appDelegate.password = DEFAULT_IDENTITY_PASSWORD;
        
        //xmpp go off line and disconnect
        [appDelegate disConnect];
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:@"click_reload_once" andValue:NO];
        [appDelegate displayValidationView];

    }];
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.validCodeField])
    {
        [self onButtonClick:self.resetPwdBtn];
    }
    else
    {
        [self.view endEditing:YES];

    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    NSUInteger newLength = [textField.text length] + string.length;
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    //只能输入数字
    if ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0 || [string isEqualToString:@""]) {
        if ([textField isEqual:self.inputField]) {
            //手机号码只能是11位
            if (newLength > 11) {
                return NO;
            }
            return YES;
        }
        return YES;
    }
    else return YES;
}

#pragma mark - customized methods
-(void)timerGetCodeAgainTick:(NSTimer*)timer{
	// to be implemented for the call time display
    
    if (getcodeSeconds > 0) {
        getcodeSeconds--;
    }
    
    if (getcodeSeconds == 0) {
        [GetCodeAgainTimer invalidate];
        GetCodeAgainTimer = nil;
        
        [self.getCodeInVoiceBtn setTitle:NSLocalizedString(@"Listen Code Again", @"Listen Code Again") forState:UIControlStateNormal];
        [self.getCodeInSMSBtn setTitle:NSLocalizedString(@"Get Code Again", @"Get Code Again") forState:UIControlStateNormal];
        
        [self.getCodeInSMSBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.getCodeInVoiceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [getCodeInVoiceBtn setEnabled:YES];
        [getCodeInVoiceBtn setBackgroundImage:[UIImage imageNamed:@"greenbtn_normal.png"] forState:UIControlStateNormal];
        
        [getCodeInSMSBtn setEnabled:YES];
        [getCodeInSMSBtn setBackgroundImage:[UIImage imageNamed:@"greenbtn_normal.png"] forState:UIControlStateNormal];
        
        
        return;
    }
    [self.getCodeInVoiceBtn setTitle:[NSString stringWithFormat:@"%@(%d)", NSLocalizedString(@"Listen Code Again", @"Listen Code Again"), getcodeSeconds] forState:UIControlStateNormal];
    [self.getCodeInSMSBtn setTitle:[NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"Get Code Again", @"Get Code Again"), getcodeSeconds] forState:UIControlStateNormal];
    

}
- (void) startGetCodeTimer
{
    self.inputField.text = @"";
    getcodeSeconds = 60;

    self.getCodeInSMSBtn.enabled = NO;
    self.getCodeInVoiceBtn.enabled = NO;
    
    self.nextBtn.hidden = NO;
    self.tipsLabel.hidden = NO;
    self.leftLabel.text = @"验证码";
    self.inputField.placeholder = NSLocalizedString(@"Please input your verify code", @"Please input your verify code");
    
    self.getCodeInSMSBtn.frame = CGRectMake(getCodeInSMSBtn.frame.origin.x, 126, getCodeInSMSBtn.frame.size.width, getCodeInSMSBtn.frame.size.height);
    self.getCodeInVoiceBtn.frame = CGRectMake(getCodeInVoiceBtn.frame.origin.x, 164, getCodeInVoiceBtn.frame.size.width, getCodeInVoiceBtn.frame.size.height);
    
    [self.getCodeInSMSBtn setBackgroundImage:[UIImage imageNamed:@"getcode_normal"] forState:UIControlStateNormal];
    [self.getCodeInVoiceBtn setBackgroundImage:[UIImage imageNamed:@"getcode_normal"] forState:UIControlStateNormal];
    
    [self.getCodeInSMSBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.getCodeInVoiceBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [self.getCodeInSMSBtn setTitle:NSLocalizedString(@"Get Code Again", @"Get Code Again") forState:UIControlStateNormal];
    [self.getCodeInVoiceBtn setTitle:NSLocalizedString(@"Listen Code Again", @"Listen Code Again") forState:UIControlStateNormal];
    
    GetCodeAgainTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                         target:self
                                                       selector:@selector(timerGetCodeAgainTick:)
                                                       userInfo:nil
                                                        repeats:YES];
    
    
}

#pragma mark - Get Code From Servcer
- (BOOL)getCodeFromServer:(NSString*)Type andNumber:(NSString*)Number
{
    
    NSString *reason = (self.registerType == Get_Back_Password) ? kGetCodeReasonRenew : kGetCodeReasonRegister;
    BOOL succ;
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             Number, @"telnumber",
                             Type, @"type",
                             reason, @"reason", nil];
    
    CCLog(@"getCodeFromServer=%@", jsonDic);
    NSData *response = [[HttpRequest instance] sendRequestSyncWithEncrypt:kGetAuthCodeURL andMethod:@"POST" andContent:jsonDic andTimeout:10 andTarget:nil andSuccessSelector:NULL andFailureSelector:NULL];
    
    if (response && [response length] != 0)
    {
        NSMutableDictionary *root = [response mutableObjectFromJSONData];
        CCLog(@"getCodeFromServer result=%@", root);
        
        NSString *result    = [root objectForKey:@"result"];
        succ = [result isEqualToString:@"success"];
        if (!succ)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message:[root objectForKey:@"text"]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
        }
        return succ;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"数据获取失败"
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
    }
    return NO;
}

#pragma mark - Commit Verify Code To Server

- (BOOL)commitVerifyCodeToServer:(NSString *)_authcode
{
    NSString *reason = (self.registerType == Get_Back_Password) ? kGetCodeReasonRenew : kGetCodeReasonRegister;

    BOOL succ;
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             userNumber, @"telnumber",
                             _authcode, @"authcode",
                             reason, @"reason", nil];
    
    CCLog(@"commitVerifyCodeToServer=%@", jsonDic);
    NSData *response = [[HttpRequest instance] sendRequestSyncWithEncrypt:kVerifyAuthCodeURL andMethod:@"POST" andContent:jsonDic andTimeout:10 andTarget:nil andSuccessSelector:NULL andFailureSelector:NULL];
    if (response && [response length] != 0)
    {
        NSMutableDictionary *root = [response mutableObjectFromJSONData];
        CCLog(@"commitVerifyCodeToServer result=%@", root);
        
        NSString *result    = [root objectForKey:@"result"];
        succ = [result isEqualToString:@"success"];
        if (!succ)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message:[root objectForKey:@"text"]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
        }
        //当输入验证码成功时，才把手机号码写入coreData
        else  [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:userNumber forKey:IDENTITY_IMPI];
        return succ;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"数据获取失败"
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
    }
    return NO;
}

#pragma mark - Send User Passwod To Server

- (BOOL)setUserPassword:(NSString *)_password
{
    NSString *reason = (self.registerType == Get_Back_Password) ? kGetCodeReasonRenew:kGetCodeReasonRegister;

    BOOL succ;
    //保存密码
    self.userPwd = _password;
    
    //if registerType is Automatic_Register ,then get IMPI form CoreData 
    if (!self.userNumber) {
        self.userNumber = [[CloudCall2AppDelegate sharedInstance] getUserName];
    }
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             self.userNumber, @"telnumber",
                             _password, @"pwd",
                             reason, @"reason", nil];
    
    CCLog(@"setPassword=%@", jsonDic);
    NSData *response = [[HttpRequest instance] sendRequestSyncWithEncrypt:kSetPasswordURL andMethod:@"POST" andContent:jsonDic andTimeout:10 andTarget:nil andSuccessSelector:NULL andFailureSelector:NULL];
    if (response && [response length] != 0)
    {
        NSMutableDictionary *root = [response mutableObjectFromJSONData];
        CCLog(@"setPassword result=%@", root);
        
        NSString *result    = [root objectForKey:@"result"];
        succ = [result isEqualToString:@"success"];
        if (!succ)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message:[root objectForKey:@"text"]
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
        }
        return succ;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"数据获取失败"
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
    }
    return NO;
}

- (BOOL)resetUserPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword
{
    BOOL succ;
    self.userPwd = newPassword;
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             self.userNumber,@"telnumber",
                             oldPassword,@"curpwd",
                             self.userPwd,@"newpwd",nil];
    
    CCLog(@"resetPassword = %@",jsonDic);
    
    NSData *response = [[HttpRequest instance] sendRequestSyncWithEncrypt:kResetPasswordURL andMethod:@"POST" andContent:jsonDic andTimeout:10 andTarget:nil andSuccessSelector:NULL andFailureSelector:NULL];
    if (response && [response length] != 0) {
        NSMutableDictionary *root = [response mutableObjectFromJSONData];
        CCLog(@"ResetPassword result=%@",root);
        
        NSString *result    = [root objectForKey:@"result"];
        succ = [result isEqualToString:@"success"];
        if (!succ)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message:[root objectForKey:@"text"]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
        }
        return succ;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"数据获取失败"
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
    }
    return NO;
}



- (void)autoSignIn
{
    MBProgressHUD *getCodeHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:getCodeHUD];
    getCodeHUD.labelText = @"正在登录...";
    
    [getCodeHUD showAnimated:YES whileExecutingBlock:^{
        [NSThread sleepForTimeInterval:2.0f];
        
        LoginManager *loginManager = [LoginManager shareInstance];
        [loginManager httpLoginUserNum:self.userNumber UserPwd:self.userPwd HttpLoginSuccessBlock:^{
            
        } HttpLoginFailedBlock:^{
            
        }];
        
     
    }completionBlock:^{
        [getCodeHUD removeFromSuperview];
        [getCodeHUD release];
    }];
}


#pragma mark - ButtonMethods

- (IBAction)onButtonClick:(id)sender
{
    [self.view endEditing:YES];
    
    if (sender == self.submitCodeBtn) //user for Auto_Register/Manaul_Register/Get_Back_Password
    {
        if (_PWField.text == nil || [_PWField.text length] == 0 || _PWComfirmationField.text == nil || [_PWComfirmationField.text length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"密码不能为空"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        if (![_PWComfirmationField.text isEqualToString:_PWField.text])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"两次输入的密码不一致,请重新输入"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        if ([_PWComfirmationField.text haveChSymbol] || [_PWComfirmationField.text isEqualToString:@"00000"] || [_PWComfirmationField.text isEqualToString:@"995995"] || [_PWComfirmationField.text isEqualToString:@"22884646"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"含有非法字符,请重新输入"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            _PWField.text = @"";
            _PWComfirmationField.text = @"";
            return;
        }
        
        if ([_PWComfirmationField.text length] < 5)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"密码过短,请重新输入"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        if ([_PWComfirmationField.text length] > 15)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"密码过长,请重新输入"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        MBProgressHUD *getCodeHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:getCodeHUD];
        getCodeHUD.labelText = @"设置密码...";
        
        [getCodeHUD showAnimated:YES whileExecutingBlock:^{
            BOOL result;
            
            result= [self setUserPassword:_PWField.text];
           
            if (result)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    if (self.registerType == Get_Back_Password)
                        self.registrationProcess = Password_Updated;
                    else
                        self.registrationProcess = Registration_Completed;
                    
                    [self autoSignIn];
                    [self setViewState:self.registrationProcess];
                });
            }
        }completionBlock:^{
            [getCodeHUD removeFromSuperview];
            [getCodeHUD release];
        }];
    }
    else if (sender == self.resetPwdBtn)
    {
        BOOL networkState = [[NgnEngine sharedInstance].networkService isReachable];
        
        if (!networkState)
        {
            //改变验证码
            [self changeValidCode:nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge")message:NSLocalizedString(@"Unreachable", @"Unreachable") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        
        if (_currPwdField.text == nil || [_currPwdField.text length] == 0 || _theNewPwdFiled.text == nil || [_theNewPwdFiled.text length] == 0||_theNewPwdComfirmationField.text == nil || [_theNewPwdComfirmationField.text length] == 0)
        {
            [self changeValidCode:nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"新旧密码不能为空"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        if (![_theNewPwdFiled.text isEqualToString:_theNewPwdComfirmationField.text])
        {
            [self changeValidCode:nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"两次输入的密码不一致,请重新输入"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        if (_validCodeField.text == nil || [_validCodeField.text length] == 0) {

            [self changeValidCode:nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert") message:NSLocalizedString(@"Please enter the valid code!", @"Please enter the valid code!") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        else if (![_validCodeField.text isEqualToString:_strValidCode])
        {
            [self changeValidCode:nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert") message:NSLocalizedString(@"Invalid valid code!", @"Invalid valid code!") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [alert show];
            [alert release];

            return ;
        }
        
        if ([_theNewPwdComfirmationField.text haveChSymbol] || [_theNewPwdComfirmationField.text isEqualToString:@"00000"] || [_theNewPwdComfirmationField.text isEqualToString:@"995995"] || [_theNewPwdComfirmationField.text isEqualToString:@"22884646"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"含有非法字符,请重新输入"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            _theNewPwdFiled.text = @"";
            _theNewPwdComfirmationField.text = @"";
            return;
        }
        
        if ([_theNewPwdComfirmationField.text length] < 5)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"密码过短,请重新输入"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        if ([_theNewPwdComfirmationField.text length] > 15)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"密码过长,请重新输入"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        MBProgressHUD *getCodeHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:getCodeHUD];
        getCodeHUD.labelText = @"重设密码...";
        
        [getCodeHUD showAnimated:YES whileExecutingBlock:^{
            BOOL result;
            result= [self resetUserPassword:self.currPwdField.text newPassword:self.theNewPwdFiled.text];
            if (result)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.registrationProcess = Password_Updated;
                    [self setViewState:self.registrationProcess];
                });
            }
        }completionBlock:^{
            [getCodeHUD removeFromSuperview];
            [getCodeHUD release];
        }];

    }
    
    else if (sender == self.nextBtn)
    {
        self.verifyCode = self.inputField.text;
        
        if (_inputField.text == nil || [_inputField.text length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"验证码不能为空"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        MBProgressHUD *getCodeHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:getCodeHUD];
        getCodeHUD.labelText = @"提交验证码...";
        
        [getCodeHUD showAnimated:YES whileExecutingBlock:^{
            BOOL result = [self commitVerifyCodeToServer:verifyCode];
            if (result)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.registrationProcess = Password_Setting;
                    [self setViewState:self.registrationProcess];
                });
            }
        }completionBlock:^{
            [getCodeHUD removeFromSuperview];
            [getCodeHUD release];
        }];
        
    }

    else if (sender == self.getCodeInSMSBtn)
    {
        
        //重新获取验证码时的判断
        if ((_inputField.text == nil && self.userNumber == nil)|| ([_inputField.text length] == 0 && [self.userNumber length] == 0))
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"手机号码不能为空"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        else
        {
            //保存所输入的手机号码
            if ([_inputField.text length] > 0) {
                self.userNumber = _inputField.text;
                
            }
        }
        
        MBProgressHUD *getCodeHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:getCodeHUD];
        getCodeHUD.labelText = @"获取验证码...";
        
        [getCodeHUD showAnimated:YES whileExecutingBlock:^{
            BOOL result = [self getCodeFromServer:kGetCodeTypeSMS andNumber:self.userNumber];
            if (result)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.tipsLabel.text = [NSString stringWithFormat:@"验证码将通过短信方式发送到以下号码:%@，请注意查收。", self.inputField.text];
                    [self startGetCodeTimer];
                });
            }
        }completionBlock:^{
            [getCodeHUD removeFromSuperview];
            [getCodeHUD release];
        }];
    }
    else if (sender == self.getCodeInVoiceBtn)
    {
        
        if ((_inputField.text == nil && self.userNumber == nil)|| ([_inputField.text length] == 0 && [self.userNumber length] == 0))
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"手机号码不能为空"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        else
        {
            //保存所输入的手机号码
            if ([_inputField.text length] > 0) {
                self.userNumber = _inputField.text;
                
            }
        }
        
        MBProgressHUD *getCodeHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:getCodeHUD];
        getCodeHUD.labelText = @"获取验证码...";
        
        [getCodeHUD showAnimated:YES whileExecutingBlock:^{
            BOOL result = [self getCodeFromServer:kGetCodeTypeVoice andNumber:self.userNumber];
            if (result)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.tipsLabel.text = [NSString stringWithFormat:@"你输入的号码是:%@。\n服务器将呼叫该号码，请注意接听电话并记下验证码。", self.inputField.text];

                    [self startGetCodeTimer];
                });
            }
        }completionBlock:^{
            [getCodeHUD removeFromSuperview];
            [getCodeHUD release];
        }];
    }
    
}

- (void)backBtnClick:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                    message:NSLocalizedString(@"Are you sure to give up the operation?", @"Are you sure to give up the operation?")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"NO", @"NO")
                                          otherButtonTitles:NSLocalizedString(@"YES", @"YES"),nil];
    alert.tag = BACK_TAG;
    [alert show];
    [alert release];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case BACK_TAG:
        {
            if (buttonIndex == 0)
            {
                // do nothing
            }
            else if (buttonIndex == 1)
            {
                [self.navigationController popViewControllerAnimated:NO];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - ChangeValidCode

-(void)changeValidCode:(id)sender
{
    [self getLocation];
    [self getNumber];
    [self.validCodeBGView setBackgroundColor:[self getRandomColor]];
}

#pragma mark - TouchMethods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - GetRandomColor

-(UIColor *)getRandomColor
{
    UIColor *color=[UIColor clearColor];
    switch ((arc4random()%5)) {
        case 0:
            color=[UIColor yellowColor];
            break;
        case 1:
            color=[UIColor redColor];
            break;
        case 2:
            color=[UIColor orangeColor];
            break;
        case 3:
            color=[UIColor cyanColor];
            break;
        case 4:
            color=[UIColor magentaColor];
            break;
        case 5:
            color=[UIColor purpleColor];
            break;
        default:
            
            break;
    }
    return  color;
}

#pragma mark - GetNumber

-(void)getNumber
{
    _strValidCode = [[NSMutableString alloc] initWithCapacity:6];
    for(NSInteger i = 0; i < 4; i++) //得到四个随机字符，取四次，可自己设长度
    {
        int arr = arc4random() % 15 + 120;
        _number = arc4random() % 9 + 0;
        switch (i) {
                
            case 0:
                self.label1.text = [NSString stringWithFormat:@"%d",_number];
                self.label1.frame = CGRectMake(self.label1.frame.origin.x, arr, self.label1.frame.size.width, self.label1.frame.size.height);
                break;
            case 1:
                self.label2.text = [NSString stringWithFormat:@"%d",_number];
                self.label2.frame = CGRectMake(self.label2.frame.origin.x, arr, self.label2.frame.size.width, self.label2.frame.size.height);
                break;
            case 2:
                self.label3.text = [NSString stringWithFormat:@"%d",_number];
                self.label3.frame = CGRectMake(self.label3.frame.origin.x, arr, self.label3.frame.size.width, self.label3.frame.size.height);
                break;
            case 3:
                self.label4.text = [NSString stringWithFormat:@"%d",_number];
                self.label4.frame = CGRectMake(self.label4.frame.origin.x, arr, self.label4.frame.size.width, self.label4.frame.size.height);
                break;
            default:
                break;
        }
        [_strValidCode appendString:[NSString stringWithFormat:@"%d",_number]];
    }
}

#pragma mark- GetLocation

- (void)getLocation
{
    [_pointArray removeAllObjects];
    for(int j = 0; j<6; j++)
    {
        int pointx = arc4random() % 70;
        int pointy = arc4random() % 30;
        CGPoint point = CGPointMake(pointx, pointy);
        NSValue *points = [NSValue valueWithCGPoint:point];
        [_pointArray addObject:points];
    }
    [self.validCodeBGView sharePoints:_pointArray];
    [self.validCodeBGView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

    [_PWSettingControl release];
    [_PWField release];
    [_PWComfirmationField release];
    [_submitCodeBtn release];
    [_tipLabel release];
    [_completedControl release];
    [_congratulationLabel release];
    [_accountNumLabel release];
    [_manualRegisterControl release];
    [_inputField release];

    [nextBtn release];
    [_phoneVerificationBtn release];
    [_passwordSettingBtn release];
    [_completedBtn release];
    [_registrationProcessView release];
    [_oneLabel release];
    [_twoLabel release];
    [_leftLabel release];

    [getCodeInVoiceBtn release];
    [getCodeInSMSBtn release];
    [_tipsLabel release];
    
    [userNumber release];
    [verifyCode release];
    [_currPwdField release];
    [_theNewPwdFiled release];
    [_theNewPwdComfirmationField release];
    [_resetPwdBtn release];
    [_lableOne release];
    [_lableTwo release];
    [_lableThree release];
    [_validCodeField release];
    [_validCodeBGView release];
    [_label2 release];
    [_label1 release];
    [_label3 release];
    [_label4 release];
    
    [_strValidCode release];
    [_pointArray release];
    [platformInfo release];
    [_PWResetScrollView release];
    [super dealloc];
}

- (void)viewDidUnload {

    [super viewDidUnload];
}
@end
