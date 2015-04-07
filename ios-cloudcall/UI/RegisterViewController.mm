//
//  RegisterViewController.m
//  CloudCall
//
//  Created by Dan on 14-1-6.
//  Copyright (c) 2014年 CloudTech. All rights reserved.
//

#import "RegisterViewController.h"
#import "ToRegisterViewController.h"
#import "MBProgressHUD.h"
#import "JSONKit.h"
#import "HttpRequest.h"
#import "UrlHeader.h"
#import "CloudCall2AppDelegate.h"

#define BACK_TAG 888


@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize platformInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+44, self.view.frame.size.width, self.view.frame.size.height)];
//    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Register", @"Register");
    //阅读《云通网络电话服务条款》的判断
    _readTerms = YES;
    
    [self.autoRegister setTitle:NSLocalizedString(@"AutoRegister", @"AutoRegister") forState:UIControlStateNormal];
    [self.manualRegister setTitle:NSLocalizedString(@"ManualRegister", @"ManualRegister") forState:UIControlStateNormal];
    
    if (iPhone5)
    {
        [self.autoRegister setFrame:CGRectMake(self.autoRegister.frame.origin.x, self.autoRegister.frame.origin.y+25, self.autoRegister.frame.size.width, self.autoRegister.frame.size.height)];
        [self.manualRegister setFrame:CGRectMake(self.manualRegister.frame.origin.x, self.manualRegister.frame.origin.y+25, self.manualRegister.frame.size.width, self.manualRegister.frame.size.height)];
        [self.tips setFrame:CGRectMake(self.tips.frame.origin.x, self.tips.frame.origin.y+25, self.tips.frame.size.width, self.tips.frame.size.height)];
    }
    

    UIButton *barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [barButtonItemBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [barButtonItemBack addTarget:self action:@selector(backBtnClick:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:barButtonItemBack] autorelease];

    
}


#pragma mark - customized method


- (void)getPhoneNumberFromSmsplatformServer
{
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             self.platformInfo.smsid, @"smsid", nil];
    CCLog(@"getPhoneNumberFromSmsplatformServer=%@", jsonDic);
    
    [[HttpRequest instance] addRequestWithEncrypt:kGetPhoneNumberFromSmsplatformURL andMethod:@"POST" andContent:jsonDic andTimeout:10 delegate:self successAction:@selector(getPhoneNumbeSuccess:) failureAction:@selector(getPhoneNumbeFailed:) userInfo:nil];
    
    }

- (void)getPhoneNumbeSuccess:(NSData *)data
{
    if (data)
    {
        NSMutableDictionary *root = [data mutableObjectFromJSONData];
        CCLog(@"getPhoneNumberFromSmsplatformServer result=%@", root);
        
        NSString *result    = [root objectForKey:@"result"];
        BOOL succ = [result isEqualToString:@"success"];
        if (!succ)
        {
            if (haveGetPhoneNum == NO)
            {
                if (haveRetryTimes <= self.platformInfo->retryTimes)
                {
                    haveRetryTimes++;
                    CCLog(@"haveRetryTimes = %d", haveRetryTimes);
                    [self performSelector:@selector(getPhoneNumberFromSmsplatformServer) withObject:nil afterDelay:self.platformInfo->interval];
                }
                else
                {
                    [HUD hide:YES];
                    haveRetryTimes = 0;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                    message:@"注册失败,如果有打开imessage的话,请先关闭,或者打开imeesage中的作为短信发送功能,设置-信息-作为短信发送"
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                    [alert show];
                    [alert release];
                }
            }
        }
        else
        {
            [HUD hide:YES];
            haveGetPhoneNum = YES;
            haveRetryTimes = 0;
            NSString *phoneNum = [root objectForKey:@"phone"];
            [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:phoneNum forKey:IDENTITY_IMPI];
            
            ToRegisterViewController *autoRegistration = [[ToRegisterViewController alloc] initWithNibName:@"ToRegisterViewController" bundle:nil];
            autoRegistration.registerType = Automatic_Register;
            autoRegistration.registrationProcess = Password_Setting;
            [self.navigationController pushViewController:autoRegistration animated:YES];
            [autoRegistration release];

        }
    }

}

- (void)getPhoneNumbeFailed:(NSData *)data
{
    [HUD hide:YES];
    haveRetryTimes = 0;
    haveGetPhoneNum = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                    message:@"网络出错,请稍后再试"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    [alert show];
    [alert release];
}

- (void)OpenWebBrowser:(NSString *)url withBarTitle:(NSString *)title withType:(TSMiniWebBrowserType)type
{
    WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
    webBrowser.mode = TSMiniWebBrowserModeNavigation;
    webBrowser.type = type;
    [webBrowser setFixedTitleBarText:title];
    webBrowser.barStyle = UIStatusBarStyleDefault;
    webBrowser.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webBrowser animated:YES];
    
    [webBrowser release];
}

- (IBAction)checkBoxClick:(id)sender
{
    UIImage *unselectedImage = [UIImage imageNamed:@"unread.png"];
    UIImage *selectedImage = [UIImage imageNamed:@"read.png"];
    if ([[self.checkBox imageForState:UIControlStateNormal] isEqual:unselectedImage]) {
        _readTerms = YES;
        [self.checkBox setImage:selectedImage forState:UIControlStateNormal];
    }
    else
    {
        _readTerms = NO;
        [self.checkBox setImage:unselectedImage forState:UIControlStateNormal];
    }
}

- (IBAction)onButtonClick:(id)sender {
    //同意服务条款才能发送验证码,找回密码不需要同意条款
    if (!_readTerms) {
        UIAlertView *readTermsAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                 message:@"请阅读云通网络电话服务条约"
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                       otherButtonTitles:nil];
        [readTermsAlert show];
        [readTermsAlert release];
        
        return;
    }
    
    if (sender == self.autoRegister)
    {
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init]; //autorelease];
            controller.recipients = [NSArray arrayWithObject:self.platformInfo.platform];
            controller.body = [NSString stringWithFormat:@"YTREG:%@",self.platformInfo.smsid]; //需要加上YTREG:前缀发送smsid才能有效
            ;
            controller.messageComposeDelegate = self;
            controller.wantsFullScreenLayout = NO;

            
            [self presentViewController:controller animated:YES completion:^{
            }];
            [controller release];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Note Info", @"Note Info")
                                                            message:NSLocalizedString(@"No SMS Support", @"No SMS Support")
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
        }

    }
    else if (sender == self.termsOfService)
    {
        [self OpenWebBrowser:URL_Disclaimer withBarTitle:self.termsOfService.titleLabel.text withType:TSMiniWebBrowserTypeDefault];
    }
    else
    {
        ToRegisterViewController *manualRegistration = [[ToRegisterViewController alloc] initWithNibName:@"ToRegisterViewController" bundle:nil];
        manualRegistration.registerType = Manual_Register;
        manualRegistration.registrationProcess = Phone_Verification;
        [self.navigationController pushViewController:manualRegistration animated:YES];
        [manualRegistration release];
    }

}

- (void)backBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//#pragma mark - alertViewDelegate
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    switch (alertView.tag) {
//        case BACK_TAG:
//        {
//            if (buttonIndex == 0)
//            {
//                // do nothing
//            }
//            else if (buttonIndex == 1)
//            {
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//            break;
//        }
//        default:
//            break;
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
//    [_autoRegister release];
//    [_manualRegister release];
    [_tips release];
    [platformInfo release];
    [_checkBox release];
    [_termsOfService release];
    [_tipsControl release];
    [_middleLabel release];
    
    [super dealloc];
}

- (void)viewDidUnload {

    [super viewDidUnload];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	// Notifies users about errors associated with the interface
	switch (result)
    {
		case MessageComposeResultCancelled:
			break;
		case MessageComposeResultSent:
        {
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            
            HUD.labelText = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"AutoRegister", @"AutoRegister")];
            [HUD show:YES];
            [self performSelector:@selector(getPhoneNumberFromSmsplatformServer) withObject:nil afterDelay:self.platformInfo->tryTime];
			break;
        }
		case MessageComposeResultFailed:
			break;
		default:
			break;
	}
	[self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud release];
}
@end
