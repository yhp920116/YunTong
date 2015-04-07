/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import <Foundation/Foundation.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>

#import "iOSNgnStack.h"

@class PeoplePicker;

@protocol PeoplePickerDelegate

@required
-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingNumber: (NgnPhoneNumber*)number;
-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingContact: (NgnContact*)contact;

@end

typedef enum PickType_e
{
	PickType_Number,
	PickType_Contact
}
PickType_t;


@interface PeoplePicker : ABPeoplePickerNavigationController<ABPeoplePickerNavigationControllerDelegate> {
	UIViewController<PeoplePickerDelegate> *delegate;
}

@property(nonatomic,retain) UIViewController<PeoplePickerDelegate> *delegate;

-(void) pickNumber: (UIViewController<PeoplePickerDelegate> *)delegate;
-(void) pickContact: (UIViewController<PeoplePickerDelegate> *)delegate;
-(void) dismiss;

@end