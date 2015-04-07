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

#import <iAd/iAd.h>
#import "BaiduMobAdView.h"
#import <immobSDK/immobView.h>
#import "NewContactViewCell.h"
#import "ContactDetailsController.h"
#import "MyTextField.h"

#define kTAGStar		10
#define kTAGPound		11
#define kTAGAudioCall	12
#define kTAGDelete		13
#define kTAGMessages	14
#define kTAGToContact	15
#define kTAGHideNumpad  16
#define kTAGViewNewworkExcDetail 21

#define kTagActionSheetCallOutNumPad    101
#define kTagActionSheetAddContactNumPad 102

#define kTAGSetLog	200
#define OriginYofiPhone5 88

#define NOT_CHECK_IS_WEICALL_USER

@class NewContactDelegate;

@interface NumpadViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate,ADBannerViewDelegate, UITabBarControllerDelegate,BannerViewContainer,UITextFieldDelegate> {
@public
    UIImageView *numpadView;
    UIImageView *dialView;
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
    UIButton *keypad_del;
    UIButton *keypad_dial;
    UIButton *keypad_star;
    UIButton *toContact;
    NSString *lastnumber;
    
	UITableView *tableView;
    ContactDetailsController* contactDetailsController;
	NgnHistoryEventMutableArray* mEvents;
    NgnContactMutableArray *contactArray;
    
	HistoryEventStatus_t mStatusFilter;
	
    NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnContactService>* mContactService;
	NgnBaseService<INgnHistoryService>* mHistoryService;
    
    NSString* dialNum;
    BOOL videocallout;
    BOOL isExist;
    BOOL isShowNumpad;
    BOOL isShowNetWorkPromptFlag;
    BOOL isConnecting;
    NSMutableArray* calloption;

    NewContactDelegate* myNewContactDelegate;
    
@private
    ADBannerView *iadbanner;
    immobView *lmbanner;
    UIButton *buttonAd;
    BaiduMobAdView *bdbanner;

}

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIImageView *numpadView;
@property (retain, nonatomic) IBOutlet UIImageView *dialView;
@property (retain, nonatomic) IBOutlet MyTextField *labelNumber;
@property (retain, nonatomic) IBOutlet MyTextField *labelNumberArea;
@property (retain, nonatomic) IBOutlet UIButton *delNum;
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
@property (retain, nonatomic) IBOutlet UIButton *toContact;
@property (retain, nonatomic) IBOutlet UILabel  *lblContact;

@property(nonatomic,retain) IBOutlet UIButton* btnClear;
@property(nonatomic,retain) IBOutlet UIButton* buttonAd;


- (IBAction) onButtonClick:(id)sender;
- (NSDictionary *) dictionaryWithValue:(id) value andLabel: (CFStringRef) label;
- (NSString *)getNumerByLetter:(NSString *)aLetter;
- (void)showOrHideDialWayIntroduce;

@end
