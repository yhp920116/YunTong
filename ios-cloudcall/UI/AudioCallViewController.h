/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import <UIKit/UIKit.h>
#import "CallViewController.h"
#import "UIUnderlinedButton.h"
#import "BannerViewContainer.h"
#import "BaiduMobAdView.h"

#import <iAd/iAd.h>
#import <immobSDK/immobView.h>

@interface AudioCallViewController : CallViewController <UIWebViewDelegate,ADBannerViewDelegate,BannerViewContainer>{
@private
	UILabel *labelStatus;
	UILabel *labelRemoteParty;
    UILabel *labelAccount;
    UILabel *labelCodec;
	UIView *viewCenter;
	UIView *viewTop;
	UIView *viewBottom;
	UIButton *buttonHangup;
	UIButton *buttonAccept;
    UIButton *buttonDecline;
	UIButton *buttonHideNumpad;
	UIButton *buttonMute;
	UIButton *buttonNumpad;
	UIButton *buttonSpeaker;
	UIButton *buttonHold;
	UIButton *buttonVideo;
	UIView *viewContact;
    UIImageView *imageViewContact;
	UIView *viewNumpad;    
    UIView *viewSecondCall;
    UIButton *buttonIgnore;
	UIButton *buttonHoldAndAnswer;
    
    UIImageView *imageViewAd;
	
    UIButton *keypad_0;
    UIButton *keypad_1;
    UIButton *keypad_2;
    UIButton *keypad_3;
    UIButton *keypad_4;
    UIButton *keypad_5;
    UIButton *keypad_6;
    UIButton *keypad_7;
    UIButton *keypad_8;
    UIButton *keypad_9;
    UIButton *keypad_sharp;
    UIButton *keypad_star;
    
    UIButton *btnCallbackWait;
    
	NgnAVSession* audioSession;
	CGFloat bottomButtonsPadding;
    
    int oldCenterViewType;
    int centerViewType;
    
    NgnAVSession* secondAudioSession;
    
    unsigned long incallSec;
    NSTimer* incallTimer;
    BOOL isAdClick;
    
    BOOL isCallTypeCallBack;
    
    int adid;
    int actionType;
@private
    ADBannerView *iadbanner;
    immobView *lmbanner;
    BaiduMobAdView *bdbanner;
    
    UIButton* buttonIncallAd;
    NSString* imgAdUrl;
    
    BOOL callconnected;    
    NSString *remotenum;
    int duration; // 通话时长
    NSTimeInterval calltime; // 呼叫时间(输完号码，按下拨打键的时间)
    NSTimeInterval conntiontime; // 接通时间(对方接通，开始通话的时间)
    CALL_OUT_MODE calltype;
    NSString* nettype;
    BOOL incomingcall;
}
//@property (nonatomic, retain) NSString* imgAdUrl;;
@property (nonatomic, assign) BOOL isAdClick;

@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UILabel *labelRemoteParty;
@property (retain, nonatomic) IBOutlet UILabel *labelAccount;
@property (retain, nonatomic) IBOutlet UILabel *labelCodec;
@property (retain, nonatomic) IBOutlet UIView *viewCenter;
@property (retain, nonatomic) IBOutlet UIView *viewTop;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;
@property (retain, nonatomic) IBOutlet UIButton *buttonHangup;
@property (retain, nonatomic) IBOutlet UIButton *buttonAccept;
@property (retain, nonatomic) IBOutlet UIButton *buttonDecline;
@property (retain, nonatomic) IBOutlet UIButton *buttonHideNumpad;
@property (retain, nonatomic) IBOutlet UIButton *buttonMute;
@property (retain, nonatomic) IBOutlet UIButton *buttonNumpad;
@property (retain, nonatomic) IBOutlet UIButton *buttonSpeaker;
@property (retain, nonatomic) IBOutlet UIButton *buttonHold;
@property (retain, nonatomic) IBOutlet UIButton *buttonVideo;
@property (retain, nonatomic) IBOutlet UIView *viewContact;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewContact;
@property (retain, nonatomic) IBOutlet UIView *viewNumpad;
@property (retain, nonatomic) IBOutlet UIView *viewSecondCall;
@property (retain, nonatomic) IBOutlet UIButton *buttonIgnore;
@property (retain, nonatomic) IBOutlet UIButton *buttonHoldAndAnswer;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewAd;
@property (retain, nonatomic) IBOutlet UIButton* buttonIncallAd;

@property (retain, nonatomic) IBOutlet UIButton *keypad_0;
@property (retain, nonatomic) IBOutlet UIButton *keypad_1;
@property (retain, nonatomic) IBOutlet UIButton *keypad_2;
@property (retain, nonatomic) IBOutlet UIButton *keypad_3;
@property (retain, nonatomic) IBOutlet UIButton *keypad_4;
@property (retain, nonatomic) IBOutlet UIButton *keypad_5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_6;
@property (retain, nonatomic) IBOutlet UIButton *keypad_7;
@property (retain, nonatomic) IBOutlet UIButton *keypad_8;
@property (retain, nonatomic) IBOutlet UIButton *keypad_9;
@property (retain, nonatomic) IBOutlet UIButton *keypad_sharp;
@property (retain, nonatomic) IBOutlet UIButton *keypad_star;

@property (retain, nonatomic) IBOutlet UIButton *btnCallbackWait;

- (IBAction) onButtonClick: (id)sender;
- (IBAction) onButtonNumpadClick: (id)sender;

@end
