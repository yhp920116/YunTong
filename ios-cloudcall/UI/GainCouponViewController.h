//
//  GainCouponViewController.h
//  CloudCall
//
//  Created by Sergio on 13-5-8.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"

#define kStopFirstRollingRound 65
#define kStopSecondRollingRound 85
#define kStopThirdRollingRound 100

@class CouponData;
@interface GainCouponViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>
{
    CouponData *couponData;
    UIPickerView *picker1;
    UIPickerView *picker2;
    UIPickerView *picker3;
    
    NSTimer *timer1;
    NSTimer *timer2;
    NSTimer *timer3;
    
    int wheelno1;
    int wheelno2;
    int wheelno3;
    
    BOOL connectionfinish;
    BOOL isNetWorkError;
    BOOL isShowError;
    BOOL isGainCoupon;
    
    NSString *resultText;
    int ROUNDCOUNT;
    
    AVAudioPlayer *player;
}
@property (nonatomic, retain) IBOutlet UIImageView *couponImg;
@property (nonatomic, retain) IBOutlet UIImageView *couponBG;
@property (nonatomic, retain) CouponData *couponData;
@property (nonatomic, retain) NSString *resultText;
@property (nonatomic, retain) IBOutlet UIPickerView *picker1;
@property (nonatomic, retain) IBOutlet UIPickerView *picker2;
@property (nonatomic, retain) IBOutlet UIPickerView *picker3;

@property (nonatomic, retain) IBOutlet UIButton *btnStart;
@property (nonatomic, retain) IBOutlet UILabel  *lblThreeSmile;
@property (nonatomic, retain) IBOutlet UIView   *viewAnnounce;
@property (nonatomic, retain) IBOutlet UILabel  *lblTipAnnounce;

@end
