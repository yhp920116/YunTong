//

#import "ShakeToSignInViewController.h"

#import "CloudCall2AppDelegate.h"
#import "JSONKit.h"
#import "MobClick.h"

#define tripleDESKey @"CloudTechCloudCall2013"

#define kADStatisticsTable         @"adstatistics"
#define kADStatisticsColId         @"id"
#define kADStatisticsColADId       @"adid"
#define kADStatisticsColShow       @"show"
#define kADStatisticsColClick      @"click"
#define kADStatisticsColIsSubmit   @"issubmit"
#define kADStatisticsColTimeByHour @"timebyhour"

@interface ShakeToSignInViewController(Private)
- (void) SigningIn;

- (void)addAnimations;

- (void) GotoWebSite;
- (void) backToSetting: (id)sender;
- (void) onSingleClickEvent;
@end

@implementation ShakeToSignInViewController(Private)

/////////////////////////////////////////////////////////

-(void) SigningIn {    
    NSString* remoteParty = @"cc-server";
    NSString* remotePartyUri = [NgnUriUtils makeValidSipUri: remoteParty];
    
    NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack]
                                                                              andToUri: remotePartyUri];
    BOOL ret = [session sendTextMessage:@"" contentType:@"text/signin"];
    CCLog(@"Send SigningIn %d", ret);
}

- (void)addAnimations
{    
    animating = YES;
    
    CGRect bounds  = [self.view bounds];
    CGFloat height = bounds.size.height;
    
    CGFloat imgUpheight   = self.imgUp.bounds.size.height;
    CGFloat imgDownheight = self.imgDown.bounds.size.height;
    
    //让imgup上下移动
    CABasicAnimation *translation2 = [CABasicAnimation animationWithKeyPath:@"position"];
    translation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translation2.fromValue = [NSValue valueWithCGPoint:CGPointMake(160, imgUpheight/2)];
    translation2.toValue = [NSValue valueWithCGPoint:CGPointMake(160, 44 - 20)];
    translation2.duration = 0.5;
    translation2.repeatCount = 1;
    translation2.autoreverses = YES;
    translation2.delegate = self;
    
    //让imagdown上下移动
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translation.fromValue = [NSValue valueWithCGPoint:CGPointMake(160, imgUpheight+imgDownheight/2)];
    translation.toValue = [NSValue valueWithCGPoint:CGPointMake(160, height - 40)];
    if (iPhone5) {
        translation.toValue = [NSValue valueWithCGPoint:CGPointMake(160, height - 80)];
    }
    translation.duration = 0.5;
    translation.repeatCount = 1;
    translation.autoreverses = YES;
    translation.delegate = self;
    
    [imgDown.layer addAnimation:translation forKey:@"translation"];
    [imgUp.layer addAnimation:translation2 forKey:@"translation2"];
}

- (void) GotoWebSite {
    if (imgAdUrl && [imgAdUrl length])
    {
        AdResourceManager *manager = [[AdResourceManager alloc] init];
        [manager updateData:adid andType:ADStatisticsUpdateTypeClick];
        
        //获取市场ID
        int mtype = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_MAKET_TYPE];
        NSString* marketType = [NSString stringWithCString:getMarketName(mtype) encoding:NSUTF8StringEncoding];
        NSString *telnumber = [[CloudCall2AppDelegate sharedInstance] getUserName];
        
        NSMutableString *url = [NSMutableString stringWithCapacity:10];
        [url appendString:imgAdUrl];
        [url appendFormat:@"?adid=%d",adid];
        [url appendFormat:@"&appkey=%@",AppKeyIdForBill];
        [url appendFormat:@"&devicetype=%@",@"iOS"];
        [url appendFormat:@"&devicename=%@",[NgnSipStack platform]];
        [url appendFormat:@"&osversion=%@",[[UIDevice currentDevice] systemVersion]];
        [url appendFormat:@"&appversion=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        [url appendFormat:@"&marketid=%@",marketType];
        [url appendFormat:@"&telnumber=%@",telnumber];
        
        [manager adClickAction:imgAdUrl andActionType:actionType andNavigation:self.navigationController];
        [manager release];
    }
}

- (void) backToSetting: (id)sender{
    if (isSignInRemind == YES)
        [self dismissModalViewControllerAnimated:NO];
    else
        [self.navigationController popViewControllerAnimated:YES];
//    [lm stopUpdatingLocation];
}

- (void) onSingleClickEvent
{
    if (!animating && !signinDone) {
        [self.navigationItem.leftBarButtonItem setEnabled:NO];

        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        NSString *pathBegan = [[NSBundle mainBundle] pathForResource:@"sharktosigninbegan" ofType:@"m4a"];
        [self playAudioWithUrl:pathBegan];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        [self addAnimations];
    }
}

@end

@implementation ShakeToSignInViewController (Timers)

-(void)timerSigninTick:(NSTimer*)timer{
    if (!signinDone) {
        signinDone = YES;
        NSString* strFailed = isCN ? @"网络不佳，请稍后再试。" :  NSLocalizedString(@"Sign in failed, please try again later!", @"Sign in failed, please try again later!");
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        [activityIndicator stopAnimating];
        [activityIndicator setHidden:YES];
        self.labelResult.text = strFailed;
    }
}

@end

@implementation ShakeToSignInViewController
@synthesize isSignInRemind;
@synthesize adid;
@synthesize shareString;
@synthesize imgUp;
@synthesize imgDown;

@synthesize resultView;
@synthesize adView;
@synthesize adButton;
@synthesize shareButton;
@synthesize resultBg;
@synthesize activityIndicator;
@synthesize labelResult;

@synthesize tipsView;
@synthesize tipsLabel;
@synthesize btnCloseTips;

#pragma mark
#pragma mark View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    
    
    self.navigationItem.title = NSLocalizedString(@"Shake to Sign In", @"Shake to Sign In");
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToSetting:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    [self.resultView setHidden:YES];
    [activityIndicator setHidden:NO];
    self.shareButton.hidden = YES;
    
    //是否显示提示框
    BOOL isShowTips = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_ISSHOWSHAKETOSIGNINTIPS];
    if (isShowTips) {
        self.tipsView.hidden = YES;
    }
    else
    {
        self.tipsLabel.text = NSLocalizedString(@"Click the image to sign in,\n you can sign in 3 times everyday", @"Click the image to sign in,\n you can sign in 3 times everyday");
    }
    
    //为图片增加点击事件
    self.imgUp.userInteractionEnabled = YES;
    self.imgDown.userInteractionEnabled = YES;
    UITapGestureRecognizer *imgUpSingleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleClickEvent)];
    UITapGestureRecognizer *imgDownSingleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleClickEvent)];
    [self.imgUp addGestureRecognizer:imgUpSingleClick];
    [self.imgDown addGestureRecognizer:imgDownSingleClick];
    
    [imgUpSingleClick release];
    [imgDownSingleClick release];
    
    //get location
//    lm = [[CLLocationManager alloc] init];
//    lm.delegate = self;
//    lm.desiredAccuracy = kCLLocationAccuracyBest;
//    lm.distanceFilter = kCLDistanceFilterNone;
//    [lm startUpdatingLocation];
//    CLLocation *location = [lm location];
    longitude = 0.0;
    latitude = 0.0;

    [appDelegate sendRequestToCloudCall];
    
    actionType = 1;
}


- (void)viewDidUnload
{
    [super viewDidUnload];    

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([[[NgnEngine sharedInstance].configurationService getStringWithKey:SHOW_NEW_FOR_SHAKE_TO_SIGNIN] length] != 0)
    {
        [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FOR_SHAKE_TO_SIGNIN andValue:nil];
        [[CloudCall2AppDelegate sharedInstance] ShowNewFeatureRemind];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewReloadData" object:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [MobClick beginLogPageView:@"ShakeToSignIn"];
    [self.navigationController setNavigationBarHidden:NO];
    
    AudioRouteTypes_t t = [[NgnEngine sharedInstance].soundService GetAudioRouteType];
    BOOL en = t==AUDIO_ROUTE_SPEAKER;
    if (!en)
        [[NgnEngine sharedInstance].soundService setSpeakerEnabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"ShakeToSignIn"];
    [self resignFirstResponder];
    
    if (player && [player isPlaying]) {
        [player stop];
    }
    
    AudioRouteTypes_t t = [[NgnEngine sharedInstance].soundService GetAudioRouteType];
    BOOL en = t==AUDIO_ROUTE_SPEAKER;
    if (!en)
        [[NgnEngine sharedInstance].soundService setSpeakerEnabled:NO];
    
    [super viewWillDisappear:animated];
}

-(void)dealloc{
    [imgDown release];
    [imgUp release];
    
    [resultView release];
    [adView release];
    [adButton release];
    [shareButton release];
    [resultBg release];
    [activityIndicator release];
    [labelResult release];
    
    [tipsView release];
    [tipsLabel release];
    [btnCloseTips release];
    
    [strShareWeibo release];
    
    [player release];
    
    if (imgAdUrl) {
        [imgAdUrl release];
        imgAdUrl = nil;
    }
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods
- (void)shareOnline:(id)sender
{
    CloudCall2AppDelegate *_appDelegate = [CloudCall2AppDelegate sharedInstance];
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeSinaWeibo, ShareTypeTencentWeibo, ShareTypeSMS, ShareTypeQQSpace, ShareTypeWeixiSession, ShareTypeWeixiTimeline, ShareTypeDouBan, nil];

    
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:self.shareString
                                       defaultContent:@""
                                                image:nil
                                                title:@"云通免费网络电话"
                                                  url:kAppRedirectURI
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeText];
    
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:(id<ISSViewDelegate>)_appDelegate.viewDelegate];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"云通免费网络电话"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"云通免费网络电话"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                          oneKeyShareList:shareList
                                                           qqButtonHidden:NO
                                                    wxSessionButtonHidden:NO
                                                   wxTimelineButtonHidden:NO
                                                     showKeyboardOnAppear:NO
                                                        shareViewDelegate:(id<ISSShareViewDelegate>)_appDelegate.viewDelegate
                                                      friendsViewDelegate:(id<ISSViewDelegate>)_appDelegate.viewDelegate
                                                    picViewerViewDelegate:nil]
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];

}

- (IBAction) onButtonClick: (id)sender {
    if (sender == adButton) {
        [self GotoWebSite];
    }
    else if (sender == shareButton)
    {
        [self shareOnline:sender];
    }
    else if(sender == btnCloseTips)
    {
        self.tipsView.hidden = YES;
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_ISSHOWSHAKETOSIGNINTIPS andValue:YES];
    }
}

- (void)playAudioWithUrl:(NSString *)urlString
{
    if (player) {
        [player release];
        player = nil;
    }
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:urlString] error:nil];
    [player prepareToPlay];
    [player play];
}

#pragma mark
#pragma mark Http Request
/**
 *	@brief	向服务器发送https请求数据
 *
 *	@param 	strType 	请求类型
 *	@param 	data 	发送的参数
 */
- (void)signIn2Server
{
    NSString *user_number = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSString *user_location_longtitude = [NSString stringWithFormat:@"%f",longitude];
    NSString *user_location_latitude = [NSString stringWithFormat:@"%f",latitude];
    NSString *ad_id = [NSString stringWithFormat:@"%d",adid];
    
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              user_number,              @"user_number",
                              user_location_longtitude, @"user_location_longtitude",
                              user_location_latitude,   @"user_location_latitude",
                              ad_id,                    @"ad_id", nil];
    
    [[HttpRequest instance] addRequestWithEncrypt:kSignInUrl andMethod:@"POST" andContent:jsonDict andTimeout:10
                         delegate:self successAction:@selector(signInSucceeded:userInfo:)
                        failureAction:@selector(signInFailed:userInfo:) userInfo:nil];
    
    [self ClearSignInRemind];
    for (int i=0; i<4; i++)
    {
        switch (i)
        {
            case 0:
            case 1:
            case 2:
            {
                [self addSignInRemindWithDateCount:(i+1)*3];
                break;
            }
            case 3:
                [self addSignInRemindWithDateCount:30];
                break;
            default:
                break;
        }
    }
}

- (void)addSignInRemindWithDateCount:(NSInteger)Days
{
    NSDate *now = [NSDate new];
#if 0
    NSTimeInterval PerDay = 60*Days;
#else
    NSTimeInterval PerDay = 24*60*60*Days;
#endif
    NSDate *sendSMSTime = [now dateByAddingTimeInterval:PerDay];
    [now release];
    
    UILocalNotification *notification = [[[UILocalNotification alloc] init] autorelease];
    if (notification != nil)
    { 
//        //加上8小时,使时间显示正确
//        NSInteger interval = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:sendSMSTime];
//        sendSMSTime = [sendSMSTime dateByAddingTimeInterval:interval];
        notification.fireDate = sendSMSTime;
        notification.timeZone = [NSTimeZone systemTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertAction = NSLocalizedString(@"OK", @"OK");
//        notification.applicationIconBadgeNumber = ++[UIApplication sharedApplication].applicationIconBadgeNumber;
//        int IconBadgeNumber = [[NgnEngine sharedInstance].configurationService getIntWithKey:NOTIFICATION_ICON_BADGE];
//        [[NgnEngine sharedInstance].configurationService setIntWithKey:NOTIFICATION_ICON_BADGE andValue:++IconBadgeNumber];

        NSString *message;
        message = [NSString stringWithFormat:NSLocalizedString(@"You haven't sign in %d days, go to sign in get YunTong points?", @"You haven't sign in %d days, go to sign in get YunTong points?"), Days];
        
        notification.alertBody = message;
        NSDictionary *SignInRemindDic = [NSDictionary dictionaryWithObject:kNotifKey_SignInRemind forKey:kNotifKey];
        notification.userInfo = SignInRemindDic;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)ClearSignInRemind
{
    for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        if([[aNotif.userInfo objectForKey:kNotifKey] isEqualToString:kNotifKey_SignInRemind])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:aNotif];
        }
    }
}
/**
 *	@brief	签到成功处理
 *
 *	@param 	data 	返回数据
 *	@param 	userInfo
 */
- (void)signInSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo
{
    NSString *aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *recvString = [aStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CCLog(@"SignIn didReceiveData:\n%@\n", recvString);
    
    NSRange range = [recvString rangeOfString:@"result"];
    if (range.location != NSNotFound)
    {
        NSMutableDictionary *root = [recvString mutableObjectFromJSONString];
        //NSString *result = [root objectForKey:@"result"];
        NSString *text = [root objectForKey:@"text"];
        NSString *weibo_text = [root objectForKey:@"weibo_text"];
        
        [activityIndicator stopAnimating];
        [activityIndicator setHidden:YES];
        self.labelResult.text = text;
        self.shareString = weibo_text;
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }
    else
    {
        NSString* strFailed = isCN ? @"网络不佳，请稍后再试。" :  NSLocalizedString(@"Sign in failed, please try again later!", @"Sign in failed, please try again later!");
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        [activityIndicator stopAnimating];
        [activityIndicator setHidden:YES];
        self.labelResult.text = strFailed;
    }
    
    [aStr release];
    
    signinDone = YES;
}

/**
 *	@brief	签到失败
 *
 *	@param 	error 	错误信息
 *	@param 	userInfo
 */
- (void)signInFailed:(NSError *)error userInfo:(NSDictionary *)userInfo
{
    signinDone = YES;
    NSString* strFailed = isCN ? @"网络不佳，请稍后再试。" :  NSLocalizedString(@"Sign in failed, please try again later!", @"Sign in failed, please try again later!");
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
    self.labelResult.text = strFailed;
}

#pragma mark
#pragma mark AnimationDelegate
- (void)animationDidStop:(CABasicAnimation *)theAnimation finished:(BOOL)flag
{
    if (signining)
        return;
    signining = YES;
    
    //AudioServicesPlaySystemSound(soundIDEnded);
    
    [activityIndicator startAnimating];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    
    if (CCAdsData* adsData = [appDelegate GetCurrSigninAdData]) {
        adid = adsData.adid;
        actionType = adsData.clickAction;
        NSString* dir = [appDelegate GetSigninAdsDirectoryPath];
        
        NSString *ringPath = [dir stringByAppendingPathComponent: [adsData.ring lastPathComponent]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:ringPath isDirectory:nil] && [adsData.ring length] != 0) {
            [self playAudioWithUrl:ringPath];
        }
        else
        {
            NSString *pathEnded = [[NSBundle mainBundle] pathForResource:@"sharktosigninended" ofType:@"m4a"];
            [self playAudioWithUrl:pathEnded];
        }
        NSString *imagePath = [dir stringByAppendingPathComponent: [adsData.image lastPathComponent]];
        NSData* imgData = [[[NSData alloc] initWithContentsOfFile:imagePath] autorelease];        
        if (imgData)
        {
            //签到广告统计计数
            AdResourceManager *manager = [[[AdResourceManager alloc] init] autorelease];
            [manager updateData:adid andType:ADStatisticsUpdateTypeShow];
                
            UIImage *image = [UIImage imageWithData:imgData];
            [adView setImage:image];
            
            if (imgAdUrl) {
                [imgAdUrl release];
                imgAdUrl = nil;
            }
            
            imgAdUrl = [[NSString alloc] initWithString:adsData.clickurl];
        }
    }
    else    //首次安装进入签到页面,图片下载有点延迟,会导致第二个声音不播放,所以需要在这里加入判断
    {
        NSString *pathEnded = [[NSBundle mainBundle] pathForResource:@"sharktosigninended" ofType:@"m4a"];
        [self playAudioWithUrl:pathEnded];
    }
    
    self.labelResult.text = NSLocalizedString(@"Signing In...", @"Signing In...");
    [self.resultView setHidden:NO];
    self.shareButton.hidden = NO;
    
    self.view.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];

#if 0    
    [self SigningIn];
#else
    [self signIn2Server];
#endif
    
    signinTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerSigninTick:) userInfo:nil repeats:NO];
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        CCLog(@"motionEnded %d, %d", animating, signinDone);
        if (!animating && !signinDone) {
            [self.navigationItem.leftBarButtonItem setEnabled:NO];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
            NSString *pathBegan = [[NSBundle mainBundle] pathForResource:@"sharktosigninbegan" ofType:@"m4a"];
            [self playAudioWithUrl:pathBegan];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            [self addAnimations];
        }
    }
}

#pragma mark
#pragma mark CLLocationManagerDelegate
//-(void) locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *) newLocation
//           fromLocation: (CLLocation *) oldLocation
//{
//    longitude = newLocation.coordinate.longitude;
//    latitude = newLocation.coordinate.latitude;
//}
//
//- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    longitude = 0.0;
//    latitude = 0.0;
//}
@end
