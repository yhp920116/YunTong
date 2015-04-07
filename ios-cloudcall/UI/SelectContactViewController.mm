/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "SelectContactViewController.h"
#import "UIKit/UIKit.h"
#import "iOSNgnStack.h"
#import "CloudCall2Constants.h"
#import "NSString+Code.h"
#import <AddressBookUI/ABPersonViewController.h>
#import "ContactViewCell.h"

#define kContactViewCellIdentifier	@"ContactViewCellIdentifier"
//@implementation ParticipantInfo
//
//@synthesize Name;
//@synthesize Number;
//@synthesize Description;
//@synthesize picture;
//
//-(void) dealloc
//{
//    [Name release];
//    [Number release];
//    [Description release];
//    [picture release];
//    [super dealloc];
//}
//
//@end

@interface SelectContactViewController(Private)
-(void) refreshData;

-(void) reloadData;
-(void) refreshDataAndReload;
@end

@implementation SelectContactViewController(Private)

-(void) refreshData {
	@synchronized(contacts) {
        [contacts removeAllObjects];
        
        NgnContactMutableArray* contacts_ = (NgnContactMutableArray*)[[[NgnEngine sharedInstance].contactService contacts] retain];
        
        NSMutableDictionary* weicallusers = [[NSMutableDictionary alloc] init];
        [[NgnEngine sharedInstance].contactService dbLoadWeiCallUserContacts:weicallusers];
        
		NSString *lastGroup = @"$$", *group;
        NSMutableArray* lastArray = nil;
        //int num = [contacts_ count];
        int filterNum = 0;
        //CCLog(@"refreshData count=%d, search=%@", [contacts_ count], self.searchBar.text);
		for (NgnContact* contact in contacts_) {
            //CCLog(@"refreshData name='%@', '%@', '%@'", contact.displayName, contact.abDisplayName, contact.cIndex);
            
//            BOOL isFriend = NO;
            for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers) {
                if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number) {
                    NSString* tmpPhoneNum1 = [phoneNumber.number phoneNumFormat];
                    NSObject *object = [weicallusers objectForKey:tmpPhoneNum1];
                    if (object) {
//                        isFriend = YES;
                        break;
                    }
                }
            }
            
            NSRange displayNameRange,abDisplayNameRange,displayNumberRange;
            if (![NgnStringUtils isNullOrEmpty:self.searchBar.text]) {
                displayNameRange = [contact.displayName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                abDisplayNameRange = [contact.abDisplayName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                contact.displayNameRange = displayNameRange;
                
                if (abDisplayNameRange.location == NSNotFound && contact.abDisplayName && [contact.abDisplayName length]) {
                    // 首字母匹配
                    NSArray *abArray = [contact.abDisplayName componentsSeparatedByString:@" "];
                    if ([self.searchBar.text length] <= [abArray count]) {
                        NSString *nameString = [NSMutableString stringWithCapacity:20];
                        for (NSString *str in abArray) {
                            if ([str length]) {
                                NSString *firstLetter = [str substringToIndex:1];
                                nameString = [nameString stringByAppendingString:firstLetter];
                            }
                        }
                        if ([nameString length]) {
                            abDisplayNameRange = [nameString rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                        }
                    }
                }
                if (abDisplayNameRange.location == NSNotFound && contact.abDisplayName && [contact.abDisplayName length]) {
                    NSString *abname = [contact.abDisplayName stringByReplacingOccurrencesOfString:@" " withString:@""];
                    if ([abname length]) {
                        abDisplayNameRange = [abname rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                    }
                }
                
                if (displayNameRange.location == NSNotFound && abDisplayNameRange.location == NSNotFound) {
                    //号码匹配
                    for (int i=0; i<[contact.phoneNumbers count]; i++) {
                        NgnPhoneNumber *phoneNumber = [contact.phoneNumbers objectAtIndex:i];
                        
                        NSString* tmpPhoneNum = [phoneNumber.number phoneNumFormat];
                        
                        if (tmpPhoneNum && [tmpPhoneNum length]) {
                            displayNumberRange = [tmpPhoneNum rangeOfString:self.searchBar.text];
                            if (displayNumberRange.location != NSNotFound) {
                                break;
                            }
                        }
                    }
                }
            } else {
                contact.displayNameRange = NSMakeRange(0, 0);
            }
            
			if (!contact || [NgnStringUtils isNullOrEmpty: contact.displayName]
                || (![NgnStringUtils isNullOrEmpty: self.searchBar.text] && (displayNameRange.location == NSNotFound)
                    && (abDisplayNameRange.location == NSNotFound) && (displayNumberRange.location == NSNotFound)))
            {
				continue;
			}
            
            group = contact.cIndex;
            if ([group caseInsensitiveCompare: lastGroup] != NSOrderedSame) {
				//CCLog(@"group=%@, last=%@", group, lastGroup);
                lastGroup = group;
				[lastArray release];
                if ([lastGroup isEqualToString:@"#"] && [[contacts allKeys] containsObject:lastGroup]) {
                    lastArray = [[contacts valueForKey:lastGroup] retain];
                } else {
                    lastArray = [[NSMutableArray alloc] init];
                    [contacts setObject: lastArray forKey: lastGroup];
                }
			}
            [lastArray addObject: contact];
            filterNum++;
		}
        
        if (weicallusers) {
			[weicallusers release];
			weicallusers = nil;
		}
        
		[lastArray release];
		[contacts_ release];
        
		[orderedSections release];
		orderedSections = [[[contacts allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] retain];
	}
}

-(void) reloadData{
    //CCLog(@"contactsviewcontroller reloadData");
	[self.tableView reloadData];
}

-(void) refreshDataAndReload{
	[self refreshData];
	[self reloadData];
}


//-(void)selectDone {
//    if (delegate) {        
//        NSMutableArray *selected = [[NSMutableArray alloc] init];
//        
//        for (int i=0; i<[orderedSections count]; i++) {
//            NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: i]];
//            for (ParticipantInfo *pi in values) {
//                if (pi->selected) {
//                    //CCLog(@"selectDone: %@, %@\n", pi.Name, pi.Number);
//                    [selected addObject: pi];
//                }
//            }
//        }
//        
//        if ([selected count]) {
//            //CCLog(@"select %d", [selected count]);
//            [delegate shouldContinueAfterPickingContacts:selected];
//            [self.navigationController popViewControllerAnimated:YES];
//        } else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") 
//                                                            message:NSLocalizedString(@"No selected contact", @"No selected contact")
//                                                           delegate:self 
//                                                  cancelButtonTitle:nil
//                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
//            [alert show];
//            [alert release];
//        }
//        
//        [selected release];
//        
//    }
//}

@end

@implementation SelectContactViewController

@synthesize searchBar;
@synthesize tableView;
@synthesize viewToolbar;
@synthesize toolbar;
@synthesize labelTitle;
@synthesize strAddNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.labelTitle.text = NSLocalizedString(@"Select Contact", @"Select Contact");
    
    ///////////////////////////////////////
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image = [UIImage imageNamed:@"toolbar_bg.png"];
    [self.toolbar addSubview:imageview];
    [imageview release];
    
    self->barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [self->barButtonItemBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonItemBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonItemBack];    
    
    if (!contacts) {
		contacts = [[NSMutableDictionary alloc] init];
	}
    [self refreshData];
    
    tableView.delegate = self;
	tableView.dataSource = self;
    tableView.tableHeaderView = searchBar;
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"searchBar_bg.png"]];
    searching = NO;
	letUserSelectRow = YES;
    self.searchBar.showsCancelButton = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden: YES];
    
//    [self refreshDataAndReload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden: NO];
}

- (void)dealloc {
    [searchBar release];
    [tableView release];
    
    [viewToolbar release];
    [toolbar release];
    [labelTitle release];
    
    [contacts removeAllObjects];
    [contacts release];
    [orderedSections release];
    
    [strAddNumber release];
    
    [super dealloc];
}

#pragma mark - IBActions

- (IBAction)onButtonToolBarItemClick: (id)sender {
    if (sender == barButtonItemBack) {
        //[self dismissModalViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } else if (sender == barButtonDone) {
        //[self selectDone];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searching = YES;
	letUserSelectRow = NO;
	//tableView.scrollEnabled = NO;
    //[self.navigationController setNavigationBarHidden:YES];
    
    self.searchBar.showsCancelButton = YES;
	
	// disable indexes
    [self reloadData];
	
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	letUserSelectRow = YES;
	searching = NO;
    //tableView.scrollEnabled = YES;
    //[self.navigationController setNavigationBarHidden:NO];
    
    self.searchBar.showsCancelButton = NO;
	//self.searchBar.text = @"";
	[self.searchBar resignFirstResponder];
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[self.searchBar resignFirstResponder];
    if ([NgnStringUtils isNullOrEmpty: self.searchBar.text]) {
        [self reloadData];
    }
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    [self refreshDataAndReload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark 
#pragma mark table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [orderedSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([orderedSections count] > section) {
        NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: section]];
        return [values count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [orderedSections objectAtIndex: section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[[UIView alloc] init] autorelease];
    myView.backgroundColor = [UIColor colorWithRed:210.0f/255.0f green:210/255.0 blue:210/255.0 alpha:0.7];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
    titleLabel.textColor=[UIColor blueColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text=[orderedSections objectAtIndex:section];
    [myView addSubview:titleLabel];
    [titleLabel release];
    return myView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    ContactViewCell *cell = (ContactViewCell*)[_tableView dequeueReusableCellWithIdentifier: kContactViewCellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactViewCell" owner:self options:nil] lastObject];
        cell.hideDialButton = YES;
	}
	@synchronized(contacts) {
		if ([orderedSections count] > indexPath.section) {
			NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
			NgnContact* contact = [values objectAtIndex: indexPath.row];
            if (contact) {
                [cell setDisplayName:contact.displayName];
                cell.contact = contact;
                cell.navigationController = self.navigationController;
                cell.hideDialButton = YES;
                [contact InitDisplayAreaInfo];
                [cell setDisplayArea:contact.displayArea];
                
			}
		}
	}
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (searching || [searchBar.text length]) {
		return nil;
	}
    return orderedSections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	NSInteger i = 0;
	@synchronized(contacts){
		for(NSString *title_ in orderedSections){
			if([title_ isEqualToString: title]){
				return i;
			}
			++i;
		}
		return i;
	}
}

#pragma mark
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView_ deselectRowAtIndexPath:indexPath animated:NO];
    if([orderedSections count] > indexPath.section)
    {
        NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
        NgnContact* contact = [values objectAtIndex: indexPath.row];
        if (contact)
        {
            ABAddressBookRef addressBook = ABAddressBookCreate();
            
            ABRecordRef person = nil;
            person = ABAddressBookGetPersonWithRecordID(addressBook, [contact myid]);
            
            ABMultiValueRef personValues = ABRecordCopyValue(person, kABPersonPhoneProperty);
            ABMutableMultiValueRef multiValue = ABMultiValueCreateMutableCopy(personValues);
            ABMultiValueAddValueAndLabel(multiValue, strAddNumber, kABPersonPhoneIPhoneLabel, NULL);
            
            CFErrorRef error = NULL;
            ABRecordSetValue(person, kABPersonPhoneProperty, multiValue , &error);
//            ABAddressBookSave(addressBook, NULL);
            
            if (SystemVersion >= 7.0)
            {
                ABPersonViewController *myABPersonViewController = [[ABPersonViewController alloc] init];
                myABPersonViewController.displayedPerson = person;
                myABPersonViewController.addressBook = addressBook;
                [myABPersonViewController setAllowsEditing:YES];
                [myABPersonViewController setEditing:YES];
                myABPersonViewController.allowsActions = YES;
                myABPersonViewController.personViewDelegate = self;
                myABPersonViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:myABPersonViewController animated:YES];
            }
            else
            {
                PersonViewController* myABPersonViewController = [[PersonViewController alloc] init];
                myABPersonViewController.displayedPerson = person;
                myABPersonViewController.addressBook = addressBook;
                [myABPersonViewController setAllowsEditing:YES];
                [myABPersonViewController setEditing:YES animated:NO];
                [myABPersonViewController setAllowsActions:NO];
                myABPersonViewController.personViewDelegate = self;
                myABPersonViewController.fromAddToExistContact = YES;
                myABPersonViewController.AddToExistContactNumber = strAddNumber;
                myABPersonViewController.contactId = [contact myid];
                
                myABPersonViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:myABPersonViewController animated:YES];
                [myABPersonViewController release];
            }
            CFRelease(personValues);
            CFRelease(multiValue);
            CFRelease(addressBook);
            
        }
    }
}

#pragma mark
#pragma mark ABPersonViewControllerDelegate
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property
                  identifier:(ABMultiValueIdentifier)identifier
{
    return true;
}

@end

