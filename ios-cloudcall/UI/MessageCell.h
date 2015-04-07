/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

#import "MessagesViewController.h"

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kMessageCellIdentifier
#undef kMessageCellHeight
#define kMessageCellIdentifier	@"MessageCellIdentifier"

@interface MessageCell : UITableViewCell {
	UILabel *labelDisplayName;
	UILabel *labelContent;
	UILabel *labelDate;
	UIImageView *headImage;
	//MessageHistoryEntry *entry;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (retain, nonatomic) IBOutlet UILabel *labelContent;
@property (retain, nonatomic) IBOutlet UILabel *labelDate;
@property (retain, nonatomic) IBOutlet UIImageView *headImage;
//@property (retain, nonatomic) MessageHistoryEntry *entry;

+(CGFloat)height;

@end
