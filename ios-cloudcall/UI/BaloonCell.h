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
#undef kBaloonCellIdentifier
#undef kBaloonCellIndentValue
#define kBaloonCellIdentifier	@"BaloonCellIdentifier"
#import "PPLabel.h"

@interface BaloonCell : UITableViewCell<PPLabelDelegate>
{
    UIImageView *imgViewAvatar;
	PPLabel *labelContent;
	UILabel *labelDate;
}


@property (nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (retain, nonatomic) IBOutlet UIImageView *imgViewAvatar;
@property (retain, nonatomic) IBOutlet PPLabel *labelContent;
@property (retain, nonatomic) IBOutlet UILabel *labelDate;
@property (retain, nonatomic) NSArray *matches;

-(void)setEvent:(NgnHistorySMSEvent*)event forTableView:(UITableView*)tableView;
+(CGFloat)getHeight:(NgnHistorySMSEvent*)event constrainedWidth:(CGFloat)width;

-(void)setSysNotify:(NgnSystemNotification*)notify andImage:(UIImage*)img forTableView:(UITableView*)tableView;
+(CGFloat)getSysNotifyHeight:(NgnSystemNotification*)notify constrainedWidth:(CGFloat)width;
+(CGFloat)getDefaultSysNotifyHeight:(NgnSystemNotification*)notify constrainedWidth:(CGFloat)width;

@end
