//
//  MoreViewCell.h
//  CloudCall
//
//  Created by CloudCall on 13-1-29.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MoreViewCellDelegate <NSObject>
-(void) buttonClickCallBack:(NSInteger)index;
@end

@interface MoreViewCell : UIView
{
    UILabel *labelName;
    UIButton *buttonAction;
    
    UIViewController<MoreViewCellDelegate> *delegate;
}
@property (nonatomic, retain) IBOutlet UILabel *labelName;
@property (nonatomic, retain) IBOutlet UIButton *buttonAction;

-(void) SetDelegate:(UIViewController<MoreViewCellDelegate> *)_delegate;
- (id)initWithFrame:(CGRect)frame withButtonTag:(NSInteger)tag withBtnNormalImage:(UIImage *)imageNormal withBtnPressImage:(UIImage *)imagePress withLabelName:(NSString *)name;
@end
