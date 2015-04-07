/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "iOSNgnStack.h"
#import "BannerViewContainer.h"
#import "ConferenceViewController.h"

#import <iAd/iAd.h>
#import <DianJinOfferPlatform/DianJinOfferBanner.h>
#import <immobSDK/immobView.h>

@class NewContactDelegate;

@interface OldNumpadViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, ADBannerViewDelegate, MFMessageComposeViewControllerDelegate, BannerViewContainer> {
@public
	UIActivityIndicatorView* activityIndicator;
	UILabel *labelStatus;
	UIImageView *viewBackground;
    UIImageView *viewBackgroundi5;
	UILabel *labelNumber;
    UIImageView *numberbg;
    
	UIButton *buttonMakeAudioCall;
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
    UIButton *keypad_del;
    UIButton *keypad_dial;
    UIButton *keypad_sharp;
    UIButton *keypad_star;
    UIButton *addContact;
    
    UIButton *buttonMakeAudioCalli5;
    UIButton *keypad_0i5;
    UIButton *keypad_1i5;
    UIButton *keypad_2i5;
    UIButton *keypad_3i5;
    UIButton *keypad_4i5;
    UIButton *keypad_5i5;
    UIButton *keypad_6i5;
    UIButton *keypad_7i5;
    UIButton *keypad_8i5;
    UIButton *keypad_9i5;
    UIButton *keypad_deli5;
    UIButton *keypad_diali5;
    UIButton *keypad_sharpi5;
    UIButton *keypad_stari5;
    UIButton *addContacti5;
    
    UIButton *buttonConference;
    
    UIImageView *imageStatus;
    UIImageView *imageVIP;
	
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
    NgnBaseService<INgnHistoryService>* mHistoryService;
    
    NSString *lastnumber;
    CALL_OUT_MODE lastcalloutmode;
    BOOL showing;
@private
    NSString *adUrl;
    
    BOOL videocallout;
    NSMutableArray* calloption;
    
    NSString* lastMsgCallId;
    
    UIButton *buttonAd;

    ADBannerView *iadbanner;
    DianJinOfferBanner *djbanner;
    immobView *lmbanner;
    
    NewContactDelegate* myNewContactDelegate;
    
    ConferenceViewController* conferenceController;
}

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UIImageView *viewBackground;
@property (retain, nonatomic) IBOutlet UIImageView *viewBackgroundi5;
@property (retain, nonatomic) IBOutlet UILabel *labelNumber;
@property (retain, nonatomic) IBOutlet UIButton *buttonMakeAudioCall;
@property (retain, nonatomic) IBOutlet UIButton *buttonConference;
@property (retain, nonatomic) IBOutlet UIImageView *imageStatus;
@property (retain, nonatomic) IBOutlet UIImageView *imageVIP;
@property (retain, nonatomic) IBOutlet UIButton *buttonAd;
@property (retain, nonatomic) IBOutlet UIImageView *numberbg;

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
@property (retain, nonatomic) IBOutlet UIButton *keypad_del;
@property (retain, nonatomic) IBOutlet UIButton *keypad_dial;
@property (retain, nonatomic) IBOutlet UIButton *keypad_star;
@property (retain, nonatomic) IBOutlet UIButton *addContact;

@property (retain, nonatomic) IBOutlet UIButton *buttonMakeAudioCalli5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_0i5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_1i5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_2i5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_3i5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_4i5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_5i5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_6i5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_7i5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_8i5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_9i5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_deli5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_diali5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_sharpi5;
@property (retain, nonatomic) IBOutlet UIButton *keypad_stari5;
@property (retain, nonatomic) IBOutlet UIButton *addContacti5;

- (IBAction) onButtonClick: (id)sender;

- (IBAction) onButtonNumpadUp: (id) sender event: (UIEvent*) e;
- (IBAction) onButtonNumpadDown: (id) sender event: (UIEvent*) e;

@end
