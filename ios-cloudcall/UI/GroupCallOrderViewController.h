//
//  GroupCallOderViewController.h
//  CloudCall
//
//  Created by CloudCall on 13-6-20.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "iOSNgnStack.h"

@interface GroupCallOrderViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>
{
    UILabel *topicLabel;
    UILabel *startTimeLabel;
    UILabel *remindLabel;
    UILabel *membersLabel;
    
    UIButton *sendOrderSMS;
    UITextField *groupCallTopic;
    
    UITextField *remindTimeField;
    UIDatePicker *remindTimePicker;
    UISwitch *remindSwitch;

    UIToolbar *keyboardToolbar;
    UITableView *orderTableView;
    NSArray *participantsOrder;
    
    NgnConferenceFavorite *conffavorite;
}
@property (nonatomic, retain) NgnConferenceFavorite *conffavorite;
@property (nonatomic, retain) IBOutlet UILabel *topicLabel;
@property (nonatomic, retain) IBOutlet UILabel *startTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *remindLabel;
@property (nonatomic, retain) IBOutlet UILabel *membersLabel;
@property (nonatomic, retain) IBOutlet UITextField *groupCallTopic;
@property (nonatomic, retain) NSArray *participantsOrder;
@property (nonatomic, retain) IBOutlet UITextField *remindTimeField;
@property (nonatomic, retain) IBOutlet UIDatePicker *remindTimePicker;
@property (nonatomic, retain) IBOutlet UISwitch *remindSwitch;

@property (nonatomic, retain) IBOutlet UIButton *sendOrderSMS;
@property (nonatomic, retain) IBOutlet UITableView *orderTableView;

- (IBAction)onSwitchChanged: (id) sender;
- (IBAction)ButtonClick:(id)sender;
- (IBAction) textFieldDoneEditing:(id)sender;
@end
