//
//  CouponDetailViewController.m
//  CloudCall
//
//  Created by Sergio on 13-5-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "CouponDetailViewController.h"
#import "JSONKit.h"
#import "MobClick.h"

@implementation CouponDetailViewController
@synthesize couponid;
@synthesize coupontypeid;
@synthesize picUrl;
@synthesize localUrl;
@synthesize couponTitle;
@synthesize price;
@synthesize detail;
@synthesize imgViewPic;
@synthesize imgViewPicHidden;
@synthesize lblTitle;
@synthesize lblPrice;
@synthesize txtViewDetail;
@synthesize showRightToolBtn;
@synthesize showImgViewPicHidden;
@synthesize isFromGainCouponPage;

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
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToPrevious:) forControlEvents: UIControlEventTouchUpInside];
    
    if (showRightToolBtn)
    {
        UIButton *toolBtnUse = [UIButton buttonWithType:UIButtonTypeCustom];
        toolBtnUse.frame = CGRectMake(260, 28, 60, 20);
        [toolBtnUse setTitle:NSLocalizedString(@"Use", @"Use") forState:UIControlStateNormal];
        [toolBtnUse setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        toolBtnUse.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        [toolBtnUse setBackgroundColor:[UIColor clearColor]];
        [toolBtnUse setBackgroundImage:[UIImage imageNamed:@"use_coupon_up.png"] forState:UIControlStateNormal];
        [toolBtnUse setBackgroundImage:[UIImage imageNamed:@"use_coupon_down.png"] forState:UIControlStateHighlighted];
        [toolBtnUse addTarget:self action:@selector(useTheTicket) forControlEvents: UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBtnUse] autorelease];
    }
    
    if (showImgViewPicHidden)
        imgViewPicHidden.hidden = NO;
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    //pic
    if (self.localUrl && ![NgnStringUtils isNullOrEmpty:self.localUrl])
    {
        self.imgViewPic.image = [UIImage imageWithContentsOfFile:self.localUrl];
    }
    else
    {
        CloudCall2AppDelegate *appDelegate = (CloudCall2AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *document = [appDelegate GetCouponImgDirectoryPath];
        NSString *imgFileName = [NSString stringWithFormat:@"%@.png",coupontypeid];
        NSString *imgFilePath = [document stringByAppendingPathComponent:imgFileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //直接文件查找本地图片
        if ([fileManager fileExistsAtPath:imgFilePath])
        {
            self.imgViewPic.image = [UIImage imageWithContentsOfFile:imgFilePath];
        }
        else
        {
        
//            NSData* imageData = [[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.picUrl]] autorelease];
//            if (imageData)
//            {
//                self.imgViewPic.image = [UIImage imageWithData:imageData];
//                
//                CloudCall2AppDelegate *appDelegate = (CloudCall2AppDelegate *)[[UIApplication sharedApplication] delegate];
//                NSString *couponDir = [appDelegate GetCouponImgDirectoryPath];
//                NSString *couponTypeIdComponent = [NSString stringWithFormat:@"%@.png",coupontypeid];
//                NSString *filePath = [couponDir stringByAppendingPathComponent:couponTypeIdComponent];
//                
//                //写入文件
//                [imageData writeToFile:filePath atomically:YES];
//                
//                //更新数据库
//                CouponManager *couponManager = [[CouponManager alloc] init];
//                [couponManager dbUpdateCouponData:@"coupon_image_url_local" andValue:filePath andCouponID:coupontypeid];
//                [couponManager release];
//            }
            [NSThread detachNewThreadSelector:@selector(loadImageInBackground) toTarget:self withObject:nil];
        }
    }
    
    //为图片增加点击事件
    imgViewPic.userInteractionEnabled = YES;
    UITapGestureRecognizer *couponImgSingleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCouponImgSingleClickEvent)];
    [imgViewPic addGestureRecognizer:couponImgSingleClick];
    [couponImgSingleClick release];
    
    self.lblTitle.text = self.couponTitle;
    self.lblPrice.text = [NSString stringWithFormat:@"￥%@", self.price];
    self.txtViewDetail.text = self.detail;
    
    if (iPhone5)
        txtViewDetail.frame = CGRectMake(txtViewDetail.frame.origin.x, txtViewDetail.frame.origin.y, txtViewDetail.frame.size.width, txtViewDetail.frame.size.height + 86);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [MobClick beginLogPageView:@"CouponDetailViewController"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [MobClick endLogPageView:@"CouponDetailViewController"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [couponid release];
    [coupontypeid release];
    [picUrl release];
    [localUrl release];
    [couponTitle release];
    [price release];
    [detail release];
    
    [imgViewPic release];
    [imgViewPicHidden release];
    [lblTitle release];
    [lblPrice release];
    [txtViewDetail release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods
- (void)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *	@brief	使用此券
 */
- (void)useTheTicket
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"My Pocket", @"My Pocket")
                                                         message:NSLocalizedString(@"Confirm to use coupon", @"Confirm to use coupon")
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               otherButtonTitles:NSLocalizedString(@"OK",@"OK"), Nil]
                              autorelease];
    alertView.tag = kTagUseTheCoupon;
    [alertView show];
}

- (void)onCouponImgSingleClickEvent
{
    if (isFromGainCouponPage)
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadImageInBackground
{
    NSData* imageData = [[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:picUrl]] autorelease];
    if (imageData)
    {
        UIImage *couponImage = [UIImage imageWithData:imageData];
        [self performSelectorOnMainThread:@selector(loadCouponImgOnMainThread:) withObject:couponImage waitUntilDone:NO];
        CloudCall2AppDelegate *appDelegate = (CloudCall2AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *couponDir = [appDelegate GetCouponImgDirectoryPath];
        NSString *couponTypeIdComponent = [NSString stringWithFormat:@"%@.png",coupontypeid];
        NSString *filePath = [couponDir stringByAppendingPathComponent:couponTypeIdComponent];
        
        //写入文件
        [imageData writeToFile:filePath atomically:YES];
        
        //更新数据库
        CouponManager *couponManager = [[CouponManager alloc] init];
        [couponManager dbUpdateCouponData:@"coupon_image_url_local" andValue:filePath andCouponID:coupontypeid];
        [couponManager release];
    }
}

- (void)loadCouponImgOnMainThread:(UIImage *)img
{
    self.imgViewPic.image = img;
}

#pragma mark
#pragma mark CouponManagerDelegate
- (void)shouldContinueAfterGetCouponsDataFromNet:(NSMutableDictionary *)userInfo;
{
    NSString *result = [userInfo objectForKey:@"requestresult"];
    
    if ([result isEqualToString:@"success"])
    {
        //更新成功
        NSString *coupon_id = [userInfo objectForKey:@"coupon_id"];
        
        CouponManager *couponManager = [[CouponManager alloc] init];
        [couponManager dbUpdateCouponDataAfterUsed:coupon_id];
        [couponManager release];
        
        //图片遮罩
        imgViewPicHidden.hidden = NO;
        
        //按钮隐藏
        self.navigationItem.rightBarButtonItem = nil;
        
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_NEEDTORELOADDATA andValue:YES];
        
    }
    else
    {
        //更新失败
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"My Pocket", @"My Pocket")
                                                             message:NSLocalizedString(@"Can't use the coupon", @"Can't use the coupon")
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                   otherButtonTitles:NSLocalizedString(@"OK",@"OK"), Nil]
                                  autorelease];
        [alertView show];
    }
}

#pragma mark
#pragma mark alertview delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //确定使用
    if (alertView.tag == kTagUseTheCoupon && buttonIndex == 1)
    {        
        NSString *user_number = [[CloudCall2AppDelegate sharedInstance] getUserName];
        NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:user_number, @"user_number", couponid, @"coupon_id", @"false", @"available", nil];
        NSArray *jsonArray = [NSArray arrayWithObject:context];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:jsonArray, @"context", nil];
        
        NSData *jsonData = [jsonDict JSONData];
        
        CouponManager *couponManager = [[[CouponManager alloc] init] autorelease];
        couponManager.delegate = self;
        [couponManager sendRequest2Server:jsonData andType:kUpdateCollectCoupons];
    }
}

@end
