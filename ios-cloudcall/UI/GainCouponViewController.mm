//
//  GainCouponViewController.m
//  CloudCall
//
//  Created by Sergio on 13-5-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "GainCouponViewController.h"
#import "CloudCall2AppDelegate.h"
#import "HttpRequest.h"
#import "CouponData.h"
#import "JSONKit.h"
#import "CouponDetailViewController.h"
#import "MyCouponViewController.h"
#import "MobClick.h"

@implementation GainCouponViewController
@synthesize couponImg;
@synthesize couponBG;
@synthesize picker1;
@synthesize picker2;
@synthesize picker3;

@synthesize btnStart;
@synthesize couponData;

@synthesize resultText;
@synthesize lblThreeSmile;
@synthesize viewAnnounce;
@synthesize lblTipAnnounce;

#pragma mark
#pragma mark View Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (couponData.coupon_image_url_local && ![NgnStringUtils isNullOrEmpty:couponData.coupon_image_url_local])
    {
        self.couponImg.image = [UIImage imageWithContentsOfFile:couponData.coupon_image_url_local];
    }
    else
    {
        CloudCall2AppDelegate *appDelegate = (CloudCall2AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *document = [appDelegate GetCouponImgDirectoryPath];
        NSString *imgFileName = [NSString stringWithFormat:@"%@.png",couponData.coupon_type_id];
        NSString *imgFilePath = [document stringByAppendingPathComponent:imgFileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //直接文件查找本地图片
        if ([fileManager fileExistsAtPath:imgFilePath])
        {
            self.couponImg.image = [UIImage imageWithContentsOfFile:imgFilePath];
        }
        else
        {
            [NSThread detachNewThreadSelector:@selector(loadImageInBackground) toTarget:self withObject:nil];
        }
    }
    
    self.lblThreeSmile.text = NSLocalizedString(@"lblThreeSmilesText", @"lblThreeSmilesText");
    self.lblTipAnnounce.text = NSLocalizedString(@"This sweepstakes and prizes has nothing to do with Apple inc.", @"This sweepstakes and prizes has nothing to do with Apple inc.");
    lblTipAnnounce.textAlignment = UITextAlignmentCenter;
    self.navigationItem.title = NSLocalizedString(@"YunTong Coupon", @"YunTong Coupon");
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToPrevious) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *toolBtnPocket = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBtnPocket.frame = CGRectMake(260, 28, 44, 44);
    [toolBtnPocket setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBtnPocket.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBtnPocket setBackgroundImage:[UIImage imageNamed:@"coupon_pocket_up.png"] forState:UIControlStateNormal];
    [toolBtnPocket setBackgroundImage:[UIImage imageNamed:@"coupon_pocket_down.png"] forState:UIControlStateHighlighted];
    [toolBtnPocket addTarget:self action:@selector(goToMyPocket) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBtnPocket] autorelease];
    
    //是否显示声明
    BOOL isShowAnnounce = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_ISHIDDENANNOUNCEONGAINCOUPON];
    
    if (isShowAnnounce)
        viewAnnounce.hidden = YES;
    else
        viewAnnounce.hidden = NO;
    
    //为图片增加点击事件
    couponImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *couponImgSingleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCouponImgSingleClickEvent)];
    [couponImg addGestureRecognizer:couponImgSingleClick];
    [couponImgSingleClick release];
    
    if (iPhone5)
    {
        couponImg.frame = CGRectMake(couponImg.frame.origin.x, couponImg.frame.origin.y+15, couponImg.frame.size.width, couponImg.frame.size.height);
        lblThreeSmile.frame = CGRectMake(lblThreeSmile.frame.origin.x, lblThreeSmile.frame.origin.y+35, lblThreeSmile.frame.size.width, lblThreeSmile.frame.size.height);
        picker1.frame = CGRectMake(picker1.frame.origin.x, picker1.frame.origin.y+55, picker1.frame.size.width, picker1.frame.size.height);
        picker2.frame = CGRectMake(picker2.frame.origin.x, picker2.frame.origin.y+55, picker2.frame.size.width, picker2.frame.size.height);
        picker3.frame = CGRectMake(picker3.frame.origin.x, picker3.frame.origin.y+55, picker3.frame.size.width, picker3.frame.size.height);
        couponBG.frame = CGRectMake(couponBG.frame.origin.x, couponBG.frame.origin.y+55, couponBG.frame.size.width, couponBG.frame.size.height);
        btnStart.frame = CGRectMake(btnStart.frame.origin.x, btnStart.frame.origin.y+68, btnStart.frame.size.width, btnStart.frame.size.height);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [MobClick beginLogPageView:@"GainCouponViewController"];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [MobClick endLogPageView:@"GainCouponViewController"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [couponImg release];
    [couponBG release];
    [picker1 release];
    [picker2 release];
    [picker3 release];
    
    [btnStart release];
    [resultText release];
    [couponData release];
    [lblThreeSmile release];
    [viewAnnounce release];
    [lblTipAnnounce release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods
- (IBAction)onBtnClick:(id)sender
{
    if (sender == btnStart) {
        [self startToRolling];
    }
}

- (void)onCouponImgSingleClickEvent
{
    if (ROUNDCOUNT > 0)
        return;
    
    CouponDetailViewController* iv = [[CouponDetailViewController alloc] initWithNibName:@"CouponDetailViewController" bundle:[NSBundle mainBundle]];
    iv.hidesBottomBarWhenPushed = YES;
    iv.title = NSLocalizedString(@"YunTong Coupon", @"YunTong Coupon");
    CouponManager *couponManager = [[CouponManager alloc] init];
    CouponData *newCouponData = [couponManager dbLoadCouponDataByCouponId:couponData.coupon_id andWho:couponData.coupon_who];
    
    iv.couponid = newCouponData.coupon_id;
    iv.coupontypeid = newCouponData.coupon_type_id;
    iv.picUrl = newCouponData.coupon_image_url;
    iv.localUrl = newCouponData.coupon_image_url_local;
    iv.couponTitle = newCouponData.coupon_name;
    iv.price = newCouponData.coupon_price;
    iv.detail = newCouponData.coupon_detail;
    iv.showRightToolBtn = NO;
    iv.showImgViewPicHidden = NO;
    iv.isFromGainCouponPage = YES;
    
    [self.navigationController pushViewController:iv animated:YES];
    [iv release];
    [couponManager release];
}

- (IBAction)onBtnCloseTipClick:(id)sender
{
    viewAnnounce.hidden = YES;
    [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_ISHIDDENANNOUNCEONGAINCOUPON andValue:YES];
}

/**
 *	@brief	选取器开始滚动
 */
- (void)startToRolling
{
    if (![[NgnEngine sharedInstance].networkService isReachable])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YunTong Coupon", @"YunTong Coupon")
                                                        message:NSLocalizedString(@"Unreachable", @"Unreachable")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if (ROUNDCOUNT >= 1)
        return;
    
    //开始滚动时将按钮等事件复原
//    isAllowToShake = NO;
//    [self resignFirstResponder];
//    self.btnGo.userInteractionEnabled = NO;
//    self.btnGameRules.userInteractionEnabled = NO;
//    self.btnBet.userInteractionEnabled = NO;
//    self.btnSendWeibo.userInteractionEnabled = NO;
    
    
    //重置中奖点数
//    self.gain.text = @"0";
//    self.shareString = @"";
//    self.gain.textColor = [UIColor blackColor];
//    wheelno1 = 1;
//    wheelno2 = 2;
//    wheelno3 = 3;
//    connectionfinish = NO;
    
    //设置联系电话
    NSString *num = [NSString stringWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
    if ([num isEqualToString:DEFAULT_IDENTITY_IMPI])
        num = @"";
    NSString *telnumber = [[NSString alloc] initWithFormat:@"%@",num];
    
    NSString *jsonStr = [[NSString alloc] initWithFormat:@"{\"user_number\":\"%@\",\"coupon_type_id\":\"%@\"}",telnumber, couponData.coupon_type_id];
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //向服务器发送请求
    [self getDataFromServer:kChallengeCouponsUrl andData:jsonData];
    
    //设置定时器,每0.05second让每个滚轮按随机数滚动
    timer1 = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(pickerViewAnimationFirst) userInfo:nil repeats:YES];
    timer2 = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(pickerViewAnimationSecond) userInfo:nil repeats:YES];
    timer3 = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(pickerViewAnimationThird) userInfo:nil repeats:YES];
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //播放声音
    NSString *pathBegan = [[NSBundle mainBundle] pathForResource:@"rolling" ofType:@"mp3"];
    [self startToPlayAudio:player andUrl:pathBegan];
    
    //CCLog(@"---Start to play slotmachine:%@---",jsonStr);
    
    [telnumber release];
    [jsonStr release];
}

- (void)pickerViewAnimationFirst
{
    if(!isShowError && ROUNDCOUNT >= kStopFirstRollingRound)
    {
        if (connectionfinish == NO)
        {
            //[self showErrorAlert:kAlertTypeSlotMachineResultNoResp];
            //[self measuresWhenError];
        }
        else
        {
            [timer1 invalidate];
            timer1 = nil;
            [self.picker1 selectRow:wheelno1 inComponent:0 animated:SystemVersion>=5.0?YES:NO];
            CCLog(@"wheel1----------%d",wheelno1);
            [self.picker1 reloadComponent:0];
            [self.picker1 setNeedsLayout];
            
            //播放停止声音
            NSString *stoprollingPath = [[NSBundle mainBundle] pathForResource:@"stoprolling" ofType:@"mp3"];
            [self startToPlayAudio:player andUrl:stoprollingPath];
        }
        
    }
    else if(isShowError)
    {
        //[self measuresWhenError];
    }
    else
    {
        [self.picker1 selectRow:ROUNDCOUNT inComponent:0 animated:YES];
        [self.picker1 reloadComponent:0];
    }
}

- (void)pickerViewAnimationSecond
{
    if(!isShowError && ROUNDCOUNT >= kStopSecondRollingRound)
    {
        [timer2 invalidate];
        timer2 = nil;
        [self.picker2 selectRow:wheelno2 inComponent:0 animated:SystemVersion>=5.0?YES:NO];
        CCLog(@"wheel2----------%d",wheelno2);
        [self.picker2 reloadComponent:0];
        [self.picker2 setNeedsLayout];
        
        //播放停止声音
        NSString *stoprollingPath = [[NSBundle mainBundle] pathForResource:@"stoprolling" ofType:@"mp3"];
        [self startToPlayAudio:player andUrl:stoprollingPath];
    }
    else if(isShowError)
    {
        //[self measuresWhenError];
    }
    else
    {
        [self.picker2 selectRow:ROUNDCOUNT inComponent:0 animated:YES];
        [self.picker2 reloadComponent:0];
    }
}

- (void)pickerViewAnimationThird
{
    ROUNDCOUNT++;
    //CCLog(@"------------%d--------",ROUNDCOUNT);
    if(!isShowError && ROUNDCOUNT >= kStopThirdRollingRound)
    {
        [timer3 invalidate];
        timer3 = nil;
        CCLog(@"wheel3----------%d",wheelno3);
        [self.picker3 selectRow:wheelno3 inComponent:0 animated:SystemVersion>=5.0?YES:NO];
        [self.picker3 reloadComponent:0];
        [self.picker3 setNeedsLayout];
        
        //播放停止声音
        NSString *stoprollingPath = [[NSBundle mainBundle] pathForResource:@"stoprolling" ofType:@"mp3"];
        [self startToPlayAudio:player andUrl:stoprollingPath];
        
        //复原各种设置
        [self performSelector:@selector(setGainandRemind) withObject:nil afterDelay:0.5];
        
    }
    else if(isShowError)
    {
        //[self measuresWhenError];
    }
    else
    {
        [picker3 selectRow:ROUNDCOUNT inComponent:0 animated:YES];
        [picker3 reloadComponent:0];
    }
}

/**
 *	@brief	让pickerview不显示空白图片
 */
- (void)displayImageInPickerView
{
    //[self.pickerView setNeedsLayout];
}

/**
 *	@brief	设置获取的点数以及播放声音
 */
- (void)setGainandRemind
{
    ROUNDCOUNT = 0;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (isGainCoupon)
    {
        NSString *bigprizeAudio = [[NSBundle mainBundle] pathForResource:@"bigprize" ofType:@"mp3"];
        [self startToPlayAudio:player andUrl:bigprizeAudio];
    }
    else
    {
        NSString *noprizeAudio = [[NSBundle mainBundle] pathForResource:@"noprize" ofType:@"mp3"];
        
        [self startToPlayAudio:player andUrl:noprizeAudio];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YunTong Coupon", @"YunTong Coupon")
                                                    message:resultText
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    [alert show];
    [alert release];
}

- (void)goToMyPocket
{
    MyCouponViewController *myCoupon = [[MyCouponViewController alloc] initWithNibName:@"MyCouponViewController" bundle:nil];
    [self.navigationController pushViewController:myCoupon animated:YES];
    [myCoupon release];
    
}

- (void)backToPrevious
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadImageInBackground
{
    NSData* imageData = [[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:couponData.coupon_image_url]] autorelease];
    if (imageData)
    {
        UIImage *couponImage = [UIImage imageWithData:imageData];
        [self performSelectorOnMainThread:@selector(loadCouponImgOnMainThread:) withObject:couponImage waitUntilDone:NO];
        CloudCall2AppDelegate *appDelegate = (CloudCall2AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *couponDir = [appDelegate GetCouponImgDirectoryPath];
        NSString *couponTypeIdComponent = [NSString stringWithFormat:@"%@.png",couponData.coupon_type_id];
        NSString *filePath = [couponDir stringByAppendingPathComponent:couponTypeIdComponent];
        
        //写入文件
        [imageData writeToFile:filePath atomically:YES];
        
        //更新数据库
        CouponManager *couponManager = [[CouponManager alloc] init];
        [couponManager dbUpdateCouponData:@"coupon_image_url_local" andValue:filePath andCouponID:couponData.coupon_type_id];
        [couponManager release];
    }
}

- (void)loadCouponImgOnMainThread:(UIImage *)img
{
    self.couponImg.image = img;
}

#pragma mark
#pragma mark HttpRequestDelegate
/**
 *	@brief	向服务器请求数据
 *
 *	@param 	url 	请求url
 */
- (void)getDataFromServer:(NSString*)strUrl andData:(NSData *) jsonData
{
    isShowError = NO;
    connectionfinish = NO;
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
    [[HttpRequest instance] addRequest:strUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                         successTarget:self successAction:@selector(httpRequestSucceeded:userInfo:)
                         failureTarget:self failureAction:@selector(httpRequestFailed:userInfo:) userInfo:userInfo];
    [userInfo release];
}

/**
 *	@brief	请求回调函数
 *
 *	@param 	data 	返回数据
 *	@param 	userInfo 	相关信息
 */
-(void)httpRequestSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo
{
    NSString *recvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *aStr = [recvString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* msgtype = [userInfo objectForKey:@"msgtype"];
    CCLog(@"GainCoupon httpRequestSucceeded:%@, msgtype:%@", aStr, msgtype);
    NSMutableDictionary *resultDict = [aStr mutableObjectFromJSONString];
    self.resultText = [resultDict objectForKey:@"text"];
    if ([[resultDict objectForKey:@"result"] isEqualToString:@"success"])
    {
        isGainCoupon = YES;
        wheelno1 = 0;
        wheelno2 = 0;
        wheelno3 = 0;
    }
    else if ([[resultDict objectForKey:@"result"] isEqualToString:@"failed"])
    {
        isGainCoupon = NO;
        while (1)
        {
            wheelno1 = rand()%2;
            wheelno2 = rand()%2;
            wheelno3 = rand()%2;
            
            if (wheelno1 == 0 && wheelno2 == 0 && wheelno3 == 0)
            {
                continue;
            }
            else
            {
                break;
            }
        }
    }
    else
    {
        wheelno1 = 1;
        wheelno2 = 1;
        wheelno3 = 1;
    }
    
    connectionfinish = YES;
    [recvString release];
}

/**
 *	@brief	https请求返回错误
 *
 *	@param 	error 	错误消息
 *	@param 	key     请求key
 */
-(void)httpRequestFailed:(NSError *)error userInfo:(NSDictionary *)userInfo {
    connectionfinish = YES;
    
    //链接错误的处理办法
    [self processWhenNetError];
}

/**
 *	@brief	错误的处理
 */
- (void)processWhenNetError
{
    //1.停止滚动
    [timer1 invalidate];
    timer1 = nil;
    [timer2 invalidate];
    timer2 = nil;
    [timer3 invalidate];
    timer3 = nil;
    
    ROUNDCOUNT = 0;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    //将pickerview的值设为哭脸
    [self.picker1 selectRow:1 inComponent:0 animated:SystemVersion>=5.0?YES:NO];
    [self.picker1 reloadComponent:0];
    [self.picker1 setNeedsLayout];
    [self.picker2 selectRow:1 inComponent:0 animated:SystemVersion>=5.0?YES:NO];
    [self.picker2 reloadComponent:0];
    [self.picker2 setNeedsLayout];
    [self.picker3 selectRow:1 inComponent:0 animated:SystemVersion>=5.0?YES:NO];
    [self.picker3 reloadComponent:0];
    [self.picker3 setNeedsLayout];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YunTong Coupon", @"YunTong Coupon")
                                                    message:NSLocalizedString(@"SlotMachine Network error", @"SlotMachine Network error")
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    [alert show];
    [alert release];
}


#pragma mark
#pragma mark picker view datasource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 1000;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIImage *img = nil;
    switch (row%2)
    {
        case 0:
            img = [UIImage imageNamed:@"smile.png"];
            break;
        case 1:
            img = [UIImage imageNamed:@"cry.png"];
            break;
        default:
            break;
    }
    
    //将图片放入imageview
    UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(18, 0, 60, 60)] autorelease];
    [imgView setImage:img];
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    
    return imgView;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 80;
}

#pragma mark
#pragma mark AVAudioPlayer
- (void)startToPlayAudio:(AVAudioPlayer *)_player andUrl:(NSString *)audioPath
{
    if (player) {
        [player release];
        player = nil;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
    [player prepareToPlay];
    [player play];
    
    //震动
    //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

@end
