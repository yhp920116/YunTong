//
//  MoreViewController.m
//  CloudCall
//
//  Created by CloudCall on 13-4-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "PointWallViewController.h"
#import "MoreViewController.h"
#import "SettingsViewController.h"
#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"
#import "NotificationViewController.h"
#import "InviteFriendsViewController.h"
#import "PersonalInfoNewViewController.h"

#import "IAPRechargeViewController.h"
#import "IAPHelperRecharge.h"
#import "RechargeCollectViewController.h"

#import "ShakeToSignInViewController.h"
#import "SlotMachineViewController.h"
#import "MobClick.h"
#import "StaticUtils.h"


#import "WebBrowser.h"
#import "HttpRequest.h"
#import "JSONKit.h"

#import "CouponListViewController.h"

enum
{
    kTagSignIn = 100,
    kTagRecommendeApps,
    kTagSlotMachine,
    kTagInviteFriends,
    kTagBalance,
    kTagGainCoupon,
    kTagTemp1,
    kTagTemp2
};
#define kDiscoverItemsFileName @"discoverItemsfile.plist"


static NSDate *localDate;

@implementation ItemsData
@synthesize iconUrl;
@synthesize title;
@synthesize url;
@synthesize enable;
@synthesize need2Update;
@synthesize update_time;
@synthesize index;

- (id) initWithTitle:(NSString *)_title withIconUrl:(NSString *)_iconUrl withUrl:(NSString *)_url withEnable:(BOOL)_enable withIndex:(NSInteger)_index withUpdateTime:(NSString *)_update_time
{
    if ((self = [super init])) {
        self.title = _title;
        self.iconUrl = _iconUrl;
        self.url = _url;
        self.update_time = _update_time;
        self.enable = _enable;
        self.index = _index;
	}
	return self;
}

- (void)dealloc
{
    [iconUrl release];
    [title release];
    [url release];
    [update_time release];
    
    [super dealloc];
}

@end

@interface MoreViewController(Private)
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

@implementation MoreViewController(Private)
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
                             if (SystemVersion >= 7.0)
                             {
                                 ctbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y + 20, ctbanner.frame.size.width, ctbanner.frame.size.height);
                             }
                             else
                             {
                                 ctbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, ctbanner.frame.size.width, ctbanner.frame.size.height);
                             }
                         }];
    } else if (bdbanner) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             if (SystemVersion >= 7.0)
                             {
                                 bdbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y + 20, bdbanner.frame.size.width, bdbanner.frame.size.height);
                             }
                             else
                             {
                                 bdbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, bdbanner.frame.size.width, bdbanner.frame.size.height);
                             }
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

@interface MoreViewController(Sip_And_Network_Callbacks)
-(void) onMessagingEvent:(NSNotification*)notification;
@end

@implementation MoreViewController(Sip_And_Network_Callbacks)

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
                    if ([[contentType lowercaseString] hasPrefix:@"text/balance"]) {
                        [self hideAlertvView];
                        
                        if ([lastMsgCallId isEqualToString: eargs.callId]) {
                            CCLog(@"Incoming message: Error -- the same call-id as the last received %@", eargs.callId);
                            break;
                        }
                        if (lastMsgCallId) {
                            [lastMsgCallId release];
                            lastMsgCallId = nil;
                        }
                        lastMsgCallId = [eargs.callId retain];
                        
                        NSString *strContent = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
                        CCLog(@"strContent: %@", strContent);
                        
                        /*   Content-Type:text/balance
                         remainmoney:            //用户余额
                         errorcode:0             //0 – 成功；无错误代码
                         */
                        
                        int balance = 0;
                        int errorcode = 0;
                        
                        NSString* strTmp = [strContent stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                        NSArray *array = [strTmp componentsSeparatedByString:@"\n"];
                        CCLog(@"array:%@",array);
                        for (NSString* str in array) {
                            CCLog(@"item:%@", str);
                            NSString* item = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            if (!item || [item length] == 0)
                                continue;
                            NSArray *as = [item componentsSeparatedByString:@":"];
                            if (as && as.count == 2) {
                                NSString* strparameter = [as objectAtIndex:0];
                                NSString* strvalue     = [as objectAtIndex:1];
                                strparameter = [strparameter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                strvalue     = [strvalue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                
                                CCLog(@"p=%@, v=%@\n", strparameter, strvalue);
                                if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"remainmoney"]) {
                                    balance = [strvalue intValue];
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"errorcode"]) {
                                    errorcode = [strvalue intValue];
                                }
                                CCLog(@"errorcode=%d", errorcode);
                            }
                        }
                        
                        NSString* strbalance = [[NSString alloc] initWithFormat:NSLocalizedString(@"Your balance is %d YunTong points.", @"Your balance is %d YunTong points."),  balance];
                        UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Balance", @"Balance")
                                                                    message: strbalance
                                                                   delegate: self
                                                          cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                        [a show];
                        [a release];
                        [strbalance release];
                        
                        [strContent release];
                        
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


@implementation MoreViewController

@synthesize scrollView;
@synthesize tempItemsArray;
@synthesize viewToolbar;
@synthesize toolbar;
@synthesize labelTitle;

@synthesize rHeaderView;
@synthesize photo;
@synthesize name;
@synthesize phoneNum;
@synthesize vipLevel;
@synthesize personalInfBtn;
@synthesize rechargeBtn;

@synthesize viewGetCloudCallPoint;
@synthesize viewPracticalFunction;
@synthesize labelGetCloudCallPoint;
@synthesize labelPracticalFunction;
@synthesize wenHaoBtn;

@synthesize buttonAd;
@synthesize barButtonSetting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Discover", @"Discover") image:[UIImage imageNamed:@"tab_discover_normal"] tag:3];
        if (SystemVersion >= 5.0)
            [item setFinishedSelectedImage:[UIImage imageNamed:@"tab_discover_down"]
               withFinishedUnselectedImage:[UIImage imageNamed:@"tab_discover_normal"]];
        
        self.tabBarItem = item;
        [item release];
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
    CloudCall2AppDelegate* appDelegate = [CloudCall2AppDelegate sharedInstance];
    [appDelegate GetAccountBalance];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tempItemsArray = [NSMutableArray arrayWithCapacity:10];
    localDate = [NSDate new];
    
    self.labelTitle.text = NSLocalizedString(@"Discover", @"Discover");
    self.labelTitle.textColor = [UIColor colorWithRed:130.0f/255.0f green:140.0f/255.0f blue:150.0f/255.0f alpha:1.0];
    self.name.adjustsFontSizeToFitWidth = YES;
    ///////////////////////////////////////
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image = [UIImage imageNamed:@"toolbar_bg.png"];
    [self.toolbar addSubview:imageview];
    [imageview release];
    ///////////////////////////////////////
    
    
    self.barButtonSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    barButtonSetting.frame = CGRectMake(266, 0, 44, 44);
    [self.barButtonSetting setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    barButtonSetting.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [self.barButtonSetting setBackgroundImage:[UIImage imageNamed:@"setting_up.png"] forState:UIControlStateNormal];
    [self.barButtonSetting setBackgroundImage:[UIImage imageNamed:@"setting_down.png"] forState:UIControlStateHighlighted];
    [barButtonSetting addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:barButtonSetting];
 
    if (SystemVersion > 5)
        [self.rHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"personalInfo_bg"]]];
    else
    {
        self.rHeaderView.layer.borderWidth = 1;
        self.rHeaderView.layer.borderColor = [[UIColor colorWithRed:166.0f/255.0f green:166.0f/255.0f blue:166.0f/255.0f alpha:0.8f] CGColor];
    }
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);

    showAllFeature = [appDelegate ShowAllFeatures];
    
//    [self updatePersonalInfo];
    [self LoadDiscoverItemsData];
    [self initButtonItems];
    
    self.labelPracticalFunction.text = NSLocalizedString(@"Useful functions", @"Useful functions");
    self.labelGetCloudCallPoint.text = NSLocalizedString(@"Earn YunTong Points", @"Earn YunTong Points");

    // add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:@"updateMoreView" object:nil];
    
    [self updateView];
    
    
    if (SystemVersion >= 7.0)
    {
        self.viewToolbar.frame = CGRectMake(self.viewToolbar.frame.origin.x, self.viewToolbar.frame.origin.y + 20, self.viewToolbar.frame.size.width, self.viewToolbar.frame.size.height);
        self.buttonAd.frame = CGRectMake(self.buttonAd.frame.origin.x, self.buttonAd.frame.origin.y + 20, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height);
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y + 20, self.scrollView.frame.size.width, self.scrollView.frame.size.height-20);
        
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
    [MobClick beginLogPageView:@"Discover"];
    [self updatePersonalInfo];
    
    NSDate *now = [NSDate new];
    if ([now compare:localDate] == NSOrderedDescending)
    {
        if (localDate)
            [localDate release];
        localDate = [[now dateByAddingTimeInterval:60*60] retain];
        //Get Info form server when view will appear
        [self getSquareappItems];
    }
    [now release];
    
    [[CloudCall2AppDelegate sharedInstance] viewChanged:self];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);

    showInAppPurchase = [appDelegate ShowInAppPurchase];

    [self.navigationController setNavigationBarHidden: YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"Discover"];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    ctbanner = appDelegate.ctbanner;
    [ctbanner bannerViewHide];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - customized methods

- (void)getSquareappItems
{
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObject:mynum forKey:@"user_number"];
    
    [[HttpRequest instance] addRequestWithEncrypt:kGetSquareAppUrl andMethod:@"POST" andContent:jsonDic andTimeout:10
                         delegate:self successAction:@selector(responseWithSucceeded:)
                        failureAction:@selector(responseWithFailed:) userInfo:nil];
}

/**
 *	@brief	保存服务器返回信息到plist文件
 */
- (void)SaveDiscoverItemsData:(NSArray *)items
{
    NSString *errorDesc;
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:(id)items format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDesc];
    
    // 这个plistData为创建好的plist文件，用其writeToFile方法就可以写成文件。下面是代码：
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    NSString *DiscoverItemsPath = [appDelegate GetDiscoverItemsDirDirectoryPath];
    NSString *savePath = [DiscoverItemsPath stringByAppendingPathComponent:kDiscoverItemsFileName];
    
    // 存文件
    if (plistData) {
        [plistData writeToFile:savePath atomically:YES];
    } else {
        CCLog(@"%@", errorDesc);
        [errorDesc release];
    }
    [self saveIconPicture:items];
}

/**
 *	@brief	读取本地存储的广告信息
 */
-(void)LoadDiscoverItemsData
{
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    NSString *path = [appDelegate GetDiscoverItemsDirDirectoryPath];
    NSString *filename = [path stringByAppendingPathComponent:kDiscoverItemsFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:nil])
    {
        NSMutableArray *appList = [[NSMutableArray alloc] initWithContentsOfFile:filename];
        
        [tempItemsArray removeAllObjects];
        for (NSMutableDictionary* d in appList)
        {
            BOOL enable = [[d objectForKey:@"enable"] boolValue];
            NSString *iconUrl = [d objectForKey:@"iconUrl"];
            int index = [[d objectForKey:@"index"] intValue];
            NSString *title = [d objectForKey:@"title"];
            NSString *url = [d objectForKey:@"url"];
            NSString *updateTime = [d objectForKey:@"update_time"];
            
            if (enable)
            {
                ItemsData *data = [[ItemsData alloc] initWithTitle:title withIconUrl:iconUrl withUrl:url withEnable:enable withIndex:index withUpdateTime:updateTime];
                [tempItemsArray addObject:data];
                [data release];
            }
        }
        [appList release];
    }
    [self updateTempItems];
}

- (void)saveIconPicture:(NSArray *)appList
{
    if (!appList || [appList count] == 0) {
        CCLog(@"discover items Array is empty!!!");
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    NSString *discoverItemsPath = [appDelegate GetDiscoverItemsDirDirectoryPath];

    NSError *error = nil;
    // fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:discoverItemsPath error:&error];
    for (NSString* f in fileList)
    {
        //如果是.plist文件的话就不删除
        NSString *suffix = [f substringFromIndex:([f length]-6)];
        if ([suffix isEqualToString:@".plist"])
            continue;
        
        BOOL del = YES;
        for (ItemsData* a in tempItemsArray)
        {
            for (NSDictionary *item in appList)
            {
                NSString *updataTime = [item objectForKey:@"update_time"];
                int index = [[item objectForKey:@"index"] intValue];
                
                //根据时间判断是否需要更新文件
                NSComparisonResult upRet = [updataTime caseInsensitiveCompare:a.update_time];
                if (a.index == index && upRet == NSOrderedAscending)
                {
                    a.need2Update = YES;
                    break;
                }
            }
            
            if (NSOrderedSame == [f caseInsensitiveCompare:[a.iconUrl lastPathComponent]] && a.need2Update == NO)
            {
                del = NO;
                break;
            }
        }
        NSString* p = [discoverItemsPath stringByAppendingPathComponent:f];
        if (del)
            [fileManager removeItemAtPath:p error:nil];
    }
    
    //实现异步加载图片
    dispatch_queue_t queue = dispatch_queue_create (DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
    dispatch_async(queue, ^{
        for (NSDictionary *item in appList)
        {
            NSString *updataTime = [item objectForKey:@"update_time"];
            int index = [[item objectForKey:@"index"] intValue];
            BOOL need2Update = NO;
            for (ItemsData *a in tempItemsArray)
            {
                //根据时间判断是否需要更新文件
                NSComparisonResult upRet = [updataTime caseInsensitiveCompare:a.update_time];
                if (a.index == index && upRet == NSOrderedAscending)
                {
                    need2Update = YES;
                    break;
                }
            }
            
            NSString *_iconUrl = [item objectForKey:@"iconUrl"];
            BOOL enable = [[item objectForKey:@"enable"] boolValue];
            if (_iconUrl && [_iconUrl length]) {
                NSString* imgfile = [discoverItemsPath stringByAppendingPathComponent:[_iconUrl lastPathComponent]];
                if (enable && (need2Update || ![fileManager fileExistsAtPath:imgfile isDirectory:nil])) {
                    CCLog(@" ---------download discover imgfile %@" , _iconUrl);
                    NSData* imageData = [[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:_iconUrl]] autorelease];
                    if (imageData) {
                        [self writeData2File:imageData toFileAtPath:imgfile];
                    } else {
                        CCLog(@"Get image failed %@", _iconUrl);
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self LoadDiscoverItemsData];
        });

    });
    dispatch_release(queue);

}

- (void)updateTempItems
{
    float viewWidth = 71;
    float viewHeight = 82;
    
    if ([tempItemsArray count] != 0)
    {
        if ([tempItemsArray count] > 2)
            scrollView.contentSize = CGSizeMake(320, SystemVersion>=7.0?(399+40):399);
        else
            scrollView.contentSize = CGSizeMake(320, 317);

        CGFloat viewPracticalFunction_y = showAllFeature ? (viewGetCloudCallPoint.frame.origin.y+viewGetCloudCallPoint.frame.size.height) : viewGetCloudCallPoint.frame.origin.y;
        self.viewPracticalFunction.frame = CGRectMake(viewGetCloudCallPoint.frame.origin.x, viewPracticalFunction_y, viewGetCloudCallPoint.frame.size.width, scrollView.contentSize.height-viewGetCloudCallPoint.frame.origin.y);
        
        CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
        NSString *discoverItemsPath = [appDelegate GetDiscoverItemsDirDirectoryPath];
        for (int i = 0; i<[tempItemsArray count]; i++)
        {
            ItemsData *data = [tempItemsArray objectAtIndex:i];
            NSString * imgfile = [discoverItemsPath stringByAppendingPathComponent:[data.iconUrl lastPathComponent]];
            
            //动态配置的tag从10开始
            MoreViewCell *view = (MoreViewCell *)[viewPracticalFunction viewWithTag:data.index+10];
            if (view == nil)
            {
                CGRect viewCellRect;
                if (i < 2)
                    viewCellRect = CGRectMake(19+viewWidth*(2+i), 29, viewWidth, viewHeight);
                else
                    viewCellRect = CGRectMake(19+viewWidth*((i-2)%4), 115, viewWidth, viewHeight);
                
                view = [[MoreViewCell alloc] initWithFrame:viewCellRect withButtonTag:data.index+10 withBtnNormalImage:[UIImage imageWithContentsOfFile:imgfile] withBtnPressImage:nil withLabelName:data.title];
                view.tag = data.index+10;
                view.hidden = !data.enable;
                [view SetDelegate:self];
                [self.viewPracticalFunction addSubview:view];
                [view release];
            }
            else
            {
                [view.buttonAction setImage:[UIImage imageWithContentsOfFile:imgfile] forState:UIControlStateNormal];
                view.labelName.text = data.title;
                view.hidden = !data.enable;
            }
        }
    }
    for (int i = [tempItemsArray count]+10; i<16; i++)
    {
        MoreViewCell *view = (MoreViewCell *)[viewPracticalFunction viewWithTag:i];
        if (view != nil)
        {
            [view removeFromSuperview];
            view = nil;
        }
    }
}

/**
 *	@brief	将数据写到文件
 *
 *	@param 	data 	数据
 *	@param 	aPath 	文件路径
 *
 *	@return	返回写入结果
 */
- (BOOL)writeData2File:(NSData*)data toFileAtPath:(NSString*)aPath
{
    if (!data || !aPath || ![aPath length])
        return NO;
    
    @try {
        if ((data == nil) || ([data length] <= 0))
            return NO;
        
        [data writeToFile:aPath atomically:YES];
        
        return YES;
    } @catch (NSException *e) {
        CCLog(@"create thumbnail exception.");
    }
    
    return NO;
}

- (void)initButtonItems
{
    float viewWidth = 71;
    float viewHeight = 82;
    MoreViewCell *view1 = [[MoreViewCell alloc] initWithFrame:CGRectMake(19, 29, viewWidth, viewHeight) withButtonTag:kTagSignIn withBtnNormalImage:[UIImage imageNamed:@"more_signIn.png"] withBtnPressImage:[UIImage imageNamed:@"more_signIn_down.png"] withLabelName:NSLocalizedString(@"Shake to Sign In", @"Shake to Sign In")];
    view1.tag = kTagSignIn;
    [view1 SetDelegate:self];
    [self.viewGetCloudCallPoint addSubview:view1];
    [view1 release];
    
    MoreViewCell *view2 = [[MoreViewCell alloc] initWithFrame:CGRectMake(19+viewWidth, 29, viewWidth, viewHeight) withButtonTag:kTagRecommendeApps withBtnNormalImage:[UIImage imageNamed:@"more_recommendedApps.png"] withBtnPressImage:[UIImage imageNamed:@"more_recommendedApps_down.png"] withLabelName:NSLocalizedString(@"Recommended Application", @"Recommended Application")];
    view2.tag = kTagRecommendeApps;
    [view2 SetDelegate:self];
    [self.viewGetCloudCallPoint addSubview:view2];
    [view2 release];
    
    MoreViewCell *view3 = [[MoreViewCell alloc] initWithFrame:CGRectMake(19+viewWidth*2, 29, viewWidth, viewHeight) withButtonTag:kTagSlotMachine withBtnNormalImage:[UIImage imageNamed:@"more_slotMachine.png"] withBtnPressImage:[UIImage imageNamed:@"more_slotMachine_down.png"] withLabelName:NSLocalizedString(@"Happy to shake", @"Happy to shake")];
    view3.tag = kTagSlotMachine;
    [view3 SetDelegate:self];
    [self.viewGetCloudCallPoint addSubview:view3];
    [view3 release];
    
    //邀请好友
    MoreViewCell *view4 = [[MoreViewCell alloc] initWithFrame:CGRectMake(19+viewWidth*3, 29, viewWidth, viewHeight) withButtonTag:kTagInviteFriends withBtnNormalImage:[UIImage imageNamed:@"more_inviteFriends.png"] withBtnPressImage:[UIImage imageNamed:@"more_inviteFriends_down.png"] withLabelName:NSLocalizedString(@"Invite Friends", @"Invite Friends")];
    view4.tag = kTagInviteFriends;
    [view4 SetDelegate:self];
    [self.viewGetCloudCallPoint addSubview:view4];
    [view4 release];
    
    //实用功能
    //查询余额
    MoreViewCell *view5 = [[MoreViewCell alloc] initWithFrame:CGRectMake(19, 29, viewWidth, viewHeight) withButtonTag:kTagBalance withBtnNormalImage:[UIImage imageNamed:@"more_balance.png"] withBtnPressImage:[UIImage imageNamed:@"more_balance_down.png"] withLabelName:NSLocalizedString(@"Balance", @"Balance")];
    view5.tag = kTagBalance;
    [view5 SetDelegate:self];
    [self.viewPracticalFunction addSubview:view5];
    [view5 release];
    
    //云通优惠券
    MoreViewCell *view6 = [[MoreViewCell alloc] initWithFrame:CGRectMake(19+viewWidth, 29, viewWidth, viewHeight) withButtonTag:kTagGainCoupon withBtnNormalImage:[UIImage imageNamed:@"coupon_up.png"] withBtnPressImage:[UIImage imageNamed:@"coupon_down.png"] withLabelName:NSLocalizedString(@"YunTong Coupon", @"YunTong Coupon")];
    view6.tag = kTagGainCoupon;
    [view6 SetDelegate:self];
    [self.viewPracticalFunction addSubview:view6];
    [view6 release];
    
    [self updateTempItems];
}

- (void)SignInRemindCallBack
{
    //这里如果使用[self.navigationController pushViewController:＊＊＊ animated:YES]的话，会使用界面混乱
    ShakeToSignInViewController* sv = [[ShakeToSignInViewController alloc] initWithNibName:@"ShakeToSignInView" bundle:[NSBundle mainBundle]];
    sv.isSignInRemind = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sv];
    [self presentModalViewController:nav animated:NO];
    [sv release];
    [nav release];
}

#pragma mark - MoreViewCellDelegate
-(void) buttonClickCallBack:(NSInteger)index
{
    switch (index) {
        case kTagSignIn:
        {
            ShakeToSignInViewController* sv = [[ShakeToSignInViewController alloc] initWithNibName:@"ShakeToSignInView" bundle:[NSBundle mainBundle]];
            sv.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:sv animated:YES];
            [sv release];
            break;
        }
        case kTagRecommendeApps:
        {
            PointWallViewController *pointWallView = [[PointWallViewController alloc] initWithNibName:@"PointWallViewController" bundle:nil];
            pointWallView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:pointWallView animated:YES];
            [pointWallView release];
            break;
        }
        case kTagSlotMachine:
        {
            if ([[NgnEngine sharedInstance].getNetworkService isReachable]) {
                SlotMachineViewController *slotMachine = [[SlotMachineViewController alloc] initWithNibName:@"SlotMachineViewController" bundle:[NSBundle mainBundle]];
                slotMachine.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:slotMachine animated:YES];
                [slotMachine release];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Happy to shake",@"Happy to shake")
                                                                message:NSLocalizedString(@"No network connection",@"No network connection")
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OK",@"OK"), nil];
                [alert show];
                [alert release];
            }

            break;
        }
        case kTagInviteFriends:
        {
            InviteFriendsViewController* iv = [[InviteFriendsViewController alloc] initWithNibName:@"InviteFriendsView" bundle:[NSBundle mainBundle]];
            iv.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:iv animated:YES];
            [iv release];
            break;
        }
        case kTagBalance:
        {
            [self GetBalance];
            [self showAlertvView:NSLocalizedString(@"Checking balance...", @"Checking balance...") andExpire:8 andFailPrompt:NSLocalizedString(@"Check balance failed, please try again later!", @"Check balance failed, please try again later!")];
            break;
        }
        case kTagGainCoupon:
        {
            CouponListViewController* iv = [[CouponListViewController alloc] initWithNibName:@"CouponListViewController" bundle:[NSBundle mainBundle]];
            iv.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:iv animated:YES];
            [iv release];
            break;
        }
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
        {
            if ([tempItemsArray count] > (index-10))
            {
                ItemsData *data = [tempItemsArray objectAtIndex:index-10];
                [self OpenWebBrowser:data.url withBarTitle:data.title withType:TSMiniWebBrowserTypeDefault];
            }
            break;
        }
        default:
            break;
    }
}

- (void)updatePersonalInfo
{
    //设置VIP等级标签
    int userLevel = 0;

    userLevel = [[[NgnEngine sharedInstance].infoService getInfoValueForkey:[ACCOUNT_LEVEL lowercaseString]] integerValue];
    if (0 == userLevel) {
        [self.vipLevel setHidden:YES];
    } else {
        [self.vipLevel setHidden:NO];
        [self.vipLevel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"vip%d.png", userLevel]]];
    }
    
    //设置联系电话
    NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
    
    if ([num isEqualToString:DEFAULT_IDENTITY_IMPI])
        num = @"";
    [self.phoneNum setText:[NSString stringWithFormat:@"%@",num]];
    
    //名字
    NSString *oldnum = [[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_LOCALNUM];
    if([oldnum isEqualToString:num])
    {
        self.name.text = [NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_NAME]];
    }
    else
    {
        self.name.text = @"";
    }
    
    //头像
    
    if ([oldnum isEqualToString:num]) {
        NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:num];
        if (contact && contact.picture != nil)
        {
            // Fetch image from NgnContact
            self.photo.image = [StaticUtils createRoundedRectImage:[UIImage imageWithData:contact.picture] size:CGSizeMake(80, 80)];
        }
        else
        {
            //Fetch image from CoreData
            self.photo.image = [StaticUtils createRoundedRectImage:[UIImage imageWithData:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_THUMBNAIL]] size:CGSizeMake(80, 80)];
        }
    }
}

- (void)updateView
{
    if ([[CloudCall2AppDelegate sharedInstance] MarkCode] == CLIENT_FOR_AS_APP_STORE)  //app store版本才需要隐藏
    {
        BOOL sh = [[CloudCall2AppDelegate sharedInstance] ShowAllFeatures];
        if (showAllFeature != sh)
        {
            showAllFeature = sh;
        }
        
        if (showAllFeature == NO)
        {
            self.viewGetCloudCallPoint.hidden = YES;
            self.viewPracticalFunction.frame = CGRectMake(viewGetCloudCallPoint.frame.origin.x, viewGetCloudCallPoint.frame.origin.y, viewPracticalFunction.frame.size.width, viewPracticalFunction.frame.size.height);
        }
        else
        {
            self.viewGetCloudCallPoint.hidden = NO;
            self.viewPracticalFunction.frame = CGRectMake(viewGetCloudCallPoint.frame.origin.x, viewGetCloudCallPoint.frame.origin.y+viewGetCloudCallPoint.frame.size.height, viewGetCloudCallPoint.frame.size.width, viewGetCloudCallPoint.frame.size.height);
        }
    }
}

- (IBAction) onButtonClick: (id)sender
{
    UIButton *Btn = (UIButton *)sender;
    
    if (Btn == personalInfBtn)
    {
        PersonalInfoNewViewController *personalInfo = [[PersonalInfoNewViewController alloc] initWithNibName:@"PersonalInfoNewViewController" bundle:nil];
        personalInfo.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personalInfo animated:YES];
        [personalInfo release];
    }
    else if (Btn == rechargeBtn)
    {
        [self GotoRecharge];
    }
    else if (Btn == wenHaoBtn)
    {
        [self OpenWebBrowser:URL_Get_FreeCall withBarTitle:NSLocalizedString(@"Earn YunTong Points", @"Earn YunTong Points") withType:TSMiniWebBrowserTypeDefault];
    }
    
}

- (IBAction) onButtonToolBarItemClick: (id)sender {
    if (sender == barButtonSetting) {
        SettingsViewController *settingView = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
        settingView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:settingView animated:YES];
        [settingView release];
    }
    
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

-(void) GotoRecharge // recharge
{
    if (showInAppPurchase)
    {
        if ([IAPHelperRecharge CanPurchase] == NO)
        {
            UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message: NSLocalizedString(@"In-App Purchases has been disabled, you can enable it in the Settings application.", @"In-App Purchases has been disabled, you can enable it in the Settings application.")
                                                       delegate: self
                                              cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
            [a show];
            [a release];
            return;
        }
        
        IAPRechargeViewController *iap =[[IAPRechargeViewController alloc] init];
        iap.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:iap animated:YES];
        [iap release];
        return;
    }
    else
    {
        RechargeCollectViewController *rechargeCollectViewController = [[[RechargeCollectViewController alloc] initWithNibName:@"RechargeCollectViewController" bundle:nil] autorelease];
        rechargeCollectViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:rechargeCollectViewController animated:YES];
    }
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

- (void)dealloc {
    [tempItemsArray release];
    [viewToolbar release];
    [toolbar release];
    [scrollView release];
    
    [rHeaderView release];
    [photo release];
    [name release];
    [phoneNum release];
    [vipLevel release];
    
    [labelTitle release];
    
    [buttonAd release];
    
    [versionUrl release];
    
    if (lastMsgCallId) {
        [lastMsgCallId release];
    }
    
    [super dealloc];
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

// BannerViewContainer
- (void)showBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
#if 0
    if (type == AD_TYPE_IAD) {
        iadbanner = (ADBannerView*)bannerView;
        [self.view addSubview:iadbanner];
        [self layoutForCurrentOrientation:animated];
    } else if (type == AD_TYPE_LIMEI) {
        lmbanner = (immobView*)bannerView;
        [self.view addSubview:lmbanner];
    } else if (type == AD_TYPE_CLOUDCALL_HK) {
        ctbanner = (CTBannerView*)bannerView;
        [self.view addSubview:ctbanner];
        
        [ctbanner bannerViewShow];
    } else if (type == AD_TYPE_BAIDU){
        bdbanner = (BaiduMobAdView*)bannerView;
        [self.view addSubview:bdbanner];
    }
#else
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    ctbanner = appDelegate.ctbanner;
    [self.view addSubview:ctbanner];
    [ctbanner bannerViewShow];
#endif
}

- (void)hideBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
#if 0
    if (type == AD_TYPE_IAD) {
        iadbanner = nil;
        [self layoutForCurrentOrientation:animated];
    }  else if (type == AD_TYPE_91DIANJIN) {
        if (djbanner) {
            [djbanner removeFromSuperview];
            djbanner = nil;
        }
    } else if (type == AD_TYPE_LIMEI) {
        if (lmbanner) {
            [lmbanner removeFromSuperview];
            lmbanner = nil;
        }
    } else if (type == AD_TYPE_CLOUDCALL_HK) {
        if (ctbanner) {
            [ctbanner removeFromSuperview];
            ctbanner = nil;
        }
    } else if (type == AD_TYPE_BAIDU) {
        if (bdbanner) {
            [bdbanner removeFromSuperview];
            bdbanner = nil;
        }
    }
#else
    if (ctbanner) {
        [ctbanner removeFromSuperview];
        ctbanner = nil;
    }
#endif
}

#pragma mark -
#pragma mark HttpRequest API

- (void)responseWithSucceeded:(NSData *)data {
	if (data == nil)
        return;
    NSMutableDictionary *root = [data mutableObjectFromJSONData];
//    CCLog(@"itemsData=%@", root);

    NSString* result   = [root objectForKey:@"result"];
    if ([result isEqualToString:@"success"])
    {
        NSArray *appList = [root objectForKey:@"appList"];
        
        [self SaveDiscoverItemsData:appList];
    }
    else
    {
        CCLog(@"error=%@", [root objectForKey:@"text"]);
    }
}

- (void)responseWithFailed:(NSError *)error {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
//                                                    message:[error localizedDescription]
//                                                   delegate:nil
//                                          cancelButtonTitle:nil
//                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
//    [alert show];
//    [alert release];
}


#pragma mark -
#pragma mark 定义UIAlertTableView的委托，buttonindex就是按下的按钮的index值

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 0:
            break;
        default:
            break;
    }
}

@end
