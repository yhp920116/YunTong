//
//  SelectParticipantFromGroupViewController.h
//  CloudCall
//
//  Created by CloudCall on 13-2-20.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"

@protocol ParticipantPickerFromGroupDelegate <NSObject>
-(void) shouldContinueAfterPickingFromGroup: (NSMutableArray*) contacts;
@end


@interface SelectParticipantFromGroupViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView;
    UIView      *viewToolbar;
    UIToolbar   *toolbar;
    UILabel     *labelTitle;
    
    UIButton *barButtonItemBack;
    UIButton *barButtonDone;
    UIBarButtonItem *barButtonSelectAll;
    
    NSMutableArray* participants;
    NgnConferenceFavorite *conffavorite;
    
    NSString *uuid;
    BOOL IsSelectAll;
    
    UIViewController<ParticipantPickerFromGroupDelegate> *delegate;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIView *viewToolbar;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) UIButton *toolBtnSelectAll;

@property (nonatomic, retain) NgnConferenceFavorite *conffavorite;
@property (nonatomic, retain) NSString *uuid;

-(void) SetDelegate:(UIViewController<ParticipantPickerFromGroupDelegate> *)delegate;

- (IBAction)onButtonToolBarItemClick: (id)sender;
@end
