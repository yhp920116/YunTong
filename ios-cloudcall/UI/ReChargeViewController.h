//
//  ReChargeViewController.h
//  CloudCall
//
//  Created by Sergio on 13-1-23.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ValidCodeBGView.h"

@interface ReChargeViewController : UIViewController
{
    UITextField *phoneNum;
    UITextField *cardNum;
    UITextField *cardPwd;
    UITextField *validCode;
    
    //验证码部分
    ValidCodeBGView *validCodeBGView;
    UILabel *lable1;
    UILabel *lable2;
    UILabel *lable3;
    UILabel *lable4;
    NSMutableArray *pointArray;
    
    int number;
    NSMutableString *strValidCode;
    BOOL is404error;
    BOOL connectionfinish;
}
@property (nonatomic,retain) NSMutableString *strValidCode;
@property (nonatomic,retain) IBOutlet UITextField *phoneNum;
@property (nonatomic,retain) IBOutlet UITextField *cardNum;
@property (nonatomic,retain) IBOutlet UITextField *cardPwd;
@property (nonatomic,retain) IBOutlet UITextField *validCode;
@property (nonatomic,retain) IBOutlet UIButton *btnSurRecharge;

@property (nonatomic,retain) IBOutlet ValidCodeBGView *validCodeBGView;
@property (nonatomic,retain) IBOutlet UILabel *lable1;
@property (nonatomic,retain) IBOutlet UILabel *lable2;
@property (nonatomic,retain) IBOutlet UILabel *lable3;
@property (nonatomic,retain) IBOutlet UILabel *lable4;

- (IBAction)btnRechargeClick:(id)sender;
- (IBAction)touchBGEndingEditing:(id)sender;
- (IBAction)changeValidCode:(id)sender;

@end
