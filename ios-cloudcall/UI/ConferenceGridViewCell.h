//
//  ConferenceGridViewCell.h
//  CloudCall
//
//  Created by CloudCall on 13-1-29.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ConferenceGridViewCellDelegate <NSObject>
-(void) shouldContinueAfterParticipantCellClick:(NSString*)number andIsAdd:(BOOL)add;
@end

@interface ConferenceGridViewCell : UIView
{
    UIImageView *headPortrait;
    UILabel *name;
    UILabel *phoneNumber;
    UIButton *buttonAction;
    UIImageView *selectedImage;
    UILabel *callingStatus;
    
    NSString* number;
    BOOL buttonIsAdd;
    
    UIViewController<ConferenceGridViewCellDelegate> *delegate;
}
@property (nonatomic, retain) IBOutlet UIImageView *headPortrait;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *phoneNumber;
@property (nonatomic, retain) IBOutlet UIButton *buttonAction;
@property (nonatomic, retain) IBOutlet UIImageView *selectedImage;
@property (nonatomic, retain) IBOutlet UILabel *callingStatus;

@property (nonatomic, retain) NSString* number;
@property (readwrite) BOOL buttonIsAdd;

-(void) SetDelegate:(UIViewController<ConferenceGridViewCellDelegate> *)_delegate;
@end
