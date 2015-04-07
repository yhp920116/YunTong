/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"
#import <MessageUI/MessageUI.h>

#import "SelectParticipantViewController.h"
#import "SelectParticipantFromGroupViewController.h"
#import "ConferenceFavoritesViewController.h"
#import "ParticipantCell.h"
#import "GMGridView.h"
#import "ConferenceMember.h"
#import "WEPopoverController.h"
#import "MoreBtnTableViewController.h"

#import <CoreTelephony/CTCallCenter.h>

typedef enum {
    CONF_MSG_NONE,
    CONF_MSG_START,
    CONF_MSG_START_RES,
    CONF_MSG_DEL_MEM,
    CONF_MSG_DEL_MEM_RES,
    CONF_MSG_ADD_MEM,
    CONF_MSG_ADD_MEM_RES,
    CONF_MSG_STOP,
    CONF_MSG_STOP_RES,
    CONF_MSG_MEM_STATUS,
    CONF_MSG_END,
    CONF_MSG_MAX
} CONF_MSG_TYPE;

typedef enum {
    CONF_STATUS_NONE,
    CONF_STATUS_STARTING,
    CONF_STATUS_TALKING,
    CONF_STATUS_STOP
} CONF_STATUS;

typedef enum {
    CellPhoneCallStateNone,
    CellPhoneCallStateDisconnected,
    CellPhoneCallStateImcoming,
    CellPhoneCallStateDialing,
    CellPhoneCallStateConnected
}CellPhoneCallState;

enum {
    kTagMoreBtn_Order,
    kTagMoreBtn_MassTexting,
    kTagMoreBtn_Edit,
    kTagMoreBtn_Share
};

@interface ConferenceViewController : UIViewController <UITextFieldDelegate,UIActionSheetDelegate,ParticipantPickerFromGroupDelegate,ParticipantPickerDelegate,ADBannerViewDelegate, GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate, MoreBtnTableViewDelegate,MFMessageComposeViewControllerDelegate> {
    UIView          *viewToolbar;
    UIToolbar       *toolbar;
    UILabel         *labelTitle;
    UILabel         *labelMaxconfMembers;
    
    UIButton        *barButtonItemBack;
    UIButton        *barButtonItemMore;
    
    UIButton        *buttonGroup;
    UIButton        *buttonSave;
    UIButton        *buttonCall;
    
    UIButton        *buttonSelectedAll;
    UIButton        *buttonPick;
    int oldGroupCallMembers;
    UITextField     *txtFieldAdd;
    
    UIView          *viewKeys;
    NgnConferenceFavorite *conffavorite;
    
    ConferenceMember* cmMyNumber;
    NSString *uuid;
    __gm_weak GMGridView *_gmGridView;
    
    CONF_STATUS confStatus;

    NSString *mynum;
    NSString *mypwd;
    BOOL isLongPress;
    BOOL isCreateGroup;
    BOOL isOrderGroupCall;
@private
    NSMutableArray* participants;
    NSMutableArray *participantsWillCall;
    BOOL isSelectedAll;
    UIToolbar* keyboardToolbar;
    
    UIAlertView* progressView;
    
    ParticipantCell *cellMyNum;
}
@property (nonatomic, retain) NgnConferenceFavorite *conffavorite;

@property (nonatomic, assign) BOOL isCreateGroup;
@property (nonatomic, assign) BOOL isOrderGroupCall;
@property(nonatomic,retain) IBOutlet UIView              *viewToolbar;
@property(nonatomic,retain) IBOutlet UIToolbar           *toolbar;
@property(nonatomic,retain) IBOutlet UILabel             *labelTitle;
@property(nonatomic,retain) IBOutlet UILabel             *labelMaxconfMembers;

@property(nonatomic,retain) IBOutlet UIButton            *buttonGroup;
@property(nonatomic,retain) IBOutlet UIButton            *buttonSave;
@property(nonatomic,retain) IBOutlet UIButton            *buttonCall;
@property(nonatomic,retain) IBOutlet UIButton            *buttonPick;
@property(nonatomic,retain) IBOutlet UIButton            *buttonSelectedAll;

@property(nonatomic,retain) IBOutlet UITextField         *txtFieldAdd;
@property (nonatomic,retain) WEPopoverController *popoverController;

@property(nonatomic,retain) IBOutlet UIView              *viewKeys;
@property (nonatomic, retain) NSString *uuid;
@property(readonly) CONF_STATUS confStatus;
@property (nonatomic, retain) ConferenceMember* cmMyNumber;
- (IBAction)onButtonToolBarItemClick: (id)sender;

- (IBAction) onButtonClick: (id)sender;

@end
