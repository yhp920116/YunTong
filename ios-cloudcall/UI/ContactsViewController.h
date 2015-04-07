/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import <UIKit/UIKit.h>
#import "ContactViewCell.h"
#import "ContactDetailsController.h"
//#import "PickerViewControllerDelegate.h"
#import "BannerViewContainer.h"
#import "EGORefreshTableHeaderView.h"

#import "iOSNgnStack.h"
#import <iAd/iAd.h>
#import "BaiduMobAdView.h"

#import <immobSDK/immobView.h>

typedef enum ContactsFilterGroup_e
{
	FilterGroupAll,
	FilterGroupOnline,
	FilterGroupWiPhone
}
ContactsFilterGroup_t;

typedef enum ContactsDisplayMode_e
{
	Display_None,
	Display_ChooseNumberForFavorite,
	Display_Searching
}
ContactsDisplayMode_t;

@class NewContactDelegate;
@class UIBadgeView;

@interface ContactsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,UIAlertViewDelegate,ContactDialDelegate,ADBannerViewDelegate,BannerViewContainer,EGORefreshTableHeaderDelegate> {
	UISearchBar *searchBar;
	UIToolbar *toolBar;
	UITableView *tableView;
	UIView *viewToolbar;
    UIView *headView;
    UIButton *secretaryBtn;
    UILabel *secretaryLabel;
    
	UIButton* barButtonItemAll;
	//UIBarButtonItem* barButtonItemWiphone;
	UIButton* barButtonItemOnline;
	//UIButton* barButtonItemSync;
    UIButton* barButtonItemAdd;
    UILabel*  labelContactsNum;
	
	ContactDetailsController* contactDetailsController;
    NewContactDelegate* myNewContactDelegate;
	
	BOOL nativeContactsChangedWhileInactive;
	BOOL searching;
	BOOL letUserSelectRow;
	NSMutableDictionary* contacts;
	NSArray* orderedSections;
	UIBadgeView *badgeView;
    
	ContactsFilterGroup_t filterGroup;
	ContactsDisplayMode_t displayMode;
    
@private
    ADBannerView *iadbanner;
    immobView *lmbanner;
    BaiduMobAdView *bdbanner;
    UIButton *buttonAd;
    
    NSString* dialNum;
    BOOL videocallout;    
    NSMutableArray* calloption;
        
    BOOL synctimeout;
    
//    NgnContact* secretary;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    //  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
    
    NSMutableDictionary* friendDic;
    
    BOOL needtoreload;
}

@property (nonatomic, retain) UIBadgeView *badgeView;
@property(nonatomic,retain) IBOutlet UIView *viewToolbar;
//@property(nonatomic,retain) IBOutlet UILabel *labelDisplayMode;
@property(nonatomic,retain) IBOutlet UILabel *labelContactsNum;
@property(nonatomic,retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UIView *headView;
@property (nonatomic, retain) IBOutlet UIButton *secretaryBtn;
@property (nonatomic, retain) IBOutlet UILabel *secretaryLabel;
//@property (nonatomic, retain) IBOutlet UISegmentedControl *m_segmentedControl;
@property(nonatomic,retain) IBOutlet UIButton* barButtonItemAll;
//@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemWiphone;
@property(nonatomic,retain) IBOutlet UIButton* barButtonItemOnline;
//@property(nonatomic,retain) IBOutlet UIButton* barButtonItemSync;
@property(nonatomic,retain) IBOutlet UIButton* barButtonItemAdd;
@property(nonatomic,retain) IBOutlet UIButton *buttonAd;

- (IBAction)onButtonToolBarItemClick: (id)sender;
- (IBAction)onButtonClick:(id)sender;

-(void) refreshDataAndReload;

@end
