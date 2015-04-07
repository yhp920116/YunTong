//
//  PersonViewController.m
//  WeiCall
//
//  Created by guobiao chen on 12-3-27.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import "PersonViewController.h"
#import <objc/runtime.h>
#import "ContactDetailsController.h"

#import "iOSNgnStack.h"

static BOOL isSwitchValue;
static BOOL isDidDeleteValue;

NSString *kAddressBookContactDeleted = @"kAddressBookContactDeleted";
	  	
typedef void (*ActionSheetDismissFuncPtr)(UIActionSheet *, SEL, NSUInteger, BOOL);
	  	
static ActionSheetDismissFuncPtr originalUIActionSheetDismiss;
	  	
static void MyUIActionSheetDismiss(UIActionSheet *self, SEL _cmd, NSUInteger buttonIndex, BOOL animated);

//add private method

static void MyUIActionSheetDismiss(UIActionSheet *self, SEL _cmd, NSUInteger buttonIndex, BOOL animated)
{
    if (buttonIndex == self.destructiveButtonIndex)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddressBookContactDeleted object:self userInfo:nil];
    }
    (*originalUIActionSheetDismiss)(self, _cmd, buttonIndex, animated);
}

@implementation UIActionSheet(Dismiss)
+(void)load
{
        @autoreleasepool
      	{
            originalUIActionSheetDismiss = (ActionSheetDismissFuncPtr)class_replaceMethod([UIActionSheet class],NSSelectorFromString(@"dismissWithClickedButtonIndex:animated:"),(IMP)MyUIActionSheetDismiss,[[NSString stringWithFormat:@"v@:%s%s", @encode(NSUInteger), @encode(BOOL)] UTF8String]);
        }	  	
}
@end

@implementation PersonViewController(Private)
-(id)init
{
    self=[super init];
    if(self){
        @try{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDelete:) name:kAddressBookContactDeleted object:nil];
            [self setValue:[NSNumber numberWithBool:YES] forKey:@"allowsDeletion"];
        }
        @catch(NSException *e){
            
        }
    }
    return self;
}
@end

//default implementation

@implementation PersonViewController
@synthesize fromAddToExistContact;
@synthesize AddToExistContactNumber;
@synthesize contactId;

+(BOOL)switchValue
{
    return isSwitchValue;
}
+(void)setSwitchValue:(BOOL)value
{
    isSwitchValue=value;
}
+(BOOL)didDeleteValue
{
    return isDidDeleteValue;
}
+(void)setDidDeleteValue:(BOOL)value
{
    isDidDeleteValue=value;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

-(void)viewDidLayoutSubviews
{
    [self.navigationItem.leftBarButtonItem setAction:@selector(setCancel:)];
    [self.navigationItem.rightBarButtonItem setAction:@selector(setDone:)];
}


-(IBAction)setDelete:(id)sender
{
    [self setEditing:NO];
    isDidDeleteValue=YES;
    [[NgnEngine sharedInstance].contactService edited:YES];
    [[NgnEngine sharedInstance].contactService load:YES];
    [self.navigationController popToRootViewControllerAnimated:NO];
    //[self.navigationController popViewControllerAnimated:NO];
}


-(IBAction)setDone:(id)sender
{
    
    if (fromAddToExistContact)
    {
        ABRecordRef person = nil;
        person = ABAddressBookGetPersonWithRecordID(self.addressBook, contactId);
        
        ABMultiValueRef personValues = ABRecordCopyValue(self.displayedPerson, kABPersonPhoneProperty);
        ABMutableMultiValueRef multiValue = ABMultiValueCreateMutableCopy(personValues);
        
        CFErrorRef error = NULL;
        ABRecordSetValue(person, kABPersonPhoneProperty, multiValue , &error);
        ABAddressBookSave(self.addressBook, NULL);
        
        CFRelease(personValues);
        CFRelease(multiValue);
        
        NgnContactEventArgs *eargs = [[NgnContactEventArgs alloc] initWithType:CONTACT_RESET_ALL];
        [NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnContactEventArgs_Name object:eargs];
        [eargs release];
        
        NgnHistoryEventArgs *historyEargs = [[NgnHistoryEventArgs alloc] initWithEventType: HISTORY_EVENT_RESET];
        [NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnHistoryEventArgs_Name object:historyEargs];
        [historyEargs release];
    }
    
    [self setEditing:NO];
    isSwitchValue=YES;
    [[NgnEngine sharedInstance].contactService edited:YES];
    [[NgnEngine sharedInstance].contactService load:YES];
    
    if (fromAddToExistContact)
    {
        ContactDetailsController *detail = nil;
        for (UIViewController *viewContoller in self.navigationController.viewControllers)
        {
            if ([viewContoller isKindOfClass:[ContactDetailsController class]])
            {
                detail = (ContactDetailsController *)viewContoller;
                break;
            }
        }
        
        NgnContact *contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:AddToExistContactNumber];
        detail.isInContact = YES;
        isSwitchValue = NO;
        detail.contact = contact;
        [self.navigationController popToViewController:detail animated:YES];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)setCancel:(id)sender
{
//    [self setDisplayedPerson:nil];
    [self setEditing:NO];
    if (fromAddToExistContact)
    {
        ContactDetailsController *detail = [self.navigationController.viewControllers objectAtIndex:1];
        [self.navigationController popToViewController:detail animated:YES];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
    [AddToExistContactNumber release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}
@end
