/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate> {
    UITableView    *tableView;
    UIView         *viewToolbar;
    UILabel        *labelNum;
    UILabel        *labelTitle;
    UIToolbar      *toolbar;
    
    UIButton* barButtonBack;
    UIButton* barButtonClear;
    
//    BOOL showDefaultMsg;
    
@private
    NSMutableArray* sysnotification;
    

    UIButton *buttonAd;
}

@property(nonatomic,retain) IBOutlet UITableView        *tableView;
@property(nonatomic,retain) IBOutlet UIView             *viewToolbar;
@property(nonatomic,retain) IBOutlet UIToolbar          *toolbar;
@property(nonatomic,retain) IBOutlet UILabel            *labelTitle;
@property(nonatomic,retain) IBOutlet UILabel            *labelNum;
@property(nonatomic,retain) IBOutlet UIButton           *buttonAd;

@end
