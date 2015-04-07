//
//  IReferViewController.h
//  CloudCall
//
//  Created by CloudCall on 13-6-25.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IReferViewController : UITableViewController
{
    NSArray *refer;
}

@property (nonatomic, retain) NSArray *refer;

- (id)initWithStyle:(UITableViewStyle)style withReferArray:(NSArray *)referArra;
@end
