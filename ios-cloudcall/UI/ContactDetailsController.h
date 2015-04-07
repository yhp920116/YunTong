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
#import "CCTableAlert.h"

#import <AddressBookUI/ABPersonViewController.h>
#import <iAd/iAd.h>

#import <immobSDK/immobView.h>
#import <AddressBookUI/ABNewPersonViewController.h>
#import "NewContactDelegate.h"
#import "RecentDetailCell.h"

#define kTagBtnInviteFriendToJoin 14

@interface ContactDetailsController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate,ABPersonViewControllerDelegate,CCTableAlertDelegate,CCTableAlertDataSource>
{
	UILabel *labelDisplayName;
	UIImageView *imageViewAvatar;
	UITableView *tableView;
    UIView *viewToolbar;
    UIToolbar *toolbar;
    UILabel *labelTitle;
	UIImageView *viewHeader;
	
	UIButton *buttonInvite;
	UIButton *buttonVideoCall;
	UIButton *buttonTextMessage;
	UIButton *buttonAddToFavorites;
	UIButton *buttonSendMsg;
    
	NgnContact *contact;
	int addToFavoritesLastIndex;
    
    NSString* dialNum;
    NSString *sendMessageNum;
    BOOL videocallout;
    NSMutableArray* calloption;
    
    UIButton *barButtonItemBack;
    UIButton *barButtonItemEdit;
    UILabel *lblTitle;
    
    BOOL isHideBtnEdit;
    BOOL isInContact;
    BOOL isAddContact;
    
    BOOL isHightLight;
    NSString *hightNumber;
    
    BOOL fromIMChatView;
    
    NewContactDelegate* myNewContactDelegate;
    NgnHistoryEventMutableArray *recentArray;
    
    NSMutableArray *msgContactsArray;
    
@private
    UIButton *buttonAd;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property(nonatomic,retain) IBOutlet UILabel *labelDisplayName;
@property(nonatomic,retain) IBOutlet UIImageView *imageViewAvatar;
@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIView *viewToolbar;
@property(nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic,retain) IBOutlet UILabel *labelTitle;
@property(nonatomic,retain) IBOutlet UIImageView *viewHeader;

@property(nonatomic,retain) IBOutlet UIButton *buttonInvite;
@property(nonatomic,retain) IBOutlet UIButton *buttonVideoCall;
@property(nonatomic,retain) IBOutlet UIButton *buttonTextMessage;
@property(nonatomic,retain) IBOutlet UIButton *buttonAddToFavorites;
@property(nonatomic,retain) IBOutlet UIButton *buttonAd;
@property(nonatomic,retain) IBOutlet UIButton *buttonSendMsg;

@property(nonatomic,retain) NgnContact *contact;

@property (nonatomic, retain) NSString *sendMessageNum;
@property(nonatomic,assign) BOOL isHideBtnEdit;
@property(nonatomic,assign) BOOL isInContact;
@property(nonatomic,retain) NgnHistoryEventMutableArray *recentArray;

@property(nonatomic,assign) BOOL isHightLight;
@property(nonatomic,retain) NSString *hightNumber;
@property(nonatomic,assign) BOOL fromIMChatView;

- (IBAction) onButtonClicked: (id)sender;
- (void)showInviteMessageView:(NSString*)phonenum andContentType:(int)contentType;

@end
