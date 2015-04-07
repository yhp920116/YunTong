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
#undef kRecentCellIdentifier
#define kRecentCellIdentifier	@"RecentCellIdentifier"

@interface RecentCell : UITableViewCell {
	UILabel *labelDisplayName;
    UILabel *labelDisplayNumber;
	UILabel *labelDuration;
	UILabel *labelDate;
    
    UIImageView *imgViewType;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayNumber;
@property (retain, nonatomic) IBOutlet UILabel *labelDuration;
@property (retain, nonatomic) IBOutlet UILabel *labelDate;
@property (retain, nonatomic) IBOutlet UIImageView *imgViewType;

-(void)setEvent: (NgnHistoryEvent*)event;

@end
