//
//  WebBrowser.m
//  WebBrowserDemo
//
//  Created by Toni Sala Echaurren on 18/01/12.
//  Copyright 2012 Toni Sala. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "WebBrowser.h"
#import "MobClick.h"
#import "CloudCall2AppDelegate.h"
#import "ReChargeViewController.h"
#import "CloudCall2AppDelegate.h"

@implementation WebBrowser

@synthesize delegate;
@synthesize mode;
@synthesize type;
@synthesize showURLStringOnActionSheetTitle;
@synthesize showPageTitleOnTitleBar;
@synthesize showReloadButton;
@synthesize showActionButton;
@synthesize barStyle;
@synthesize barTintColor;
@synthesize domainLockList;
@synthesize currentURL;
@synthesize m_urlString;
@synthesize showToolBarBtn;

#define kToolBarHeight  44
#define kTabBarHeight   49

enum actionSheetButtonIndex {
	kSafariButtonIndex,
	kChromeButtonIndex,
};

#pragma mark - Private Methods

-(void)setTitleBarText:(NSString*)pageTitle {
    if (mode == TSMiniWebBrowserModeModal) {
        navigationBarModal.topItem.title = pageTitle;
        
    } else if(mode == TSMiniWebBrowserModeNavigation) {
        
        if(pageTitle)
            [[self navigationItem] setTitle:pageTitle];
    }
}

-(void) toggleBackForwardButtons {
    buttonGoBack.enabled = webView.canGoBack;
    buttonGoForward.enabled = webView.canGoForward;
}

-(void)showActivityIndicators {
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)hideActivityIndicators {
    [activityIndicator setHidden:YES];
    [activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void) dismissController {
    if ( webView.loading ) {
        [webView stopLoading];
    }
    if (mode == TSMiniWebBrowserModeModal)
    {
        [self dismissModalViewControllerAnimated:YES];
        if ([[CloudCall2AppDelegate sharedInstance] audioCallController].isAdClick == YES)
            [[CloudCall2AppDelegate sharedInstance] audioCallController].isAdClick = NO;
            
    }
    else if (mode == TSMiniWebBrowserModeNavigation)
        [self.navigationController popViewControllerAnimated:YES];
    
    // Notify the delegate
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(tsMiniWebBrowserDidDismiss)]) {
        [delegate tsMiniWebBrowserDidDismiss];
    }
}

-(void)onBtnRechargeDirectly
{
    ReChargeViewController *rechargeViewController = [[[ReChargeViewController alloc] initWithNibName:@"ReChargeViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:rechargeViewController animated:YES];
}

- (void)toolbarAndNavigationBarShow
{
    if (toolBar.hidden == YES && isDragButton == NO)
    {
        showToolBarBtn.hidden = YES;
        toolBar.hidden = NO;
        
        CGFloat height = SystemVersion>=7 ? (self.view.frame.size.height-toolBar.frame.size.height-64) : (self.view.frame.size.height-toolBar.frame.size.height-self.navigationController.navigationBar.frame.size.height);
        
        if (mode == TSMiniWebBrowserModeModal)
        {
            navigationBarModal.hidden = NO;
            webView.frame = CGRectMake(0, SystemVersion>=7 ? kToolBarHeight+20 : kToolBarHeight, 320, height);
        }
        else if(mode == TSMiniWebBrowserModeNavigation)
        {
            [self.navigationController setNavigationBarHidden: NO];
            webView.frame = CGRectMake(0, 0, 320, height);
        }

    }
    isDragButton = NO;
    
}

-(void) handleSingleTap:(UITapGestureRecognizer *)recognizer  {
    if (toolBar.hidden == NO)
    {
        [UIView beginAnimations:@"toolbarShowAndHide"context:nil];//动画开始
        [UIView setAnimationDuration:0.30];
        
        showToolBarBtn.hidden = NO;
        toolBar.hidden = YES;
        if (mode == TSMiniWebBrowserModeNavigation)
        {
            [self.navigationController setNavigationBarHidden: YES];
        }
        else if(mode == TSMiniWebBrowserModeModal)
        {
            navigationBarModal.hidden = YES;
        }
        webView.frame = CGRectMake(0, SystemVersion>=7 ? 20 : 0, 320, SystemVersion>=7?(self.view.frame.size.height-20):self.view.frame.size.height);
        
        [UIView commitAnimations];
    }
    
    
    // Your code here
}

-(void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
    isDragButton = YES;
    
    // get the touch
    UITouch *touch = [[event touchesForView:button] anyObject];
    
    // get delta
    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;
    
    CGFloat new_x = button.center.x + delta_x;
    CGFloat new_y = button.center.y + delta_y;
    
    if (new_x <= 0)
        new_x = 10;
    else if (new_x >= 320)
        new_x = 310;
    
    if (new_y <= 20)
        new_y = 20;
    else if (new_y >= (self.view.frame.size.height-20))
        new_y = self.view.frame.size.height - 20;
    
    // move button
    button.center = CGPointMake(new_x, new_y);
}

//Added in the dealloc method to remove the webview delegate, because if you use this in a navigation controller
//WebBrowser can get deallocated while the page is still loading and the web view will call its delegate-- resulting in a crash
-(void)dealloc
{
    [webView setDelegate:nil];
    [webView release];
    [toolBar release];
    [navigationBarModal release];
    [activityIndicator release];
    [buttonGoBack release];
    [buttonGoForward release];
    [domainLockList release];
    [currentURL release];
    [showToolBarBtn release];
    
    [super dealloc];
}

#pragma mark - Init

// This method is only used in modal mode
-(void) initTitleBar {
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(10, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(dismissController) forControlEvents: UIControlEventTouchUpInside];
    
    if (mode == TSMiniWebBrowserModeNavigation)
    {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
        
        //网络异常
        if(type == TSMiniWebBrowserTypeNetworkExc)
        {
            if ([CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_BAIDU  || [CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_91DIANJIN) {
                //                [AderSDK stopAdService];
            }
        }
        
        //普通充值
        if (type == TSMiniWebBrowserTypeRecharge) {
            UIButton *btnRechargeDirectly = [UIButton buttonWithType:UIButtonTypeCustom];
            btnRechargeDirectly.frame = CGRectMake(0, 0, 61, 28);
            [btnRechargeDirectly setTitle:NSLocalizedString(@"Prepaid directly", @"Prepaid directly") forState:UIControlStateNormal];
            [btnRechargeDirectly setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnRechargeDirectly.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
            [btnRechargeDirectly setBackgroundImage:[UIImage imageNamed:@"reconnect_up.png"] forState:UIControlStateNormal];
            [btnRechargeDirectly setBackgroundImage:[UIImage imageNamed:@"reconnect_down.png"] forState:UIControlStateHighlighted];
            [btnRechargeDirectly addTarget:self action:@selector(onBtnRechargeDirectly) forControlEvents: UIControlEventTouchUpInside];
            
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btnRechargeDirectly] autorelease];
        }
    }
    else if(mode == TSMiniWebBrowserModeModal)
    {
        UINavigationItem *titleBar = [[[UINavigationItem alloc] initWithTitle:@""] autorelease];
        titleBar.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];;
        CGFloat width = self.view.frame.size.width;
        navigationBarModal = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, SystemVersion>=7.0?20:0, width, 44)];
        if (SystemVersion >= 5.0)
        {    //ios5 新特性
            //设置title颜色,字体,阴影等
            UIColor *cc = [UIColor whiteColor];
            UIFont *font = [UIFont systemFontOfSize:17];
            NSValue *value = [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)];
            NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   cc, UITextAttributeTextColor,
                                   font, UITextAttributeFont,
                                   value, UITextAttributeTextShadowOffset, nil];
            navigationBarModal.titleTextAttributes = dict;
        }
        if (SystemVersion >= 7.0)
        {
            webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y+20, webView.frame.size.width, webView.frame.size.height-20);
        }
        
        //判断设备的版本
        if (SystemVersion >= 5.0)
        {    //ios5 新特性
            [navigationBarModal setBackgroundImage:[UIImage imageNamed:@"toolbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
        }
        else
        {
            navigationBarModal.tintColor = [UIColor colorWithRed:56.0/255.0 green:163.0/255.0 blue:253.0/255.0 alpha:1.0];
        }
        
        //navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        navigationBarModal.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        navigationBarModal.barStyle = barStyle;
        [navigationBarModal pushNavigationItem:titleBar animated:NO];
        
        [self.view addSubview:navigationBarModal];
    }    
}

-(void) initToolBar {
    if (mode == TSMiniWebBrowserModeNavigation) {
        self.navigationController.navigationBar.barStyle = barStyle;
    }
    
    CGSize viewSize = self.view.frame.size;
    if (mode == TSMiniWebBrowserModeTabBar) {
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -1, viewSize.width, kToolBarHeight)];
    } else {
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-kToolBarHeight, viewSize.width, kToolBarHeight)];
    }
    
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    toolBar.barStyle = barStyle;
    [self.view addSubview:toolBar];
    
    buttonGoBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTouchUp:)];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 30;
    
    buttonGoForward = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonTouchUp:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *buttonReload = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(reloadButtonTouchUp:)];
    
    UIBarButtonItem *fixedSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace2.width = 20;
    
    UIBarButtonItem *buttonAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(buttonActionTouchUp:)];
    
    // Activity indicator is a bit special
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.frame = CGRectMake(11, 7, 20, 20);
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 43, 33)];
    [containerView addSubview:activityIndicator];
    UIBarButtonItem *buttonContainer = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    
    // Add butons to an array
    NSMutableArray *toolBarButtons = [[NSMutableArray alloc] init];
    [toolBarButtons addObject:buttonGoBack];
    [toolBarButtons addObject:fixedSpace];
    [toolBarButtons addObject:buttonGoForward];
    [toolBarButtons addObject:flexibleSpace];
    [toolBarButtons addObject:buttonContainer];
    if (showReloadButton) {
        [toolBarButtons addObject:buttonReload];
    }
    if (showActionButton) {
        [toolBarButtons addObject:fixedSpace2];
        [toolBarButtons addObject:buttonAction];
    }
    
    // Set buttons to tool bar
    [toolBar setItems:toolBarButtons animated:YES];
	
    [fixedSpace release];
    [flexibleSpace release];
    [buttonReload release];
    [fixedSpace2 release];
    [buttonAction release];
    [buttonContainer release];
    [containerView release];
    [toolBarButtons release];
    
	// Tint toolBar
	[toolBar setTintColor:barTintColor];
}

-(void) initWebView {
    CGSize viewSize = self.view.frame.size;
    if (mode == TSMiniWebBrowserModeModal) {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kToolBarHeight, viewSize.width, viewSize.height-kToolBarHeight*2)];
    } else if(mode == TSMiniWebBrowserModeNavigation) {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, viewSize.width, viewSize.height-kToolBarHeight)];
    } else if(mode == TSMiniWebBrowserModeTabBar) {
        self.view.backgroundColor = [UIColor redColor];
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kToolBarHeight-1, viewSize.width, viewSize.height-kToolBarHeight+1)];
    }
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    
    webView.scalesPageToFit = YES;
    
    webView.delegate = self;
    
    // Load the URL in the webView
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlToLoad];
    [webView loadRequest:requestObj];
}

#pragma mark -

- (id)initWithUrl:(NSURL*)url {
    self = [self init];
    if(self)
    {
        urlToLoad = url;
        m_urlString = [url absoluteString];
        
        // Defaults
        mode = TSMiniWebBrowserModeNavigation;
        showURLStringOnActionSheetTitle = YES;
        showPageTitleOnTitleBar = YES;
        showReloadButton = YES;
        showActionButton = YES;
        forcedTitleBarText = nil;
        barStyle = UIStatusBarStyleDefault;
		barTintColor = nil;
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Main view frame.
    if (mode == TSMiniWebBrowserModeTabBar) {
        CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height - kTabBarHeight;
        if (![UIApplication sharedApplication].statusBarHidden) {
            viewHeight -= [UIApplication sharedApplication].statusBarFrame.size.height;
        }
        self.view.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    }
    
    // Store the current navigationBar bar style to be able to restore it later.
    if (mode == TSMiniWebBrowserModeNavigation) {
        originalBarStyle = self.navigationController.navigationBar.barStyle;
    }
    
    // Init tool bar
    [self initToolBar];
    
    // Init web view
    [self initWebView];
    
    // Init title bar if presented modally
    [self initTitleBar];
    
    // Status bar style
    
    //toolbar show button
    self.showToolBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showToolBarBtn setImage:[UIImage imageNamed:@"toolbar_show_Btn"] forState:UIControlStateNormal];
    [showToolBarBtn addTarget:self action:@selector(toolbarAndNavigationBarShow) forControlEvents:UIControlEventTouchUpInside];
    // add drag listener
    [showToolBarBtn addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    showToolBarBtn.frame = CGRectMake(270, iPhone5?(SystemVersion>=7 ? 518 : 498):(SystemVersion>=7 ? 430 : 410), 40, 40);
    showToolBarBtn.hidden = YES;
    [self.view addSubview:showToolBarBtn];
    
    //singleTap
    UITapGestureRecognizer* singleTap=[[UITapGestureRecognizer
                                        alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTouchesRequired=1;
    singleTap.delegate=self;
    [webView addGestureRecognizer:singleTap];
    [singleTap release];
    
    // UI state
    buttonGoBack.enabled = NO;
    buttonGoForward.enabled = NO;
    if (forcedTitleBarText != nil) {
        [self setTitleBarText:forcedTitleBarText];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"WebBrowser"];
    if (SystemVersion >= 5.0)
    {
        for (id subview in self.view.subviews)
        {
            if ([subview isKindOfClass: [UIWebView class]])
            {
                UIWebView *sv = subview;
                [sv.scrollView setScrollsToTop:NO];
            }
        }
        [webView.scrollView setScrollsToTop:YES];
    }
	if (mode == TSMiniWebBrowserModeNavigation)
        [self.navigationController setNavigationBarHidden:NO];
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self handleSingleTap:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"WebBrowser"];
    
    // Restore navigationBar bar style.
    if (mode == TSMiniWebBrowserModeNavigation) {
        self.navigationController.navigationBar.barStyle = originalBarStyle;
    }
    
    //网络异常
    if(type == TSMiniWebBrowserTypeNetworkExc)
    {
        if ([CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_BAIDU || [CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_91DIANJIN) {
            //[AderSDK setAdsViewPoint:CGPointMake(0, -100)];
            //            [AderSDK stopAdService];
        }
    }
    
    // Restore Status bar style
    [[UIApplication sharedApplication] setStatusBarStyle:(UIStatusBarStyle)originalBarStyle animated:NO];
    
    // Stop loading
    [webView stopLoading];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

/* Fix for landscape + zooming webview bug.
 * If you experience perfomance problems on old devices ratation, comment out this method.
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGFloat ratioAspect = webView.bounds.size.width/webView.bounds.size.height;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            // Going to Portrait mode
            for (UIScrollView *scroll in [webView subviews]) { //we get the scrollview
                // Make sure it really is a scroll view and reset the zoom scale.
                if ([scroll respondsToSelector:@selector(setZoomScale:)]){
                    scroll.minimumZoomScale = scroll.minimumZoomScale/ratioAspect;
                    scroll.maximumZoomScale = scroll.maximumZoomScale/ratioAspect;
                    [scroll setZoomScale:(scroll.zoomScale/ratioAspect) animated:YES];
                }
            }
            break;
        default:
            // Going to Landscape mode
            for (UIScrollView *scroll in [webView subviews]) { //we get the scrollview
                // Make sure it really is a scroll view and reset the zoom scale.
                if ([scroll respondsToSelector:@selector(setZoomScale:)]){
                    scroll.minimumZoomScale = scroll.minimumZoomScale *ratioAspect;
                    scroll.maximumZoomScale = scroll.maximumZoomScale *ratioAspect;
                    [scroll setZoomScale:(scroll.zoomScale*ratioAspect) animated:YES];
                }
            }
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - Action Sheet

- (void)showActionSheet {
    NSString *urlString = @"";
    if (showURLStringOnActionSheetTitle) {
        NSURL* url = [webView.request URL];
        urlString = [url absoluteString];
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = urlString;
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", nil)];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
        // Chrome is installed, add the option to open in chrome.
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Chrome", nil)];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    if (mode == TSMiniWebBrowserModeTabBar) {
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
    //else if (mode == TSMiniWebBrowserModeNavigation && [self.navigationController respondsToSelector:@selector(tabBarController)]) {
    else if (mode == TSMiniWebBrowserModeNavigation && self.navigationController.tabBarController != nil) {
        [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    }
    else {
        [actionSheet showInView:self.view];
    }
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    
    NSURL *theURL = [webView.request URL];
    if (theURL == nil || [theURL isEqual:[NSURL URLWithString:@""]]) {
        theURL = [NSURL URLWithString:m_urlString];
    }
    
    if (buttonIndex == kSafariButtonIndex) {
        [[UIApplication sharedApplication] openURL:theURL];
    }
    else if (buttonIndex == kChromeButtonIndex) {
        NSString *scheme = theURL.scheme;
        
        // Replace the URL Scheme with the Chrome equivalent.
        NSString *chromeScheme = nil;
        if ([scheme isEqualToString:@"http"]) {
            chromeScheme = @"googlechrome";
        } else if ([scheme isEqualToString:@"https"]) {
            chromeScheme = @"googlechromes";
        }
        
        // Proceed only if a valid Google Chrome URI Scheme is available.
        if (chromeScheme) {
            NSString *absoluteString = [theURL absoluteString];
            NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
            NSString *urlNoScheme = [absoluteString substringFromIndex:rangeForScheme.location];
            NSString *chromeURLString = [chromeScheme stringByAppendingString:urlNoScheme];
            NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
            
            // Open the URL with Chrome.
            [[UIApplication sharedApplication] openURL:chromeURL];
        }
    }
}

#pragma mark - Actions

- (void)backButtonTouchUp:(id)sender {
    [webView goBack];
    
    [self toggleBackForwardButtons];
}

- (void)forwardButtonTouchUp:(id)sender {
    [webView goForward];
    
    [self toggleBackForwardButtons];
}

- (void)reloadButtonTouchUp:(id)sender {
    [webView reload];
    
    [self toggleBackForwardButtons];
}

- (void)buttonActionTouchUp:(id)sender {
    [self showActionSheet];
}

#pragma mark - Public Methods

- (void)setFixedTitleBarText:(NSString*)newTitleBarText {
    forcedTitleBarText = newTitleBarText;
    showPageTitleOnTitleBar = NO;
}

- (void)loadURL:(NSURL*)url {
    [webView loadRequest: [NSURLRequest requestWithURL: url]];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[request.URL absoluteString] hasPrefix:@"sms:"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
	
	else
	{
		if ([[request.URL absoluteString] hasPrefix:@"http://www.youtube.com/v/"] ||
			[[request.URL absoluteString] hasPrefix:@"http://itunes.apple.com/"] ||
			[[request.URL absoluteString] hasPrefix:@"http://phobos.apple.com/"]) {
			[[UIApplication sharedApplication] openURL:request.URL];
			return NO;
		}
		
		else
		{
            if (domainLockList == nil || [domainLockList isEqualToString:@""])
            {
				if (navigationType == UIWebViewNavigationTypeLinkClicked)
				{
					self.currentURL = request.URL.absoluteString;
				}
                
                return YES;
            }
            
            else
            {
                NSArray *domainList = [domainLockList componentsSeparatedByString:@","];
                BOOL sendToSafari = YES;
                
                for (int x = 0; x < domainList.count; x++)
                {
                    if ([[request.URL absoluteString] hasPrefix:(NSString *)[domainList objectAtIndex:x]] == YES)
                    {
                        sendToSafari = NO;
                    }
                }
				
                if (sendToSafari == YES)
                {
                    [[UIApplication sharedApplication] openURL:[request URL]];
                    
                    return NO;
                }
                
                else
                {
					if (navigationType == UIWebViewNavigationTypeLinkClicked)
					{
						self.currentURL = request.URL.absoluteString;
					}
                    
                    return YES;
                }
            }
		}
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self toggleBackForwardButtons];
    
    [self showActivityIndicators];
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    // Show page title on title bar?
    if (showPageTitleOnTitleBar) {
        NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        [self setTitleBarText:pageTitle];
    }
    
    [self hideActivityIndicators];
    
    [self toggleBackForwardButtons];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideActivityIndicators];
    
    // To avoid getting an error alert when you click on a link
    // before a request has finished loading.
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
	
    // Show error alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not load page", @"Could not load page")
                                                    message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
    [alert release];
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer
                                                    *)otherGestureRecognizer {
    return YES;
}

@end
