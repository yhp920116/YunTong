//
//  AboutLocalViewController.m
//  CloudCall
//
//  Created by CloudCall on 12-8-24.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import "AboutLocalViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DeclareViewController.h"
#import "SettingsViewController.h"
#import "CloudCall2AppDelegate.h"
#import "WebBrowser.h"
#import "UrlHeader.h"

#define kOfficialWebsite    RootUrl
#define kOfficialBBS        @"http://bbs.callwine.net"
#define kSinaWeiBo          @"http://weibo.cn/cloudcall"
#define kTencnetWeiBo       @"http://t.qq.com/cloudcall"

@interface AboutLocalViewController ()

@end

@implementation AboutLocalViewController
@synthesize Version;
@synthesize DeclareLabel;
@synthesize DeclareBtn;
@synthesize labelCopyright;

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
    
    self.title = NSLocalizedString(@"About", @"About");
    // Do any additional setup after loading the view from its nib.
    self.Version = [[[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 37)] autorelease];
    Version.lineBreakMode = UILineBreakModeWordWrap;
    Version.highlightedTextColor = [UIColor whiteColor];
    Version.numberOfLines = 0;
    Version.opaque = NO; // 选中Opaque表示视图后面的任何内容都不应该绘制
    Version.backgroundColor = [UIColor whiteColor];
    Version.font = [UIFont systemFontOfSize:15.0];
    Version.layer.cornerRadius = 5;
    [[Version layer] setBorderWidth:1.0f];
    Version.text = [NSString stringWithFormat:@"  %@  %@", NSLocalizedString(@"Version:", @"Version:"), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    Version.layer.borderColor = [[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] CGColor];
    [self.view addSubview:Version];

    self.DeclareLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 150, 280, 37)] autorelease];
    DeclareLabel.lineBreakMode = UILineBreakModeWordWrap;
    DeclareLabel.highlightedTextColor = [UIColor whiteColor];
    DeclareLabel.numberOfLines = 0;
    DeclareLabel.opaque = NO; // 选中Opaque表示视图后面的任何内容都不应该绘制
    DeclareLabel.backgroundColor = [UIColor whiteColor];
    DeclareLabel.font = [UIFont systemFontOfSize:15.0];
    DeclareLabel.layer.cornerRadius = 5;
    [[DeclareLabel layer] setBorderWidth:1.0f];
    DeclareLabel.text = [NSString stringWithFormat:@"  %@", NSLocalizedString(@"Disclaimer", @"Disclaimer")];
    DeclareLabel.layer.borderColor = [[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] CGColor];
    //[self.view insertSubview:DeclareLabel atIndex:2];
    [self.DeclareBtn setHidden:YES];
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(10, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToSetting:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*)[[UIApplication sharedApplication] delegate]);
    if (appDelegate.logViewController) {
        UIButton *toolBtnLog = [UIButton buttonWithType:UIButtonTypeCustom];
        toolBtnLog.frame = CGRectMake(135, 7, 72, 30);
        [toolBtnLog setTitle:@"Log" forState:UIControlStateNormal];
        [toolBtnLog setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        toolBtnLog.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        [toolBtnLog setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_up.png"] forState:UIControlStateNormal];
        [toolBtnLog setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_down.png"] forState:UIControlStateHighlighted];
        [toolBtnLog addTarget:self action:@selector(viewLog) forControlEvents: UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBtnLog] autorelease];
    }
    
    labelCopyright.text = NSLocalizedString(@"Copyright declare", @"Copyright declare");
    
    if(iPhone5)
    {
        self.labelCopyright.frame = CGRectMake(self.labelCopyright.frame.origin.x, self.labelCopyright.frame.origin.y + 88, self.labelCopyright.frame.size.width, self.labelCopyright.frame.size.height);
    }
    
    [self CreateProductUILabel];
    [self CreateProductBtn];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)dealloc
{
    [Version release];
    [DeclareLabel release];
    [super dealloc];
}

- (void) backToSetting: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewLog
{
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*)[[UIApplication sharedApplication] delegate]);
    if (appDelegate.logViewController)
        [self.navigationController pushViewController:appDelegate.logViewController animated:YES];
}

- (void)CreateProductUILabel
{
    CGFloat pointY = DeclareLabel.frame.origin.y + DeclareLabel.frame.size.height-10;
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    if ([appDelegate ShowAllFeatures]) {
        //创建
        UILabel *officialWebsiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, pointY+22.0f, 70.0f, 21.0f)];
        officialWebsiteLabel.backgroundColor = [UIColor clearColor];
        officialWebsiteLabel.text = NSLocalizedString(@"Official website: ", @"Official website: ");
        officialWebsiteLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        [self.view addSubview:officialWebsiteLabel];
        [officialWebsiteLabel release];
        
        UILabel *officialQQqunLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, pointY+44.0f, 140.0f, 21.0f)];
        officialQQqunLabel.backgroundColor = [UIColor clearColor];
        officialQQqunLabel.text = NSLocalizedString(@"Official BBS: ", @"Official BBS: ");
        officialQQqunLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        //[self.view addSubview:officialQQqunLabel];
        [officialQQqunLabel release];
    }
    
    UILabel *officialWeiBoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, pointY+66.0f, 140.0f, 21.0f)];
    officialWeiBoLabel.backgroundColor = [UIColor clearColor];
    officialWeiBoLabel.text = NSLocalizedString(@"Sina weibo: ", @"Sina weibo: ");
    officialWeiBoLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    //[self.view addSubview:officialWeiBoLabel];
    [officialWeiBoLabel release];    
    
    UILabel *officialBoKeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, pointY+88.0f, 140.0f, 21.0f)];
    officialBoKeLabel.backgroundColor = [UIColor clearColor];
    officialBoKeLabel.text = NSLocalizedString(@"Tencent weibo: ", @"Tencent weibo: ");
    officialBoKeLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    //[self.view addSubview:officialBoKeLabel];
    [officialBoKeLabel release];

    //UILabel *developerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, pointY+110.0f, 210.0f, 21.0f)];
//    UILabel *developerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, pointY+66.0f, 210.0f, 21.0f)];
//    developerLabel.backgroundColor = [UIColor clearColor];
//    developerLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"We chat public account: ", @"We chat public account: "), @"云通" ];
//    developerLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
//    [self.view addSubview:developerLabel];
//    [developerLabel release];
}

- (void)CreateProductBtn
{
    CGFloat pointY = DeclareLabel.frame.origin.y + DeclareLabel.frame.size.height-10;
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    if ([appDelegate ShowAllFeatures]) {
        //创建打开官网按钮
        UIButton *officialWebSiteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        officialWebSiteBtn.frame = CGRectMake(85.0f, pointY+22.0f, 160.0f, 21.0f);
        [officialWebSiteBtn setTitle:kOfficialWebsite forState:UIControlStateNormal];
        [officialWebSiteBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        officialWebSiteBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        officialWebSiteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.view addSubview:officialWebSiteBtn];
        [officialWebSiteBtn addTarget:self action:@selector(OpenOfficialWebSite:)  forControlEvents:UIControlEventTouchUpInside];
        
        //创建打开官网论坛按钮
        UIButton *officialBBSbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        officialBBSbtn.frame = CGRectMake(85.0f, pointY+44.0f, 180.0f, 21.0f);
        [officialBBSbtn setTitle:kOfficialBBS forState:UIControlStateNormal];
        [officialBBSbtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        officialBBSbtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        officialBBSbtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //[self.view addSubview:officialBBSbtn];
        [officialBBSbtn addTarget:self action:@selector(OpenOfficialBBS:)  forControlEvents:UIControlEventTouchUpInside];
    }
    
    //创建打开新浪微博按钮
    UIButton *SinaWeiBoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    SinaWeiBoBtn.frame = CGRectMake(85.0f, pointY+66.0f, 160.0f, 21.0f);
    
    [SinaWeiBoBtn setTitle:kSinaWeiBo forState:UIControlStateNormal];
    [SinaWeiBoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    SinaWeiBoBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    SinaWeiBoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //[self.view addSubview:SinaWeiBoBtn];
    [SinaWeiBoBtn addTarget:self action:@selector(OpenSinaWeiBo:)  forControlEvents:UIControlEventTouchUpInside];
    
    //创建打开腾讯微博按钮
    UIButton *TencnetWeiBoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    TencnetWeiBoBtn.frame = CGRectMake(85.0f, pointY+88.0f, 150.0f, 21.0f);
    
    [TencnetWeiBoBtn setTitle:kTencnetWeiBo forState:UIControlStateNormal];
    [TencnetWeiBoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    TencnetWeiBoBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    TencnetWeiBoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //[self.view addSubview:TencnetWeiBoBtn];
    [TencnetWeiBoBtn addTarget:self action:@selector(OpenTencnetWeiBo:)  forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)OnDeclareBtnClick:(id)sender
{
    DeclareViewController * DelareViewCtrl = [[DeclareViewController alloc] initWithNibName:@"DeclareViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:DelareViewCtrl animated:YES];
    [DelareViewCtrl release];
}


- (void)OpenOfficialWebSite:(id)sender
{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kOfficialWebsite]];
    [self OpenWebBrowser:kOfficialWebsite];
}

- (void)OpenOfficialBBS:(id)sender
{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kOfficialBBS]];
    [self OpenWebBrowser:kOfficialBBS];
}

- (void)OpenSinaWeiBo:(id)sender
{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kSinaWeiBo]];
    [self OpenWebBrowser:kSinaWeiBo];
}

- (void)OpenTencnetWeiBo:(id)sender
{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTencnetWeiBo]];
    [self OpenWebBrowser:kTencnetWeiBo];
}

- (void)OpenWebBrowser:(NSString *)url
{
    WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
    webBrowser.mode = TSMiniWebBrowserModeNavigation;
    
    webBrowser.barStyle = UIStatusBarStyleDefault;
    webBrowser.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webBrowser animated:YES];
    
    [webBrowser release];
}

@end
