/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kIAPProductCellIdentifier
#define kIAPProductCellIdentifier	@"IAPProductCellIdentifier"

@interface IAPProductCell : UITableViewCell {
	UILabel*  labelTitle;
	UILabel*  labelDescription;
    UIButton* buttonRecharge;
}

@property (nonatomic, readonly, copy) NSString  *reuseIdentifier;
@property (retain, nonatomic) IBOutlet UILabel  *labelTitle;
@property (retain, nonatomic) IBOutlet UILabel  *labelDescription;
@property (retain, nonatomic) IBOutlet UIButton *buttonRecharge;

-(void) SetProductInfo:(NSString*) title andDescription:(NSString*)description;
+(CGFloat)getHeight:(NSString*)description constrainedWidth:(CGFloat)width;

@end
