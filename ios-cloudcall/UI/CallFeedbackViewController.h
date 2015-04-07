/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import <UIKit/UIKit.h>

#import "CloudCall2AppDelegate.h"

@interface CallFeedbackViewController : UIViewController <UITableViewDelegate, UITextViewDelegate> {
@private
    UIControl   *childControl;
    UIImageView *imageViewAd;    
    UIButton* buttonImgAd;

    UIButton* buttonLevel3;
    UIButton* buttonLevel2;
    UIButton* buttonLevel1;
    
    NSString* imgAdUrl;
    
    UITextView* txtViewFeedback;
    UILabel*    labelExpirePrompt;
    int adid;
    int actionType;
    
@private
    CallFeedbackData* callfeedbackdata;
    
    CGPoint txtViewFeedbackOrig;
    int expireTime;
    NSTimer* closeViewTimer;
    
    NSString* userFeedback;
}
@property (nonatomic, retain) NSString *userFeedback;
@property (retain, nonatomic)  IBOutlet UIControl  *childControl;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewAd;
@property (retain, nonatomic) IBOutlet UIButton* buttonImgAd;
@property (retain, nonatomic) IBOutlet UITextView* txtViewFeedback;
@property (retain, nonatomic) IBOutlet UILabel*    labelExpirePrompt;

@property (retain, nonatomic) IBOutlet UIButton* buttonLevel3;
@property (retain, nonatomic) IBOutlet UIButton* buttonLevel2;
@property (retain, nonatomic) IBOutlet UIButton* buttonLevel1;

@property (retain, nonatomic) CallFeedbackData* callfeedbackdata;


- (IBAction)backgroundTap:(id)sender;

//-(void) SetImageAd:(NSData*)imgData andImgURL:(NSString*)imgurl;

- (IBAction) onButtonClick: (id)sender;

@end
