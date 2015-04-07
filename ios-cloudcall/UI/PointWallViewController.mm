//
//  PointWallViewController.m
//  CloudCall
//
//  Created by CloudCall on 13-4-1.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "PointWallViewController.h"
#import "MobClick.h"
#import "HttpRequest.h"
#import "JSONKit.h"
#import "CloudCall2AppDelegate.h"

#import "DianRuAdWall.h"

#define kTagActionAlertIntegralExchange 1
#define kTagActionAlertIntegralExchangeMaxValue 2

#define kTagActionAlertIntegralDianRuExchange 10
#define kTagActionAlertIntegralExchangeMaxValueDianRu 11

@interface PointWallViewController(Sip_And_Network_Callbacks)
-(void) onMessagingEvent:(NSNotification*)notification;
@end

@implementation PointWallViewController(Sip_And_Network_Callbacks)

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
                
                BOOL txtMsg = YES;
                if (contentType) {
                    if ([[contentType lowercaseString] hasPrefix:@"text/adclick"])
                    {
                        [self hideHUD];
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
                        
                        /*
                         advertiser:客户端发过来的advertiser
                         admtype: 客户端发过来的admtype,暂时不用，留空。
                         rechargemoney:
                         remainmoney:
                         errorcode: //0 – 成功；401 – 失败
                         */
                        int recharge = 0;
                        int balance = 0;
                        int errorcode = 0;
                        
                        NSString *advertiser = nil;
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
                                if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"rechargemoney"]) {
                                    recharge = [strvalue intValue];
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"remainmoney"]) {
                                    balance = [strvalue intValue];
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"errorcode"]) {
                                    errorcode = [strvalue intValue];
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"advertiser"]) {
                                    advertiser = [NSString stringWithString:strvalue];
                                }
                            }
                        }
                        
                        NSMutableString* strbalance = nil;
                        if (errorcode == 0) { // succ
                            strbalance = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"Got %d YunTong points, your balance is %d YunTong points.", @"Got %d YunTong points, your balance is %d YunTong points."), recharge, balance];
                        } else if (errorcode == 401) { // fail
                            ;// do nothing
                        }
                        if ([advertiser isEqualToString:@"immob"])
                        {
                            CCLog(@"immob");
                            if (errorcode == 0) {
                                lm_score -= recharge;
                            }
                            if (lm_score > 0)
                            {
                                [strbalance appendFormat:@"%@%i%@\n%@",NSLocalizedString(@"Still leave", @"Still leave"), lm_score, NSLocalizedString(@"integral.", @"integral."),NSLocalizedString(@"Continue to Exchange?", @"Continue to Exchange?")];
                                UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                            message: strbalance
                                                                           delegate: self
                                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                  otherButtonTitles:NSLocalizedString(@"Continue", @"Continue"), nil];
                                a.tag = kTagActionAlertIntegralExchangeMaxValue;
                                [a show];
                                [a release];
                            }
                            else
                            {
                                [strbalance appendFormat:@"%@%i%@\n", NSLocalizedString(@"Still leave", @"Still leave"), lm_score, NSLocalizedString(@"integral.", @"integral.")];
                                UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                            message: strbalance
                                                                           delegate: self
                                                                  cancelButtonTitle: nil
                                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                                [a show];
                                [a release];
                            }
                        }
                        else if ([advertiser isEqualToString:@"dianjin"])
                        {
                            CCLog(@"dianjin");
                            UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                        message: strbalance
                                                                       delegate: self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                            [a show];
                            [a release];
                        }
                        else if ([advertiser isEqualToString:@"dianru"])
                        {
                            CCLog(@"dianru");
                            if (errorcode == 0) {
                                dianru_score -= recharge;
                            }
                            if (dianru_score > 0)
                            {
                                [strbalance appendFormat:@"%@%i%@\n%@",NSLocalizedString(@"Still leave", @"Still leave"), dianru_score, NSLocalizedString(@"integral.", @"integral."),NSLocalizedString(@"Continue to Exchange?", @"Continue to Exchange?")];
                                UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                            message: strbalance
                                                                           delegate: self
                                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                  otherButtonTitles:NSLocalizedString(@"Continue", @"Continue"), nil];
                                a.tag = kTagActionAlertIntegralExchangeMaxValueDianRu;
                                [a show];
                                [a release];
                            }
                            else
                            {
                                [strbalance appendFormat:@"%@%i%@\n", NSLocalizedString(@"Still leave", @"Still leave"), dianru_score, NSLocalizedString(@"integral.", @"integral.")];
                                UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                            message: strbalance
                                                                           delegate: self
                                                                  cancelButtonTitle: nil
                                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                                [a show];
                                [a release];
                            }

                        }
                        
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

@implementation PointWallViewController
@synthesize tipView;
@synthesize tipText;
@synthesize btnCloseTip;
@synthesize tableView;
@synthesize lm_AdWall;
@synthesize aplist;

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
    
    
    self.title = NSLocalizedString(@"Recommended Application", @"Recommended Application");
    CloudCall2AppDelegate *appDelegate = [CloudCall2AppDelegate sharedInstance];
    if ([appDelegate getAppStoreRelease] < [appDelegate getCurrentRelease])
    {
        show91Only = YES;
    }
    else
    {
        show91Only = NO;
    }
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(0, 28, 44, 44);
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(back:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reloadBtn.frame = CGRectMake(260, 0, 59, 44);
    [reloadBtn setBackgroundImage:[UIImage imageNamed:@"SyncContact_up"] forState:UIControlStateNormal];
    [reloadBtn setBackgroundImage:[UIImage imageNamed:@"SyncContact_down"] forState:UIControlStateHighlighted];
    [reloadBtn addTarget:self action:@selector(reloadPointWall:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:reloadBtn] autorelease];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.aplist = [NSMutableArray arrayWithCapacity:20];
    
    // add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
    
#if DianJin_Enable
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActivatedDidFinishChange:) name:kDJAppActivateDidFinish object:nil];
#endif
    
    //获取广告列表
    [self getAdPlatformList];
    
    NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
    //AdUnitID 可以到力美广告平台去获取:http://www.immob.cn
    lm_AdWall = [[immobView alloc] initWithAdUnitID:immobWallKey];
    //此属性针对多账户用户，主要用于区分不同账户下的积分
    [lm_AdWall.UserAttribute setObject:num forKey:@"accountname"];
    lm_AdWall.delegate = self;
    if (SystemVersion >= 6.0 && [appDelegate MarkCode] != CLIENT_FOR_AS_APP_STORE)
    {
        [lm_AdWall.UserAttribute setObject:@"YES" forKey:@"disableStoreKit"];
    }
    else
    {
        [lm_AdWall.UserAttribute setObject:@"NO" forKey:@"disableStoreKit"];
    }
        
    //点入积分墙
    [DianRuAdWall beforehandAdWallWithDianRuAppKey:DianRuWallKey];
    //初始化代理，用于接收获取积分和消费积分结果，并设置系统ApplicationKey
    [DianRuAdWall initAdWallWithDianRuAdWallDelegate:self];
    appDelegate.isOpenDianRuWallPoints = YES;
    
    maxExchangePoints = appDelegate.maxexchangepoints;
    
    //设置提示栏
    BOOL tipSwitch = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_ISSHOWSHAKETOWALLPOINTTIPS];
    if (tipSwitch) {
        [self.tipView removeFromSuperview];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,self.tableView.frame.origin.y - 30 , self.tableView.frame.size.width, self.tableView.frame.size.height + 30)];
    }
    //设置提示信息
    self.tipText.text = NSLocalizedString(@"wall points info tips", @"wall points info tips");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PointWall"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PointWall"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [CloudCall2AppDelegate sharedInstance].isOpenDianRuWallPoints = NO;
}

- (void)reloadPointWall:(id)sender
{
    [self getAdPlatformList];
}

- (void)LiMeiRecommendedSoftware
{
    [lm_AdWall immobViewRequest];
}

- (void)dealloc
{
    if (self.tipView) {
        [tipView release];
    }
    if (tipText) {
        [tipText release];
    }
    [btnCloseTip release];
    [aplist release];
    lm_AdWall.delegate = nil;
    [lm_AdWall release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rechargeCloudCallPoints:(id)sender
{
    UIButton *Btn = (UIButton *)sender;
    if ([[NgnEngine sharedInstance].sipService isRegistered])
    {
        switch (Btn.tag)
        {
            case kPointWall_LiMei:
            {
                [self QueryLiMeiScore];
                break;
            }
            case kPointWall_DianRu:
            {
                [self QueryDianRuScore];
                break;
            }
            default:
                break;
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Integral Exchange Error", @"Integral Exchange Error")
                                                        message:NSLocalizedString(@"Could not Exchanging, server not ready", @"Could not Exchanging, server not ready")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    }
}

- (void)getAdPlatformList
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = NSLocalizedString(@"Loading...", @"Loading...");
    [HUD show:YES];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:10];
    
    [[HttpRequest instance] addRequest:kPointWallUrl andMethod:@"GET" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:nil andTimeout:10
                         successTarget:self successAction:@selector(responseWithSucceeded:)
                         failureTarget:self failureAction:@selector(responseWithFailed:) userInfo:nil];
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

- (void)QueryLiMeiScore
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.labelText = NSLocalizedString(@"Integral Exchange...", @"Integral Exchange...");
    [HUD show:YES];
    
    NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
    [lm_AdWall immobViewQueryScoreWithAdUnitID:immobWallKey WithAccountID:num];
    
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:10];
}

- (void)QueryDianRuScore
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.labelText = NSLocalizedString(@"Integral Exchange...", @"Integral Exchange...");
    [HUD show:YES];
    
    [DianRuAdWall getRemainPoint];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:10];
}

- (IBAction)closeTip:(id)sender
{
    [self.tipView removeFromSuperview];
    [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_ISSHOWSHAKETOWALLPOINTTIPS andValue:YES];
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,self.tableView.frame.origin.y - 30 , self.tableView.frame.size.width, self.tableView.frame.size.height + 30)];
}

#pragma mark -
#pragma mark - TableView Datasource
- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView_
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section
{
    return [aplist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell"];
    UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];
        
        //创建兑换按钮
        UIButton *rechargeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rechargeBtn.frame = CGRectMake(250, 15, 56, 30);
        [rechargeBtn setTitleColor:[UIColor colorWithRed:235.0/255.0 green:85.0/255.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
        [rechargeBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
        [rechargeBtn setTitle:NSLocalizedString(@"Exchange", @"Exchange") forState:UIControlStateNormal];
        [rechargeBtn setBackgroundImage:[UIImage imageNamed:@"rechargeBtn_bg_normal.png"] forState:UIControlStateNormal];
        [rechargeBtn setBackgroundImage:[UIImage imageNamed:@"rechargeBtn_bg_down.png"] forState:UIControlStateHighlighted];
        rechargeBtn.tag = [[aplist objectAtIndex:indexPath.row] intValue];
        [rechargeBtn addTarget:self action:@selector(rechargeCloudCallPoints:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:rechargeBtn];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"下载应用送点数(%d)", indexPath.row+1];
    cell.imageView.image = [UIImage imageNamed:@"wall_points_icon"];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    cell.detailTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    cell.detailTextLabel.numberOfLines = 0;
    
    switch ([[aplist objectAtIndex:indexPath.row] intValue])
    {
        case kPointWall_91DianJin:
        {
            UIButton *rechargeBtn = (UIButton *)[cell viewWithTag:[[aplist objectAtIndex:indexPath.row] intValue]];
            rechargeBtn.hidden = YES;
            cell.detailTextLabel.text = @"1.下载安装并成功激活\n2.激活后可立刻得到点数";
            break;
        }
        case kPointWall_DianRu:
        case kPointWall_LiMei:
        {
            cell.detailTextLabel.text = @"1.需下载安装并激活,才能获得积分.\n2.累积积分不超过2000,请及时兑换.";
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    switch ([[aplist objectAtIndex:indexPath.row] intValue])
    {
        case kPointWall_91DianJin:
        {
#if DianJin_Enable
            [[CloudCall2AppDelegate sharedInstance] createDianJinAd];
            [[DianJinOfferPlatform defaultPlatform] showOfferWall:self delegate:self];
#endif
            break;
        }
        case kPointWall_DianRu:
        {
            [DianRuAdWall showAdWall:self];
            break;
        }
        case kPointWall_LiMei:
        {
            [self LiMeiRecommendedSoftware];
            break;
        }
        default:
            break;
    }

}

//////////////////////
#pragma mark -
#pragma mark dianjin callback
- (void) appActivatedDidFinishChange:(NSNotification *)notice {
    NSDictionary *dict = [notice object];
    CCLog(@"Wall_dict=%@", dict);
    NSNumber *result = [dict objectForKey:@"result"];
    if ([result boolValue]) {
        NSNumber *awardAmount = [dict objectForKey:@"awardAmount"];
        NSString *identifier = [dict objectForKey:@"identifier"];
        CCLog(@"settings identifier = %@, %@", identifier, awardAmount);
        
        if ([awardAmount intValue] != 0)
        {
            CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
            [appDelegate AdClick:[awardAmount intValue] withType:AD_TYPE_91DIANJIN];
        }
    } else {
       /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"点数赠送失败"
                                                        message:@"请确认曾经是否安装过该软件,然后删除再重新下载安装"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];*/
    }
}

/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark immobViewDelegate methods

/**
 *email phone sms等所需要
 *返回当前添加immobView的ViewController
 */
- (UIViewController *)immobViewController{
    
    return self;
}

/**
 *根据广告的状态来决定当前广告是否展示到当前界面上 AdReady
 *YES  当前广告可用
 *NO   当前广告不可用
 */
- (void) immobViewDidReceiveAd:(immobView *)immobView
{
    [self.view addSubview:lm_AdWall];
    [self.navigationController setNavigationBarHidden:YES];
    [lm_AdWall immobViewDisplay];
}

- (void) immobView: (immobView*) immobView didFailReceiveimmobViewWithError: (NSInteger) errorCode{
    
    UIAlertView *uA=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"当前广告不可用" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
    [uA show];
    [uA release];
    
    
    //如果想实现隐藏积分墙按钮功能，请将下面代码注释去掉
//    if (isFirst) {
//       adwallb.hidden=NO;
//        isFirst=NO;
//       }
    
    NSLog(@"errorCode:%i",errorCode);
}

/**
 *查询积分接口回调
 */
- (void) immobViewQueryScore:(NSUInteger)score WithMessage:(NSString *)message {
    CCLog(@"score:%i", score);
    lm_score = score;
    if (maxIntegralExchange == YES)
    {
        maxIntegralExchange = NO;
        NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
        [self.lm_AdWall immobViewReduceScore: lm_score>maxExchangePoints ? maxExchangePoints:lm_score
                                WithAdUnitID:immobWallKey WithAccountID:num];
        return;
    }
    
    if (score > 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Integral", @"Integral")
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"You have %d integral. Do you want to exchang the integral to YunTong Points?", @"You have %d integral. Do you want to exchang the integral to YunTong Points?"), score]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        alert.tag = kTagActionAlertIntegralExchange;
        [alert release];
    }  else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Integral", @"Integral")
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"You have no integral.", @"You have no integral."),score]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        alert.tag = kTagActionAlertIntegralExchange;
        [alert release];
    }
}

- (void) immobViewReduceScore:(BOOL)status WithMessage:(NSString *)message
{
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    if (status == YES)
    {
        [appDelegate AdClick: lm_score > maxExchangePoints ? maxExchangePoints : lm_score withType:AD_TYPE_LIMEI];
    }
    else
    {
        UIAlertView *uA=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Integral Exchange Error", @"Integral Exchange Error")
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                         otherButtonTitles:nil, nil];
        [uA show];
        [uA release];
    }
}

-(void)onDismissScreen:(immobView *)immobView{
    [self.navigationController setNavigationBarHidden:NO];
    CCLog(@"onDismissScreen");
}
-(void)onPresentScreen:(immobView *)immobView{
    CCLog(@"onPresentScreen");
}
-(void)onLeaveApplication:(immobView *)immobView{
    CCLog(@"onLeaveApplication");
}

#pragma mark -
#pragma mark DianRuSDKDelegate
-(void)didReceiveSpendScoreResult:(BOOL)isSuccess
{
    if(isSuccess)
    {
        //消费积分成功，重新获取当前积分值
        CloudCall2AppDelegate *appDelegate = [CloudCall2AppDelegate sharedInstance];
        [appDelegate AdClick: dianru_score > maxExchangePoints ? maxExchangePoints : dianru_score withType:AD_TYPE_DIANRU];
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消费积分提示" message:@"消费积分成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
    }
    else
    {
        //获取积分失败，提示用户
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消费积分提示" message:@"消费积分失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)didReceiveGetScoreResult:(int)point
{
    //返回-1，为获取积分失败，可能是由于网络原因，或者服务器暂时无法访问等。提示用户
    CCLog(@"%d",point);
    dianru_score = point;
    
    if(point == -1)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取积分提示"
                                                            message:@"获取积分失败"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }

    if (maxIntegralExchange == YES)
    {
        maxIntegralExchange = NO;
        [DianRuAdWall spendPoint:dianru_score>maxExchangePoints ? maxExchangePoints:dianru_score];
        return;
    }

    if (point > 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Integral", @"Integral")
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"You have %d integral. Do you want to exchang the integral to YunTong Points?", @"You have %d integral. Do you want to exchang the integral to YunTong Points?"), point]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        alert.tag = kTagActionAlertIntegralDianRuExchange;
        [alert release];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Integral", @"Integral")
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"You have no integral.", @"You have no integral."),point]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        alert.tag = kTagActionAlertIntegralDianRuExchange;
        [alert release];
    }
}

-(NSString *)dianruAdWallAppUserId
{
    NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
    return num;
}

#pragma mark -
#pragma mark 定义UIAlertTableView的委托，buttonindex就是按下的按钮的index值

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case kTagActionAlertIntegralExchange:
            if (buttonIndex == 1) {
                NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
                [self.lm_AdWall immobViewReduceScore: lm_score>maxExchangePoints ? maxExchangePoints:lm_score
                                        WithAdUnitID:immobWallKey WithAccountID:num];
            }
            else
            {
                [self hideHUD];
            }
            break;
        case kTagActionAlertIntegralExchangeMaxValue:
        {
            if (buttonIndex == 1)
            {
                maxIntegralExchange = YES;
                [self QueryLiMeiScore];
            }
            break;
        }
        case kTagActionAlertIntegralDianRuExchange:
        {
            if (buttonIndex == 1) {
                [DianRuAdWall spendPoint:dianru_score>maxExchangePoints ? maxExchangePoints:dianru_score];
            }
            else
            {
                [self hideHUD];
            }
            break;
        }
        case kTagActionAlertIntegralExchangeMaxValueDianRu:
        {
            if (buttonIndex == 1)
            {
                maxIntegralExchange = YES;
                [self QueryDianRuScore];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark HttpRequest API

- (void)responseWithSucceeded:(NSData *)data {
    [self hideHUD];
	if (data == nil)
        return;
    [aplist removeAllObjects];
    NSMutableDictionary *root = [data mutableObjectFromJSONData];
    CCLog(@"PointWallData=%@",root);
    NSString* result   = [root objectForKey:@"result"];
    if ([result isEqualToString:@"success"])
    {
        NSArray *aplistArray = [root objectForKey:@"adwall"];
        
        for (NSString *adList in aplistArray)
        {
            if ([adList isEqualToString:@"dianjin"])
                [aplist addObject:[NSNumber numberWithInt:kPointWall_91DianJin]];
            else if ([adList isEqualToString:@"immob"])
                [aplist addObject:[NSNumber numberWithInt:kPointWall_LiMei]];
            else if ([adList isEqualToString:@"dianru"])
                [aplist addObject:[NSNumber numberWithInt:kPointWall_DianRu]];
        }
        
        if (!DianJin_Enable || ([aplist containsObject:[NSNumber numberWithInt:kPointWall_91DianJin]] && ![MobClick isJailbroken]))
        {
            [aplist removeObject:[NSNumber numberWithInt:kPointWall_91DianJin]];
        }
        [self.tableView reloadData];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message:[root objectForKey:@"text"]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    }
}

- (void)responseWithFailed:(NSError *)error {
    [self hideHUD];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
//                                                    message:[error localizedDescription]
//                                                   delegate:nil
//                                          cancelButtonTitle:nil
//                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
//    [alert show];
//    [alert release];
}

@end
