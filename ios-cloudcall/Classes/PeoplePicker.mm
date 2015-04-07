/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import "PeoplePicker.h"

#import <AddressBook/AddressBook.h>

#import "CloudCall2AppDelegate.h"

@implementation PeoplePicker

@synthesize delegate;

-(void) viewDidLoad{
	[super viewDidLoad];
	
	self.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)picker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
	
	NgnContact* contact = [[NgnContact alloc] initWithABRecordRef:person];
	BOOL shoudContinue = [self.delegate peoplePicker:self  shouldContinueAfterPickingContact:contact];
	[contact release];
	
	return shoudContinue;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)picker shouldContinueAfterSelectingPerson:(ABRecordRef)person
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
	
	BOOL shoudContinue = NO;
	NgnPhoneNumber* ngnPhoneNumber = nil;
	
	//if(kABPersonPhoneProperty == property && kABPersonPhoneProperty == identifier){
		ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
		int idx = ABMultiValueGetIndexForIdentifier (phoneProperty, identifier);
		CFStringRef label = ABMultiValueCopyLabelAtIndex(phoneProperty, idx);
		CFStringRef description = (CFStringRef)ABAddressBookCopyLocalizedLabel(label);
		CFStringRef number = (CFStringRef)ABMultiValueCopyValueAtIndex(phoneProperty, idx);
		
		ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber: (NSString*)number andDescription: (NSString*)description];
		
		CFRelease(phoneProperty);
		CFRelease(label);
		CFRelease(description);
		CFRelease(number);
	//}

	shoudContinue = [self.delegate peoplePicker:self shouldContinueAfterPickingNumber:ngnPhoneNumber];
	[ngnPhoneNumber release];
	
	return shoudContinue;
}


// Dismisses the people picker and shows the application when users tap Cancel.
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)picker;{	
	[self dismiss];
}

-(void) pickNumber: (UIViewController<PeoplePickerDelegate> *)delegate_{
	self.peoplePickerDelegate = self;
	self.delegate = delegate_;
	[self.delegate presentModalViewController:self animated:YES];
}

-(void) pickContact: (UIViewController<PeoplePickerDelegate> *)delegate_{
	self.peoplePickerDelegate = self;
	self.delegate = delegate_;
	[self.delegate presentModalViewController:self animated:YES];
}

-(void) dismiss{
	[self.delegate dismissModalViewControllerAnimated:YES];
}

-(void)dealloc{
	[delegate release];
	[super dealloc];
}

@end