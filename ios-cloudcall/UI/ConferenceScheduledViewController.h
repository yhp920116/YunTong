/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"

@interface ConferenceScheduledViewController : UIViewController <UITableViewDelegate,UITableViewDataSource> {
    UITableView     *tableView;
    
    NSMutableArray *scheduled;
}

@property(nonatomic,retain) IBOutlet UITableView         *tableView;


- (IBAction) onButtonClick: (id)sender;


@end
