/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "InviteFriendsViewController.h"
#import "IReferViewController.h"
#import "CloudCall2AppDelegate.h"
#import "UIKit/UIKit.h"
#import "iOSNgnStack.h"
#import "CloudCall2Constants.h"
#import <AddressBookUI/ABPersonViewController.h>
#import "HttpRequest.h"
#import "JSONKit.h"
#import "CCGTMBase64.h"
#import "MBProgressHUD.h"
#import <ShareSDK/ShareSDK.h>
#import "WebBrowser.h"

#define Get_Refer_Detailed @"getReferDetailed"
#define Get_Share_Text @"getShareText"

@implementation InviteFriendsViewController

@synthesize shareUrlLabel;

@synthesize shareUrlField;
@synthesize tableView;
@synthesize referee;
@synthesize refer;
@synthesize shareButton;
@synthesize cpButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //初始化
    setRefereeAward = 200;
    inviteAward = 300;
    award = 0;
    
    
    //本地化
    [self.shareButton setTitle:NSLocalizedString(@"Invite Friends", @"Invite Friends") forState:UIControlStateNormal];
    [self.cpButton setTitle:NSLocalizedString(@"Copy Link", @"Copy Link") forState:UIControlStateNormal];
    self.shareUrlLabel.text = NSLocalizedString(@"Share Link:", @"Share Link:");
    
    self.referee = [[NgnEngine sharedInstance].configurationService getStringWithKey:ACCOUNT_REFEREE];
    
    NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
    shareUrlField.text = [NSString stringWithFormat:@"%@/refer/index.php?invite=%@", RootUrl,[CCGTMBase64 stringByEncodingBytes:[num UTF8String] length:[num length]]];
    
    self.title = NSLocalizedString(@"Invite Friends", @"Invite Friends");
//    //判断设备的版本
//    if (SystemVersion >= 5.0)
//    {    //ios5 新特性
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"toolbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
//    }
//    else
//    {
//        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:56.0/255.0 green:163.0/255.0 blue:253.0/255.0 alpha:1.0];
//    }

    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToSetting:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    [self getReferDetailed];
    
    tableView.delegate = self;
	tableView.dataSource = self;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void) backToSetting: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [shareUrlLabel release];
    
    [tableView release];
    [referee release];
    [refer release];
    [shareUrlField release];
    [cpButton release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - customized mehods
- (IBAction)ButtonClick:(id)sender
{
    if (sender == shareButton)
    {
        NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
        
        NSDictionary *jsonDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"invite", @"type",
                                 num, @"user_number", nil];
        
        NSData *jsonData = [jsonDic JSONData];
        NSDictionary *usrInfo = [NSDictionary dictionaryWithObject:Get_Share_Text forKey:@"msgtype"];
        
        [[HttpRequest instance] addRequest:kGroupCallShareContentUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                             successTarget:self successAction:@selector(responseWithSucceeded:userInfo:)
                             failureTarget:self failureAction:@selector(responseWithFailed:userInfo:) userInfo:usrInfo];
        [self shareOnline:sender];
    }
    else if (sender == cpButton)
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:self.shareUrlField.text];
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = NSLocalizedString(@"Copy Successfully", @"Copy Successfully");
        [HUD show:YES];
        [HUD hide:YES afterDelay:1];
        [HUD release];
    }
}

- (void)getReferDetailed
{
    NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];

    NSDictionary *jsonDic = [NSDictionary dictionaryWithObjectsAndKeys:num, @"user_number", nil];
    NSData *jsonData = [jsonDic JSONData];
    
    NSDictionary *usrInfo = [NSDictionary dictionaryWithObject:Get_Refer_Detailed forKey:@"msgtype"];
    
    [[HttpRequest instance] addRequest:kGetreferUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                         successTarget:self successAction:@selector(responseWithSucceeded:userInfo:)
                         failureTarget:self failureAction:@selector(responseWithFailed:userInfo:) userInfo:usrInfo];
}

- (void)OpenWebBrowser:(NSString *)url
{
    WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
    webBrowser.mode = TSMiniWebBrowserModeNavigation;
    webBrowser.type = TSMiniWebBrowserTypeDefault;
    webBrowser.barStyle = UIStatusBarStyleDefault;
    webBrowser.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webBrowser animated:YES];
    
    [webBrowser release];
}

- (void)shareOnline:(id)sender
{
    CloudCall2AppDelegate *_appDelegate = [CloudCall2AppDelegate sharedInstance];
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeSinaWeibo, ShareTypeTencentWeibo, ShareTypeSMS, ShareTypeQQSpace, ShareTypeWeixiSession, ShareTypeWeixiTimeline, ShareTypeDouBan, nil];

    
    NSString *shareString = [[NgnEngine sharedInstance].configurationService getStringWithKey:INVITE_SHARE_TEXT];
    if ([shareString length] == 0)
    {
        shareString = [NSString stringWithFormat:@"打电话还要钱？图森破！让给力的云通帮你的话费详单减减压，猛戳这里%@", shareUrlField.text];
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:shareString
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
                                    CCLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    CCLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}


#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;//3;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.backgroundColor = [UIColor clearColor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	switch (indexPath.row)
    {
        case 0:
        {
            NSString *refereeName = nil;
            //显示号码名字
            NgnContactMutableArray* contacts_ = (NgnContactMutableArray*)[[[NgnEngine sharedInstance].contactService contacts] retain];
            for (NgnContact* contact in contacts_) {
                BOOL found = NO;
                for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers) {
                    if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number) {
                        NSString* tmpPhoneNum = [phoneNumber.number phoneNumFormat];
                        
                        if (IsPureNumber(tmpPhoneNum)) {
                            if ([tmpPhoneNum isEqualToString:referee])
                            {
                                refereeName = contact.displayName;
                                found = YES;
                                break;
                            }
                        }
                    }
                }
                if (found)
                    break;
            }
            [contacts_ release];
            
            NSString* strRef = [[NgnEngine sharedInstance].configurationService getStringWithKey:ACCOUNT_REFEREE];
            if ([strRef isEqualToString:DEFAULT_ACCOUNT_REFEREE] && [referee length] == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Set Referee", @"Set Referee");
                cell.detailTextLabel.text = NSLocalizedString(@"Set recommended person and the recommended can gain points", @"Set recommended person and the recommended can gain points");
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                if ([refereeName length] > 0)
                {
                    NSString *labelText = [NSString stringWithFormat:@"%@: %@ (%@)", NSLocalizedString(@"My Referee", @"My Referee"), refereeName,referee];
                    NSRange headRange = [labelText rangeOfString:NSLocalizedString(@"My Referee", @"My Referee")];
                    
                    cell.textLabel.text = labelText;
                    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"I have gain %d YunTong points,%@ have gain %d YunTong points", @"I have gain %d YunTong points,%@ have gain %d YunTong points"), setRefereeAward, refereeName, inviteAward];
                    
                    if (SystemVersion >= 6.0) {
                        NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:labelText] autorelease];
                        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(headRange.length+1, labelText.length-headRange.length-1)];
                        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:15.0f] range:NSMakeRange(headRange.length+1, labelText.length-headRange.length-1)];
                        
                        [cell.textLabel setAttributedText:attributedString];
                    }
                }
                else
                {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"My Referee", @"My Referee"), referee];
                    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"I have gain %d YunTong points,%@ have gain %d YunTong points", @"I have gain %d YunTong points,%@ have gain %d YunTong points"), setRefereeAward, referee, inviteAward];

                }
                
            }
            break;
        }
        case 1:
        {
            cell.textLabel.text = NSLocalizedString(@"I recommend people", @"I recommend people");
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Recommended %d people successful,Gain %d YunTong points", @"Recommended %d people successful,Gain %d YunTong points"), [refer count], award];
            break;
        }
        case 2:
        {
            cell.textLabel.text = NSLocalizedString(@"Referee Top", @"Referee Top");
            cell.detailTextLabel.text = NSLocalizedString(@"who is the best?", @"who is the best?");
            break;
        }
        default:
            break;
    }
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            NSString* strRef = [[NgnEngine sharedInstance].configurationService getStringWithKey:ACCOUNT_REFEREE];
            if (![strRef isEqualToString:DEFAULT_ACCOUNT_REFEREE] || [referee length] != 0)
                return nil;
            break;
        }
        default:
            break;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    switch (indexPath.row)
    {
        case 0:
        {
            SelectNumberViewController* sv = [[SelectNumberViewController alloc] initWithNibName:@"SelectNumberView" bundle:[NSBundle mainBundle] andDelegate:self andStyle:Select_Number_Style_Single andType:Select_Number_Type_Mobile_Only];
            [self.navigationController pushViewController:sv animated:YES];
            [sv release];
            break;
        }
        case 1:
        {
            if ([refer count] == 0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"My Referee", @"My Referee")
                                                                message:NSLocalizedString(@"You did not succeed recommend people, rush to invite friends to join the YunTong, both parties can gain YunTong points", @"You did not succeed recommend people, rush to invite friends to join the YunTong, both parties can gain YunTong points")
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"I know", @"I know"), nil];
                [alert show];
                [alert release];
            }
            else
            {
                IReferViewController* irv = [[IReferViewController alloc] initWithStyle:UITableViewStylePlain withReferArray:refer];
                [self.navigationController pushViewController:irv animated:YES];
                [irv release];
            }

            break;
        }
        case 2:
        {
            [self OpenWebBrowser:kRankingListUrl];
            break;
        }
        default:
            break;
    }
}

#pragma mark - NumberPickerDelegate <NSObject>
-(void) setRefereeSucess
{
    [self getReferDetailed];
}

#pragma mark -
#pragma mark HttpRequest API

- (void)responseWithSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo {
	if (data == nil)
        return;
    NSString* msgtype = [userInfo objectForKey:@"msgtype"];
    
    if ([msgtype isEqualToString:Get_Refer_Detailed])
    {
        NSMutableDictionary *root = [data mutableObjectFromJSONData];
        NSString* result   = [root objectForKey:@"result"];
        CCLog(@"refereeInfo=%@", root);
        if ([result isEqualToString:@"success"])
        {
            setRefereeAward = [[root objectForKey:@"setRefereeAward"] intValue];
            inviteAward = [[root objectForKey:@"inviteAward"] intValue];
            
            NSArray *refereeArray = [root objectForKey:@"referee"];
            if ([refereeArray count]>0)
            {
                self.referee = [refereeArray objectAtIndex:0];
                
                [[NgnEngine sharedInstance].configurationService setStringWithKey:ACCOUNT_REFEREE andValue:referee];
            }
            self.refer = [root objectForKey:@"refer"];
            award = [[root objectForKey:@"award"] intValue];
            
            [self.tableView reloadData];
        }
        else
        {
            CCLog(@"error=%@", [root objectForKey:@"text"]);
        }
    }
    else if ([msgtype isEqualToString:Get_Share_Text])
    {
        NSMutableDictionary *root = [data mutableObjectFromJSONData];
        NSString* result   = [root objectForKey:@"result"];
        if ([result isEqualToString:@"success"])
        {
            NSString *shareText = [root objectForKey:@"sharetext"];
            
            [[NgnEngine sharedInstance].configurationService setStringWithKey:INVITE_SHARE_TEXT andValue:shareText];
            
        }
        else
        {
            CCLog(@"error=%@", [root objectForKey:@"text"]);
        }
    }
    
}

- (void)responseWithFailed:(NSError *)error userInfo:(NSDictionary *)userInfo{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
//                                                    message:[error localizedDescription]
//                                                   delegate:nil
//                                          cancelButtonTitle:nil
//                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
//    [alert show];
//    [alert release];
}

@end
