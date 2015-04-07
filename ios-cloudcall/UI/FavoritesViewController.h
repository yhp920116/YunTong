/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import "PeoplePicker.h"

#import "iOSNgnStack.h"

@interface FavoritesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,PeoplePickerDelegate,UIActionSheetDelegate> {
	UITableView *tableView;
	UIView *viewNoFavorites;
    UILabel *labelPrpmpt;
	UIButton *buttonAddFavorite;
	UIBarButtonItem *navigationItemEdit;
	UIBarButtonItem *navigationItemDone;
	UIBarButtonItem *navigationItemAdd;
	
	NSMutableArray* favorites;
	NgnPhoneNumber* pickedNumber;
}

@property(nonatomic,retain) NgnPhoneNumber *pickedNumber;

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIView *viewNoFavorites;
@property(nonatomic,retain) IBOutlet UILabel *labelPrpmpt;
@property(nonatomic,retain) IBOutlet UIButton *buttonAddFavorite;

- (IBAction) onButtonAddFavoriteClick: (id)sender;
- (IBAction) onButtonNavivationItemClick: (id)sender;

@end
