//
//  IMSelectImgViewController.h
//  CloudCall
//
//  Created by Sergio on 13-7-23.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"

typedef enum
{
    IMSelectImgViewTypeSelectImg = 0,
    IMSelectImgViewTypeOrgImg,
}IMSelectImgViewType;

@protocol IMSelectImgDelegate <NSObject>

- (void)selectedImageType:(UIImage *)image;

@end

@interface IMSelectImgViewController : UIViewController<ASIProgressDelegate, UIActionSheetDelegate>
{
    UIScrollView *scrollView;
    UIImage *selectedImg;
    UIImageView *selectedImageView;
    UIImage *compressImg;
    
    NSString *smallImageUrl;
    NSString *orgImageUrl;
    
    IMSelectImgViewType viewType;
    
    UILabel *lblProgress;
    UIProgressView *progressView;
    NSString *msgID;
    
    UIButton *btnBack;
}

@property (nonatomic, assign) id<IMSelectImgDelegate> selectImgDelegate;
@property (nonatomic, retain) UIImage *selectedImg;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *selectedImageView;
@property (nonatomic, retain) UIImage *compressImg;
@property (nonatomic, assign) IMSelectImgViewType viewType;

@property (nonatomic, retain) IBOutlet UIView *topView;
@property (nonatomic, retain) IBOutlet UIView *bottomView;

@property (nonatomic, retain) NSString *smallImageUrl;
@property (nonatomic, retain) NSString *orgImageUrl;

@property (nonatomic, retain) IBOutlet UILabel *lblProgress;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) NSString *msgID;
@property (nonatomic, retain) UIButton *btnBack;
@end
