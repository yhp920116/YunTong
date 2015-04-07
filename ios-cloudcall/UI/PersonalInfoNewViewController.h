//
//  PersonalInfoNewViewController.h
//  CloudCall
//
//  Created by Sergio on 13-1-29.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"
#import "MBProgressHUD.h"


@interface PersonalInfoNewViewController : UIViewController<UIAlertViewDelegate, UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIButton *barButtonItemBack;
    UIButton *barButtonItemSubmit;
    UIView *tipView;
    
    UITableView *tableView;
    UITableViewCell *headerCell;
    UIView *rHeaderView;
    UIImage *photoImage;
    UIImageView *photo;
    UITextField *name;
    UIImageView *vipLevel;
    UILabel *phoneNum;
    
    NSArray *personalInfoPlaceholderArray;
    NSArray *personalInfoArray;
    NSMutableDictionary *personalInfoDict;
    
    NSString *trueName;
    NSString *nickName;
    NSString *sex;
    NSString *birthday;
    NSString *email;
    NSString *qq;
    NSString *sinawb;
    
    UITextField *currentTextFeild;
    NSInteger editingFeildIndex;
    
    UIPickerView *pickerGender;
    NSArray *genderData;
    UIDatePicker *pickerBirthdate;
    UIToolbar *keyboardToolbar;
    NSString *oldContent;
        
    NSString *sina_Id;
    NSString *sina_gender;
    NSString *sina_location;
    NSString *sina_profileUrl;
    NSString *sina_verified;
    NSDictionary *sina_weiBoJsonData;
    
@private
    NSInteger reqType;
    MBProgressHUD *_hud;
}

@property (nonatomic,retain) IBOutlet UIView *tipView;
@property (nonatomic,retain) IBOutlet UILabel *tipText;
@property (nonatomic,retain) IBOutlet UIButton *btnCloseTip;
@property (nonatomic,retain) IBOutlet UITableView *tableView;
@property (nonatomic,retain) IBOutlet UITableViewCell *headerCell;
@property (nonatomic,retain) IBOutlet UIView *rHeaderView;
@property (nonatomic,retain) IBOutlet UIImageView *photo;
@property (nonatomic,retain) IBOutlet UITextField *name;
@property (nonatomic,retain) IBOutlet UIImageView *vipLevel;
@property (nonatomic,retain) IBOutlet UILabel *phoneNum;
@property (nonatomic,retain) NSArray *personalInfoPlaceholderArray;
@property (nonatomic,retain) NSArray *personalInfoArray;
@property (nonatomic,retain) NSMutableDictionary *personalInfoDict;
@property (nonatomic,retain) NSString *trueName;
@property (nonatomic,retain) NSString *nickName;
@property (nonatomic,retain) NSString *sex;
@property (nonatomic,retain) NSString *birthday;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *qq;
@property (nonatomic,retain) NSString *sinawb;
@property (nonatomic,retain) UITextField *currentTextFeild;
@property (nonatomic,retain) IBOutlet UIPickerView *pickerGender;
@property (nonatomic,retain) IBOutlet UIDatePicker *pickerBirthdate;

@property (nonatomic,retain) IBOutlet UIButton *buttonAd;


@property (nonatomic,retain) NSString *sina_Id;
@property (nonatomic,retain) NSString *sina_gender;
@property (nonatomic,retain) NSString *sina_location;
@property (nonatomic,retain) NSString *sina_verified;
@property (nonatomic,retain) NSString *sina_profileUrl;
@property (nonatomic,retain) NSDictionary *sina_weiBoJsonData;

@property (retain) MBProgressHUD *hud;

- (IBAction)touchBGEndingEditing:(id)sender;
- (IBAction)closeTip:(id)sender;
@end
