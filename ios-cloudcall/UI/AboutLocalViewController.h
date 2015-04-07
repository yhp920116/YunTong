//
//  AboutLocalViewController.h
//  CloudCall
//
//  Created by CloudCall on 12-8-24.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutLocalViewController : UIViewController
{
    UILabel *Version;
    UILabel *DeclareLabel;//只是用来显示白色的背景
    UIButton *DeclareBtn;
    UILabel *labelCopyright;
}

@property(nonatomic, retain) UILabel *Version;
@property(nonatomic, retain) UILabel *DeclareLabel;
@property(nonatomic, retain) IBOutlet UIButton *DeclareBtn;
@property(nonatomic, retain) IBOutlet UILabel *labelCopyright;

- (IBAction)OnDeclareBtnClick:(id)sender;
- (void) backToSetting: (id)sender;
@end
