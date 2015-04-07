/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import "BannerViewContainer.h"

#import <iAd/iAd.h>
#import "BaiduMobAdView.h"
#import <immobSDK/immobView.h>

#define kTagFaceView 110

@interface MessagesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,BannerViewContainer> {
    UISearchBar *searchBar;
    UIToolbar *toolBar;
	UITableView *tableView;
	UIView *viewToolbar;
    UILabel *labelTitle;
    
@private
    ADBannerView *iadbanner;
    immobView *lmbanner;
    BaiduMobAdView *bdbanner;
    UIButton *buttonAd;
    NSMutableArray *friendArray;
}

@property (retain, nonatomic) IBOutlet UIButton *buttonAd;
@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIView *viewToolbar;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;

- (void)EnterIMChatView:(NSString *)friendAccount;
@end
