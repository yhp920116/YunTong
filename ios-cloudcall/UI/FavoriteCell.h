/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

 #import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kFavoriteCellIdentifier
#define kFavoriteCellIdentifier	@"FavoriteCellIdentifier"

@interface FavoriteCell : UITableViewCell {
	UILabel *labelDisplayName;
	UILabel *labelPhoneType;
	UIImageView *imageViewPhoneType;
	UIButton *buttonDetails;
	NgnFavorite *favorite;
	UINavigationController *navigationController;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (retain, nonatomic) IBOutlet UILabel *labelPhoneType;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewPhoneType;
@property (retain, nonatomic) IBOutlet UIButton *buttonDetails;
@property(nonatomic, retain) NgnFavorite *favorite;
@property(nonatomic, retain) UINavigationController *navigationController;


- (IBAction) onButtonDetailsClick: (id)sender;

@end
