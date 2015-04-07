/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "NewContactViewCell.h"
#import "ContactDetailsController.h"

#define kContactViewCellHeight 48.f

@implementation NewContactViewCell

@synthesize labelDisplayName;
@synthesize labelDisplayArea;
@synthesize labelDisplayMsg;
@synthesize contact;
@synthesize navigationController;

-(NSString *)reuseIdentifier{
	return kNewContactViewCellIdentifier;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

-(void) setDisplayName: (NSString*)displayName{
	labelDisplayName.text = displayName;
}

-(void) setDisplayArea: (NSString*)displayArea
{
    labelDisplayArea.text = displayArea;
}

/**
 *	@brief	设置显示名字与字体颜色
 *
 *	@param 	range 	需要设置不同颜色的位置
 */
- (void)setDisplayName: (NSString*)displayName andRange:(NSRange)range
{
    labelDisplayName.text = displayName;
    
    if (SystemVersion >= 6.0) {
        NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:displayName] autorelease];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, displayName.length)];
        
        if (range.length >= 1)
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:3.0/255.0 green:165.0/255.0 blue:255.0/255.0 alpha:1] range:range];
        
        [labelDisplayName setAttributedText:attributedString];
    }
}

-(void) setDisplayArea: (NSString*)displayArea andRange:(NSRange)range
{
    labelDisplayArea.text = displayArea;
    
    if (SystemVersion >= 6.0) {
        NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:displayArea] autorelease];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, displayArea.length)];
        
        if (range.length >= 1)
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:3.0/255.0 green:165.0/255.0 blue:255.0/255.0 alpha:1] range:range];
        
        [labelDisplayArea setAttributedText:attributedString];
    }
}

-(void) setDisplayMsg: (NSString*)displayMsg andRange:(NSRange)range
{
    labelDisplayMsg.text = displayMsg;
    
    if (SystemVersion >= 6.0) {
        NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:displayMsg] autorelease];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1] range:NSMakeRange(0, displayMsg.length)];
        
        if (range.length >= 1)
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:3.0/255.0 green:165.0/255.0 blue:255.0/255.0 alpha:1] range:range];
        
        [labelDisplayMsg setAttributedText:attributedString];
    }
}

+(CGFloat)getHeight{
	return kContactViewCellHeight;
}

- (void)dealloc {
	[labelDisplayName release];
    [labelDisplayArea release];
	[labelDisplayMsg release];
    
    [super dealloc];
}

-(void)setContact:(NgnContact *)_contact{
	[self->contact release];
	self->contact = [_contact retain];
}

-(NgnContact *)contact{
	return self->contact;
}
@end
