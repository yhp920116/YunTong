/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "IAPProductCell.h"


@implementation IAPProductCell

@synthesize labelTitle;
@synthesize labelDescription;
@synthesize buttonRecharge;

-(NSString *)reuseIdentifier{
	return kIAPProductCellIdentifier;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

-(void) SetProductInfo:(NSString*) title andDescription:(NSString*)description {
    labelTitle.text = title;
    labelDescription.text = description;
}

- (void)dealloc {
	[labelTitle release];
	[labelDescription release];
    [buttonRecharge release];
	
    [super dealloc];
}

#define kCellTopHeight		     20.f
#define kCellBottomHeight	     20.f
#define kCellTitleHeight	     20.f
#define kCellDescriptionFontSize 13.f

+(CGFloat)getHeight:(NSString*)description constrainedWidth:(CGFloat)width{
    CGSize constraintSize;
    constraintSize.width = width;
    constraintSize.height = MAXFLOAT;
    CGSize contentSize = [description sizeWithFont:[UIFont fontWithName:@"Arial" size:kCellDescriptionFontSize] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return kCellTopHeight + kCellBottomHeight + kCellTitleHeight + contentSize.height;
}


@end
