/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SelectNumberViewController.h"

@interface InviteFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NumberPickerDelegate>
{
    UILabel *shareUrlLabel;
    
    UITableView *tableView;
    UITextField *shareUrlField;
    UIButton *cpButton;
    UIButton *shareButton;

    int setRefereeAward;
    int inviteAward;
    int award;

    NSString *referee;
    NSArray *refer;
    
}
@property (nonatomic, retain) IBOutlet UILabel *shareUrlLabel;
@property (nonatomic, retain) IBOutlet UITextField *shareUrlField;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *cpButton;

@property (nonatomic, retain) NSString *referee;
@property (nonatomic, retain) NSArray *refer;

- (IBAction)ButtonClick:(id)sender;
- (void)OpenWebBrowser:(NSString *)url;

@end
