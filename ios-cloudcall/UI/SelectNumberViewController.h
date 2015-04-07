/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@protocol NumberPickerDelegate <NSObject>
-(void) setRefereeSucess;
@end


@interface NumberInfo : NSObject {
@public
    NSString* Name;
	NSString* Number;
    NSString* Description;
    
    BOOL selected;
    
    NSRange displayNameRange;
    NSRange displayNumberRange;
}

@property (nonatomic,assign) NSRange displayNameRange;
@property (nonatomic,assign) NSRange displayNumberRange;

@end

typedef enum {
    Select_Number_Style_Multiple,
    Select_Number_Style_Single    
} SelectNumberStyle;

typedef enum {
    Select_Number_Type_Default,
    Select_Number_Type_Mobile_Only,
    Select_Number_Type_Multiple_In_One,
} SelectNumberType;

@interface SelectNumberViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    UISearchBar *searchBar;
    UITableView *tableView;
    
    UIBarButtonItem *barButtonDone;
    UIButton *toolBtnDone;
    
    NSMutableDictionary* contacts;
    NSArray* orderedSections;
    
    
    UIViewController<NumberPickerDelegate> *delegate;
    
@private
    SelectNumberStyle style;
    SelectNumberType type;
    
    NSIndexPath* lastIndexPath;
    
    BOOL searching;
	BOOL letUserSelectRow;
    
    MBProgressHUD *_hud;
    
}

@property (retain, nonatomic) IBOutlet UIView *searchView;
@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) UIButton *toolBtnDone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDelegate:(UIViewController<NumberPickerDelegate> *)_delegate andStyle:(SelectNumberStyle)_style andType:(SelectNumberType)_type;
- (void) backToSetting: (id)sender;

@end
