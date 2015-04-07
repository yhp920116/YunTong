/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "MessageCell.h"

#define kMessageCellHeight		50.f

@implementation MessageCell

@synthesize labelDisplayName;
@synthesize labelContent;
@synthesize labelDate;
@synthesize headImage;

-(NSString *)reuseIdentifier{
	return kMessageCellIdentifier;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

/*-(MessageHistoryEntry*)entry{
	return self->entry;
}

-(void)setEntry:(MessageHistoryEntry*)entry_{
	[self.entry release];
	if((self->entry = [entry_ retain])){
		// remote party
		NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:self.entry.remoteParty];
		self.labelDisplayName.text = (contact && contact.displayName) ? contact.displayName :
						(self.entry.remoteParty ? self.entry.remoteParty : NSLocalizedString(@"Unknown", @"Unknown"));
		
		// content
		self.labelContent.text =  self.entry.content ? self.entry.content : @"";
		
		// date
		self.labelDate.text = [[NgnDateTimeUtils historyEventDate] stringFromDate:self.entry.date];
        
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
}*/

+(CGFloat)height{
	return kMessageCellHeight;
}

- (void)dealloc {
	[labelDisplayName release];
	[labelContent release];
	[labelDate release];
	[headImage release];
	
    [super dealloc];
}


@end
