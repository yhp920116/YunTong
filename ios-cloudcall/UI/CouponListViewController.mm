//
//  CouponListViewController.m
//  CloudCall
//
//  Created by Sergio on 13-5-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "CouponListViewController.h"
#import "GainCouponViewController.h"
#import "CouponManager.h"
#import "JSONKit.h"
#import "MyCouponViewController.h"
#import "MobClick.h"

#define CustomRowCount   8
#define CustomRowHeight  60.0f
#define AppIconWidth     70.0f
#define AppIconHeight    50.0f

static NSString *const TopPaidAppsFeed = @"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml";

@implementation CouponListViewController
@synthesize tableView;
@synthesize couponArray;
@synthesize errorMsg;

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
    
    //get location
//    CLLocationManager *lm = [[CLLocationManager alloc] init];
//    lm.delegate = self;
//    lm.desiredAccuracy = kCLLocationAccuracyBest;
//    lm.distanceFilter = kCLDistanceFilterNone;
//    [lm startUpdatingLocation];
//    CLLocation *location = [lm location];
    
    //从服务器更新数据
    NSString *user_number = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSString *user_location_longtitude = [NSString stringWithFormat:@"%f",longitude];
    NSString *user_location_latitude = [NSString stringWithFormat:@"%f",latitude];
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              user_number,              @"user_number",
                              user_location_longtitude, @"user_location_longtitude",
                              user_location_latitude,   @"user_location_latitude", nil];
    
    NSData *jsonData = [jsonDict JSONData];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.labelText = NSLocalizedString(@"Loading...", @"Loading...");
    [HUD show:YES];
    
    CouponManager *couponManager = [[[CouponManager alloc] init] autorelease];
    couponManager.delegate = self;
    [couponManager sendRequest2Server:jsonData andType:kDownloadCouponList];
    
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:10];
        
    self.navigationItem.title = NSLocalizedString(@"YunTong Coupon", @"YunTong Coupon");
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToPrevious:) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *toolBtnPocket = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBtnPocket.frame = CGRectMake(260, 28, 44, 44);
    [toolBtnPocket setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBtnPocket.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBtnPocket setBackgroundImage:[UIImage imageNamed:@"coupon_pocket_up.png"] forState:UIControlStateNormal];
    [toolBtnPocket setBackgroundImage:[UIImage imageNamed:@"coupon_pocket_down.png"] forState:UIControlStateHighlighted];
    [toolBtnPocket addTarget:self action:@selector(goToMyPocket) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBtnPocket] autorelease];
    
    /*
    classifyBtn = [[UIButton alloc] initWithFrame:CGRectMake(107, 0, 107, 35)];
    [classifyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    classifyBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [classifyBtn setTitle:@"全部分类" forState:UIControlStateNormal];
    [classifyBtn setBackgroundImage:[UIImage imageNamed:@"segment_down.png"] forState:UIControlStateNormal];
    //[classifyBtn setBackgroundImage:[UIImage imageNamed:@"coupon_pocket_down.png"] forState:UIControlStateHighlighted];
    [classifyBtn addTarget:self action:@selector(classifySelected:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolBar addSubview:classifyBtn];*/
    
    
    _lazyImages.tableView = self.tableView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [MobClick beginLogPageView:@"CouponListViewController"];

    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [MobClick endLogPageView:@"CouponListViewController"];
}

- (void)dealloc
{
    //[_lazyImages.tableView release];
    
    [classifyBtn release];
    
    [_entries release];
    [tableView release];
    [couponArray release];
    [errorMsg release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods
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

- (IBAction)classifySelected:(id)sender
{
    UIButton *Btn = (UIButton *)sender;
    /*if (Btn == classifyBtn)
     {
     DoubleTableViewController *contentViewController = [[DoubleTableViewController alloc] initWithFiltertype:YDT_Filter_Type_Category];
     contentViewController.firstcatetoryid = parentid;
     contentViewController.numTableViewController = self;
     //        contentViewController.filtertype = YDT_Filter_Type_Category;
     self.popoverController = [[[WEPopoverController alloc] initWithContentViewController:contentViewController] autorelease];
     [self.popoverController presentPopoverFromRect:Btn.frame
     inView:self.view
     permittedArrowDirections:UIPopoverArrowDirectionUp
     animated:YES];
     [contentViewController release];
     }*/
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
        
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:10];
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


/*-(void)UpdateAfterFilterSelected:(int)leftindex andRightIndex:(int)rightIndex andFilterType:(int)filtertype{
    NSString* str = @"";
    switch (filtertype) {
        case YDT_Filter_Type_District:
        {
            districtid = -1;
            //            if (leftindex >= 0)
            //            {
            //                if (index == 0)
            //                {
            //                    str = @"全部地区";
            //                }
            //                else
            //                {
            //                    int i = leftindex * 2 - 1;
            //                    YDTDistrict* d = [districts objectAtIndex:i];
            //                    str = d.name;
            //                    districtid = d.myid;
            //                }
            //            }
            //            else if (rightIndex >= 0)
            //            {
            //                int i = rightIndex * 2;
            //                YDTDistrict* d = [districts objectAtIndex:i];
            //                str = d.name;
            //                districtid = d.myid;
            //            }
            
            if (leftindex == 0) {
                str = @"全部地区";
            } else {
                YDTDistrict* d = [districts objectAtIndex:leftindex-1];
                str = d.name;
                districtid = d.myid;
            }
            
            [self.regionBtn setTitle:str forState:UIControlStateNormal];
            
            [shops removeAllObjects];
            startOffset = 0;
            
            [self dataLoading];
            
            break;
        }
        case YDT_Filter_Type_Category:
        {
            //            categoryid = -1;
            if (rightIndex == 0)
            {
                YDTCategory* yc = [firstCategories objectAtIndex:leftindex];
                categoryid = yc.myid;
                str = yc.name;
            }
            else
            {
                YDTCategory* yc = [secondCategories objectAtIndex:rightIndex-1];
                categoryid = yc.myid;
                str = yc.name;
            }
            
            [self.classifyBtn setTitle:str forState:UIControlStateNormal];
            if (fromSearchView == NO)
            {
                self.title = str;
            }
            
            [shops removeAllObjects];
            startOffset = 0;
            [self dataLoading];
            
            break;
        }
        case YDT_Filter_Type_Sort:
        {
            NSArray* a = [sorttypies objectAtIndex:leftindex];
            sorttype = [[a objectAtIndex:0] intValue];
            str = [a objectAtIndex:1];
            
            [self.sortBtn setTitle:str forState:UIControlStateNormal];
            
            [shops removeAllObjects];
            startOffset = 0;
            [self dataLoading];
            
            break;
        }
            
        default:
            break;
    }
}*/

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
    GainCouponViewController* iv = [[GainCouponViewController alloc] initWithNibName:@"GainCouponViewController" bundle:[NSBundle mainBundle]];
    CouponData *oldCouponData = [couponArray objectAtIndex:indexPath.row];
    CouponManager *couponManager = [[CouponManager alloc] init];
    CouponData *couponData = [couponManager dbLoadCouponDataByCouponId:oldCouponData.coupon_id andWho:oldCouponData.coupon_who];
    iv.couponData = couponData;
    iv.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:iv animated:YES];
    [iv release];
    [couponManager release];
}

#pragma mark
#pragma mark CouponManagerDelegate
- (void)shouldContinueAfterGetCouponsDataFromNet:(NSMutableDictionary *)userInfo;
{
    [self hideHUD];
    [self.couponArray removeAllObjects];
    
    CouponManager *couponManager = [[CouponManager alloc] init];
    
    NSMutableArray *localDBArray = [[NSMutableArray alloc] initWithArray:[couponManager dbLoadCouponData:kDBLoadAllCouponsData]];
    self.couponArray = localDBArray;
    
    if ([couponArray count] == 0)
    {
        tableView.hidden = YES;
        if (![[NgnEngine sharedInstance].networkService isReachable])
            self.errorMsg.text = NSLocalizedString(@"Fail to get coupons info", @"Fail to get coupons info");
        else
            self.errorMsg.text = NSLocalizedString(@"There is no coupon now", @"There is no coupon now");
        
    }
    else
        [self.tableView reloadData];
    
    [localDBArray release];
    [couponManager release];
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

#pragma mark
#pragma mark CLLocationManagerDelegate
-(void) locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *) newLocation
           fromLocation: (CLLocation *) oldLocation
{
    longitude = newLocation.coordinate.longitude;
    latitude = newLocation.coordinate.latitude;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    longitude = 0.0;
    latitude = 0.0;
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

@end
