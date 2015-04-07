
//

 
#import "CallFeedbackViewController.h"

/*=== CallFeedbackViewController (Private) ===*/
@interface CallFeedbackViewController(Private)
+(void) applyGradienWithColors: (NSArray*)colors forView: (UIView*)view_ withBorder:(BOOL)border;
-(void) closeView:(BOOL)send2server;
@end

@interface CallFeedbackViewController (KeyboardNotifications)
-(void) keyboardWillHide:(NSNotification *)note;
-(void) keyboardWillShow:(NSNotification *)note;
-(void) keyboardNotificationWithNote:(NSNotification *)note willShow: (BOOL) showing;
@end

//
//	CallFeedbackViewController(Private)
//
@implementation CallFeedbackViewController(Private)

+(void) applyGradienWithColors: (NSArray*)colors forView: (UIView*)view_ withBorder:(BOOL)border{
	for(CALayer *ly in view_.layer.sublayers){
		if([ly isKindOfClass: [CAGradientLayer class]]){
			[ly removeFromSuperlayer];
			break;
		}
	}
	
	if(colors){
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.colors = colors;
		gradient.frame = CGRectMake(0.f, 0.f, view_.frame.size.width, view_.frame.size.height);
		if(border){
			gradient.cornerRadius = 8.f;
			gradient.borderWidth = 2.f;
			gradient.borderColor = [[UIColor grayColor] CGColor];
		}
		
		view_.backgroundColor = [UIColor clearColor];
		[view_.layer insertSublayer:gradient atIndex:0];
	}
}

-(void) closeView:(BOOL)send2server {
    if (send2server)
        [[CloudCall2AppDelegate sharedInstance] SendCallFeedback2Server:callfeedbackdata];
    
    [[CloudCall2AppDelegate sharedInstance].tabBarController dismissModalViewControllerAnimated:NO];
}

@end


//
// CallFeedbackViewController (Timers)
//
@implementation CallFeedbackViewController (Timers)

-(void)timerCloseView:(NSTimer*)timer{
    expireTime--;
    if (expireTime == 0) {
        if (closeViewTimer) {
            [closeViewTimer invalidate];
            closeViewTimer = nil;
        }
        
        [self closeView:NO];
        
        return;
    }
    
    NSString* t = [[NSString alloc] initWithFormat:@"%02d秒后自动关闭...", expireTime];
    labelExpirePrompt.text = t;
    [t release];
}

@end

@implementation CallFeedbackViewController (KeyboardNotifications)

-(void) keyboardWillHide:(NSNotification *)note{
	[self keyboardNotificationWithNote:note willShow:NO];
}

-(void) keyboardWillShow:(NSNotification *)note{
	[self keyboardNotificationWithNote:note willShow:YES];
}

-(void) keyboardNotificationWithNote:(NSNotification *)note willShow: (BOOL)showing{
    if (showing) {
        [imageViewAd setHidden:YES];
        [buttonImgAd setHidden:YES];
        
        CGRect keyboardBounds;        
        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
        
        CGRect tempFrame;
        CGRect frame = txtViewFeedback.frame;
        tempFrame.origin = imageViewAd.frame.origin;
        tempFrame.size = CGSizeMake(frame.size.width, frame.size.height);
        
        [UIView beginAnimations:@"Curl"context:nil];//动画开始
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:txtViewFeedback];
        [txtViewFeedback setFrame:tempFrame];
        [UIView commitAnimations];
    } else {
        [imageViewAd setHidden:NO];
        [buttonImgAd setHidden:NO];
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        CGRect rect;
        rect.origin = txtViewFeedbackOrig;
        rect.size = txtViewFeedback.frame.size;
        txtViewFeedback.frame = rect;
        [UIView commitAnimations];
    }
}
@end


//
//	CallFeedbackViewController
//

@implementation CallFeedbackViewController

@synthesize childControl;
@synthesize imageViewAd;
@synthesize buttonImgAd;
@synthesize txtViewFeedback;
@synthesize labelExpirePrompt;

@synthesize buttonLevel3;
@synthesize buttonLevel2;
@synthesize buttonLevel1;
@synthesize userFeedback;

@synthesize callfeedbackdata;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {		
		self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

//-(void) SetImageAd:(NSData*)imgData andImgURL:(NSString*)imgurl {
//    UIImage *image = [UIImage imageWithData:imgData];
//    [imageViewAd setImage:image];
//    
//    self.imgAdUrl = imgurl;
//}

- (void) GotoWebSite {
    if (imgAdUrl && [imgAdUrl length] && adid != 9999) {
        AdResourceManager *manager = [[[AdResourceManager alloc] init] autorelease];
        [manager updateData:adid andType:ADStatisticsUpdateTypeClick];
        
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
    [self presentModalViewController:webBrowser animated:YES];
    
    [webBrowser release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtViewFeedbackOrig = txtViewFeedback.frame.origin;
    
    [txtViewFeedback setDelegate:self];
    [txtViewFeedback setReturnKeyType:UIReturnKeyDone];
    [txtViewFeedback setText:@"如有其他意见，请留言后点击右侧评论按键提交"];
    [txtViewFeedback setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
    [txtViewFeedback setTextColor:[UIColor lightGrayColor]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];    
    
    adid = 9999;
    actionType = 1;
    if ([[CloudCall2AppDelegate sharedInstance] ShowAllFeatures]) {
        if (CCAdsData *adsData = [[CloudCall2AppDelegate sharedInstance] GetCurrCallFeedBackData]) {
            if (NSData* imgData = [[CloudCall2AppDelegate sharedInstance] GetCallFeedBackImage:[adsData.image lastPathComponent]]) {
                adid = adsData.adid;
                actionType = adsData.clickAction;
                UIImage *image = [UIImage imageWithData:imgData];
                [imageViewAd setImage:image];
                
                if (imgAdUrl) {
                    [imgAdUrl release];
                    imgAdUrl = nil;
                }
                
                imgAdUrl = [[NSString alloc] initWithString:adsData.clickurl];
                
                //签到广告统计计数
                AdResourceManager *manager = [[[AdResourceManager alloc] init] autorelease];
                [manager updateData:adid andType:ADStatisticsUpdateTypeShow];
            }
        }
    }
    
    expireTime = 15; 
    closeViewTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCloseView:) userInfo:nil repeats:YES];
}

-(void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction) onButtonClick: (id)sender{
    if (closeViewTimer) {
        [closeViewTimer invalidate];
        closeViewTimer = nil;
        
        [labelExpirePrompt setHidden:YES];
    }
    
    if (sender == buttonImgAd) {
        [self GotoWebSite];
    } else if (sender == buttonLevel3) {
        callfeedbackdata.quality = 3;        
        callfeedbackdata.context = userFeedback; // 用户反馈的文本
        
        [self closeView:YES];
    } else if (sender == buttonLevel2) {
        callfeedbackdata.quality = 2;
        callfeedbackdata.context = userFeedback; // 用户反馈的文本
        
        [self closeView:YES];
    } else if (sender == buttonLevel1) {
        callfeedbackdata.quality = 1;        
        callfeedbackdata.context = userFeedback; // 用户反馈的文本
        
        [self closeView:YES];
    }
}

- (void)dealloc {
    [imageViewAd release];
    [buttonImgAd release];

    [buttonLevel3 release];
    [buttonLevel2 release];
    [buttonLevel1 release];
    [userFeedback release];
    [txtViewFeedback release];
    
    [callfeedbackdata release];
    [labelExpirePrompt release];
    
    if (closeViewTimer) {
        [closeViewTimer invalidate];
        closeViewTimer = nil;
    }
    if (imgAdUrl) {
        [imgAdUrl release];
        imgAdUrl = nil;
    }
	
    [super dealloc];
}

#pragma mark -
#pragma mark 触摸背景来关闭虚拟键盘

- (IBAction)backgroundTap:(id)sender
{
    if (txtViewFeedbackOrig.y != txtViewFeedback.frame.origin.y)
    {
        [imageViewAd setHidden:NO];
        [buttonImgAd setHidden:NO];
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        CGRect rect;
        rect.origin = txtViewFeedbackOrig;
        rect.size = txtViewFeedback.frame.size;
        txtViewFeedback.frame = rect;
        [UIView commitAnimations];
        
        if (txtViewFeedback.text.length == 0) {
            txtViewFeedback.textColor = [UIColor lightGrayColor];
            txtViewFeedback.text = @"如有其他意见，请留言后点击右侧评论按键提交";
            [txtViewFeedback resignFirstResponder];
        }
        [self.txtViewFeedback resignFirstResponder];
    }
    
}

// UITextViewDelegate
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (txtViewFeedback.textColor == [UIColor lightGrayColor]) {
        txtViewFeedback.text = @"";
        txtViewFeedback.textColor = [UIColor blackColor];
        
        if (closeViewTimer) {
            [closeViewTimer invalidate];
            closeViewTimer = nil;
            
            [labelExpirePrompt setHidden:YES];
        }
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if (txtViewFeedback.text.length == 0) {
        userFeedback = nil;
        
        txtViewFeedback.textColor = [UIColor lightGrayColor];
        txtViewFeedback.text = @"如有其他意见，请留言后点击右侧评论按键提交";
        [txtViewFeedback resignFirstResponder];
    } else {
        self.userFeedback = txtViewFeedback.text;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(txtViewFeedback.text.length == 0){
            txtViewFeedback.textColor = [UIColor lightGrayColor];
            txtViewFeedback.text = @"如有其他意见，请留言后点击右侧评论按键提交";
            [txtViewFeedback resignFirstResponder];
        }
        return NO;
    }
    
    return YES;
}

@end
