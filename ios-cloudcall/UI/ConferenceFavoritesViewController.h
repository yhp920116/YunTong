/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"
#import "BannerViewContainer.h"
#import "EGORefreshTableHeaderView.h"
#import "SelectParticipantFromGroupViewController.h"

#import <iAd/iAd.h>
#import <immobSDK/immobView.h>
#import "BaiduMobAdView.h"

#define kConferenceFavTableReload @"ConfFavTableViewReload"

@interface ConferenceFavoritesViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,BannerViewContainer,EGORefreshTableHeaderDelegate> {
    UITableView *tableView;
    UIView      *viewToolbar;
    UIToolbar   *toolbar;
    UILabel     *labelTitle;    
    NSString    *GroupName;    //从群组中选择成员时,用于判断隐藏本群组
    UITextField *m_nameTextField;
    UITableViewCell     *cellCreateGroup;
    
    UIButton *barButtonItemBack;
    UIButton *barButtonAddGroup;
    
    NSMutableArray *favorites;
    BOOL isFromConferenceView;
    
    int longPressRow;
    BOOL actionSheetShowed;
    
    UIViewController<ParticipantPickerFromGroupDelegate> *delegate;
@private
    ADBannerView *iadbanner;
    immobView *lmbanner;
    BaiduMobAdView *bdbanner;

    UIButton *buttonAd;
    
    NSString* mynum;
    EGORefreshTableHeaderView *_refreshHeaderView;    
    //  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;

    NSString* myfamilygrpid;
    NSString* myfriendsgrpid;
}
@property (nonatomic, assign) BOOL isFromConferenceView;
@property (nonatomic, retain) NSString *GroupName;
@property (nonatomic, retain) UITextField *m_nameTextField;

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIView *viewToolbar;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;

@property(nonatomic, retain) IBOutlet UITableViewCell *cellCreateGroup;
@property(nonatomic,retain) IBOutlet UIButton            *buttonAd;

- (IBAction)onButtonToolBarItemClick: (id)sender;
- (void)addDefultGroup:(NSString *)myMumber;
- (void)SetDelegate:(UIViewController<ParticipantPickerFromGroupDelegate> *)_delegate;
- (void)enterGroupDetailedView:(NSString *)_uuid;
@end
