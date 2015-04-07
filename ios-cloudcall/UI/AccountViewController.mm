/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 

#import "AccountViewController.h"
#import "MailComposeViewController.h"
#import "CloudCall2AppDelegate.h"

#import "MobClick.h"
#import <DianJinOfferPlatform/DianJinTransitionParam.h>

#define kTagActionAlertDeactivate   1
#define kTagActionAlertContactsSync_Enable  2
#define kTagActionAlertContactsSync_Disable 3

@interface AccountViewController(Private)
// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
- (void) layoutForCurrentOrientation:(BOOL)animated;
- (void) GotoWebSite;

///////////////////////////////////////////////////////////////////////////////////////////////////
// create a sub-thread running at background to getconfiguration and start to register
-(BOOL) StartToGetConfigurationFromNetAndRegister;
-(void) StartToRegister;
-(void) StartReRegisterThread;
///////////////////////////////////////////////////////////////////////////////////////////////////
@end

@interface AccountViewController(Sip_And_Network_Callbacks)
-(void) onNetworkEvent:(NSNotification*)notification;
-(void) onRegistrationEvent:(NSNotification*)notification;
@end

@implementation AccountViewController(Sip_And_Network_Callbacks)
-(void) onNetworkEvent:(NSNotification*)notification {
	NgnNetworkEventArgs *eargs = [notification object];
	
	switch (eargs.eventType) {
		case NETWORK_EVENT_STATE_CHANGED:
		default:
		{
			CCLog(@"NetworkEvent reachable=%@ networkType=%i", 
                  [NgnEngine sharedInstance].networkService.reachable ? @"YES" : @"NO", [NgnEngine sharedInstance].networkService.networkType);
			
			if ([NgnEngine sharedInstance].networkService.reachable) {
                NgnNetworkType_t type = [[NgnEngine sharedInstance].networkService getNetworkType];
                NSString* strType = [[NgnEngine sharedInstance].networkService getNetworkTypeName:type];                
                if (strType) [self.netStatus setText:strType];
                else [self.netStatus setText:@""];
			} else {
                //network unreachable
                [self.netStatus setText:@"unreachable"];
            }
			
			break;
		}
	}
}

//== REGISTER events == //
-(void) onRegistrationEvent:(NSNotification*)notification {
    NgnRegistrationEventArgs* eargs = [notification object];
	CCLog(@"SettingsView: Reg notify: %d, %d, %@", eargs.eventType, eargs.sipCode, eargs.sipPhrase ? eargs.sipPhrase : @"");
    
	// gets the new registration state
	ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];	
	switch (registrationState) {
		case CONN_STATE_CONNECTED: {
            [self.connStatus setText:NSLocalizedString(@"CCOnline", @"CCOnline")];
            [self.buttonLogin setEnabled:NO];
            break;
        }
		case CONN_STATE_CONNECTING:
            [self.connStatus setText:NSLocalizedString(@"Connecting", @"Connecting")];
            [self.buttonLogin setEnabled:NO];
            break;
        case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:            
		case CONN_STATE_TERMINATING:
		default:
            [self.connStatus setText:NSLocalizedString(@"CCOffline", @"CCOffline")];
            [self.buttonLogin setEnabled:YES];
			break;
	}
}
@end

@implementation AccountViewController(Private)
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
    bannerOrigin.y = 0;
    CGFloat bannerHeight = 0.0f;
    
    if (iadbanner) {
        // First, setup the banner's content size and adjustment based on the current orientation
        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
            iadbanner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifier480x32;
        else {
            if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 4.2) {
                iadbanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
            } else {
                iadbanner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifier320x50;
            }
        }
        bannerHeight = iadbanner.bounds.size.height;
        
        // Depending on if the banner has been loaded, we adjust the content frame and banner location
        // to accomodate the ad being on or off screen.
        // This layout is for an ad at the bottom of the view.
        
        // And finally animate the changes, running layout for the content view if required.
        [UIView animateWithDuration:animationDuration
                         animations:^{                         
                             iadbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, iadbanner.frame.size.width, iadbanner.frame.size.height);
                         }];
    } else if (djbanner) {        
        bannerHeight = djbanner.bounds.size.height;
        [UIView animateWithDuration:animationDuration
                         animations:^{                         
                             djbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, djbanner.frame.size.width, djbanner.frame.size.height);
                         }];
    }
    else if (lmbanner) {        
        bannerHeight = lmbanner.bounds.size.height;
        [UIView animateWithDuration:animationDuration
                         animations:^{                         
                             lmbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, lmbanner.frame.size.width, lmbanner.frame.size.height);
                         }];
    }
}

- (void) GotoWebSite {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.5icloudcall.com"]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// create a sub-thread running at background to getconfiguration and start to register

-(BOOL) queryConfigurationAndRegister{
    if ([NgnEngine sharedInstance].networkService.reachable == NO) 
        return NO;
    
	BOOL bon3G = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
	BOOL buse3G = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
	if (bon3G && !buse3G) {
		return NO;
	} else {
        BOOL ret = [[NgnEngine sharedInstance].sipService registerIdentity];		
        return ret;
	}
    
    return NO;
}

-(BOOL) StartToGetConfigurationFromNetAndRegister {    
    BOOL ret = [self queryConfigurationAndRegister];
    if (NO == ret) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"WeiCall", @"WeiCall")
                                                        message: NSLocalizedString(@"Connect to server failed, please check your network connection.", @"Connect to server failed, please check your network connection.")
                                                       delegate: self cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    }
    return ret;
}

-(void) StartToRegister {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    [self performSelectorOnMainThread:@selector(StartToGetConfigurationFromNetAndRegister) withObject:nil waitUntilDone:NO];    
    [pool release];
}

-(void) StartReRegisterThread {
    [NSThread detachNewThreadSelector:@selector(StartToRegister) toTarget:self withObject:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
@end

@implementation AccountViewController

@synthesize tableView;

@synthesize cellMyNumber;
@synthesize labelMyNum;
@synthesize myNum;
@synthesize buttonDeactivate;

@synthesize cellConnStatus;
@synthesize labelConnStatus;
@synthesize connStatus;
@synthesize buttonLogin;

@synthesize cellNetStatus;
@synthesize labelNetStatus;  
@synthesize netStatus;

@synthesize cellSyncContacts;
@synthesize labelSyncContacts;  
@synthesize syncContacts;

@synthesize cellUse3G;
@synthesize labelUse3G;
@synthesize use3G;

@synthesize cellDialTone;
@synthesize labelDialTone;  
@synthesize dialTone;

@synthesize cellSendLog;
@synthesize buttonSendLog;

@synthesize cellVersion;
@synthesize labelVersion;
@synthesize version;

@synthesize cellCopyright;
@synthesize labelCopyright;

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
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    

#if 0
    ///////////////////////////////////////
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image=[UIImage imageNamed:@"tabbar_bg.png"];
    [self.toolbar addSubview:imageview];
    ///////////////////////////////////////
#else
    ///////////////////////////////////////
    UIImageView *topBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    topBar.image = [UIImage imageNamed:@"tabbar_bg.png"];
    [self.navigationController.navigationBar addSubview:topBar];
    
    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    labelTitle.text = NSLocalizedString(@"Settings", @"Settings");
    labelTitle.textAlignment = UITextAlignmentCenter;
    [labelTitle setBackgroundColor:[UIColor clearColor]];
    labelTitle.font = [UIFont systemFontOfSize:17];
    labelTitle.textColor= [UIColor whiteColor];
    [self.navigationController.navigationBar addSubview:labelTitle];
    ///////////////////////////////////////
#endif
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.myNum.text = @"";
    
    [self.labelMyNum setText:NSLocalizedString(@"My Number", @"My Number")];
    [self.buttonDeactivate setTitle:NSLocalizedString(@"Deactivate", @"Deactivate") forState:UIControlStateNormal];
    
    [self.labelConnStatus setText:NSLocalizedString(@"Connect status", @"Connect status")];    
    [self.connStatus setText:NSLocalizedString(@"CCOffline", @"CCOffline")];
    [self.buttonLogin setTitle:NSLocalizedString(@"Login", @"Login") forState:UIControlStateNormal];
    
    [self.labelNetStatus setText:NSLocalizedString(@"Net Status", @"Net Status")];


    [self.labelSyncContacts setText:NSLocalizedString(@"Allow to Sync Contacts", @"Allow to Sync Contacts")];
    
    [self.labelUse3G setText:NSLocalizedString(@"Use 2G/3G", @"Use 2G/3G")];
    
    [self.labelDialTone setText:NSLocalizedString(@"Dial Tone", @"Dial Tone")];
    
    [self.buttonSendLog setTitle:NSLocalizedString(@"Send Log via Email", @"Send Log via Email") forState:UIControlStateNormal];
    
    if ([NgnEngine sharedInstance].networkService.reachable) {
        NgnNetworkType_t type = [[NgnEngine sharedInstance].networkService getNetworkType];
        NSString* strType = [[NgnEngine sharedInstance].networkService getNetworkTypeName:type];                
        if (strType) [self.netStatus setText:strType];
        else [self.netStatus setText:@""];
    } else {
        //network unreachable
        [self.netStatus setText:NSLocalizedString(@"Unreachable", @"Unreachable")];
    }
    
    [self.labelVersion setText:NSLocalizedString(@"Version:", @"Version:")];
    [self.version setText:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        
    [self.labelCopyright setText:NSLocalizedString(@"Copyright declare", @"Copyright declare")];
    
    // add observers
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkEvent:) name:kNgnNetworkEventArgs_Name object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];

    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    if (appDelegate.adType == AD_TYPE_UMENG) {
        umbanner = [[UMUFPBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50) appKey:UMENG_APP_KEY slotId:nil currentViewController:self];
        umbanner.mBackgroundColor = [UIColor lightGrayColor];
        umbanner.mTextColor = [UIColor whiteColor];
        umbanner.delegate = (id<UMUFPBannerViewDelegate>)self;
        [self.view addSubview:umbanner];
        [umbanner release];
        [umbanner requestPromoterDataInBackground];
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
    [MobClick beginLogPageView:@"Settings"];
    
    ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];	
	switch (registrationState) {
		case CONN_STATE_CONNECTED: {
            [self.connStatus setText:NSLocalizedString(@"CCOnline", @"CCOnline")];
            [self.buttonLogin setEnabled:NO];
            break;
        }
		case CONN_STATE_CONNECTING:
            [self.connStatus setText:NSLocalizedString(@"Connecting", @"Connecting")];
            [self.buttonLogin setEnabled:NO];
            break;
        case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:            
		case CONN_STATE_TERMINATING:
		default:
            [self.connStatus setText:NSLocalizedString(@"CCOffline", @"CCOffline")];
            [self.buttonLogin setEnabled:YES];
			break;
	}
    
    NSString *num = [[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_IMPI];
    [self.myNum setText:num];
    [self.buttonDeactivate setEnabled: [num length]?YES:NO];
    
    int syncc = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_ACCESS_CONTACTS_LIST];
    [self.syncContacts setOn:(syncc==GENERAL_ACCESS_CONTACTS_LIST_ALLOW) animated:NO];
    
    BOOL en = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
    [self.use3G setOn:en animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"Settings"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kTagActionAlertDeactivate:
            if (buttonIndex == 0) { // Cancel
                ;// do nothing
            } else if (buttonIndex == 1) { // OK
                [[NgnEngine sharedInstance].sipService stopStackSynchronously];                
                
                [[NgnEngine sharedInstance].contactService dbClearWeiCallUsers];
                
                self.myNum.text = @"";
                [self.buttonDeactivate setEnabled:NO];
                
                [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:DEFAULT_GENERAL_ACCESS_CONTACTS_LIST]; 
                
                [[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPI andValue:DEFAULT_IDENTITY_IMPI];
                [[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_PASSWORD andValue:DEFAULT_IDENTITY_PASSWORD];
                
                NSString* strhost = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_HOST];                
                [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_REG_HOST andValue:strhost];                
                
                CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                [appDelegate displayValidationView];
                [appDelegate HaveSetReferee:NO];
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
        default:
            break;
    }
}

/*-(void) SignIn {
    NSString* remoteParty = @"cc-server";
    NSString* remotePartyUri = [NgnUriUtils makeValidSipUri: remoteParty];
    
    NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack] 
                                                                              andToUri: remotePartyUri];        
    BOOL ret = [session sendTextMessage:@"" contentType:@"text/signin"];
    CCLog(@"SignIn %d", ret);
}*/

- (IBAction) onButtonClick: (id)sender {
    if (sender == buttonDeactivate) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"WeiCall", @"WeiCall")
                                                        message: NSLocalizedString(@"Are you sure you want to deavtivate current number?", @"Are you sure you want to deavtivate current number?")
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
        alert.tag = kTagActionAlertDeactivate;
        [alert show];
        [alert release];
    } else if (sender == buttonLogin) {
#if 1
        [self StartReRegisterThread];
#else
        BOOL ret = [[NgnEngine sharedInstance].sipService registerIdentity]; // Ask for access code
        if (NO == ret) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"WeiCall", @"WeiCall")
                                                            message: NSLocalizedString(@"Connect to server failed, please check your network connection.", @"Connect to server failed, please check your network connection.")
                                                           delegate: self cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
        }
#endif
    } else if (sender == buttonSendLog) {
        if ([MFMailComposeViewController canSendMail] == YES) {        
            NSString* attachfile = [[NgnEngine sharedInstance].logService getCompressdLogFile];
            //SendMail
            MailComposeViewController* mailer = [MailComposeViewController alloc];
            [self.navigationController pushViewController:mailer animated:YES];
            NSArray *toRecipients = [NSArray arrayWithObjects:@"support@cloudcall.hk", nil];
            [mailer Sendmail:toRecipients Subject:NSLocalizedString(@"WeiCall log", @"WeiCall log") MessageBody:@"" isHTML:NO attach:attachfile attachDispName:NSLocalizedString(@"WeiCall log", @"WeiCall log")];
            [mailer release];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"No Email Account", @"No Email Account")
                                                            message: NSLocalizedString(@"You must set up an email account for your device before you send mail.", @"You must set up an email account for your device before you send mail.")
                                                           delegate: nil
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
        }
    }
}

- (IBAction) onSwitchChanged: (id) sender {
    UISwitch *switcher = (UISwitch *)sender;
    if (switcher == syncContacts) {
        BOOL en = switcher.isOn;
        NSString* strPrompt = en ? NSLocalizedString(@"Are you sure you want to enable contacts sync?", @"Are you sure you want to enable contacts sync?") : NSLocalizedString(@"Are you sure you want to disable contacts sync?", @"Are you sure you want to disable contacts sync?");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Contacts Sync", @"Contacts Sync")
                                                        message: strPrompt
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
        alert.tag = en ? kTagActionAlertContactsSync_Enable : kTagActionAlertContactsSync_Disable;
        [alert show];
        [alert release];
    } else if (switcher == use3G) {
        BOOL en = switcher.isOn;
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_3G andValue:en];
    } else if (switcher == dialTone) {
        BOOL en = switcher.isOn;
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_DIAL_TONE_ENABLE andValue:en];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//
//	UITableViewDelegate
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{    
    switch(section){        
        case 0:  return NSLocalizedString(@"Personal Information", @"Personal Information");
        case 1:  return NSLocalizedString(@"Settings", @"Settings");
        case 2:  return NSLocalizedString(@"About", @"About");
        case 3:  return NSLocalizedString(@"Log", @"Log");
        default: return nil;
    }
}

/*- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{    
    switch(section){        
        case 0:  return @"";
        case 1:  return @"";
        case 2:  return @"";
        case 3:  return@"";
        default: return nil;
    }
}*/

- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section {    
    switch(section){        
        case 0: return 3;
        case 1: return 3;
        case 2: return 2;
        case 3: return 1;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch(indexPath.row){
                case 0:
                    return cellMyNumber;
                case 1:
                    return cellConnStatus;
                case 2:
                    return cellNetStatus;
                default:
                    return nil;                    
            }
            break;
        case 1:
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
        case 2:
            switch(indexPath.row){
                case 0:
                    return cellVersion;
                case 1:
                    return cellCopyright;
                default:
                    return nil;                    
            }
            break;
        case 3:
            switch(indexPath.row){
                case 0:
                    return cellSendLog;
                default:
                    return nil;
            }
            break;
        default:
            return nil;
            break;
    }
}

- (void)dealloc {
    [self.tableView release];
    
    [labelTitle release];
    
    [self.cellMyNumber release];
    [self.labelMyNum release];
    [self.myNum release];
    [self.buttonDeactivate release];
 
    [self.cellNetStatus release];
    [self.labelNetStatus release];
    [self.netStatus release];
    
    [self.cellSyncContacts release];
    [self.labelSyncContacts release];
    [self.syncContacts release];
    
    [self.cellUse3G release];
    [self.labelUse3G release];
    [self.use3G release];
    
    [self.cellDialTone release];
    [self.labelDialTone release];
    [self.dialTone release];
    
    [self.cellSendLog release];
    [self.buttonSendLog release];
    
    [self.cellVersion release];
    [self.labelVersion release];
    [self.version release];
    
    [self.cellCopyright release];
    [self.labelCopyright release];
    
    [self.buttonAd release];

    [super dealloc];
}

// BannerViewContainer
- (void)showBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
    if (type == AD_TYPE_IAD) {
        iadbanner = (ADBannerView*)bannerView;        
        [self.view addSubview:iadbanner];
        [self layoutForCurrentOrientation:animated];
    } else if (type == AD_TYPE_91DIANJIN) {
        djbanner = (DianJinOfferBanner*)bannerView;
        [self.view addSubview:djbanner];
    }
    else if (type == AD_TYPE_LIMEI)
    {
        lmbanner = (immobView*)bannerView;
        [self.view addSubview:lmbanner];
        [lmbanner immobViewDisplay];
    }
}

- (void)hideBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
    if (type == AD_TYPE_IAD) {
        iadbanner = nil;        
        [self layoutForCurrentOrientation:animated];
    } else if (type == AD_TYPE_91DIANJIN) {
        djbanner = nil;
        [djbanner removeFromSuperview];
    }
    else if (type == AD_TYPE_LIMEI)
    {
        lmbanner = nil;
        [lmbanner removeFromSuperview];
    }
             
}

@end
