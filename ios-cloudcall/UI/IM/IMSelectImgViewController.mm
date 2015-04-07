//
//  IMSelectImgViewController.m
//  CloudCall
//
//  Created by Sergio on 13-7-23.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "IMSelectImgViewController.h"
#import "EGOImageView.h"
#import "EGOImageLoader.h"
#import "ASIFormDataRequest.h"
#import "CloudCall2AppDelegate.h"

#define ScreenScale             [UIScreen mainScreen].scale
#define IMAGE_MAX_SIZE_WIDTH    [UIScreen mainScreen].bounds.size.width * ScreenScale / 3
#define IMAGE_MAX_SIZE_HEIGHT   [UIScreen mainScreen].bounds.size.height * ScreenScale / 3

#define MainScreenWidth         CGRectGetWidth([UIScreen mainScreen].applicationFrame)
#define MainScreenHeight        CGRectGetHeight([UIScreen mainScreen].applicationFrame)

#define kButtonTagCancel        101
#define kButtonTagOrginal       102
#define kButtonTagFinish        103

@implementation IMSelectImgViewController
@synthesize selectImgDelegate;
@synthesize selectedImg;
@synthesize scrollView;
@synthesize selectedImageView;
@synthesize viewType;
@synthesize compressImg;
@synthesize topView;
@synthesize bottomView;

@synthesize smallImageUrl;
@synthesize orgImageUrl;

@synthesize lblProgress;
@synthesize progressView;
@synthesize msgID;
@synthesize btnBack;

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
    [topView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"im_toolbar_bg.png"]]];
    
    [scrollView setFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight)];
    
    lblProgress.hidden = YES;
    progressView.hidden = YES;
    
    self.selectedImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *imgUpSingleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageViewSingleClick)];
    [self.selectedImageView addGestureRecognizer:imgUpSingleClick];
    [imgUpSingleClick release];
    
    selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(6, 0, 44, 44)];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    btnBack.tag = 101;
    [btnBack addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [topView addSubview:btnBack];
    
    if (iPhone5)
    {
        selectedImageView.frame = CGRectMake(selectedImageView.frame.origin.x, selectedImageView.frame.origin.y - 28, selectedImageView.frame.size.width, selectedImageView.frame.size.height);
    }
    
    if (viewType == IMSelectImgViewTypeSelectImg) {
        [bottomView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"im_toolbar_bg.png"]]];
        
        if (iPhone5)
            [bottomView setFrame:CGRectMake(bottomView.frame.origin.x, bottomView.frame.origin.y + 88, bottomView.frame.size.width, bottomView.frame.size.height)];
        
        UIButton *btnOriginalImg = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnOriginalImg setFrame:CGRectMake(250, 9, 60, 26)];
        [btnOriginalImg setTitle:NSLocalizedString(@"Full Image", @"Full Image") forState:UIControlStateNormal];
        [btnOriginalImg.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [btnOriginalImg.titleLabel setTextColor:[UIColor whiteColor]];
        [btnOriginalImg setBackgroundImage:[UIImage imageNamed:@"im_sendoriginalimg_up.png"] forState:UIControlStateNormal];
        [btnOriginalImg setBackgroundImage:[UIImage imageNamed:@"im_sendoriginalimg_down.png"] forState:UIControlStateHighlighted];
        btnOriginalImg.tag = 102;
        [btnOriginalImg addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btnUse = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnUse setFrame:CGRectMake(250, 8, 60, 31)];
        [btnUse setTitle:NSLocalizedString(@"Done", @"Done") forState:UIControlStateNormal];
        [btnUse.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [btnUse.titleLabel setTextColor:[UIColor blackColor]];
        [btnUse setBackgroundImage:[UIImage imageNamed:@"im_sendimg_up.png"] forState:UIControlStateNormal];
        [btnUse setBackgroundImage:[UIImage imageNamed:@"im_sendimg_down.png"] forState:UIControlStateHighlighted];
        btnUse.tag = 103;
        [btnUse addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [topView addSubview:btnOriginalImg];
        [bottomView addSubview:btnUse];
        
        if (selectedImg)
        {
            self.compressImg = [self fitSmallImage:selectedImg];
//            self.compressImg = [self compressImage:selectedImg andQuality:0.5];
//            [selectedImageView setFrame:CGRectMake(self.view.center.x - compressImg.size.width/2, self.view.center.y - compressImg.size.height/2, selectedImageView.frame.size.width, selectedImageView.frame.size.height)];
            [selectedImageView setImage:compressImg];
        }
    }
    else if(viewType == IMSelectImgViewTypeOrgImg)
    {
        [bottomView setHidden:YES];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onImageViewLongPress:)];
        [selectedImageView addGestureRecognizer:longPressGesture];
        [longPressGesture release];
        
        NSString *myAccount = [[CloudCall2AppDelegate sharedInstance] getUserName];

        CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*)[[UIApplication sharedApplication] delegate]);
        NSString *IMCachesDir = [appDelegate GetIMCachesDirectoryPath];
        NSString *myDir = [IMCachesDir stringByAppendingPathComponent:myAccount];
        NSString *fileName = [NSString stringWithFormat:@"%@_org.jpg",msgID];
        NSString *filePath = [myDir stringByAppendingPathComponent:fileName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];

        if ([fileManager fileExistsAtPath:filePath isDirectory:nil])
        {
            selectedImageView.userInteractionEnabled = YES;
            
            UIImage *orgImage = [UIImage imageWithContentsOfFile:filePath];
            selectedImageView.image = orgImage;
        }
        else
        {
            btnBack.enabled = NO;
            selectedImageView.userInteractionEnabled = NO;
            
            [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(setBtnBackEnable) userInfo:nil repeats:NO];
            
            NSString *smFileName = [NSString stringWithFormat:@"%@_small.jpg",msgID];
            NSString *smFilePath = [myDir stringByAppendingPathComponent:smFileName];
            
            //优先从本地读取
            if ([fileManager fileExistsAtPath:smFilePath isDirectory:nil])
                [selectedImageView setImage:[UIImage imageWithContentsOfFile:smFilePath]];
            else
                [selectedImageView setImage:[UIImage imageNamed:@"missingAvatar"]];
            
            //从网络加载
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:orgImageUrl]];
            [request setDownloadProgressDelegate:self];
            [request setShowAccurateProgress:YES];
            [request setDelegate:self];
            
            lblProgress.hidden = NO;
            progressView.hidden = NO;
            [request startAsynchronous];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)dealloc
{
    [selectedImg release];
    [scrollView release];
    [selectedImageView release];
    [compressImg release];
    [topView release];
    [bottomView release];
    
    [smallImageUrl release];
    [orgImageUrl release];
    
    [lblProgress release];
    [progressView release];
    [msgID release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods
- (void)onButtonClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == kButtonTagCancel)      //取消
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(button.tag == kButtonTagOrginal)  //原图发送
    {
        if([selectImgDelegate respondsToSelector:@selector(selectedImageType:)])
            [selectImgDelegate selectedImageType:selectedImg];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(button.tag == kButtonTagFinish)  //完成---默认使用压缩图
    {
        if([selectImgDelegate respondsToSelector:@selector(selectedImageType:)])
        {
            if (self.compressImg)
                [selectImgDelegate selectedImageType:self.compressImg];
            else
                [selectImgDelegate selectedImageType:selectedImg];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UIImage *)compressImage:(UIImage *)image andQuality:(float)quality
{
    if (nil == image)
    {
        return nil;
    }
    
    double compressionRatio = 1;
    int resizeAttempts = 6;
    
    NSData * imgData = UIImageJPEGRepresentation(image,compressionRatio);
    
    NSLog(@"Starting Size: %i", [imgData length]);
    
    //Trying to push it below around about 0.4 meg
    while ([imgData length] > 300000 && resizeAttempts > 0) {
        resizeAttempts -= 1;
        
        NSLog(@"Image was bigger than 400000 Bytes. Resizing.");
        NSLog(@"%i Attempts Remaining",resizeAttempts);
        
        //Increase the compression amount
        compressionRatio = compressionRatio * quality;
        NSLog(@"compressionRatio %f",compressionRatio);
        //Test size before compression
        NSLog(@"Current Size: %i",[imgData length]);
        imgData = UIImageJPEGRepresentation(image,compressionRatio);
        
        //Test size after compression
        NSLog(@"New Size: %i",[imgData length]);
    }
    
    //Set image by comprssed version
    UIImage *newImage = [UIImage imageWithData:imgData];
    
    return newImage;
}

- (UIImage *)fitSmallImage:(UIImage *)image
{
    if (nil == image)
    {
        return nil;
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    if ([imageData length] <= 300000)   //小于300KB
    {
        return image;
    }
    CGSize size = [self fitsize:image.size];
//    CGSize size = image.size;
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [image drawInRect:rect];
    UIImage *newing = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newing;
}

- (CGSize)fitsize:(CGSize)thisSize
{
    if(thisSize.width == 0 && thisSize.height ==0)
        return CGSizeMake(0, 0);
//    CGFloat wscale = thisSize.width/IMAGE_MAX_SIZE_WIDTH;
//    CGFloat hscale = thisSize.height/IMAGE_MAX_SIZE_HEIGHT;
    CGFloat scale = 5.0;//(wscale>hscale)?wscale:hscale;
    CGSize newSize = CGSizeMake(thisSize.width/scale, thisSize.height/scale);
    return newSize;
}

- (void)onImageViewSingleClick
{
    topView.hidden = !topView.hidden;
    if (viewType == IMSelectImgViewTypeSelectImg)
        bottomView.hidden = !bottomView.hidden;
}

- (void)onImageViewLongPress:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Save to Phone", @"Save to Phone"), nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
}

-(BOOL)writeData2File:(NSData*)data toFileAtPath:(NSString*)aPath{
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

- (void)setBtnBackEnable
{
    btnBack.enabled = YES;
}

#pragma mark -
#pragma mark ASIHttpRequest
- (void) requestFinished:(ASIHTTPRequest *) aRequest
{
    NSData *resultData = [aRequest responseData];
    
    if (resultData)
    {
        UIImage *orgImage = [UIImage imageWithData:resultData];
        selectedImageView.image = orgImage;
        lblProgress.hidden = YES;
        progressView.hidden = YES;
        selectedImageView.userInteractionEnabled = YES;
        
        NSString *myAccount = [[CloudCall2AppDelegate sharedInstance] getUserName];
        
        CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*)[[UIApplication sharedApplication] delegate]);
        NSString *IMCachesDir = [appDelegate GetIMCachesDirectoryPath];
        NSString *myDir = [IMCachesDir stringByAppendingPathComponent:myAccount];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 创建存放IM个人cache文件夹
        if (![fileManager fileExistsAtPath:myDir isDirectory:nil]) {
            if ([fileManager createDirectoryAtPath:myDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
                CCLog(@"创建存放IM个人cache文件夹失败");
            }
        }
        NSString *fileName = [NSString stringWithFormat:@"%@_org.jpg",msgID];
        
        NSString *filePath = [myDir stringByAppendingPathComponent:fileName];
        
        [self writeData2File:resultData toFileAtPath:filePath];
    }
    btnBack.enabled = YES;
}

- (void) requestFailed:(ASIHTTPRequest *) aRequest
{
    //失败处理方案
    btnBack.enabled = YES;
}

#pragma mark -
#pragma mark ASIProgressDelegate
- (void)setProgress:(float)newProgress
{
    [self.progressView setProgress:newProgress animated:YES];
    self.lblProgress.text = [NSString stringWithFormat:@"%0.f%%",newProgress*100];
}

//- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength;
//{
//    [self.progressView setProgress:newLength animated:YES];
//    NSLog(@"totalupload:%lld",newLength);
//    self.lblProgress.text = [NSString stringWithFormat:@"%0.f%%",newLength*100];
//    
//}
#pragma mark -
#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return selectedImageView; //返回ScrollView上添加的需要缩放的视图
}

- (void)scrollViewDidZoom:(UIScrollView *)_scrollView
{
    //缩放操作中被调用
    //使图片居中
    CGFloat offsetX = (_scrollView.bounds.size.width > _scrollView.contentSize.width)?(_scrollView.bounds.size.width - _scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (_scrollView.bounds.size.height > _scrollView.contentSize.height)?(_scrollView.bounds.size.height - _scrollView.contentSize.height)/2 : 0.0;
    selectedImageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,_scrollView.contentSize.height/2 + offsetY);
}

//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//    //缩放结束后被调用
//}

#pragma mark - UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        UIImage *image = selectedImageView.image;
        
        if (image)
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

#pragma mark - UIImageWriteToSavePhonesAlbum CallBack
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *saveResultMsg = NSLocalizedString(@"Success to save image!", @"Success to save image!");
    
    if(error)
        saveResultMsg = NSLocalizedString(@"Fail to save image!", @"Fail to save image!");
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = saveResultMsg;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
    [HUD release];
}
@end
