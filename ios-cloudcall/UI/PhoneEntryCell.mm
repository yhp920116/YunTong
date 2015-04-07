/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "PhoneEntryCell.h"
#import "AreaOfPhoneNumber.h"

@implementation PhoneEntryCell

@synthesize labelAreaOfPhone;
@synthesize labelPhoneValue;
//@synthesize imgViewFriend;

-(NSString *)reuseIdentifier{
	return kPhoneEntryCellIdentifier;
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

-(void) setNumber:(NgnPhoneNumber *)number_{
 [self.number release];
 if((self->number = [number_ retain]))
 {
     AreaOfPhoneNumber *areaOfPhoneNumber = [[AreaOfPhoneNumber alloc] initWithPhoneNumber:self.number.number];
     self.labelAreaOfPhone.text = [areaOfPhoneNumber getAreaByPhoneNumber];
     [areaOfPhoneNumber release];
     
     self.labelPhoneValue.text = self.number.number;
//     [self.imgViewFriend setHidden:YES];
     
     CGFloat width = [labelPhoneValue.text sizeWithFont:labelPhoneValue.font].width;
     CGRect labelRect = labelPhoneValue.frame;
     
     CGRect areaRect = labelAreaOfPhone.frame;
     labelAreaOfPhone.frame = CGRectMake(labelRect.origin.x + width + 5, areaRect.origin.y, areaRect.size.width, areaRect.size.height);
 }
}

-(NgnPhoneNumber*) number{
	return self->number;
}

-(void)setFriend:(BOOL)isFriend {
    CGFloat width = [labelPhoneValue.text sizeWithFont:labelPhoneValue.font].width;
    CGRect labelRect = labelPhoneValue.frame;
    
    CGRect areaRect = labelAreaOfPhone.frame;
    labelAreaOfPhone.frame = CGRectMake(labelRect.origin.x + width + 5, areaRect.origin.y, areaRect.size.width, areaRect.size.height);
    
    if (isFriend) {
//        [self.imgViewFriend setHidden:NO];
        
//        width = [labelAreaOfPhone.text sizeWithFont:labelAreaOfPhone.font].width;
//        CGRect imgRect = imgViewFriend.frame;
//        areaRect = labelAreaOfPhone.frame;
//        imgViewFriend.frame = CGRectMake(areaRect.origin.x + width + 5, imgRect.origin.y, imgRect.size.width, imgRect.size.height);
    } else {
//        [self.imgViewFriend setHidden:YES];
    }
}

- (void)dealloc {
	[labelAreaOfPhone release];
	[labelPhoneValue release];
//    [imgViewFriend release];
	[number release];
	
    [super dealloc];
}


@end
