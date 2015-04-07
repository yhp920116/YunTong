/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "ValidationViewController.h"
#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"
#import "ConferenceFavoritesViewController.h"
#import "StaticUtils.h"
#import "MobClick.h"
#import "HttpRequest.h"

#import "RegisterViewController.h"
#import "ToRegisterViewController.h"

#define kTagActionAlertAccessContacts           1
#define kTagActionAlertAccessContactsApproved   2
#define kTagActionAlertPhoneNumConfirm          3
#define kTagActionAlertPhoneNumConfirmListen    4


enum Validation_State_T {
    Validation_UnLogin,
    Validation_Logining,
    Validation_Login_Success,
    Validation_Login_Failed
};

@implementation PlatformInfo
@synthesize smsid;
@synthesize platform;
@synthesize remark;

- (void)dealloc
{
    [smsid release];
    [platform release];
    [remark release];
    
    [super dealloc];
}

@end

@interface ValidationViewController (KeyboardNotifications)
-(void) keyboardWillHide:(NSNotification *)note;
-(void) keyboardWillShow:(NSNotification *)note;
-(void) keyboardNotificationWithNote:(NSNotification *)note willShow: (BOOL) showing;
@end

@implementation ValidationViewController (Timers)

//-(void)timerGetCodeAgainTick:(NSTimer*)timer{
//	// to be implemented for the call time display
//
//    if (getcodeSeconds > 0) {
//        getcodeSeconds--;
//    }
//    
//    if (getcodeSeconds == 0) {
//        [GetCodeAgainTimer invalidate];
//        GetCodeAgainTimer = nil;
//        
//        [buttonGetCode setEnabled:YES];
//        [buttonGetCode setBackgroundImage:[UIImage imageNamed:@"access_code_normal.png"] forState:UIControlStateNormal];
//        
//        [buttonListenCode setEnabled:YES];
//        [buttonListenCode setBackgroundImage:[UIImage imageNamed:@"access_code_normal.png"] forState:UIControlStateNormal];
//        
//        NSString* str = listeningCode ? [NSString stringWithString:NSLocalizedString(@"Not receive the call? Press 'Listen Code' or press 'Get Code Again'.", @"Not receive the call? Press 'Listen Code' or press 'Get Code Again'.")] : [NSString stringWithString:NSLocalizedString(@"Not receive code? Press 'Listen Code' or press 'Get Code Again'.", @"Not receive code? Press 'Listen Code' or press 'Get Code Again'.")];
//        [self.labelGetCodeAgain setText: str];
//        
//        listeningCode = NO;
//        
//        return;
//    }
//    
//    NSString* str = listeningCode ? [NSString stringWithFormat:NSLocalizedString(@"Not receive the call? Press 'Listen Code' or press 'Get Code Again' after %02d seconds.", @"Not receive the call? Press 'Listen Code' or press 'Get Code Again' after %02d seconds."), getcodeSeconds] : [NSString stringWithFormat:NSLocalizedString(@"Not receive code? Press 'Listen Code' or press 'Get Code Again' after %02d seconds.", @"Not receive code? Press 'Listen Code' or press 'Get Code Again' after %02d seconds."), getcodeSeconds];
//    [self.labelGetCodeAgain setText:str];
//}

@end


@implementation ValidationViewController (KeyboardNotifications)

-(void) keyboardWillHide:(NSNotification *)note{
	[self keyboardNotificationWithNote:note willShow:NO];
}

-(void) keyboardWillShow:(NSNotification *)note{
	[self keyboardNotificationWithNote:note willShow:YES];
}

-(void) keyboardNotificationWithNote:(NSNotification *)note willShow: (BOOL)showing{
    if (showing) {
        CGRect keyboardBounds;
    
        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];

        CGRect tempFrame;
        CGRect frame = ValidationChildControl.frame;
        tempFrame.origin = CGPointMake(frame.origin.x, 460 - frame.size.height - keyboardBounds.size.height);
        tempFrame.size = CGSizeMake(frame.size.width, frame.size.height);
     
        [UIView beginAnimations:@"Curl"context:nil];//动画开始
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:ValidationChildControl];
        [ValidationChildControl setFrame:tempFrame];
        [UIView commitAnimations];
    } else {
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        CGRect rect = CGRectMake(0.0f, 0.0f, ValidationChildControl.frame.size.width, ValidationChildControl.frame.size.height);
        ValidationChildControl.frame = rect;
        [UIView commitAnimations];
    }
}
@end

@implementation ValidationViewController

@synthesize imageViewPhoneNum;
@synthesize textEditPhoneNum;
@synthesize imageViewCode;
@synthesize textEditCode;
@synthesize buttonLogin;
@synthesize buttonForget;
@synthesize buttonRegister;
@synthesize ValidationChildControl;
@synthesize isLogOut;
@synthesize platformInfo;

-(void)cancelInput {
    [currEditing resignFirstResponder];
    currEditing.text = @"";
    if (oldContent) {
        currEditing.text = oldContent;
    }
}

-(void)doneWithInput {
    [currEditing resignFirstResponder];
}

- (void) setViewState:(Validation_State_T)type {
    switch (type) {
        case Validation_UnLogin: {
            self->state = type;

            
            int acc = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_ACCESS_CONTACTS_LIST];
            if (acc == -1 && SystemVersion < 6.0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Contacts Access", @"Contacts Access")
                                                            message: NSLocalizedString(@"The WeiCall needs to access your contacts and sync contacts.", @"The WeiCall needs to access your contacts and sync contacts.")
                                                           delegate: self
                                                  cancelButtonTitle: NSLocalizedString(@"Why?", @"Why?")
                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                alert.tag = kTagActionAlertAccessContacts;
                [alert show];
                [alert release];
            }
            
            //[self.textEdit becomeFirstResponder];
            
            break;
        }
        case Validation_Logining: {
            if ([self.textEditCode.text length] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message: NSLocalizedString(@"Invalid password!", @"Invalid password!")
                                                               delegate: nil
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                [self hideHUD];
                return;
            }
            
            if ([self.textEditCode.text haveChSymbol] || [self.textEditCode.text isEqualToString:@"00000"] || [self.textEditCode.text isEqualToString:@"995995"] || [self.textEditCode.text isEqualToString:@"22884646"])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message:@"含有非法字符,请重新输入"
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                [self hideHUD];
                return;
            }
            
            self->state = type;
            
            
            if (self->phoneNum)
                [self->phoneNum release];
            self->phoneNum = [[NSString alloc] initWithString:self.textEditPhoneNum.text];
            
            if (self->accessCode) {
                [self->accessCode release];
                self->accessCode = nil;
            }
            self->accessCode = [[NSString alloc] initWithString: self.textEditCode.text];

            
            LoginManager *loginManager = [LoginManager shareInstance];
            
            [loginManager httpLoginUserNum:self->phoneNum UserPwd:self->accessCode HttpLoginSuccessBlock:^{
                
                [self setViewState:Validation_Login_Success];
                
            } HttpLoginFailedBlock:^{
                
                [self setViewState:Validation_Login_Failed];
                
            }];
            
            break;        
        }
        case Validation_Login_Success: {
            self->state = type;
            [self hideHUD];

            break;
        } 
        case Validation_Login_Failed:
        {
            self->state = type;
            [self hideHUD];
            if (self->accessCode) {
                [self->accessCode release];
                self->accessCode = nil;
            }
            //登录失败不写入用户数据
            break;
        }
        default:
            CCLog(@"setViewState: Unknow state");
            break;
    }
}

- (BOOL)getSmsplatformInfo
{
    BOOL succ = NO;
    NSData *response = [[HttpRequest instance] sendRequestSyncWithEncrypt:kGetSmsplatformInfoURL andMethod:@"POST" andContent:nil andTimeout:10 andTarget:nil andSuccessSelector:NULL andFailureSelector:NULL];
    if (response && [response length] != 0)
    {
        self.platformInfo = [[PlatformInfo alloc] init];
        NSMutableDictionary *root = [response mutableObjectFromJSONData];
        
        NSString *result              = [root objectForKey:@"result"];
        self.platformInfo.platform    = [root objectForKey:@"platform"];
        self.platformInfo.smsid       = [root objectForKey:@"smsid"];
        self.platformInfo->tryTime    = [[root objectForKey:@"try"] intValue];
        self.platformInfo->retryTimes = [[root objectForKey:@"retrytimes"] intValue];
        self.platformInfo->interval   = [[root objectForKey:@"interval"] intValue];
        self.platformInfo.remark      = [root objectForKey:@"remark"];
        
        succ = [result isEqualToString:@"success"];
        if (!succ)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message:[root objectForKey:@"text"]
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
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



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kTagActionAlertAccessContacts:
            if (buttonIndex == 0) { // Why?
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                                message: NSLocalizedString(@"To determine which of your contacts are using WeiCall service, WeiCall needs to access your contacts. Then you can call your WeiCall contacts for free.", @"To determine which of your contacts are using WeiCall service, WeiCall needs to access your contacts. Then you can call your WeiCall contacts for free.")
                                                               delegate: self
                                                      cancelButtonTitle: NSLocalizedString(@"Not Allow", @"Not Allow")
                                                      otherButtonTitles: NSLocalizedString(@"Allow", @"Allow"), nil];
                alert.tag = kTagActionAlertAccessContactsApproved;
                [alert show];
                [alert release];

                
            } else if (buttonIndex == 1) { // OK
                //CCLog(@"The Second Button Pressed");
                [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:GENERAL_ACCESS_CONTACTS_LIST_ALLOW];
            }
            break;
        case kTagActionAlertAccessContactsApproved:
            if (buttonIndex == 0) { // Not Allow
                [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:GENERAL_ACCESS_CONTACTS_LIST_NOT_ALLOW];
            } else if (buttonIndex == 1) { // Allow
                [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:GENERAL_ACCESS_CONTACTS_LIST_ALLOW];
            }
            break;
        case kTagActionAlertPhoneNumConfirm:
            if (buttonIndex == 0) { // Cancel
                ; // do nothing
            } else if (buttonIndex == 1) { // OK               

            }
            break;
        default:
            break;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NgnEngine sharedInstance].sipService stopStackSynchronously];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    [appDelegate PhoneNumValidating:YES];
    
    UIImageView *phoneNumImage = [[UIImageView alloc] initWithFrame:CGRectMake(7, 8, 15, 15)];
    phoneNumImage.image = [UIImage imageNamed:@"phoneNum.png"];
    [self.imageViewPhoneNum addSubview:phoneNumImage];
    [phoneNumImage release];
    
    [self.textEditPhoneNum setPlaceholder:NSLocalizedString(@"Cellphone No.", @"Cellphone No.")];
    [self.textEditCode setPlaceholder:NSLocalizedString(@"Password", @"Password")];
    
    UIImageView *passwordImage = [[UIImageView alloc] initWithFrame:CGRectMake(7, 8, 15, 15)];
    passwordImage.image = [UIImage imageNamed:@"password.png"];
    [self.imageViewCode addSubview:passwordImage];
    [passwordImage release];
    
    [self.buttonLogin setTitle:NSLocalizedString(@"Log in", @"Log in") forState:UIControlStateNormal];
    [self.buttonForget setTitle:NSLocalizedString(@"Forget", @"Forget") forState:UIControlStateNormal];
    [self.buttonRegister setTitle:NSLocalizedString(@"Register", @"Register") forState:UIControlStateNormal];
    
    [buttonLogin setBackgroundImage:[UIImage imageNamed:@"logInButton_press.png"] forState:UIControlStateHighlighted];
    
    if (iPhone5) {
        //[self.view setFrame:CGRectMake(0, 0, 640, 1136)];
//        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"loginbgfori5.png"]]];
        
        
        [self.textEditPhoneNum setFrame:CGRectMake(self.textEditPhoneNum.frame.origin.x, self.textEditPhoneNum.frame.origin.y + 25, self.textEditPhoneNum.frame.size.width, self.textEditPhoneNum.frame.size.height)];
        [self.textEditCode setFrame:CGRectMake(self.textEditCode.frame.origin.x, self.textEditCode.frame.origin.y + 25, self.textEditCode.frame.size.width, self.textEditCode.frame.size.height)];
        [self.imageViewPhoneNum setFrame:CGRectMake(self.imageViewPhoneNum.frame.origin.x, self.imageViewPhoneNum.frame.origin.y + 25, self.imageViewPhoneNum.frame.size.width, self.imageViewPhoneNum.frame.size.height)];
        [self.imageViewCode setFrame:CGRectMake(self.imageViewCode.frame.origin.x, self.imageViewCode.frame.origin.y + 25, self.imageViewCode.frame.size.width, self.imageViewCode.frame.size.height)];
        [self.buttonLogin setFrame:CGRectMake(self.buttonLogin.frame.origin.x, self.buttonLogin.frame.origin.y + 25, self.buttonLogin.frame.size.width, self.buttonLogin.frame.size.height)];
        [self.buttonForget setFrame:CGRectMake(self.buttonForget.frame.origin.x, self.buttonForget.frame.origin.y+25, self.buttonForget.frame.size.width, self.buttonForget.frame.size.height)];
        [self.buttonRegister setFrame:CGRectMake(self.buttonRegister.frame.origin.x, self.buttonRegister.frame.origin.y+25, self.buttonRegister.frame.size.width, self.buttonRegister.frame.size.height)];
        [self.middleLine setFrame:CGRectMake(self.middleLine.frame.origin.x, self.middleLine.frame.origin.y + 25, self.middleLine.frame.size.width, self.middleLine.frame.size.height)];
    }
    else
    {
//        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"log_in_bg.png"]]];
    }
    
    NSString* impi = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSString* pwd = [[CloudCall2AppDelegate sharedInstance] getUserPassword];
    CCLog(@"UserPwd = %@",pwd);
    if (![impi isEqualToString:DEFAULT_IDENTITY_IMPI])
        [self.textEditPhoneNum setText:impi];
    if (![pwd isEqualToString:DEFAULT_IDENTITY_PASSWORD]) {
        [self.textEditCode setText:pwd];
    }
    self.textEditPhoneNum.delegate = self;
    self.textEditCode.delegate = self;
    
    ////////////////////////////////////////////////////////
    keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.items = [NSArray arrayWithObjects:
                             [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelInput)] autorelease],
                             [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                             [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithInput)] autorelease],
                             nil];
    [keyboardToolbar sizeToFit];
    
    self.textEditPhoneNum.inputAccessoryView = keyboardToolbar;
    self.textEditCode.inputAccessoryView = keyboardToolbar;
    ////////////////////////////////////////////////////////
    
    [self setViewState:Validation_UnLogin];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
    
    if (SystemVersion > 5)
        [UIApplication sharedApplication].statusBarHidden = YES;

    [MobClick beginLogPageView:@"Validation"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isLogOut == NO)
    {
        [[NgnEngine sharedInstance].contactService start];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (SystemVersion > 5)
        [UIApplication sharedApplication].statusBarHidden = NO;

    [MobClick endLogPageView:@"Validation"];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [self setButtonForget:nil];
    [self setButtonRegister:nil];
    [self setMiddleLine:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [imageViewPhoneNum release];
    [textEditPhoneNum release];
    [imageViewCode release];
    [textEditCode release];
    [buttonLogin release];
    [ValidationChildControl release];
    
    [self->phoneNum release];
    [self->accessCode release];
    
    [keyboardToolbar release];
    [buttonForget release];
    [buttonRegister release];
    [platformInfo release];
    
    [_middleLine release];
    [super dealloc];
}

- (IBAction) onbuttonClick: (id)sender {
    if (sender == buttonLogin) {
        
        [self.view endEditing:YES];
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        HUD.labelText = NSLocalizedString(@"Login...", @"Login...");
        [HUD show:YES];
        [self performSelector:@selector(hideHUD) withObject:nil afterDelay:20];
        
        [self setViewState:Validation_Logining];
        return;
    }
    else if (sender == buttonForget)
    {
        MBProgressHUD *logHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:logHUD];
        
        [logHUD showAnimated:YES whileExecutingBlock:^{
            [self getSmsplatformInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                //忘记密码
                ToRegisterViewController *getPasswordBackViewController = [[ToRegisterViewController alloc] initWithNibName:@"ToRegisterViewController" bundle:Nil];
                getPasswordBackViewController.platformInfo = self.platformInfo;
                getPasswordBackViewController.registerType = Get_Back_Password;
                getPasswordBackViewController.registrationProcess = Phone_Verification;
                [self.navigationController pushViewController:getPasswordBackViewController animated:YES];
                [getPasswordBackViewController release];
            });
        }completionBlock:^{
            [logHUD removeFromSuperview];
            [logHUD release];
        }];

        return;
    }
    else if (sender == buttonRegister)
    {
        MBProgressHUD *logHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:logHUD];
        
        [logHUD showAnimated:YES whileExecutingBlock:^{
            BOOL result = [self getSmsplatformInfo];
            BOOL simCard = [StaticUtils haveSimCard];
            
            if (result && [MFMessageComposeViewController canSendText] && simCard)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:Nil];
                    registerViewController.platformInfo = self.platformInfo;
                    [self.navigationController pushViewController:registerViewController animated:YES];
                    [registerViewController release];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ToRegisterViewController *toRegisterViewController = [[ToRegisterViewController alloc] initWithNibName:@"ToRegisterViewController" bundle:Nil];
                    toRegisterViewController.platformInfo = self.platformInfo;
                    toRegisterViewController.registerType = Manual_Register;
                    toRegisterViewController.registrationProcess = Phone_Verification;
                    [self.navigationController pushViewController:toRegisterViewController animated:YES];
                    [toRegisterViewController release];
                });
            }
        }completionBlock:^{
            [logHUD removeFromSuperview];
            [logHUD release];
        }];
        
        

        return;
    }
    [self backgroundTap:nil];
}

- (void)hideHUD
{
    if (HUD != nil)
    {
        [HUD hide:YES];
        [HUD release];
        HUD = nil;
    }
}

#pragma mark - textFieldDelegate

#pragma mark - textFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.textEditCode)
        return YES;
    
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    if ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0 || [string isEqualToString:@""]) {
        return YES;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message:@"请输入数字"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return NO;
    }
    return nil;
}

#pragma mark -
#pragma mark 触摸背景来关闭虚拟键盘
- (IBAction)backgroundTap:(id)sender
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, ValidationChildControl.frame.size.width, ValidationChildControl.frame.size.height);
    ValidationChildControl.frame = rect;
    [UIView commitAnimations];

    [self.textEditPhoneNum resignFirstResponder];
    [self.textEditCode resignFirstResponder];
}

/*#pragma mark -
#pragma mark 解决虚拟键盘挡住UITextField的方法
- (void)keyboardWillShow:(NSNotification *)noti
{
    float height = 216.0;
    CGRect tempFrame;
    CGRect frame = ValidationChildControl.frame;
    tempFrame.origin = CGPointMake(frame.origin.x, 460 - frame.size.height - height);
    tempFrame.size = CGSizeMake(frame.size.width, frame.size.height);
    
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:ValidationChildControl];
    [ValidationChildControl setFrame:tempFrame];
    [UIView commitAnimations];
}
*/

- (IBAction) onEditingChanged: (id)sender {
    /*if (buttonOK.enabled == NO) {
        buttonOK.enabled = YES;
    }*/
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currEditing = textField;
    
    if (oldContent) {
        [oldContent release];
        oldContent = nil;
    }
    if ([textField.text length])
        oldContent = [[NSString alloc] initWithString:textField.text];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (oldContent) {
        [oldContent release];
        oldContent = nil;
    }
}

@end
