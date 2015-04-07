//
//  RecentDetailCell.h
//  CloudCall
//
//  Created by Sergio on 13-6-14.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kRecentDetailCellIdentifier
#define kRecentDetailCellIdentifier	@"kRecentDetailCellIdentifier"

@interface RecentDetailCell : UITableViewCell{
    UILabel *labelDisplayNumber;
    UILabel *labelDuration;
    UILabel *labelDate;
    UIImageView *imgViewType;
    UILabel *callType;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayNumber;
@property (retain, nonatomic) IBOutlet UILabel *labelDuration;
@property (retain, nonatomic) IBOutlet UILabel *labelDate;
@property (retain, nonatomic) IBOutlet UIImageView *imgViewType;
@property (retain, nonatomic) IBOutlet UILabel *callType;

-(void)setEvent: (NgnHistoryEvent*)event;
@end
