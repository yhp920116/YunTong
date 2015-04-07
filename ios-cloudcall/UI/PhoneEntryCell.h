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
#undef kPhoneEntryCellIdentifier
#define kPhoneEntryCellIdentifier	@"PhoneEntryCellIdentifier"

@interface PhoneEntryCell : UITableViewCell {
	UILabel *labelAreaOfPhone;
	UILabel *labelPhoneValue;
    UIImageView* imgViewFriend;
	NgnPhoneNumber* number;
}

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (nonatomic, retain) NgnPhoneNumber *number;
@property (retain, nonatomic) IBOutlet UILabel *labelAreaOfPhone;
@property (retain, nonatomic) IBOutlet UILabel *labelPhoneValue;
//@property (retain, nonatomic) IBOutlet UIImageView* imgViewFriend;


-(void)setFriend:(BOOL)isFriend;


@end
