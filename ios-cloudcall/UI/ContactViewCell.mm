/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "ContactViewCell.h"
#import "ContactDetailsController.h"
#import "StaticUtils.h"

#define kContactViewCellHeight 48.f

@implementation ContactViewCell

@synthesize imgViewAvatar;
@synthesize labelDisplayName;
@synthesize labelDisplayArea;
@synthesize imgViewFriend;
@synthesize buttonDail;
@synthesize buttonDetails;
@synthesize contact;
@synthesize navigationController;

@synthesize badgeColor, badgeColorHighlighted, showShadow;
@synthesize hideDialButton;


-(NSString *)reuseIdentifier{
	return kContactViewCellIdentifier;
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

-(void) setDisplayName: (NSString*)displayName{
	labelDisplayName.text = displayName;
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

-(void) setDisplayArea: (NSString*)displayArea
{
    labelDisplayArea.text = displayArea;
}

-(void) setIsFriend: (BOOL)_friend {
    if (_friend) {
        [imgViewFriend setHidden:NO];        
        
        CGFloat width = [labelDisplayName.text sizeWithFont:labelDisplayName.font].width;        
        CGRect labelRect = labelDisplayName.frame;
        
        CGRect imgRect = imgViewFriend.frame;
        CGFloat offset = (labelRect.size.height - imgRect.size.height)/2;
        imgViewFriend.frame = CGRectMake(labelRect.origin.x + width + 5, labelRect.origin.y + offset, imgRect.size.width, imgRect.size.height);
    } else {
        [imgViewFriend setHidden:YES];
    }
}

+(CGFloat)getHeight{
	return kContactViewCellHeight;
}


- (void)dealloc {
	[labelDisplayName release];
    [labelDisplayArea release];
    [buttonDail release];
    [buttonDetails release];
	
    [super dealloc];
}

-(void)setContact:(NgnContact *)_contact{
	[self->contact release];
	self->contact = [_contact retain];
    
    [buttonDail setHidden: [contact.phoneNumbers count] == 0];
    
    buttonDail.hidden = hideDialButton;
    
    dispatch_queue_t queue = dispatch_queue_create (DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
    dispatch_async(queue, ^{
        if (contact && contact.picture)
        {
            UIImage *avatarImage = [StaticUtils createRoundedRectImage:[UIImage imageWithData:contact.picture] size:CGSizeMake(80, 80)];
            dispatch_async(dispatch_get_main_queue(), ^{
                imgViewAvatar.image = avatarImage;
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                imgViewAvatar.image = [StaticUtils createRoundedRectImage:[UIImage imageNamed:@"contact_noavatar_icon"] size:CGSizeMake(80, 80)];
            });
        }
    });
    dispatch_release(queue);
}

-(NgnContact *)contact{
	return self->contact;
}

-(void) SetDelegate:(UIViewController<ContactDialDelegate> *)_delegate {
    delegate = _delegate;
}

- (IBAction) onButtonClick: (id)sender{
    if (sender == buttonDail) {
        if ([contact.phoneNumbers count] > 1) {
            if (self.contact && self.navigationController) {
                ContactDetailsController *details = [[ContactDetailsController alloc] initWithNibName:@"ContactDetails" bundle:nil];
                details.contact = self.contact;
                [self.navigationController pushViewController:details animated:YES];
                [details release];
            }
        } else {
            if (delegate) {
                if ([self.contact.phoneNumbers count])
                {
                    NgnPhoneNumber* phonenum = [self.contact.phoneNumbers objectAtIndex:0];
                    if (phonenum)
                    {
                        [delegate shouldContinueAfterContactDialClick:phonenum.number];
                    }
                }
            }
        }
    } else if (sender == buttonDetails)
        if (self.contact && self.navigationController) {
            ContactDetailsController *details = [[ContactDetailsController alloc] initWithNibName:@"ContactDetails" bundle:nil];
            details.contact = self.contact;
            [self.navigationController pushViewController:details animated:YES];
            [details release];
        }
}
@end
