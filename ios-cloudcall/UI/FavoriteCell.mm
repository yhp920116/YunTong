/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "FavoriteCell.h"
#import "ContactDetailsController.h"

@interface FavoriteCell(Private)
+(UIImage*) imageForMediaType: (NgnMediaType_t)mediaType;
@end


@implementation FavoriteCell(Private)

+(UIImage*) imageForMediaType: (NgnMediaType_t)mediaType{
	static UIImage* imageSMS = nil;
	static UIImage* imageAudio = nil;
	static UIImage* imageVideo = nil;
	
	switch (mediaType) {
		case MediaType_SMS:
			if(imageSMS == nil){
				imageSMS = [[UIImage imageNamed:@"type_sms"] retain];
			}
			return imageSMS;
			
		case MediaType_Audio:
			if(imageAudio == nil){
				imageAudio = [[UIImage imageNamed:@"type_audio"] retain];
			}
			return imageAudio;
			
		case MediaType_AudioVideo:
		case MediaType_Video:
			if(imageVideo == nil){
				imageVideo = [[UIImage imageNamed:@"type_video"] retain];
			}
			return imageVideo;
			
		default:
			return nil;
	}
}
@end



@implementation FavoriteCell

@synthesize labelDisplayName;
@synthesize labelPhoneType;
@synthesize imageViewPhoneType;
@synthesize buttonDetails;
@synthesize navigationController;

-(NSString *)reuseIdentifier{
	return kFavoriteCellIdentifier;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setFavorite:(NgnFavorite* )favorite_{
	[self->favorite release];
	self.labelPhoneType.text = @"";
	self.labelDisplayName.text = @"";
	
	if((self->favorite = [favorite_ retain])){
		if(self.favorite.contact){
			for (NgnPhoneNumber* phoneNumber in self.favorite.contact.phoneNumbers) {
				if([phoneNumber.number isEqualToString: self.favorite.number]){
					self.labelPhoneType.text = phoneNumber.description;
					break;
				}
			}
		}
		self.labelDisplayName.text = self.favorite.displayName;
		self.buttonDetails.hidden = (self.favorite.contact == nil);
		self.imageViewPhoneType.image =[FavoriteCell imageForMediaType:self.favorite.mediaType];
	}
}

-(NgnFavorite *)favorite{
	return self->favorite;
}

- (IBAction) onButtonDetailsClick: (id)sender{
	if(self.favorite.contact && self.navigationController){
		ContactDetailsController *details = [[ContactDetailsController alloc] initWithNibName:@"ContactDetails" bundle:nil];
		details.contact = self.favorite.contact;
		[self.navigationController pushViewController:details animated:YES];
		[details release];
	}
}

- (void)dealloc {
	[favorite release];
	[labelDisplayName release];
	[labelPhoneType release];
	[imageViewPhoneType release];
	[navigationController release];
	[buttonDetails release];
	
    [super dealloc];
}


@end
