/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import "SettingsViewController.h"
#import "CloudCall2AppDelegate.h"
#import "AboutLocalViewController.h"
#import "GuideViewController.h"
#import "CallTypeViewController.h"
#import "MobClick.h"

#import "WebBrowser.h"
#import "AFKReviewTroller.h"
#import "ToRegisterViewController.h"

#define kTagActionAlertDeactivate   1
#define kTagActionAlertContactsSync_Enable  2
#define kTagActionAlertContactsSync_Disable 3
#define kTagActionAlertUpdateVersion 4

#define kTagActionAlertRecommendedSoftware 6
#define kTagActionAlertAwardPraise 21   //前往appstore评论

#define kTagActionAlertUse3G_Enable 8
#define kTagActionAlertUse3G_Disable 9

@interface SettingsViewController(Private)
// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
- (void)layoutForCurrentOrientation:(BOOL)animated;
- (BOOL) hideAlertvView;
- (void) hideAlertvView:(NSString*)errPrompt;
- (void) hideAlertvViewTimeout:(NSString*)errPrompt;
- (void) showAlertvView:(NSString*)prompt andExpire:(int)time andFailPrompt:(NSString*)failPrompt;
@end

@interface SettingsViewController(Sip_And_Network_Callbacks)
-(void) onMessagingEvent:(NSNotification*)notification;
@end

@implementation SettingsViewController(Sip_And_Network_Callbacks)

//== PagerMode IM (MESSAGE) events == //
-(void) onMessagingEvent:(NSNotification*)notification {
	NgnMessagingEventArgs* eargs = [notification object];
#if 1
	switch (eargs.eventType) {
		case MESSAGING_EVENT_CONNECTING:
		case MESSAGING_EVENT_CONNECTED:
		case MESSAGING_EVENT_TERMINATING:
		case MESSAGING_EVENT_TERMINATED:
		case MESSAGING_EVENT_FAILURE:
		case MESSAGING_EVENT_SUCCESS:
		case MESSAGING_EVENT_OUTGOING:
		default:
		{
			break;
		}
			
		case MESSAGING_EVENT_INCOMING:
		{
            //CCLog(@"settings Incoming message: content:\n%s",  eargs.payload?[eargs.payload bytes]:"<NULL>");
			if(eargs.payload){
				// The payload is a NSData object which means that it could contain binary data
				// here I consider that it's utf8 text message
				NSString* contentType = [eargs getExtraWithKey: kExtraMessagingEventArgsContentType];
				//NSString* from = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUri];
				//NSString* userName = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUserName];
				//content-transfer-encoding: base64\r\n
				//NSString* content = [NSString stringWithUTF8String: (const char*)[eargs.payload bytes]];
				
				// default content: e.g. plain/text
				//NSData *content = eargs.payload;
				//CCLog(@"settings Incoming message: from:%@\n with ctype:%@\n and content:\n%s", userName, contentType, [content bytes]);
                
                if (contentType) {
                    if ([[contentType lowercaseString] hasPrefix:@"text/versionupdate"])
                    {
                        [self hideAlertvView];
                        break;
                    }
                }
			}
			break;
		}
	}
#endif
}
@end

@implementation SettingsViewController(Private)
-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    // by default content consumes the entire view area
    //CGRect contentFrame = self.view.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by the banner height to get the final position
	//CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    CGPoint bannerOrigin;
    bannerOrigin.x = 0;
    bannerOrigin.y = self.buttonAd.bounds.origin.y;
    
    if (iadbanner) {
        // First, setup the banner's content size and adjustment based on the current orientation
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
            iadbanner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifierPortrait;
        else {
            iadbanner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
            
        }
        
        // Depending on if the banner has been loaded, we adjust the content frame and banner location
        // to accomodate the ad being on or off screen.
        // This layout is for an ad at the bottom of the view.
        
        // And finally animate the changes, running layout for the content view if required.
        [UIView animateWithDuration:animationDuration
                         animations:^{                         
                             iadbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, iadbanner.frame.size.width, iadbanner.frame.size.height);
                         }];
    }
    else if (lmbanner) {        
        [UIView animateWithDuration:animationDuration
                         animations:^{                         
                             lmbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, lmbanner.frame.size.width, lmbanner.frame.size.height);
                         }];
    } else if (ctbanner) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             ctbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, ctbanner.frame.size.width, ctbanner.frame.size.height);
                         }];
    }
}

//////////////////////

-(BOOL) hideAlertvView {
    if (!alertShow) return NO;
    alertShow = NO;    
    if (alertProcess) {
        [alertProcess dismissWithClickedButtonIndex:0 animated:NO];
    }
    return YES;
}

- (void) hideAlertvViewTimeout:(NSString*)errPrompt{
    if (NO == [self hideAlertvView]) return;
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    [appDelegate SetCheckingVersionUpdate:NO];
    
    if (errPrompt) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message: NSLocalizedString(errPrompt, errPrompt)
                                                       delegate: self
                                          cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
        [a show];
        [a release];
    }
}

- (void) hideAlertvView:(NSString*)errPrompt{
    if (NO == [self hideAlertvView]) return;
    
    if (errPrompt) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                    message: NSLocalizedString(errPrompt, errPrompt)
                                                   delegate: self
                                          cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
        [a show];
        [a release];
    }
}

- (void) showAlertvView:(NSString*)prompt andExpire:(int)time andFailPrompt:(NSString*)failPrompt {
    alertProcess = [[UIAlertView alloc] initWithTitle:prompt
                                        message:nil
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles: nil];
    [alertProcess show];
    alertShow = YES;
    
    // Create and add the activity indicator
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.center = CGPointMake(alertProcess.bounds.size.width / 2.0f, alertProcess.bounds.size.height - 40.0f);
    [aiv startAnimating];
    [alertProcess addSubview:aiv];
    [aiv release];    

    [alertProcess release];
    
    // Auto dismiss after expire
    [self performSelector:@selector(hideAlertvViewTimeout:) withObject:failPrompt afterDelay:time];
}

@end

@implementation SettingsViewController

@synthesize tableView;

@synthesize cellCheckUpdate;
@synthesize cellAbout;
@synthesize cellAppStorePraise;
@synthesize cellHelp;

@synthesize cellSyncContacts;
@synthesize labelSyncContacts;
@synthesize syncContacts;

@synthesize cellUse3G;
@synthesize labelUse3G;
@synthesize use3G;

@synthesize cellDialTone;
@synthesize labelDialTone;
@synthesize dialTone;
@synthesize cellUseWizard;

@synthesize cellCloudCallRate;
@synthesize cellCloudCallType;
@synthesize cellDeactivate;
@synthesize cellGetPassword;

@synthesize buttonAd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    CCLog(@"SettingView didReceiveMemoryWarning");
    // Release any cached data, images, etc that aren't in use.
}

// communication with server
-(void) GetBalance {
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    [appDelegate GetAccountBalance];
}

-(void) CheckVersion {    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    [appDelegate CheckVersionUpdate:NO];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Settings", @"Settings");

    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(back:) forControlEvents: UIControlEventTouchUpInside];
    
    if (SystemVersion >= 7.0)
    {
        syncContacts.frame = CGRectMake(syncContacts.frame.origin.x+40, syncContacts.frame.origin.y, syncContacts.frame.size.width, syncContacts.frame.size.height);
        use3G.frame = CGRectMake(use3G.frame.origin.x+40, use3G.frame.origin.y, use3G.frame.size.width, use3G.frame.size.height);
        dialTone.frame = CGRectMake(dialTone.frame.origin.x+40, dialTone.frame.origin.y, dialTone.frame.size.width, dialTone.frame.size.height);
    }
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    //版本检测
    [[self.cellCheckUpdate textLabel] setText:NSLocalizedString(@"Check Update", @"Check Update")];
    self.cellCheckUpdate.showsReorderControl=YES;
    self.cellCheckUpdate.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    //UseWizard
    [[self.cellUseWizard textLabel] setText:NSLocalizedString(@"Using Wizard", @"Using Wizard")];
    self.cellUseWizard.showsReorderControl=YES;
    self.cellUseWizard.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    //Help
    [[self.cellAbout textLabel] setText:NSLocalizedString(@"About", @"About")];
    self.cellAbout.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.cellAbout.showsReorderControl=YES;
    self.cellAbout.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    //到appstore评分
    [[self.cellAppStorePraise textLabel] setText:NSLocalizedString(@"Award Praise", @"Award Praise")];
    self.cellAppStorePraise.showsReorderControl=YES;
    self.cellAppStorePraise.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

    [[self.cellHelp textLabel] setText:NSLocalizedString(@"Help", @"Help")];
    self.cellHelp.showsReorderControl=YES;
    self.cellHelp.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    //云通费率
    [[self.cellCloudCallRate textLabel] setText:NSLocalizedString(@"YunTong Rate", @"YunTong Rate")];
    self.cellCloudCallRate.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.cellCloudCallRate.showsReorderControl = YES;
    self.cellCloudCallRate.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    //拨号方式介绍
    [[self.cellCloudCallType textLabel] setText:NSLocalizedString(@"YunTong Type", @"YunTong Type")];
    self.cellCloudCallType.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.cellCloudCallType.showsReorderControl = YES;
    self.cellCloudCallType.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    //GetPassword
    [[self.cellGetPassword textLabel] setText:NSLocalizedString(@"ChangePassword", @"ChangePassword")];
    self.cellGetPassword.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.cellGetPassword.showsReorderControl = YES;
    self.cellGetPassword.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    
    
    [self.labelSyncContacts setText:NSLocalizedString(@"Allow to Sync Contacts", @"Allow to Sync Contacts")];
    [self.labelUse3G setText:NSLocalizedString(@"Use 2G/3G", @"Use 2G/3G")];
    [self.labelDialTone setText:NSLocalizedString(@"Dial Tone", @"Dial Tone")];
    
    [[self.cellDeactivate textLabel] setText:NSLocalizedString(@"Log Out", @"Log Out")];
    self.cellDeactivate.showsReorderControl=YES;
    self.cellDeactivate.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    // add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewReloadData) name:@"tableViewReloadData" object:nil];
    
    //判断是否第一次启动:
    //是--同步联系人、使用2G/3G网络、按键音设置为开启状态
    //否--读取用户设置
    if ([[NgnEngine sharedInstance].configurationService getBoolWithKey:DEFAULT_ACCOUNT_FIRSTLAUNCH]) {
        self.syncContacts.on = YES;
        self.use3G.on = YES;
        self.dialTone.on = YES;
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:GENERAL_ACCESS_CONTACTS_LIST_ALLOW];
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_3G andValue:YES];
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_DIAL_TONE_ENABLE andValue:YES];
        
        //第一次启动后将属性设置为NO
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:DEFAULT_ACCOUNT_FIRSTLAUNCH andValue:NO];
    }
    else{
        //根据用户设置设定开关
        self.syncContacts.on = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_ACCESS_CONTACTS_LIST];
        self.use3G.on = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
        self.dialTone.on = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_DIAL_TONE_ENABLE];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
    
    [self layoutForCurrentOrientation:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"Settings"];    
    
    [[CloudCall2AppDelegate sharedInstance] viewChanged:self];
    
    if (needToReloadData) {
        needToReloadData = NO;
        [self.tableView reloadData]; // update unread system nofication display number
    }
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedCheckVersion) name:kCheckVersionUpdateNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"Settings"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCheckVersionUpdateNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) onButtonClick: (id)sender {

//  else if (sender == buttonSendLog) {
//        if ([MFMailComposeViewController canSendMail] == YES) {
//            NSString* attachfile = [[NgnEngine sharedInstance].logService getCompressdLogFile];
//            //SendMail
//            MailComposeViewController* mailer = [MailComposeViewController alloc];
//            [self.navigationController pushViewController:mailer animated:YES];
//            NSArray *toRecipients = [NSArray arrayWithObjects:@"support@cloudcall.hk", nil];
//            [mailer Sendmail:toRecipients Subject:NSLocalizedString(@"WeiCall log", @"WeiCall log") MessageBody:@"" isHTML:NO attach:attachfile attachDispName:NSLocalizedString(@"WeiCall log", @"WeiCall log")];
//            [mailer release];
//        } else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"No Email Account", @"No Email Account")
//                                                            message: NSLocalizedString(@"You must set up an email account for your device before you send mail.", @"You must set up an email account for your device before you send mail.")
//                                                           delegate: nil
//                                                  cancelButtonTitle: nil
//                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
//            [alert show];
//            [alert release];
//        }
//    }
}

- (IBAction) onSwitchChanged: (id) sender
{
    UISwitch *switcher = (UISwitch *)sender;
    if (switcher == syncContacts)
    {
        BOOL en = switcher.isOn;
        
        NSString* strPrompt = en ? NSLocalizedString(@"Are you sure you want to enable contacts sync?", @"Are you sure you want to enable contacts sync?") : NSLocalizedString(@"Are you sure you want to disable contacts sync?", @"Are you sure you want to disable contacts sync?");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Contacts Sync", @"Contacts Sync")
                                                        message: strPrompt
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
        alert.tag = en ? kTagActionAlertContactsSync_Enable : kTagActionAlertContactsSync_Disable;
        [alert show];
        [alert release];
        
    }
    else if (switcher == use3G)
    {
        BOOL en = switcher.isOn;
        
        //code by Sergio
        //start
        BOOL on3G = [NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN;
        if (on3G) {
            if (en) { // 在”打开手机网络”&&“打开云通使用2G/3G网络”的情况下，重新请求（停止服务再启动服务）
                [[NgnEngine sharedInstance].sipService stopStackSynchronously];
                [[NgnEngine sharedInstance].sipService registerIdentity];
                
                [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_3G andValue:YES];
            } else {//在”打开手机网络”&&“关闭云通使用2G/3G网络”的情况下
                //提示用户在只有手机网络可用&&关闭了使用2G/3G网络的情况下，开启使用2G/3G网络
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YunTong", @"YunTong")
                message:NSLocalizedString(@"Only cell phone network is available. If you disable it, you will not able to use YunTong.", @"Only cell phone network is available. If you disable it, you will not able to use YunTong.")
                                                               delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                alert.tag = kTagActionAlertUse3G_Disable;
                [alert show];
                [alert release];
            }
        } else {
            [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_3G andValue:en];
        }
        //end
    }
    else if (switcher == dialTone)
    {
        BOOL en = switcher.isOn;
        
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_DIAL_TONE_ENABLE andValue:en];
    }
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section
{
    BOOL sh = [[CloudCall2AppDelegate sharedInstance] ShowAllFeatures];
    switch(section)
    {
        case 0:
            return 3;
        case 1:
            if (sh && [[CloudCall2AppDelegate sharedInstance] MarkCode] == CLIENT_FOR_AS_APP_STORE)
#if 0
                return 9;
            else
                return 8;
#else
                return 8;
            else
                return 7;
#endif
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL sh = [[CloudCall2AppDelegate sharedInstance] ShowAllFeatures];

    switch (indexPath.section)
    {
        case 0:
            switch(indexPath.row){
                case 0:
                    return cellSyncContacts;
                case 1:
                    return cellUse3G;
                case 2:
                    return cellDialTone;
                default:
                    return nil;
            }
            break;
        case 1:
            if (sh && [[CloudCall2AppDelegate sharedInstance] MarkCode] == CLIENT_FOR_AS_APP_STORE)
            {
                switch(indexPath.row){
                    case 0:
                        return cellCloudCallRate;
                    case 1:
                        return cellCloudCallType;
                    case 2:
                        return cellCheckUpdate;
#if 0
                    case 3:
                        return cellUseWizard;
                    case 4:
                        return cellAbout;
                    case 5:
                        return cellHelp;
                    case 6:
                        return cellAppStorePraise;
                    case 7:
                        return cellDeactivate;
#else
                    case 3:
                        return cellAbout;
                    case 4:
                        return cellHelp;
                    case 5:
                        return cellAppStorePraise;
                    case 6:
                        return cellGetPassword;
                    case 7:
                        return cellDeactivate;
#endif
                    default:
                        return nil;
                }
            }
            else
            {
                switch(indexPath.row){
                    case 0:
                        return cellCloudCallRate;
                    case 1:
                        return cellCloudCallType;
                    case 2:
                        return cellCheckUpdate;
#if 0
                    case 3:
                        return cellUseWizard;
                    case 4:
                        return cellAbout;
                    case 5:
                        return cellHelp;
                    case 6:
                        return cellDeactivate;
#else
                    case 3:
                        return cellAbout;
                    case 4:
                        return cellHelp;
                    case 5:
                        return cellGetPassword;
                    case 6:
                        return cellDeactivate;
#endif
                    default:
                        return nil;
                }
            }
            break;
        default:
            return nil;
            break;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    cellSelected = nil;
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    BOOL sh = [[CloudCall2AppDelegate sharedInstance] ShowAllFeatures];

    switch (indexPath.section) {
        case 0:
            break;
        case 1:
        {
            switch(indexPath.row){
                case 0:
                {
                    [self OpenWebBrowser:URL_Rate withBarTitle:NSLocalizedString(@"YunTong Rate", @"YunTong Rate") withType:TSMiniWebBrowserTypeDefault];
                    break;
                }
                case 1:
                {
                    CallTypeViewController *callTypeViewController = [[CallTypeViewController alloc] initWithNibName:@"CallTypeViewController" bundle:nil];
                    [self.navigationController pushViewController:callTypeViewController animated:YES];
                    [callTypeViewController release];
                    break;
                }
                case 2: {
                    [self CheckVersion];
                    [self showAlertvView:NSLocalizedString(@"Checking update...", @"Checking update...") andExpire:8 andFailPrompt:NSLocalizedString(@"Check update failed, please try again later!", @"Check update failed, please try again later!")];
                    break;
                }
#if 0
                case 3:
                {
                    GuideViewController *teachViewCtrlr = [[GuideViewController alloc] initWithNibName:@"GuideViewController" bundle:nil];
                    [self presentModalViewController:teachViewCtrlr animated:NO];
                    [teachViewCtrlr release];
                    break;
                }
                case 4:
                {
                    AboutLocalViewController *aboutLocal = [[AboutLocalViewController alloc] initWithNibName:@"AboutLocalViewController" bundle:[NSBundle mainBundle]];
                    aboutLocal.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:aboutLocal animated:YES];
                    [aboutLocal release];
                    break;
                }
                case 5:
                {
                    
                    NSString *url = nil;
                    if ([appDelegate ShowAllFeatures]) {
                        url = URL_Faq;
                    } else {
                        url = [NSString stringWithFormat:@"%@/inApp/faq.html", RootUrl];
                    }

                    [self OpenWebBrowser:url withBarTitle:NSLocalizedString(@"Help", @"Help") withType:TSMiniWebBrowserTypeDefault];
                    break;
                }
                case 6:
                {
                    if (sh && [[CloudCall2AppDelegate sharedInstance] MarkCode] == CLIENT_FOR_APP_STORE)
                    {
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                        message: NSLocalizedString(@"Award Praise Content", @"Award Praise Content")
                                                                       delegate: self
                                                              cancelButtonTitle: NSLocalizedString(@"Wait for a moment", @"Wait for a moment")
                                                              otherButtonTitles: NSLocalizedString(@"Go now", @"Go now"), nil];
                        alert.tag = kTagActionAlertAwardPraise;
                        [alert show];
                        [alert release];
                    }
                    else
                    {
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log Out", @"Log Out")
                                                                        message: NSLocalizedString(@"Are you sure you want to deavtivate current number?", @"Are you sure you want to deavtivate current number?")
                                                                       delegate: self
                                                              cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel")
                                                              otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                        alert.tag = kTagActionAlertDeactivate;
                        [alert show];
                        [alert release];
                    }
                    break;
                }
                case 7:
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                    message: NSLocalizedString(@"Are you sure you want to deavtivate current number?", @"Are you sure you want to deavtivate current number?")
                                                                   delegate: self
                                                          cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel")
                                                          otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                    alert.tag = kTagActionAlertDeactivate;
                    [alert show];
                    [alert release];
                    break;
                }
#else
                case 3:
                {
                    AboutLocalViewController *aboutLocal = [[AboutLocalViewController alloc] initWithNibName:@"AboutLocalViewController" bundle:[NSBundle mainBundle]];
                    aboutLocal.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:aboutLocal animated:YES];
                    [aboutLocal release];
                    break;
                }
                case 4:
                {
                    
                    NSString *url = nil;
                    if ([appDelegate ShowAllFeatures]) {
                        url = URL_Faq;
                    } else {
                        url = [NSString stringWithFormat:@"%@/inApp/faq.html", RootUrl];
                    }
                    
                    [self OpenWebBrowser:url withBarTitle:NSLocalizedString(@"Help", @"Help") withType:TSMiniWebBrowserTypeDefault];
                    break;
                }
                case 5:
                {
                    if (sh && [[CloudCall2AppDelegate sharedInstance] MarkCode] == CLIENT_FOR_APP_STORE) {
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"YunTong", @"YunTong")
                                                                        message: NSLocalizedString(@"Award Praise Content", @"Award Praise Content")
                                                                       delegate: self
                                                              cancelButtonTitle: NSLocalizedString(@"Wait for a moment", @"Wait for a moment")
                                                              otherButtonTitles: NSLocalizedString(@"Go now", @"Go now"), nil];
                        alert.tag = kTagActionAlertAwardPraise;
                        [alert show];
                        [alert release];
                    }
                    else
                    {
                        // Get Password
                        ToRegisterViewController *getPassword = [[ToRegisterViewController alloc] initWithNibName:@"ToRegisterViewController" bundle:nil];
                        getPassword.registerType = Change_Password;
                        getPassword.registrationProcess = Password_Resetting;
                        [self.navigationController pushViewController:getPassword animated:YES];
                        [getPassword release];
                        
                    }
                    break;
                }
                case 6:
                {
                    if (sh && [[CloudCall2AppDelegate sharedInstance] MarkCode] == CLIENT_FOR_AS_APP_STORE)
                    {
                        // Get Password
                        ToRegisterViewController *getPassword = [[ToRegisterViewController alloc] initWithNibName:@"ToRegisterViewController" bundle:nil];
                        getPassword.registerType = Change_Password;
                        getPassword.registrationProcess = Password_Resetting;
                        [self.navigationController pushViewController:getPassword animated:YES];
                        [getPassword release];
                    }
                    else
                    {
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"YunTong", @"YunTong")
                                                                        message: NSLocalizedString(@"Are you sure you want to deavtivate current number?", @"Are you sure you want to deavtivate current number?")
                                                                       delegate: self
                                                              cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel")
                                                              otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                        alert.tag = kTagActionAlertDeactivate;
                        [alert show];
                        [alert release];
                    }
                    break;
                }
                case 7:
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"YunTong", @"YunTong")
                                                                    message: NSLocalizedString(@"Are you sure you want to deavtivate current number?", @"Are you sure you want to deavtivate current number?")
                                                                   delegate: self
                                                          cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel")
                                                          otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                    alert.tag = kTagActionAlertDeactivate;
                    [alert show];
                    [alert release];
                    break;
                }
#endif
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 44;
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSUInteger row = [indexPath row];
    if (indexPath.section == 2)
    {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView_ accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {	
	[self tableView:tableView_ didSelectRowAtIndexPath:indexPath];
}

#pragma mark - WebBrowser

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

- (void)dealloc {
    [tableView release];
    [buttonAd release];
    
    [cellCheckUpdate release];
    
    [cellAbout release];
    [cellHelp release];
    
    [versionUrl release];

    [cellCloudCallRate release];
    [cellCloudCallType release];
    [cellAppStorePraise release];
    
    [cellSyncContacts release];
    [labelSyncContacts release];
    [syncContacts release];
    
    [cellUse3G release];
    [labelUse3G release];
    [use3G release];
    
    [cellDialTone release];
    [labelDialTone release];
    [dialTone release];
    
    if (lastMsgCallId) {
        [lastMsgCallId release];
    }

    [cellGetPassword release];
    [super dealloc];
}

- (void)tableViewReloadData
{
    [self.tableView reloadData];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)ShowNewFeatureRemind:(NSString *)newFeature andShowCell:(UITableViewCell *)cell
{
    UIImageView *newFeatureShow = (UIImageView *)[cell viewWithTag:10];

    if ([[[NgnEngine sharedInstance].configurationService getStringWithKey:newFeature] length] != 0)
    {
        if (newFeatureShow == nil)
        {
            newFeatureShow = [[UIImageView alloc] initWithFrame:CGRectMake(239, 12, 33, 20)];
            newFeatureShow.image = [UIImage imageNamed:@"new_Feature_Remind.png"];
            newFeatureShow.tag = 10;
            [cell addSubview:newFeatureShow];
            [newFeatureShow release];
        }
    }
    else
    {
        if (newFeatureShow != nil)
        {
            newFeatureShow.hidden = YES;
            [newFeatureShow removeFromSuperview];
            newFeatureShow = nil;
        }
    }
}


#pragma mark -
#pragma mark 定义UIAlertTableView的委托，buttonindex就是按下的按钮的index值

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    switch (alertView.tag)
    {
        case kTagActionAlertDeactivate:
            if (buttonIndex == 0) { // Cancel
                ;// do nothing
            } else if (buttonIndex == 1) { // OK Remove the account
                
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                hud.labelText = @"注销中..";
                [self.view addSubview:hud];
                [hud showAnimated:YES whileExecutingBlock:^{
                    
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
                } completionBlock:^{
                        [appDelegate displayValidationView];
                        [hud removeFromSuperview];
                        [hud release];
                }];
            }
            break;
        case kTagActionAlertContactsSync_Enable:
            if (buttonIndex == 0) { // Cancel
                [self.syncContacts setOn:NO animated:YES];
            } else if (buttonIndex == 1) { // OK
                [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:GENERAL_ACCESS_CONTACTS_LIST_ALLOW];
            }
            break;
        case kTagActionAlertContactsSync_Disable:
            if (buttonIndex == 0) { // Cancel
                [self.syncContacts setOn:YES animated:YES];
            } else if (buttonIndex == 1) { // OK
                [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:GENERAL_ACCESS_CONTACTS_LIST_NOT_ALLOW];
            }
            break;
        case kTagActionAlertUse3G_Disable:
            if (buttonIndex == 0) { // Cancel
                [self.use3G setOn:YES animated:YES];
            } else if (buttonIndex == 1) { // OK
                [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_3G andValue:NO];
                
                //停止sip协议栈服务
                [[NgnEngine sharedInstance].sipService stopStackSynchronously];
            }
            break;
        case kTagActionAlertUpdateVersion:
            if (buttonIndex == 0)
            { // Cancel
                [versionUrl release];
                versionUrl = nil;
                
            }
            else if (buttonIndex == 1)
            { // Update
                if (versionUrl) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionUrl]];
                    [versionUrl release];
                    versionUrl = nil;
                }
            }
            break;
        case kTagActionAlertRecommendedSoftware:
            break;
        case kTagActionAlertAwardPraise:
            if (buttonIndex == 1)
            {
                [AFKReviewTroller sendPraiseDataToServer];
                //appstore评分
                int appId = [[[[NSBundle mainBundle] infoDictionary] objectForKey:kCloudCallAppID] intValue];
                
                //不再提醒
                [[NgnEngine sharedInstance].configurationService setBoolWithKey:@"isNeverPromptAppraise" andValue:YES];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:SystemVersion<7.0? @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d" : @"itms-apps://itunes.apple.com/app/id%d",appId]];
                [[UIApplication sharedApplication] openURL:url];
            }
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark kCheckVersionUpdateNotification
- (void)finishedCheckVersion
{
    [self hideAlertvView];
}

@end
