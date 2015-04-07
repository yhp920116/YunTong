//
//  RechargeCollectViewController.h
//  CloudCall
//
//  Created by Sergio on 13-6-21.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudCall2AppDelegate.h"

@interface RechargeCollectViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *rechargeArray;
}

@property (nonatomic,retain) NSMutableArray *rechargeArray;
@property (nonatomic,retain) IBOutlet UITableView *_tableView;

@end
