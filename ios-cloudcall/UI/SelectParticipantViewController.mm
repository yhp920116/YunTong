/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "SelectParticipantViewController.h"
#import "CloudCall2AppDelegate.h"
#import "UIKit/UIKit.h"
#import "iOSNgnStack.h"
#import "CloudCall2Constants.h"
#import "ConferenceViewController.h"
#import <AddressBookUI/ABPersonViewController.h>

@implementation ParticipantInfo

@synthesize Name;
@synthesize Number;
@synthesize Description;
@synthesize picture;

-(void) dealloc
{
    [Name release];
    [Number release];
    [Description release];
    [picture release];
    [super dealloc];
}

@end

@interface SelectParticipantViewController(Private)
-(void) refreshData;

-(void) reloadData;
-(void) refreshDataAndReload;
@end

@implementation SelectParticipantViewController(Private)

-(void) refreshData {
	@synchronized(contacts){
		[contacts removeAllObjects];
        
        NgnContactMutableArray* contacts_ = (NgnContactMutableArray*)[[[NgnEngine sharedInstance].contactService contacts] retain];
        
		NSString *lastGroup = @"$$", *group;
        NSMutableArray* lastArray = nil;
		for (NgnContact* contact in contacts_) {
            if (!contact || [NgnStringUtils isNullOrEmpty: contact.displayName]
                || (![NgnStringUtils isNullOrEmpty: searchBar.text]
                    && ([contact.displayName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch].location == NSNotFound)
                    && ([contact.abDisplayName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch].location == NSNotFound)))
            {
				continue;
			}
            
            BOOL first = YES;
            
            for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers) {
                if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number) {
                    NSString* tmpPhoneNum = [phoneNumber.number phoneNumFormat];
                    
                    if (IsPureNumber(tmpPhoneNum)) {
                        ParticipantInfo *pi = [[ParticipantInfo alloc] init];
                        pi.Name   = contact.displayName;
                        pi.Number = tmpPhoneNum;
                        pi.Description = phoneNumber.description;
                        pi.picture = contact.picture;
                        pi->selected = IsSelectAll;
                        
                        group = contact.cIndex;
                        
                        if (first && [group caseInsensitiveCompare: lastGroup] != NSOrderedSame) {
                            first = NO;
                            
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
                        [lastArray addObject: pi];
                        [pi release];
                    }
                }
            }
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


-(void)selectDone {
    NSMutableArray *selected = [[NSMutableArray alloc] init];
    for (int i=0; i<[orderedSections count]; i++) {
        NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: i]];
        for (ParticipantInfo *pi in values) {
            if (pi->selected) {
                //CCLog(@"selectDone: %@, %@\n", pi.Name, pi.Number);
                [selected addObject: pi];
            }
        }
    }
    
    if ([selected count]) {
        //CCLog(@"select %d", [selected count]);
        if (isNewGroup == YES)
        {
            NSString *mynum =  [[CloudCall2AppDelegate sharedInstance] getUserName];
            NSMutableArray* members = [[NSMutableArray alloc] init];
            
            [[NgnEngine sharedInstance].storageService dbClearConfParticipants:uuid];
            for (ParticipantInfo *pi in selected) {
                if (![mynum isEqualToString:pi->Number])
                {
                    if (pi && pi.Number && [pi.Number length]) {
                        [[NgnEngine sharedInstance].storageService dbAddConfParticipant:uuid andPhoneNum:pi.Number];
                    }
                    GroupCallMember* m = [[GroupCallMember alloc] initWithName:pi.Name andNumber:pi.Number];
                    [members addObject:m];
                    [m release];
                }
            }
            
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            conffavorite.updatetime = time;
            conffavorite.status = conffavorite.status;
            [[NgnEngine sharedInstance].storageService dbUpdateConfFavorite:conffavorite];
            
            /////////////////////////////////////////////////////////////////////////////////////
            CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
            GroupCallRecord* r = [[GroupCallRecord alloc] initWithUserNumber:mynum andName:self.conffavorite.name andGroupId:uuid andType:self.conffavorite.type andUpdateTime:conffavorite.updatetime andMembers:members];
            [appDelegate UpdateGroupCallRecords:[NSArray arrayWithObject:r]];
            [r release];
            [members release];
            /////////////////////////////////////////////////////////////////////////////////////
            
            ConferenceViewController *conferenceController = [[ConferenceViewController alloc] initWithNibName: @"ConferenceView" bundle:nil];
            conferenceController.conffavorite = conffavorite;
            conferenceController.isCreateGroup = isNewGroup;
            
            [self.navigationController pushViewController:conferenceController animated:YES];
            conferenceController.uuid = conffavorite.uuid;
            [conferenceController release];
            
        }
        else
        {
            if (delegate) { 
                [delegate shouldContinueAfterPickingContacts:selected];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") 
                                                        message:NSLocalizedString(@"No selected contact", @"No selected contact")
                                                       delegate:self 
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    }
    [selected release];
}

@end

@implementation SelectParticipantViewController

@synthesize conffavorite;
@synthesize searchBar;
@synthesize tableView;
@synthesize viewToolbar;
@synthesize toolbar;
@synthesize labelTitle;
@synthesize isNewGroup;
@synthesize uuid;

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
    
    ///////////////////////////////////////
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image = [UIImage imageNamed:@"toolbar_bg.png"];
    [self.toolbar addSubview:imageview];
    [imageview release];
    ///////////////////////////////////////
    
//    self.labelTitle.text = NSLocalizedString(@"Contacts", @"Contacts");
    
    self->barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [self->barButtonItemBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonItemBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonItemBack];    
    
    NSString* strSelectAll   = NSLocalizedString(@"Select All", @"Select All");
    NSString* strDeselectAll = NSLocalizedString(@"Deselect All", @"Deselect All");
    NSString* strAll = [strSelectAll length] > [strDeselectAll length] ? strSelectAll : strDeselectAll;
    CGSize strAllSize = [strAll sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(280, 100) lineBreakMode:UILineBreakModeCharacterWrap];
    self->barButtonSelectAll = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonSelectAll.frame = CGRectMake(135, 7, 72, 30);
    [self->barButtonSelectAll setTitle:IsSelectAll ? NSLocalizedString(@"Deselect All", @"Deselect All") : NSLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    [self->barButtonSelectAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self->barButtonSelectAll.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self->barButtonSelectAll setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_up.png"] forState:UIControlStateNormal];
    [self->barButtonSelectAll setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonSelectAll addTarget:self action:@selector(selectAll) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonSelectAll];
    
    self->barButtonDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonDone.frame = CGRectMake(276, 0, 44, 44);
    self->barButtonDone.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [self->barButtonDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self->barButtonDone setBackgroundImage:[UIImage imageNamed:@"submit_up.PNG"] forState:UIControlStateNormal];
    [self->barButtonDone setBackgroundImage:[UIImage imageNamed:@"submit_down.PNG"] forState:UIControlStateHighlighted];
    [self->barButtonDone addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonDone];
    
    if (!contacts) {
		contacts = [[NSMutableDictionary alloc] init];
	}
    [self refreshData];
    
    tableView.delegate = self;
	tableView.dataSource = self;
    tableView.tableHeaderView = searchBar;
    
    if (SystemVersion >= 7.0)
    {
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.viewToolbar.frame = CGRectMake(self.viewToolbar.frame.origin.x, self.viewToolbar.frame.origin.y + 20, self.viewToolbar.frame.size.width, self.viewToolbar.frame.size.height);
    }
    
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden: NO];
}

- (void)dealloc {
    [searchBar release];
    [tableView release];
    [conffavorite release];
    [uuid release];
    
    [viewToolbar release];
    [toolbar release];
    [labelTitle release];
    
    [contacts removeAllObjects];
    [contacts release];
    [orderedSections release];
    
    [super dealloc];
}

-(void) SetDelegate:(UIViewController<ParticipantPickerDelegate> *)_delegate {
    delegate = _delegate;
}

#pragma mark - IBActions

- (IBAction)onButtonToolBarItemClick: (id)sender {
    if (sender == barButtonItemBack) {
        if (isNewGroup == YES)
            [self.navigationController popToRootViewControllerAnimated:YES];
        else
            [self.navigationController popViewControllerAnimated:YES];
    } else if (sender == barButtonDone) {
        [self selectDone];
    }
}

-(void)selectAll {
    IsSelectAll = !IsSelectAll;
    
    for (int i=0; i<[orderedSections count]; i++) {
        NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: i]];
        for (ParticipantInfo *ci in values) {
            ci->selected = YES;
        }
    }
    
    [self refreshData];
	[self.tableView reloadData];
    
    NSString* strAll = IsSelectAll ? NSLocalizedString(@"Deselect All", @"Deselect All") : NSLocalizedString(@"Select All", @"Select All");
    /*CGSize strAllSize = [strAll sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(280, 100) lineBreakMode:UILineBreakModeCharacterWrap];
     self.toolBtnSelectAll.frame = CGRectMake(135, 28, strAllSize.width, 30);*/
    [self->barButtonSelectAll setTitle:strAll forState:UIControlStateNormal];
}

//
//	Searching
//

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

#pragma mark - IBActions

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
    myView.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:0.7];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
    titleLabel.textColor=[UIColor blueColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text=[orderedSections objectAtIndex:section];
    [myView addSubview:titleLabel];
    [titleLabel release];
    return myView;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	@synchronized(contacts) {
        if ([orderedSections count] > indexPath.section) {
            NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
            ParticipantInfo* pi = [values objectAtIndex: indexPath.row];
            if (pi) {
                //CCLog(@"select participant: %@, %@\n", pi.Name, pi.Number);
                [cell.textLabel setText: pi.Name];
                
                NSString* str = nil;
                if (pi.Description && [pi.Description length]) {
                    str = [NSString stringWithFormat:@"%@ (%@)", pi.Number, pi.Description];
                } else {
                    str = pi.Number;
                }
                [cell.detailTextLabel setText:str];
                
                [cell setAccessoryType: pi->selected ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone];
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

- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([orderedSections count] > indexPath.section){
        NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
        ParticipantInfo* pi = [values objectAtIndex: indexPath.row];
        pi->selected = !pi->selected;
        
        UITableViewCell *selectedCell = [tableView_ cellForRowAtIndexPath:indexPath];
        [selectedCell setAccessoryType: pi->selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
        
        [tableView_ deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (letUserSelectRow) {
		return indexPath;
	} else {
        [self.searchBar resignFirstResponder];
		return nil;
	}
}

@end

