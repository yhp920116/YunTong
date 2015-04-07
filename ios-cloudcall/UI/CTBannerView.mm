//

#import "CTBannerView.h"
#import "CloudCall2AppDelegate.h"
#import "WebBrowser.h"

NSString* ad_banner_list_file = @"ctbanner.plist";

@interface CTBannerView(Private)

-(NSString*)getAdsDirectoryPath;

-(CCAdsData*)GetCurrAdData;

-(void)updateBannerDisplay;

- (void) adButtonClick: (id)sender;
- (void) GotoWebSite;
@end

@implementation CTBannerView(Private)

-(NSString*)getAdsDirectoryPath{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    return [dir stringByAppendingPathComponent:@"CTBannerAds"];
}

-(CCAdsData*)GetCurrAdData {
    if (!adsArray || [adsArray count] == 0)
        return nil;
    
    if (currAdIndex >= [adsArray count])
        currAdIndex = 0;
    CCAdsData* a = [adsArray objectAtIndex:currAdIndex];
    
    currAdIndex++;
    
    return a;
}

-(void)updateBannerDisplay{
//    NSString* file = [[self getAdsDirectoryPath] stringByAppendingPathComponent:ad_banner_list_file];
//    self.adsArray = [AdResourceManager LoadAdsDataFromFile:file];
    
    [adsArray removeAllObjects];
    AdResourceManager *manager = [[AdResourceManager alloc] init];
    [manager dbLoadAdsData:adsArray andMyIndex:ADSMyindexBanner];

    adid = 9999;
    actionType = 1;
    if (CCAdsData* adsData = [self GetCurrAdData]) {
        adid = adsData.adid;
        actionType = adsData.clickAction;
        NSString *bannerDir = [self getAdsDirectoryPath];
        NSString *imagePath = [bannerDir stringByAppendingPathComponent: [adsData.image lastPathComponent]];
        NSData* imgData = [[[NSData alloc] initWithContentsOfFile:imagePath] autorelease];
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData];
            [imgView setImage:image];
        }
        
        if (imgAdUrl) {
            [imgAdUrl release];
            imgAdUrl = nil;
        }
        
        imgAdUrl = [[NSString alloc] initWithString:adsData.clickurl];
        
        //在前台时才算符合条件
        if ([CloudCall2AppDelegate sharedInstance].isCountBanner)
        {
            //广告统计计数
            [manager updateData:adid andType:ADStatisticsUpdateTypeShow];
        }
    }
    [manager release];
}

- (void) adButtonClick: (id)sender{
    [self GotoWebSite];
}

- (void) GotoWebSite {
    if (imgAdUrl && [imgAdUrl length] && adid != 9999) {
        //广告点击计数
        AdResourceManager *manager = [[AdResourceManager alloc] init];
        [manager updateData:adid andType:ADStatisticsUpdateTypeClick];
        [manager release];
        CCLog(@"%@", imgAdUrl);
        
        if (actionType == ADActionTypeOpenInnerBrowser) {
            [self OpenWebBrowser:imgAdUrl];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[imgAdUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
    
    }
}

- (void)OpenWebBrowser:(NSString *)url
{
    WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
    webBrowser.mode = TSMiniWebBrowserModeModal;
    
    webBrowser.barStyle = UIStatusBarStyleDefault;
    webBrowser.hidesBottomBarWhenPushed = YES;
    [[CloudCall2AppDelegate sharedInstance].tabBarController presentModalViewController:webBrowser animated:YES];
    
    [webBrowser release];
}

@end

@implementation CTBannerView
@synthesize adsArray;

-(CTBannerView*)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        buttonAd = [[UIButton alloc] initWithFrame:frame];        
        [buttonAd addTarget:self action:@selector(adButtonClick:) forControlEvents: UIControlEventTouchUpInside];
        [self addSubview:buttonAd];
        
        imgView = [[UIImageView alloc] initWithFrame:frame];
        [imgView setImage:[UIImage imageNamed:@"adbanner.png"]];
        [self addSubview:imgView];
        
        self.adsArray = [NSMutableArray arrayWithCapacity:10];
//        labelCT = [[UILabel alloc] initWithFrame:CGRectMake(270,0,50,20)];
//        labelCT.font = [UIFont systemFontOfSize:10.0];
//        [labelCT setBackgroundColor:[UIColor clearColor]];
//        [labelCT setText:@"CloudTech"];
//        [labelCT setTextColor:[UIColor whiteColor]];
//        [self addSubview:labelCT];
    }
    return self;
}

-(void)dealloc {
    [imgView release];
//    [labelCT release];
    if (adsArray) {
        [adsArray release];
        adsArray = nil;
    }
    
    if (refreshTimer) {
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
    
    if (imgAdUrl) {
        [imgAdUrl release];
        imgAdUrl = nil;
    }
    
    [super dealloc];
}

-(void)bannerViewShow {
    show = YES;
    
    if (refreshTimer) {
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateBannerDisplay) userInfo:nil repeats:YES];
    
    [self updateBannerDisplay];
}

-(void)bannerViewHide {
    show = NO;
    if (refreshTimer) {
        [refreshTimer invalidate];
        refreshTimer = nil;
    }    
}

// AdResourceManagerDelegate
-(void) shouldContinueAfterGetAdDataFromNet
{
    [adsArray removeAllObjects];
    AdResourceManager *manager = [[AdResourceManager alloc] init];
    [manager dbLoadAdsData:adsArray andMyIndex:ADSMyindexBanner];
    [manager release];
    
    if (show) {
        [self updateBannerDisplay];
    }
}


@end
