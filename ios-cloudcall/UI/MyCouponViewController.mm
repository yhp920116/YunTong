//
//  CouponListViewController.m
//  CloudCall
//
//  Created by Sergio on 13-5-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "MyCouponViewController.h"
#import "CouponListViewController.h"
#import "GainCouponViewController.h"
#import "CouponManager.h"
#import "JSONKit.h"
#import "MobClick.h"

#define CustomRowCount   8
#define CustomRowHeight  60.0f
#define AppIconWidth     70.0f
#define AppIconHeight    50.0f

static NSString *const TopPaidAppsFeed = @"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml";

@implementation MyCouponViewController
@synthesize tableView;
@synthesize couponArray;
@synthesize errorMsg;

@synthesize couponid;

#pragma mark
#pragma mark View Liftcycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _lazyImages = [[MHLazyTableImages alloc] init];
		_lazyImages.placeholderImage = [UIImage imageNamed:@"coupon_default.png"];
		_lazyImages.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.couponArray = [NSMutableArray arrayWithCapacity:10];
    
    //从服务器更新数据
    NSString *user_number = [[CloudCall2AppDelegate sharedInstance] getUserName];
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:user_number, @"user_number", nil];
    
    NSData *jsonData = [jsonDict JSONData];
    
    CouponManager *couponManager = [[[CouponManager alloc] init] autorelease];
    couponManager.delegate = self;
    [couponManager sendRequest2Server:jsonData andType:kDownloadCollectCoupons];
    
    //是否需要重新加载数据
    [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_NEEDTORELOADDATA andValue:NO];
    
    self.navigationItem.title = NSLocalizedString(@"My Pocket", @"My Pocket");
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToPrevious:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    _lazyImages.tableView = self.tableView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [MobClick beginLogPageView:@"MyCouponViewController"];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    //是否需要重新加载数据,主要是用于显示优惠券是否已使用
    BOOL needToReloadData = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_NEEDTORELOADDATA];
    if (needToReloadData)
    {
        [self refreshTableViewData];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [MobClick endLogPageView:@"MyCouponViewController"];
}

- (void)dealloc
{
    //[_lazyImages.tableView release];
    [_entries release];
    [tableView release];
    [couponArray release];
    [errorMsg release];
    [couponid release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods
- (void)refreshTableViewData
{
    [self.couponArray removeAllObjects];
    
    CouponManager *couponManager = [[CouponManager alloc] init];
    
    NSString *user_number = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSMutableArray *localDBArray = [[NSMutableArray alloc] initWithArray:[couponManager dbLoadCouponData:user_number]];
    self.couponArray = localDBArray;
    
    if ([couponArray count] == 0)
    {
        tableView.hidden = YES;
        if (![[NgnEngine sharedInstance].networkService isReachable])
            self.errorMsg.text = NSLocalizedString(@"Fail to get coupons info", @"Fail to get coupons info");
        else
            self.errorMsg.text = NSLocalizedString(@"You have no coupon", @"You have no coupon");
        
    }
    else
        [self.tableView reloadData];
    
    //是否需要重新加载数据
    [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_NEEDTORELOADDATA andValue:NO];
    
    [localDBArray release];
    [couponManager release];
}

/**
 *	@brief	查看我的优惠券
 */
- (void)goToMyPocket
{
    MyCouponViewController *myCoupon = [[MyCouponViewController alloc] initWithNibName:@"MyCouponViewController" bundle:nil];
    [self.navigationController pushViewController:myCoupon animated:YES];
    [myCoupon release];
    
}

- (void)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setEntries:(NSArray *)entries
{
	_entries = [entries retain];
	[self.tableView reloadData];
}

- (void)setImageForCellAtIndexPathBelowIOS5:(NSIndexPath *)indexPath
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    UIImage *couponImg = [self loadImageFromNetForCellAtIndexPath:indexPath];
    
    if (couponImg) {
        CGSize size = CGSizeMake(AppIconWidth, AppIconHeight);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
        CGRect imageRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        [couponImg drawInRect:imageRect];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        UITableViewCell *tableViewCell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        UIImageView *cellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 4, AppIconWidth, AppIconHeight)];
        cellImageView.contentMode = UIViewContentModeScaleAspectFit;
        [cellImageView setBackgroundColor:[UIColor clearColor]];
        [tableViewCell insertSubview:cellImageView aboveSubview:tableViewCell.imageView];
        [cellImageView performSelectorOnMainThread:@selector(setImage:) withObject:newImage waitUntilDone:NO];
        
        [cellImageView release];
    }
    
    [pool release];
    
}

- (UIImage *)loadImageFromNetForCellAtIndexPath:(NSIndexPath *)indexPath
{
    CouponData *couponData = [couponArray objectAtIndex:indexPath.row];
    NSString *imgUrl = couponData.coupon_thumbnail_url;
    
    NSData* imageData = [[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imgUrl]] autorelease];
    UIImage *couponImage;
    if (imageData)
    {
        couponImage = [UIImage imageWithData:imageData];
        CloudCall2AppDelegate *appDelegate = (CloudCall2AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *couponDir = [appDelegate GetCouponImgDirectoryPath];
        NSString *couponTypeIdComponent = [NSString stringWithFormat:@"%@_thumbnail.png",couponData.coupon_type_id];
        NSString *filePath = [couponDir stringByAppendingPathComponent:couponTypeIdComponent];
        
        //写入文件
        [imageData writeToFile:filePath atomically:YES];
        
        //更新数据库
        CouponManager *couponManager = [[CouponManager alloc] init];
        [couponManager dbUpdateCouponData:@"coupon_thumbnail_url_local" andValue:filePath andCouponID:couponData.coupon_type_id];
        [couponManager release];
        
        return couponImage;
    }
    else
        return nil;
}

#pragma mark
#pragma mark UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [self.couponArray count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *couponListCellIdentifier = @"couponListCellIdentifier";
    CouponListCell *couponListCell = (CouponListCell*)[_tableView dequeueReusableCellWithIdentifier: couponListCellIdentifier];
    if (couponListCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CouponListCell" owner:self options:nil];
        for (id oneObject in nib) {
            if ([oneObject isKindOfClass:[CouponListCell class]]) {
                couponListCell = (CouponListCell *)oneObject;
            }
        }
    }
    
    CouponData *couponData = [couponArray objectAtIndex:indexPath.row];
    [couponListCell setCoupon:couponData];
    
    [couponListCell.imageView setBackgroundColor:[UIColor clearColor]];
    //查找本地图片,如果有的话就显示,没有的话动态加载
    if (couponData.coupon_thumbnail_url_local && ![NgnStringUtils isNullOrEmpty:couponData.coupon_thumbnail_url_local])
    {
        UIImage *localImg = [UIImage imageWithContentsOfFile:couponData.coupon_thumbnail_url_local];
        if (localImg.size.height != AppIconHeight || localImg.size.width != AppIconWidth)
        {
            CGSize size = CGSizeMake(AppIconWidth, AppIconHeight);
            UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
            CGRect imageRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
            [localImg drawInRect:imageRect];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            couponListCell.imageView.image = newImage;
        }
        else
            couponListCell.imageView.image = localImg;
    }
    else
    {
        if (SystemVersion < 5.0)
        {
            UIImage *defaultImg = [UIImage imageNamed:@"coupon_default.png"];
            CGSize size = CGSizeMake(AppIconWidth, AppIconHeight);
            UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
            CGRect imageRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
            [defaultImg drawInRect:imageRect];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            couponListCell.imageView.image = newImage;
            
            [NSThread detachNewThreadSelector:@selector(setImageForCellAtIndexPathBelowIOS5:) toTarget:self withObject:indexPath];
        }
        else
            [_lazyImages addLazyImageForCell:couponListCell withIndexPath:indexPath];
    }
    
    return couponListCell;
    
}

#pragma mark
#pragma mark tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    CouponData *oldCouponData = [self.couponArray objectAtIndex:indexPath.row];
    CouponDetailViewController* iv = [[CouponDetailViewController alloc] initWithNibName:@"CouponDetailViewController" bundle:[NSBundle mainBundle]];
    iv.hidesBottomBarWhenPushed = YES;
    iv.title = NSLocalizedString(@"My Pocket", @"My Pocket");
    CouponManager *couponManager = [[CouponManager alloc] init];
    CouponData *couponData = [couponManager dbLoadCouponDataByCouponId:oldCouponData.coupon_id andWho:oldCouponData.coupon_who];
    iv.couponid = couponData.coupon_id;
    iv.coupontypeid = couponData.coupon_type_id;
    iv.picUrl = couponData.coupon_image_url;
    iv.localUrl = couponData.coupon_image_url_local;
    iv.couponTitle = couponData.coupon_name;
    iv.price = couponData.coupon_price;
    iv.detail = couponData.coupon_detail;
    //是否显示使用此券按钮
    if ([couponData.type isEqualToString:@"single"] && couponData.available)
        iv.showRightToolBtn = YES;
    //是否显示已使用
    if (couponData.available)
        iv.showImgViewPicHidden = NO;
    else
        iv.showImgViewPicHidden = YES;
    iv.isFromGainCouponPage = NO;
    [self.navigationController pushViewController:iv animated:YES];
    [iv release];
    [couponManager release];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CouponData *couponData = [self.couponArray objectAtIndex:indexPath.row];
        self.couponid = couponData.coupon_id;
        
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"My Pocket", @"My Pocket")
                                                             message:NSLocalizedString(@"Confirm to delete coupon", @"Confirm to delete coupon")
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                   otherButtonTitles:NSLocalizedString(@"OK",@"OK"), Nil]
                                  autorelease];
        alertView.tag = kTagDeleteCoupon;
        [alertView show];
    }
}

#pragma mark
#pragma mark CouponManagerDelegate
- (void)shouldContinueAfterGetCouponsDataFromNet:(NSMutableDictionary *)userInfo;
{
    NSString *type = [userInfo objectForKey:@"msgtype"];
    
    if ([type isEqualToString:kDeleteCollectCoupons])
    {
        NSString *result = [userInfo objectForKey:@"requestresult"];
        
        if ([result isEqualToString:@"success"])
        {
            //删除成功
            NSString *coupon_id = [userInfo objectForKey:@"coupon_id"];
            
            CouponManager *couponManager = [[CouponManager alloc] init];
            [couponManager dbDeleteACouponData:coupon_id andWho:@""];
            [couponManager release];
            
            [self refreshTableViewData];
        }
        else
        {
            //删除失败
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"My Pocket", @"My Pocket")
                                                                 message:NSLocalizedString(@"Fail to delete coupon", @"Fail to delete coupon")
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                       otherButtonTitles:NSLocalizedString(@"OK",@"OK"), Nil]
                                      autorelease];
            [alertView show];

        }
    }
    else
    {
        [self refreshTableViewData];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_lazyImages scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[_lazyImages scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - MHLazyTableImagesDelegate

- (NSURL *)lazyTableImages:(MHLazyTableImages *)lazyTableImages lazyImageURLForIndexPath:(NSIndexPath *)indexPath
{
	CouponData *couponData = [couponArray objectAtIndex:indexPath.row];
	return [NSURL URLWithString:couponData.coupon_thumbnail_url];
}

- (UIImage *)lazyTableImages:(MHLazyTableImages *)lazyTableImages postProcessLazyImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath
{
    if (image.size.width != AppIconWidth || image.size.height != AppIconHeight)
 		return [self scaleImage:image toSize:CGSizeMake(AppIconWidth, AppIconHeight)];
    else
        return image;
}

- (void)finishedLoadImg:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath
{
    CouponData *couponData = [couponArray objectAtIndex:indexPath.row];
    CloudCall2AppDelegate *appDelegate = (CloudCall2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *couponDir = [appDelegate GetCouponImgDirectoryPath];
    NSString *couponTypeIdComponent = [NSString stringWithFormat:@"%@_thumbnail.png",couponData.coupon_type_id];
    NSString *filePath = [couponDir stringByAppendingPathComponent:couponTypeIdComponent];
    
    //写入文件
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    //更新数据库
    CouponManager *couponManager = [[CouponManager alloc] init];
    [couponManager dbUpdateCouponData:@"coupon_thumbnail_url_local" andValue:filePath andCouponID:couponData.coupon_type_id];
    [couponManager release];
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size
{
	UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
	CGRect imageRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
	[image drawInRect:imageRect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

#pragma mark
#pragma mark alertview delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //确定删除
    if (alertView.tag == kTagDeleteCoupon && buttonIndex == 1)
    {
        //从服务器删除数据
        NSString *user_number = [[CloudCall2AppDelegate sharedInstance] getUserName];
        NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:user_number, @"user_number", couponid, @"coupon_id", nil];
        NSArray *jsonArray = [NSArray arrayWithObject:context];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:jsonArray, @"context", nil];
        
        NSData *jsonData = [jsonDict JSONData];
        
        CCLog(@"delete coupon from server jsondata:",[jsonDict JSONString]);
        
        CouponManager *couponManager = [[[CouponManager alloc] init] autorelease];
        couponManager.delegate = self;
        [couponManager sendRequest2Server:jsonData andType:kDeleteCollectCoupons];
    }
}

#pragma mark
#pragma mark ContactDialDelegate
- (void)reloadTableViewAfterUsedCoupon
{
    [self refreshTableViewData];
}

@end
