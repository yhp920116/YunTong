//
//  SelectTableViewController.h
//  CloudCall
//
//  Created by Sergio on 13-3-5.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>

enum PopViewType
{
    kTagTableViewForSlotMachine,
    kTagTableAlertInvite,
    kTagTableAlertSendMsg
};

@protocol SelectTableViewDelegate <NSObject>
- (void)selectTableViewDidSelected:(NSInteger)index andType:(PopViewType)type;
@end

@interface SelectTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *pointArray;
    id <SelectTableViewDelegate>delegate;
    
    PopViewType popViewType;
}

@property (nonatomic,assign) id <SelectTableViewDelegate>delegate;
@property (nonatomic,retain) UITableView *pointTableView;
@property (nonatomic,retain) NSMutableArray *pointArray;

- (id)initWithFiltertype:(NSMutableArray *)array andViewType:(PopViewType)type andSize:(CGSize)size;

@end
