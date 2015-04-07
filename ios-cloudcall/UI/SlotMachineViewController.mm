//
//  SlotMachineViewController.m
//  CloudCall
//
//  Created by Sergio on 13-3-4.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import "SlotMachineViewController.h"
#import "JSONKit.h"
#import "MobClick.h"
#import "HttpRequest.h"
#import "WebBrowser.h"
#import <ShareSDK/ShareSDK.h>
#import "StaticUtils.h"

#define test 0   //老虎机自动测试
#define kStopFirstRollingRound 65

@implementation SlotMachineViewController

@synthesize column;
@synthesize wheelArray;
@synthesize lblBet;
@synthesize bet;
@synthesize lblGain;
@synthesize gain;
@synthesize lblRemindPoint;
@synthesize remindPoint;
@synthesize balance;
@synthesize btnBet;
@synthesize btnGo;
@synthesize btnGameRules;
@synthesize btnSendWeibo;
@synthesize pointsView;
@synthesize btnView;
@synthesize canShowRollingSubtitle;
@synthesize subtitle;
@synthesize slotmachineAdsInfo;
@synthesize pointListArray;
@synthesize bigPrizeText;

@synthesize popoverController;
@synthesize shareString;

@synthesize lblShowResult;

#pragma mark
#pragma mark Self Method

- (void)shareOnline:(id)sender
{
    CloudCall2AppDelegate *_appDelegate = [CloudCall2AppDelegate sharedInstance];
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeSinaWeibo, ShareTypeTencentWeibo, ShareTypeSMS, ShareTypeQQSpace, ShareTypeWeixiSession, ShareTypeWeixiTimeline, ShareTypeDouBan, nil];
    
    //截图
    /*CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    }
    else
    {
        UIGraphicsBeginImageContext(imageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow * window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            UIGraphicsPushContext(context);
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            CGContextConcatCTM(context, [window transform]);
            CGContextTranslateCTM(context, -[window bounds].size.width*[[window layer] anchorPoint].x, -[window bounds].size.height*[[window layer] anchorPoint].y);
            [[window layer] renderInContext:context];
            
            UIGraphicsPopContext();
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();*/
    
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:shareString
                                       defaultContent:@""
                                                image:nil//[ShareSDK jpegImageWithImage:image quality:0.8]
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
                                    CCLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    CCLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

/**
 *	@brief	返回
 */
- (void) onBtnBackClick: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *	@brief	按钮点击事件
 *  btnBet       :  选择赌注
 *  btnGo        :  开始摇奖
 *  btnGameRules :  打开游戏规则
 *  btnSendWeibo :  发送微博分享
 *	@param 	sender 	按钮
 */
- (IBAction)onBtnClick:(id)sender
{
    if (sender == btnBet)
    {
        SelectTableViewController *contentView = [[SelectTableViewController alloc] initWithFiltertype:self.pointListArray andViewType:kTagTableViewForSlotMachine andSize:CGSizeMake(80, [pointListArray count]>5?160:32*[pointListArray count])];
        contentView.delegate = self;
        self.popoverController = [[[WEPopoverController alloc] initWithContentViewController:contentView] autorelease];
        CGRect popFrame = CGRectMake(btnBet.frame.origin.x, btnBet.frame.origin.y + pointsView.frame.origin.y, btnBet.frame.size.width, btnBet.frame.size.height);
        [popoverController presentPopoverFromRect:popFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        [contentView release];
    }
    else if(sender == btnGo)
    {
//        self.shareString = [betAffer objectAtIndex:rand()%[betAffer count]];
        [self startToRolling];
    }
    else if(sender == btnGameRules)
    {
        [self OpenWebBrowser:kGameRuleURI];
    }
    else if(sender == btnSendWeibo)
    {
        [self shareOnline:sender];
    }
}

- (void)OpenWebBrowser:(NSString *)url
{
    WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
    webBrowser.mode = TSMiniWebBrowserModeNavigation;
    
    [webBrowser setFixedTitleBarText:NSLocalizedString(@"Game Rules", @"Game Rules")];
    webBrowser.barStyle = UIStatusBarStyleDefault;
    webBrowser.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webBrowser animated:YES];
    
    [webBrowser release];
}

/**
 *	@brief	选取器开始滚动
 */
- (void)startToRolling
{
    if (!self.slotmachineAdsInfo || [self.slotmachineAdsInfo count] == 0 || !isFinishUpdateAds)
    {
        [self showErrorAlert:kAlertTypeSlotMachineLoadingPrize];
        return;
    }
    if (isNetWorkError)
    {
        [self showErrorAlert:kAlertTypeSlotMachineNetWorkErr];
        return;
    }
    NSString *betPoint = [self.bet.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int ibetPoint = [betPoint intValue];
    
    if ([betPoint isEqualToString:@"0"])
    {
        [self showErrorAlert:kAlertTypeSlotMachineSelectBet];
        return;
    }
    
    if (ibetPoint > balance) {
        [self showErrorAlert:kAlertTypeSlotMachineBetMoreThanBalance];
        return;
    }
    
    if (ROUNDCOUNT >= 1)
        return;
    
    //开始滚动时将按钮等事件复原
    isAllowToShake = NO;
    [self resignFirstResponder];
    self.btnGo.userInteractionEnabled = NO;
    self.btnGameRules.userInteractionEnabled = NO;
    self.btnBet.userInteractionEnabled = NO;
    self.btnSendWeibo.userInteractionEnabled = NO;
    
    //扣除投注点数
    int oldBalance = [self.remindPoint.text intValue];
    int selectedBet = [self.bet.text intValue];
    int newBalance = oldBalance - selectedBet;
    self.remindPoint.text = [NSString stringWithFormat:@"%d",newBalance];
    
    //重置中奖点数
    self.gain.text = @"0";
    self.shareString = @"";
    self.gain.textColor = [UIColor blackColor];
    
    //设置联系电话
    NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
    if ([num isEqualToString:DEFAULT_IDENTITY_IMPI])
        num = @"";
    NSString *telnumber = [[NSString alloc] initWithFormat:@"%@",num];
    
    NSString *jsonStr = [[NSString alloc] initWithFormat:@"{\"telnumber\":\"%@\",\"betpoint\":\"%@\"}",telnumber, betPoint];
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //向服务器发送请求
    [self getDataFromServer:kGetSlotMachineResultURI andData:jsonData andKey:kKeyGetSlotMachineResult];
    
    //设置定时器,每0.05second让每个滚轮按随机数滚动
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(pickerViewAnimation) userInfo:nil repeats:YES];
    
    [_slotMachine startSliding];
    
    //播放声音
    NSString *pathBegan = [[NSBundle mainBundle] pathForResource:@"rolling" ofType:@"mp3"];
    [self startToPlayAudio:player andUrl:pathBegan];
    
    //CCLog(@"---Start to play slotmachine:%@---",jsonStr);
    
    [telnumber release];
    [jsonStr release];
}


- (void)pickerViewAnimation
{
    ROUNDCOUNT++;
    if(!isShowError && ROUNDCOUNT >= kStopFirstRollingRound)
    {
        if (connectionfinish == NO)
        {
            [self showErrorAlert:kAlertTypeSlotMachineResultNoResp];
            [self measuresWhenError];
        }
        else
        {
            [timer invalidate];
            timer = nil;
            if (wheelArray && [wheelArray count]==3)
            {
                [_slotMachine stopSliding:wheelArray andIsError:NO];
            }
        }
        
    }
    else if(isShowError)
    {
        [self measuresWhenError];
    }
    else
    {

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
    self.gain.text = [NSString stringWithFormat:@"%d",gainPoints];
    if (gainPoints > 0) {
        self.gain.textColor = [UIColor redColor];
    }
    else
    {
        self.gain.textColor = [UIColor blackColor];
    }
    self.remindPoint.text = [NSString stringWithFormat:@"%d",balance];
    
    if(gainPoints == 0 && flagBigPrize == 0 && awardsname == 0)
    {
        NSString *noprizeAudio = [[NSBundle mainBundle] pathForResource:@"noprize" ofType:@"mp3"];
        
        [self startToPlayAudio:player andUrl:noprizeAudio];
    }
    else if (awardsname >= 5) {
        NSString *smallprizeAudio = [[NSBundle mainBundle] pathForResource:@"sharktosigninended" ofType:@"m4a"];
        
        [self startToPlayAudio:player andUrl:smallprizeAudio];
    }
    else if(awardsname == 3 || awardsname == 4)
    {
        NSString *noprizeAudio = [[NSBundle mainBundle] pathForResource:@"bigprize" ofType:@"mp3"];
        
        [self startToPlayAudio:player andUrl:noprizeAudio];
    }
    else if(awardsname == 1 || awardsname == 2)
    {
        CCLog(@"big");
        NSString *bigprizeAudio = [[NSBundle mainBundle] pathForResource:@"bigprize" ofType:@"mp3"];
        [self startToPlayAudio:player andUrl:bigprizeAudio];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Happy to shake",@"Happy to shake")
                                                        message:bigPrizeText
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK",@"OK"), nil];
        [alert show];
        [alert release];
    }
    ROUNDCOUNT = 0;
    isAllowToShake = YES;
    
    //将按钮等事件复原
    [self becomeFirstResponder];
    self.btnGo.userInteractionEnabled = YES;
    self.btnGameRules.userInteractionEnabled = YES;
    self.btnBet.userInteractionEnabled = YES;
    self.btnSendWeibo.userInteractionEnabled = YES;
    
#if test // for test
    [self screenShots];
#endif
}

/**
 *	@brief	出现网络链接异常等错误时的处理办法
 */
- (void)measuresWhenError
{
    //1.停止滚动
    [timer invalidate];
    timer = nil;
    
    //2.停止声音
    if (player && [player isPlaying]) {
        [player stop];
    }
    
    //3.老虎机初始化
    
    NSArray *array = [NSArray arrayWithObjects:
                       [NSNumber numberWithInteger:0],
                       [NSNumber numberWithInteger:1],
                       [NSNumber numberWithInteger:2], nil];
    [_slotMachine stopSliding:array andIsError:YES];
    
    //4.结果初始化
    self.gain.text = @"0";

    
    //5.返回扣除投注点数
    int oldBalance = [self.remindPoint.text intValue];
    int selectedBet = [self.bet.text intValue];
    int newBalance = oldBalance + selectedBet;
    self.remindPoint.text = [NSString stringWithFormat:@"%d",newBalance];
    
    //6.恢复状态,按钮可点击等
    ROUNDCOUNT = 0;
    isAllowToShake = YES;
    isNetWorkError = NO;
    connectionfinish = YES;
    [self becomeFirstResponder];
    self.btnGo.userInteractionEnabled = YES;
    self.btnGameRules.userInteractionEnabled = YES;
    self.btnBet.userInteractionEnabled = YES;
    self.btnSendWeibo.userInteractionEnabled = YES;
}

/**
 *	@brief	加载老虎机图片
 */
- (void)loadSlotMachineImgItems
{
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    NSString *slotAdsPath = [appDelegate GetSlotMachineImgDirectoryPath];
//    NSString *adsPath = [documentsPath stringByAppendingPathComponent:@"Ads"];
//    [self LoadSlotMachineAdsData];
    
    adsCount = [self.slotmachineAdsInfo count];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [self.column removeAllObjects];
    for (int i= 1;i <= 3;i++)
    {
        NSMutableArray *imgArray = [[NSMutableArray alloc] init];
        for (int j = 0;j < [self.slotmachineAdsInfo count];j++)
        {
            CCAdsData *adsData = [self.slotmachineAdsInfo objectAtIndex:j];
            //加载图片
            NSString *imgName = [[[NSString alloc] initWithFormat:@"%@",[adsData.image lastPathComponent]] autorelease];
            NSString *imgFilePath = [slotAdsPath stringByAppendingPathComponent:imgName];
            
            UIImage *img;
            if ([fileManager fileExistsAtPath:imgFilePath]) {
                img = [UIImage imageWithContentsOfFile:imgFilePath];
            }
            else
            {
                img = [UIImage imageNamed:@"cloudcall.png"];
            }
                        
            //将图片放入imageview
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
            [imgView setImage:img];
            [imgView setContentMode:UIViewContentModeScaleToFill];
            [imgArray addObject:imgView];
            
            [imgView release];
            
            [self.column addObject:img];
        }
        
        
        [imgArray release];  
    }
    
    //初始化欢乐摇一摇位置
    _slotMachine.dataSource = self;
    
    if (HUD != nil)
    {
        [HUD hide:YES];
        [HUD release];
        HUD = nil;
    }
}

/**
 *	@brief	滚动字幕
 */
- (void)showSubtitle
{
    if (!self.subtitle) return;
    NSMutableArray* subtitles = [[NSMutableArray alloc] initWithObjects:self.subtitle,nil];
    if (canShowRollingSubtitle && [subtitles count] != 0)
    {
        //自动滚动banner的动画实现
        [self pauseSubtitle];
        if (iPhone5) {
            rollingView = [[JHTickerView alloc] initWithFrame:CGRectMake(0, 435 + 88, 320, 20)];
        }
        else
        {
            rollingView = [[JHTickerView alloc] initWithFrame:CGRectMake(0, 435, 320, 20)];
        }
        rollingView.backgroundColor = [UIColor clearColor];
        [rollingView setDirection:JHTickerDirectionLTR];
        [rollingView setTickerStrings:subtitles];
        [rollingView setTickerSpeed:68.0f];
        [rollingView start];
        
        [self.view addSubview:rollingView];
    }
    else
    {
        [self pauseSubtitle];
    }
    [subtitles release];
}

/**
 *	@brief	暂停滚动字幕
 */
- (void)pauseSubtitle
{
    if (rollingView != nil)
    {
        [rollingView pause];
        [rollingView removeFromSuperview];
        [rollingView release];
        rollingView = nil;
    }
}

- (void)hideHUDTimeout
{
    if (HUD != nil)
    {
        [HUD hide:YES];
        [HUD release];
        HUD = nil;
    }
}

- (void)getDataFromNet
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.labelText = NSLocalizedString(@"Loading...", @"Loading...");
    [HUD show:YES];
    [self performSelector:@selector(hideHUDTimeout) withObject:nil afterDelay:20];
    
    //self telnumber
    NSString* mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    
    //获取余额、字幕、投注列表
    NSString *getSlotMachineInitJson = [NSString stringWithFormat:@"{\"telnumber\":\"%@\"}",mynum];
    NSData *getSlotMachineInitData = [getSlotMachineInitJson dataUsingEncoding:NSUTF8StringEncoding];
    [self getDataFromServer:kGetSlotMachineInitDataURI andData:getSlotMachineInitData andKey:kKeyGetSlotMachineInitData];
    
    //向服务器请求查看有无更新
//    NSString *downloadAdsJson = [NSString stringWithFormat:@"{\"telnumber\":\"%@\", \"type\":\"%@\"}", mynum, @"tiger"];
//    NSData *downloadAdsJsonData = [downloadAdsJson dataUsingEncoding:NSUTF8StringEncoding];
//    [self getDataFromServer:kDownloadAdsURI andData:downloadAdsJsonData andKey:kKeyDownloadAds];
}

- (void)hideAlertWindow
{
    alertLevelWindow.hidden = YES;
    [alertLevelWindow release];
    alertLevelWindow = nil;
    
    if (cbNeverPrompt.checked) {
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_NeverPromptHappyToShakeAnnounce andValue:YES];
    }
}

#pragma mark
#pragma mark download images filesr
/**
 *	@brief	读取本地存储的广告信息
 */
-(void)LoadSlotMachineAdsData
{
    if (self.slotmachineAdsInfo) {
        [slotmachineAdsInfo release];
        self.slotmachineAdsInfo = nil;
    }
    self.slotmachineAdsInfo = [[[NSMutableArray alloc] init] autorelease];
    AdResourceManager *manager = [[AdResourceManager alloc] init];
    [manager dbLoadAdsData:slotmachineAdsInfo andMyIndex:ADSMyindexSlotMachine];
    [manager release];
    
    if (!slotmachineAdsInfo || [slotmachineAdsInfo count] == 0) {
        CCLog(@"SlotMachine: getAdImageFromNet: adsArray is empty!!!");
        return;
    }
    [self startGetSlotMachineAdsDataFromNet];
}

/**
 *	@brief	保存服务器返回信息到plist文件
 */
- (void)SaveSlotMachineAdsData
{
    if (self.slotmachineAdsInfo == nil)
        return;
    
    //CCLog(@"adsDict=%@", slotmachineAdsInfo);
    NSString *errorDesc;
    NSDictionary *innerDict;
    NSString *name;
    
    NSMutableArray* ads = [[NSMutableArray alloc] init];
    for (CCAdData* a in slotmachineAdsInfo) {
        NSMutableDictionary* d = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      a.adUrl,      @"adUrl",
        [NSString stringWithFormat:@"%d", a.adid],  @"adid",
                                      a.audioUrl,   @"audioUrl",
                                      a.imageUrl,   @"imageUrl",
                                      a.name,       @"name",
                                      a.adText,     @"text",
                                      a.updateDate, @"updateDate",
                                      a.type,       @"type",
                                      nil];
        
        [ads addObject:d];
    }
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:(id)ads format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDesc];
    
    // 这个plistData为创建好的plist文件，用其writeToFile方法就可以写成文件。下面是代码：
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    NSString *documentsPath = [appDelegate GetSlotMachineImgDirectoryPath];
    NSString *savePath = [documentsPath stringByAppendingPathComponent:kSlotMachineAdsInfoFileName];
    
    // 存文件
    if (plistData) {
        [plistData writeToFile:savePath atomically:YES];
    } else {
        CCLog(@"%@", errorDesc);
        [errorDesc release];
    }
    
    [ads release];
}

/**
 *	@brief	后台启动一个线程从网络下载图片
 */
- (void)startGetSlotMachineAdsDataFromNet
 {
     [self performSelectorInBackground:@selector(getSlotMachineAdDataFromNet) withObject:nil];
}

/**
 *	@brief	从网络下载图片
 */
-(void)getSlotMachineAdDataFromNet
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    NSString *slotmachineAdsPath = [appDelegate GetSlotMachineImgDirectoryPath];
    
    for (CCAdsData* adsData in slotmachineAdsInfo) {
        if (adsData.image && [adsData.image length]) {
            NSString* imgfile = [slotmachineAdsPath stringByAppendingPathComponent:[adsData.image lastPathComponent]];
            if (adsData.need2Update || ![fileManager fileExistsAtPath:imgfile isDirectory:nil]) {
                CCLog(@" ---------download slotmachine imgfile %@" , adsData.image);
                NSData* imageData = [[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:adsData.image]] autorelease];
                if (imageData)
                {
                    [self writeData2File:imageData toFileAtPath:imgfile];
                    AdResourceManager *manager = [[[AdResourceManager alloc] init] autorelease];
                    [manager dbUpdateADsUpdateStateByAdid:adsData.adid];
                }
                else
                {
                    CCLog(@"Get image failed %@", adsData.image);
                }
            }
        }
    }
    
    //读取老虎机图片
    [self performSelectorOnMainThread:@selector(loadSlotMachineImgItems) withObject:nil waitUntilDone:NO];

    isFinishUpdateAds = YES;
    
    [pool release];
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

#pragma mark
#pragma mark HttpRequestDelegate
/**
 *	@brief	向服务器请求数据
 *
 *	@param 	url 	请求url
 */
- (void)getDataFromServer:(NSString*)strUrl andData:(NSData *) jsonData andKey:(NSString *)strKey
{
    isShowError = NO;
    connectionfinish = NO;
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
	[userInfo setObject:strKey forKey:@"msgtype"];
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
    NSString *recvString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSString *aStr = [recvString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* msgtype = [userInfo objectForKey:@"msgtype"];
    CCLog(@"SlotMachine httpRequestSucceeded:%@, msgtype:%@", aStr, msgtype);
    
    if([msgtype isEqualToString:kKeyGetSlotMachineInitData]) {
        //余额
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] initWithDictionary:[aStr mutableObjectFromJSONString]];
        NSString *strBalance = [[NSString alloc] initWithString:[resultDict objectForKey:@"balance"]];
        [self setBalance:[strBalance intValue]];
        self.remindPoint.text = strBalance;
        
        //字幕
        self.subtitle = [resultDict objectForKey:@"subtitle"];
        //显示字幕
        canShowRollingSubtitle = YES;
        [self showSubtitle];
        
        //投注列表
        if (self.pointListArray) {
            self.pointListArray = [resultDict objectForKey:@"pointlist"];
        }
        if ([self.pointListArray count]) {
            self.bet.text = [NSString stringWithFormat:@"%@",[self.pointListArray objectAtIndex:0]];
        }
        [resultDict release];
        [strBalance release];
    }
    else if([msgtype isEqualToString:kKeyDownloadAds])
    {
        NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithDictionary:[aStr mutableObjectFromJSONString]];
        
        NSMutableArray* adlist = [root objectForKey:@"adlist"];
        //NSMutableDictionary* adlist23 = [adlist objectAtIndex:0];
        
        NSMutableArray* newAdsArray = [[NSMutableArray alloc] init];
        for (NSMutableDictionary* d in adlist) {
            NSString* adUrl = [d objectForKey:@"adUrl"];
            NSString* adid = [d objectForKey:@"adid"];
            NSString* audioUrl = [d objectForKey:@"audioUrl"];
            NSString* imageUrl = [d objectForKey:@"imageUrl"];
            NSString* name = [d objectForKey:@"name"];
            NSString* text = [d objectForKey:@"text"];
            NSString* type = [d objectForKey:@"type"];
            NSString* updateDate = [[NSString alloc] initWithString:[d objectForKey:@"updateDate"]];
            
            BOOL update = YES;
            for (CCAdData* a in self.slotmachineAdsInfo) {
                //CCLog(@"name--%@,update--%@,aupdate:%@",a.name,updateDate,a.updateDate);
                //根据时间判断是否需要更新文件
                NSComparisonResult upRet = [updateDate caseInsensitiveCompare:a.updateDate];
                if (NSOrderedSame == [a.name caseInsensitiveCompare:name] && (upRet == NSOrderedSame || upRet == NSOrderedAscending)) {
                    update = NO;
                    break;
                }
            }
            
            CCAdData* ad = [[CCAdData alloc] initWithName:name andImageUrl:imageUrl andAudioUrl:audioUrl andAdUrl:adUrl andAdText:text andAdID:[adid intValue] andType:type andUpdateDate:updateDate andNeed2Update:update];
            [newAdsArray addObject:ad];
            [updateDate release];
            [ad release];
        }
        
        self.slotmachineAdsInfo = newAdsArray;
        
        [newAdsArray release];
        [root release];
        
        [self SaveSlotMachineAdsData];
        [self startGetSlotMachineAdsDataFromNet];
    }
    #pragma mark -- kKeyGetSlotMachineResult --
    else if([msgtype isEqualToString:kKeyGetSlotMachineResult])
    {
        NSRange range1 = [aStr rangeOfString:@"投注的点数比余额大"];
        if(range1.location != NSNotFound)
        {
            [self showErrorAlert:kAlertTypeSlotMachineBetMoreThanBalance];
            isShowError = YES;
            [self measuresWhenError];
            return;
        }
        
        NSRange range2 = [aStr rangeOfString:@"rewardpoint"];
        if(range2.location != NSNotFound)
        {
            NSMutableDictionary *resultDict = [[[NSMutableDictionary alloc] initWithDictionary:[aStr mutableObjectFromJSONString]] autorelease];
            
            gainPoints = [[resultDict objectForKey:@"rewardpoint"] intValue];
            self.balance = [[resultDict objectForKey:@"balance"] intValue];
            awardsname = [[resultDict objectForKey:@"awardsname"] intValue];
            if (gainPoints > 0) {
                NSString *tmpShareString = [[NSString alloc] initWithFormat:[betAffer objectAtIndex:rand()%[betAffer count]], gainPoints,gainPoints/10, RootUrl];
                self.shareString = tmpShareString;
                [tmpShareString release];
            }
            else
            {
                self.shareString = [NSString stringWithFormat:[betBefore objectAtIndex:0], RootUrl];
            }
            
            if (awardsname == 1 || awardsname == 2) {
                NSString *weibocontext = [[NSString alloc] initWithString:[resultDict objectForKey:@"weibocontext"]];
                self.shareString = weibocontext;
                [weibocontext release];
            }
            
            NSArray *tmpWheelArray = [[resultDict objectForKey:@"awards"] componentsSeparatedByString:@","];
#if test // for test
            self.lblShowResult.text = [NSString stringWithFormat:@"结果:%@ 奖级:%@ 中奖点数:%@",[resultDict objectForKey:@"awards"],[resultDict objectForKey:@"awardsname"],[resultDict objectForKey:@"rewardpoint"]];
#endif
            if ([wheelArray count] >= 3) {
                int wheelno1 = [[tmpWheelArray objectAtIndex:0] intValue];
                int wheelno2 = [[tmpWheelArray objectAtIndex:1] intValue];
                int wheelno3 = [[tmpWheelArray objectAtIndex:2] intValue];
                
                self.wheelArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:wheelno1], [NSNumber numberWithInt:wheelno2], [NSNumber numberWithInt:wheelno3], nil];
                //判断返回结果是否超出图片值
                if (wheelno1 > adsCount || wheelno2 > adsCount || wheelno3 > adsCount)
                {
                    [self showErrorAlert:kAlertTypeSlotMachineNetWorkErr];
                    isShowError = YES;
                    [self measuresWhenError];
                    return;
                }
                
            }
            else
            {
                [self showErrorAlert:kAlertTypeSlotMachineNetWorkErr];
                isShowError = YES;
                [self measuresWhenError];
                return;
            }
            flagBigPrize = [[resultDict objectForKey:@"flag"] intValue];
            
            if (flagBigPrize != 0) {
                NSString *resultText = [[NSString alloc] initWithString:[resultDict objectForKey:@"text"]];
                self.bigPrizeText = resultText;
                [resultText release];
            }
            
        }
        else
        {
            [self showErrorAlert:kAlertTypeSlotMachineNetWorkErr];
            isShowError = YES;
            [self measuresWhenError];
            return;
        }
    }
    connectionfinish = YES;
}

/**
 *	@brief	https请求返回错误
 *
 *	@param 	error 	错误消息
 *	@param 	key     请求key
 */
-(void)httpRequestFailed:(NSError *)error userInfo:(NSDictionary *)userInfo {
    isNetWorkError = YES;
    connectionfinish = YES;
    if (error) {
        //链接错误的处理办法
        //[self performSelectorOnMainThread:@selector(processWhenNetError) withObject:nil waitUntilDone:NO];
        [self processWhenNetError];
    }
}

/**
 *	@brief	错误的处理
 */
- (void)processWhenNetError
{
    [self showErrorAlert:kAlertTypeSlotMachineNetWorkErr];
    [self measuresWhenError];
}

#pragma mark
#pragma mark view lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.column = [NSMutableArray arrayWithCapacity:5];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化投注列表
    //允许用户摇动
    isAllowToShake = YES;
    isFinishUpdateAds = NO;
    initSlotMachineImg = YES;
    
    self.pointListArray = [NSMutableArray arrayWithCapacity:20];
    self.wheelArray = [NSArray arrayWithObjects:
                       [NSNumber numberWithInteger:0],
                       [NSNumber numberWithInteger:1],
                       [NSNumber numberWithInteger:2], nil];
    
    //初始化老虎机
    _slotMachine = [[ZCSlotMachine alloc] initWithFrame:CGRectMake(0, SystemVersion>=7.0 ? 54.0f : 44.0f, 300, 216)];
    _slotMachine.center = CGPointMake(self.view.frame.size.width / 2, 120);
    _slotMachine.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _slotMachine.contentInset = UIEdgeInsetsMake(5, 8, 5, 8);
    _slotMachine.backgroundImage = [UIImage imageNamed:@"SlotMachineBackground"];
    _slotMachine.coverImage = [UIImage imageNamed:@"SlotMachineCover"];
    
    _slotMachine.delegate = self;
    
    [self.view addSubview:_slotMachine];
    
    //请求字幕,投注列表等信息
    [self getDataFromNet];
    
    //读取老虎机广告图片信息
    [self LoadSlotMachineAdsData];
    
    //微博分享内容
	betBefore = [[NSMutableArray alloc] initWithObjects:@"我在用云通@云通免费网络电话 #欢乐摇一摇#，边玩边赚话费！还有Iphone5，Ipad mini拿，大家也来一起玩吧！%@", nil];
    betAffer = [[NSMutableArray alloc] initWithObjects:
                @"#欢乐摇一摇#碉堡了！我在@云通免费网络电话 中玩欢乐摇一摇，获得了%d云通点，可以免费打%d分钟！%@",
                @"#欢乐摇一摇#刚刚拿着@云通免费网络电话 来哈林摇！摇到了%d云通点，可以免费打%d分钟！不拿白不拿！%@", nil];
    self.shareString = [betBefore objectAtIndex:0];
    
    if (iPhone5) {
        self.pointsView.frame = CGRectMake(self.pointsView.frame.origin.x, self.pointsView.frame.origin.y + 18, self.pointsView.frame.size.width, self.pointsView.frame.size.height);
        self.btnView.frame = CGRectMake(self.btnView.frame.origin.x, self.btnView.frame.origin.y + 88, self.btnView.frame.size.width, self.btnView.frame.size.height);
    }
    
    //滚动字幕
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showSubtitle)
                                                name:@"showSubtitle"object:nil];
    //顶部标题栏
    UIImageView *navImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slotmachinetitle.png"]] autorelease];
    navImageView.frame = CGRectMake(0, SystemVersion>=7.0 ? 20.0f : 0.0f, 320, 44);
    [self.view addSubview:navImageView];
    
    //设置页面文本信息
    lblBet.text = NSLocalizedString(@"Bet", @"Bet");
    lblGain.text = NSLocalizedString(@"Gain", @"Gain");
    lblRemindPoint.text = NSLocalizedString(@"Surplus", @"Surplus");
    
    [btnGo setImage:[UIImage imageNamed:@"smbtngodown.png"] forState:UIControlStateHighlighted];
    

    //设置导航栏左按钮图标
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(4, SystemVersion>=7.0 ? 20.0f : 0.0f, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"smbtnbackup.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"smbtnbackdown.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(onBtnBackClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:toolBackBtn];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    BOOL isShowAnnounce = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_NeverPromptHappyToShakeAnnounce];
    if (!isShowAnnounce && [appDelegate MarkCode] == CLIENT_FOR_APP_STORE)
    {
        //中英文适配
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        NSString *currentLanguage = [languages objectAtIndex:0];
        BOOL isCN = [currentLanguage isEqualToString:@"zh-Hans"];
        
        //声明内容
        UILabel *lblAnnounce = [[UILabel alloc] initWithFrame:CGRectMake(20, 32, 250, 300)];
        lblAnnounce.backgroundColor = [UIColor clearColor];
        lblAnnounce.textColor = [UIColor whiteColor];
        if (isCN)
            lblAnnounce.font = [UIFont systemFontOfSize:15.0f];
        else
            lblAnnounce.font = [UIFont systemFontOfSize:13.0f];
        lblAnnounce.numberOfLines = 0;//上面两行设置多行显示
        lblAnnounce.text = NSLocalizedString(@"Sweepstakes statement announce", @"Sweepstakes statement announce");
        
        //已阅读和不再提示
        CGRect cbReadFrame = CGRectMake(20, 330, 250, 18);
        cbRead = [[SSCheckBoxView alloc] initWithFrame:cbReadFrame style:kSSCheckBoxViewStyleGlossy checked:YES];
        [cbRead setText:NSLocalizedString(@"I have read and agreed to the statement", @"I have read and agreed to the statement")];
        cbRead.enabled = NO;
        
        CGRect cbNeverPromptFrame = CGRectMake(20, 360, 250, 18);
        cbNeverPrompt = [[SSCheckBoxView alloc] initWithFrame:cbNeverPromptFrame style:kSSCheckBoxViewStyleGlossy checked:YES];
        [cbNeverPrompt setText:NSLocalizedString(@"No longer prompt", @"No longer prompt")];
        
        if (SystemVersion >= 7.0)
        {
            CGRect windowRect = CGRectMake(20,20,[[UIScreen mainScreen] bounds].size.width - 30,[[UIScreen mainScreen] bounds].size.height - 30);
            alertLevelWindow = [[UIWindow alloc] initWithFrame:windowRect];
            alertLevelWindow.windowLevel = UIWindowLevelAlert;
            alertLevelWindow.backgroundColor = [UIColor whiteColor];
            lblAnnounce.textColor = [UIColor blackColor];
            [alertLevelWindow addSubview:lblAnnounce];
            
            UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(98 , 8, 200, 30)];
            lblTitle.backgroundColor = [UIColor clearColor];
            lblTitle.textColor = [UIColor blackColor];
            lblTitle.font = [UIFont systemFontOfSize:18.0f];
            lblTitle.numberOfLines = 0;//上面两行设置多行显示
            lblTitle.text = NSLocalizedString(@"Sweepstakes statement For iOS 7", @"Sweepstakes statement For iOS 7");
            [alertLevelWindow addSubview:lblTitle];
            [lblTitle release];
            
            [alertLevelWindow addSubview:cbRead];
            
            UILabel *lblNeverPrompt = [[UILabel alloc] initWithFrame:CGRectMake(52, 369, 250, 18)];
            lblNeverPrompt.backgroundColor = [UIColor clearColor];
            lblNeverPrompt.textColor = [UIColor blackColor];
            if (isCN)
                lblNeverPrompt.font = [UIFont systemFontOfSize:15.0f];
            else
                lblNeverPrompt.font = [UIFont systemFontOfSize:13.0f];
            lblNeverPrompt.numberOfLines = 0;//上面两行设置多行显示
            lblNeverPrompt.text = NSLocalizedString(@"No longer prompt", @"No longer prompt");
            [alertLevelWindow addSubview:cbNeverPrompt];
            [alertLevelWindow addSubview:lblNeverPrompt];
            [lblNeverPrompt release];
            
            UIButton *btnOK = [UIButton buttonWithType: UIButtonTypeCustom];
            [btnOK setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnOK setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            btnOK.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 30 - 50, [[UIScreen mainScreen] bounds].size.width - 30, 50);
            [btnOK setBackgroundColor:[UIColor whiteColor]];
            [btnOK addTarget:self action:@selector(hideAlertWindow) forControlEvents: UIControlEventTouchUpInside];
            [btnOK setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
            btnOK.titleLabel.font = [UIFont systemFontOfSize:16.0f];
            [btnOK.titleLabel setTextColor:[UIColor blueColor]];
            [alertLevelWindow addSubview:btnOK];
            
            [alertLevelWindow makeKeyAndVisible];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sweepstakes statement", @"Sweepstakes statement")
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            
            [alert addSubview:lblAnnounce];
            [alert addSubview:cbRead];
            [alert addSubview:cbNeverPrompt];
            
            [alert show];
            [alert release];
        }
        [cbNeverPrompt release];
        [cbRead release];
        [lblAnnounce release];
    }
    
    
    if (SystemVersion >= 7.0)
    {
        self.pointsView.frame = CGRectMake(pointsView.frame.origin.x, pointsView.frame.origin.y+20, pointsView.frame.size.width, pointsView.frame.size.height);
        self.btnView.frame = CGRectMake(btnView.frame.origin.x, btnView.frame.origin.y+20, btnView.frame.size.width, btnView.frame.size.height);
        self->rollingView.frame = CGRectMake(rollingView.frame.origin.x, rollingView.frame.origin.y+20, rollingView.frame.size.width, rollingView.frame.size.height);
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSubtitle) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSubtitle) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseSubtitle) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseSubtitle) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidUnload
{
    //停止播放音乐
    if (player || [player isPlaying]) {
        [player stop];
    }
    
    if (player) {
        [player release];
        player = nil;
    }
    
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"SlotMachine"];
    
    //隐藏原来的导航栏
    [super.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [MobClick endLogPageView:@"SlotMachine"];
    
    //让手机变成第一响应者
    [self becomeFirstResponder];
    
    if (self.subtitle) {
        //显示字幕
        canShowRollingSubtitle = YES;
        [self showSubtitle];
    }
    
#if test // for test
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(startToRolling) userInfo:nil repeats:YES];
#endif
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    if ([[[NgnEngine sharedInstance].configurationService getStringWithKey:SHOW_NEW_FOR_SLOTMACHINE] length] != 0)
    {
        [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FOR_SLOTMACHINE andValue:nil];
        [[CloudCall2AppDelegate sharedInstance] ShowNewFeatureRemind];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewReloadData" object:nil];
    }
    //将手机第一响应者注销
    [self resignFirstResponder];
    [super.navigationController setNavigationBarHidden:NO];
    
    //隐藏字幕
    if (rollingView) {
        canShowRollingSubtitle = NO;
        [self pauseSubtitle];
    }
    
    //停止播放音乐
    if (player || [player isPlaying]) {
        [player stop];
    }
    if (player) {
        [player release];
        player = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)screenShots
{
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    }
    else
    {
        UIGraphicsBeginImageContext(imageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow * window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            UIGraphicsPushContext(context);
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            CGContextConcatCTM(context, [window transform]);
            CGContextTranslateCTM(context, -[window bounds].size.width*[[window layer] anchorPoint].x, -[window bounds].size.height*[[window layer] anchorPoint].y);
            [[window layer] renderInContext:context];
            
            UIGraphicsPopContext();
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //save
    NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
    static int index = 0;
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/%@-%d.png",num,index];
    if ([UIImagePNGRepresentation(image) writeToFile:path atomically:YES]) {
        index += 1;
        CCLog(@"Succeeded!");
    }
    else {
        CCLog(@"Failed!");
    }
//    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    CCLog(@"Suceeded!");
}

- (void)dealloc
{
    [wheelArray release];
    [lblBet release];
    [bet release];
    [lblGain release];
    [gain release];
    [lblRemindPoint release];
    [remindPoint release];
    [btnBet release];
    [btnGo release];
    [btnGameRules release];
    [btnSendWeibo release];
    [pointsView release];
    [btnView release];
    [subtitle release];
    [slotmachineAdsInfo release];
    [pointListArray release];
    [bigPrizeText release];
    
    [popoverController release];
    
    [shareString release];
    [betBefore release];
    [betAffer release];
    [lblShowResult release];
    
    if (column) {
        [column release];
    }

    if (player) {
        [player release];
    }
    
    if (cbRead) {
        [cbRead release];
    }
    if (cbNeverPrompt) {
        [cbNeverPrompt release];
    }
    
    [super dealloc];
}

#pragma mark
#pragma mark Motion Shake
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        CCLog(@"------slot machine shake began-----");
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        CCLog(@"------slot machine shake ended-----");
        [self startToRolling];
    }
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

#pragma mark
#pragma mark my UIAlertView
/**
 *	@brief	弹出消息
 */
- (void)showErrorAlert:(int)alertType
{
    switch (alertType) {
        case kAlertTypeSlotMachineNetWorkErr://网络状况不佳,请稍后再试
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Happy to shake",@"Happy to shake")
                                                            message:NSLocalizedString(@"SlotMachine Network error",@"SlotMachine Network error")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK",@"OK"), nil];
            [alert show];
            [alert release];
            break;
        }
        case kAlertTypeSlotMachineLoadingPrize://正在加载奖项
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Happy to shake",@"Happy to shake")
                                                            message:NSLocalizedString(@"Loading...",@"Loading...")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK",@"OK"), nil];
            [alert show];
            [alert release];
            break;
        }
        case kAlertTypeSlotMachineBetMoreThanBalance:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Happy to shake",@"Happy to shake")
                                                            message:NSLocalizedString(@"Bet more than balance",@"Bet more than balance")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK",@"OK"), nil];
            [alert show];
            [alert release];
            break;
        }
        case kAlertTypeSlotMachineSelectBet:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Happy to shake",@"Happy to shake")
                                                            message:NSLocalizedString(@"Please select bet",@"Please select bet")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK",@"OK"), nil];
            [alert show];
            [alert release];
            break;
        }
        case kAlertTypeSlotMachineResultNoResp:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Happy to shake",@"Happy to shake")
                                                            message:NSLocalizedString(@"Slotmachine request timeout",@"Slotmachine request timeout")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK",@"OK"), nil];
            [alert show];
            [alert release];
            break;
        }
        default:
            break;
    }
}

#pragma mark
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CCLog(@"1 checkedValue------%d",cbRead.checked);
    CCLog(@"2 checkedValue------%d",cbNeverPrompt.checked);
    if (cbNeverPrompt.checked) {
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_NeverPromptHappyToShakeAnnounce andValue:YES];
    }
}

#pragma mark - SelectTableViewDelegate
- (void)selectTableViewDidSelected:(NSInteger)index andType:(PopViewType)type
{
    if (type == kTagTableViewForSlotMachine)
    {
        self.bet.text = [NSString stringWithFormat:@"%@",[self.pointListArray objectAtIndex:index]];
        [self.popoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - ZCSlotMachineDelegate

- (void)slotMachineWillStartSliding:(ZCSlotMachine *)slotMachine {
    //    _startButton.enabled = NO;
}

- (void)slotMachineDidEndSliding:(ZCSlotMachine *)slotMachine {
    CCLog(@"animation compeleted");
    
}

- (void)slotMachineDidEndEveryColmun:(NSInteger)Colmun
{
    //播放停止声音
    NSString *stoprollingPath = [[NSBundle mainBundle] pathForResource:@"stoprolling" ofType:@"mp3"];
    [self startToPlayAudio:player andUrl:stoprollingPath];
    if (Colmun == 3) {
        //复原各种设置
        [self performSelector:@selector(setGainandRemind) withObject:nil afterDelay:0.5];
    }
}

#pragma mark - ZCSlotMachineDataSource
- (CGFloat)slotContainerLayer_y:(ZCSlotMachine *)slotMachine
{
    return SystemVersion>=7.0 ? 54.0f : 44.0f;
}

- (NSArray *)iconsForSlotsInSlotMachine:(ZCSlotMachine *)slotMachine {
    return column;
}

- (NSUInteger)numberOfSlotsInSlotMachine:(ZCSlotMachine *)slotMachine {
    return 3;
}

- (CGFloat)slotWidthInSlotMachine:(ZCSlotMachine *)slotMachine {
    return 92.0f;
}

- (CGFloat)slotSpacingInSlotMachine:(ZCSlotMachine *)slotMachine {
    return 2.0f;
}

@end
