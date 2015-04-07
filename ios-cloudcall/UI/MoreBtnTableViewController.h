//
//  MoreBtnTableViewController.h
//  CloudCall
//
//  Created by CloudCall on 13-6-20.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoreBtnTableViewDelegate <NSObject>
- (void)MoreBtnTableViewDidSelectRowAtIndexPath:(NSInteger)optionClick;
@end


@interface MoreBtnTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *optionsArray;
}

@property (nonatomic,retain) UITableView *optionsTableView;
@property (nonatomic,retain) NSMutableArray *optionsArray;

@property (nonatomic, retain) id<MoreBtnTableViewDelegate> delegate;
@end
