//
//  CreateGroupViewController.h
//  CloudCall
//
//  Created by CloudCall on 13-6-19.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGroupViewController : UIViewController
{
    UIButton *addGroupMembersBtn;
    UILabel *inputGroupNameLabel;
    UITextField *groupNameField;
}
@property (nonatomic, retain) IBOutlet UILabel *inputGroupNameLabel;
@property (nonatomic, retain) IBOutlet UIButton *addGroupMembersBtn;
@property (nonatomic, retain) IBOutlet UITextField *groupNameField;

- (IBAction)ButtonClick:(id)sender;
@end
