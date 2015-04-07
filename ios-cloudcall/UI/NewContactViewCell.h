//
//  NewContactViewCell.h
//  CloudCall
//
//  Created by Sergio on 13-4-2.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kContactViewCellIdentifier
#define kNewContactViewCellIdentifier	@"NewContactViewCellIdentifier"

@interface NewContactViewCell : UITableViewCell {
	UILabel *labelDisplayName;
    UILabel *labelDisplayArea;
    UILabel *labelDisplayMsg;
    NgnContact *contact;
    UINavigationController *navigationController;
}

@property (retain, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayArea;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayMsg;
@property(nonatomic, readonly, copy) NSString  *reuseIdentifier;
@property(nonatomic, retain) NgnContact *contact;
@property(nonatomic, retain) UINavigationController *navigationController;

-(void) setDisplayName: (NSString*)displayName;
-(void) setDisplayName: (NSString*)displayName andRange:(NSRange)range;
-(void) setDisplayArea: (NSString*)displayArea;
-(void) setDisplayArea: (NSString*)displayArea andRange:(NSRange)range;
-(void) setDisplayMsg: (NSString*)displayMsg andRange:(NSRange)range;
+(CGFloat)getHeight;
@end

