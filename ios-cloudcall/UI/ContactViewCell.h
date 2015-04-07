/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"


// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kContactViewCellIdentifier
#define kContactViewCellIdentifier	@"ContactViewCellIdentifier"


@protocol ContactDialDelegate <NSObject>
-(void) shouldContinueAfterContactDialClick:(NSString*)dialNum;
@end


@interface ContactViewCell : UITableViewCell {
    UIImageView* imgViewAvatar;
	UILabel *labelDisplayName;
    UILabel *labelDisplayArea;
    UIImageView* imgViewFriend;
    UIButton *buttonDail;
    UIButton *buttonDetails;
    NgnContact *contact;
    UINavigationController *navigationController;
    
    UIViewController<ContactDialDelegate> *delegate;
    
    BOOL hideDialButton;
}

@property (retain, nonatomic) IBOutlet UIImageView* imgViewAvatar;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayArea;
@property (retain, nonatomic) IBOutlet UIImageView* imgViewFriend;
@property (retain, nonatomic) IBOutlet UIButton *buttonDail;
@property (retain, nonatomic) IBOutlet UIButton *buttonDetails;
@property (nonatomic, readonly, copy) NSString  *reuseIdentifier;
@property (nonatomic, retain) NgnContact *contact;
@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic, retain)   UIColor *badgeColor;
@property (nonatomic, retain)   UIColor *badgeColorHighlighted;
@property (nonatomic, assign)   BOOL showShadow;
@property (nonatomic, assign)   BOOL hideDialButton;

-(void) setDisplayName: (NSString*)displayName;
-(void) setDisplayName: (NSString*)displayName andRange:(NSRange)range;
-(void) setDisplayArea: (NSString*)displayArea;
-(void) setIsFriend: (BOOL)_friend;

+(CGFloat)getHeight;
-(void) setIsFriend: (BOOL)_friend;
-(void) SetDelegate:(UIViewController<ContactDialDelegate> *)_delegate;

- (IBAction) onButtonClick: (id)sender;

@end
