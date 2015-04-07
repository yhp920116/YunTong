/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "SelectNumberViewController.h"
#import "CloudCall2AppDelegate.h"
#import "UIKit/UIKit.h"
#import "iOSNgnStack.h"
#import "CloudCall2Constants.h"
#import <AddressBookUI/ABPersonViewController.h>
#import "HttpRequest.h"
#import "JSONKit.h"

#define kTagSetRefereeSuccess 100

@implementation NumberInfo

@synthesize displayNameRange;
@synthesize displayNumberRange;

-(NumberInfo*)init {
	if ((self = [super init])){
        displayNameRange = NSMakeRange(0, 0);
        displayNumberRange = NSMakeRange(0, 0);
    }
    return self;
}

- (void)dealloc {
    [Name release];
	[Number release];
    [Description release];
    
    [super dealloc];
}

@end


@interface SelectNumberViewController(Private)
-(void) refreshData;
-(void) reloadData;
-(void) refreshDataAndReload;
@end

@implementation SelectNumberViewController(Private)

-(void) refreshData {
    @synchronized(contacts) {
		[contacts removeAllObjects];
        
        NgnContactMutableArray* contacts_ = (NgnContactMutableArray*)[[[NgnEngine sharedInstance].contactService contacts] retain];
        
        NSString *lastGroup = @"$$", *group;
        NSMutableArray* lastArray = nil;
        for (NgnContact* contact in contacts_) {        
            NSRange displayNameRange = NSMakeRange(0, 0);
            NSRange abDisplayNameRange = NSMakeRange(0, 0);
            NSRange displayNumberRange = NSMakeRange(0, 0);
            if (![NgnStringUtils isNullOrEmpty:self.searchBar.text]) {
                displayNameRange = [contact.displayName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                abDisplayNameRange = [contact.abDisplayName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                
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
            }
            
			if (!contact || [NgnStringUtils isNullOrEmpty: contact.displayName]
                || (![NgnStringUtils isNullOrEmpty: self.searchBar.text] && (displayNameRange.location == NSNotFound)
                    && (abDisplayNameRange.location == NSNotFound) && (displayNumberRange.location == NSNotFound)))
            {
				continue;
			}
        
            BOOL first = YES;
            for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers) {
                if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number) {
                    NSString* tmpPhoneNum = [phoneNumber.number phoneNumFormat];
                    BOOL found = NO;
                    if (type == Select_Number_Type_Mobile_Only) {
                        if (IsPureNumber(tmpPhoneNum)) {
                            found = YES;
                        }
                    } else {
                        if (IsPureNumber(tmpPhoneNum)) {
                            found = YES;
                        }
                    }
                
                    if (found == NO)
                        continue;
                
                    NumberInfo *pi = [NumberInfo alloc];
                    pi->Name   = [[NSString alloc] initWithString:contact.displayName];
                    pi->Number = [[NSString alloc] initWithString:tmpPhoneNum];
                    pi->Description = [[NSString alloc] initWithString: phoneNumber.description];                       
                
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
        [lastArray release];
        [contacts_ release];
        
        [orderedSections release];        
        orderedSections = [[[contacts allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] retain];
    }
}

-(void)selectDone {
    NSString *selectedNumber = nil;
    for (int i=0; i<[orderedSections count]; i++) {
        NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: i]];
        for (NumberInfo *pi in values) {
            if (pi->selected) {
                //CCLog(@"selectDone: %@, %@\n", pi->Name, pi->Number);
                selectedNumber = pi->Number;
            }
        }
    }
    
    if ([selectedNumber length] != 0) {
        //CCLog(@"select %d", [selected count]);
        NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
        NSDictionary *jsonDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 num, @"user_number",
                                 selectedNumber, @"referee", nil];
        NSData *jsonData = [jsonDic JSONData];
        
        if (!_hud) {
            _hud = [[MBProgressHUD alloc] initWithView:self.view];

        }
        _hud.labelText = NSLocalizedString(@"Submitting...", @"Submitting...");
        [self.view addSubview:_hud];
        
        [_hud show:YES];
        [[HttpRequest instance] addRequest:kSetrefereeUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                                 successTarget:self successAction:@selector(responseWithSucceeded:)
                                 failureTarget:self failureAction:@selector(responseWithFailed:) userInfo:nil];
        
        
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert") 
                                                        message:NSLocalizedString(@"No selected contact", @"No selected contact")
                                                       delegate:self 
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
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

@end

@implementation SelectNumberViewController

@synthesize searchBar;
@synthesize tableView;
@synthesize toolBtnDone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDelegate:(UIViewController<NumberPickerDelegate> *)_delegate andStyle:(SelectNumberStyle)_style andType:(SelectNumberType)_type {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        delegate = _delegate;
        style = _style;
        type = _type;
    }
    
    return self;
}

//-(void)viewDidLayoutSubviews
//{
//
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Set Referee", @"Set Referee");
    
    //提交按钮
    self.toolBtnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBtnDone.frame = CGRectMake(273, 0, 44, 44);
    [self.toolBtnDone setBackgroundImage:[UIImage imageNamed:@"submit_up.PNG"] forState:UIControlStateNormal];
    [self.toolBtnDone setBackgroundImage:[UIImage imageNamed:@"submit_down.PNG"] forState:UIControlStateHighlighted];
    [toolBtnDone addTarget:self action:@selector(selectDone) forControlEvents: UIControlEventTouchUpInside];
    
    barButtonDone = [[UIBarButtonItem alloc] initWithCustomView:toolBtnDone];
    
    self.navigationItem.rightBarButtonItem = barButtonDone;
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToSetting:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (!contacts) {
		contacts = [[NSMutableDictionary alloc] init];
	}
    [self refreshData];
    
    tableView.delegate = self;
	tableView.dataSource = self;
    tableView.tableHeaderView = self.searchView;
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"searchBar_bg.png"]];
    searching = NO;
	letUserSelectRow = YES;
    self.searchBar.showsCancelButton = NO;
    
    if ([tableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        if (SystemVersion >= 7.) {
            tableView.sectionIndexBackgroundColor = [UIColor clearColor];
            
        }
        if (SystemVersion >= 6.) {
            tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        }
    }
    
}

- (void)viewDidUnload
{
    [self setSearchView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)dealloc {
    [searchBar release];
    [tableView release];
    
    [barButtonDone release];
    
    [contacts removeAllObjects];
    [contacts release];
    [orderedSections release];
    
    if (lastIndexPath)
        [lastIndexPath release];
    
    [_searchView release];
    [super dealloc];
}

- (void) backToSetting: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//
//	Searching
//

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searching = YES;
	letUserSelectRow = NO;

	tableView.scrollEnabled = NO;
    
    [self.navigationController setNavigationBarHidden:YES];

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
    
    [self.navigationController setNavigationBarHidden:NO];

    self.searchBar.showsCancelButton = NO;
	//self.searchBar.text = @"";
	[self.searchBar resignFirstResponder];
	
	tableView.scrollEnabled = YES;
	
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


-(void) SetDelegate:(UIViewController<NumberPickerDelegate> *)_delegate {
    delegate = _delegate;
}

#pragma mark - HUDHide

- (void)hideHUD
{
    if (_hud != nil)
    {
        [_hud hide:YES];
        [_hud release];
        _hud = nil;
    }
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
    @synchronized(contacts){
		return [orderedSections objectAtIndex: section];
	}
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    @synchronized(contacts) {
        if([orderedSections count] > indexPath.section){
            NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
            NumberInfo* pi = [values objectAtIndex: indexPath.row];
            if (pi) {
                //CCLog(@"select participant: %@, %@\n", pi.Name, pi->Number);
                [cell.textLabel setText: pi->Name];
                if (SystemVersion >= 6.0) {
                    if (pi->displayNameRange.length) {
                        NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:pi->Name] autorelease];
                        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, pi->displayNameRange.length)];
                        
                        if (pi->displayNameRange.length >= 1)
                            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:3.0/255.0 green:165.0/255.0 blue:255.0/255.0 alpha:1] range:pi->displayNameRange];
                        
                        [cell.textLabel setAttributedText:attributedString];
                    }
                }
            
                NSString* str = nil;
                if (pi->Description && [pi->Description length]) {
                    str = [NSString stringWithFormat:@"%@ (%@)", pi->Number, pi->Description];
                } else {
                    str = pi->Number;
                }
                [cell.detailTextLabel setText:str];
                if (SystemVersion >= 6.0) {
                    if (pi->displayNumberRange.length) {
                        NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:str] autorelease];
                        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, pi->displayNumberRange.length)];
                        
                        if (pi->displayNumberRange.length >= 1)
                            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:3.0/255.0 green:165.0/255.0 blue:255.0/255.0 alpha:1] range:pi->displayNumberRange];
                        
                        [cell.detailTextLabel setAttributedText:attributedString];
                    }
                }

                [cell setAccessoryType: pi->selected ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone];
            }
        }
    }
	
	return cell;
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
    @synchronized(contacts) {
        if([orderedSections count] > indexPath.section) {        
            NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
            NumberInfo* pi = [values objectAtIndex: indexPath.row];
            pi->selected = !pi->selected;
        
            UITableViewCell *selectedCell = [tableView_ cellForRowAtIndexPath:indexPath];
            [selectedCell setAccessoryType: pi->selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
        
            if (style == Select_Number_Style_Single) {
                if (lastIndexPath) {            
                    NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: lastIndexPath.section]];
                    NumberInfo* ni = [values objectAtIndex: lastIndexPath.row];
                    if (ni->selected) 
                        ni->selected = NO;
                
                    if ([orderedSections count] > lastIndexPath.section) {            
                        UITableViewCell *lastSelectedCell = [tableView_ cellForRowAtIndexPath:lastIndexPath];
                        [lastSelectedCell setAccessoryType: UITableViewCellAccessoryNone];
                    }                
                
                    [lastIndexPath release];
                    lastIndexPath = nil;
                }        
                if (pi->selected) 
                    lastIndexPath = [indexPath retain];
            }
    
            [tableView_ deselectRowAtIndexPath:indexPath animated:NO];
        }
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

#pragma mark -
#pragma mark HttpRequest API

- (void)responseWithSucceeded:(NSData *)data {
    [self hideHUD];
	if (data == nil)
        return;
    
    NSMutableDictionary *root = [data mutableObjectFromJSONData];
    NSString* result   = [root objectForKey:@"result"];
    if ([result isEqualToString:@"success"])
    {
//        int my_award = [[root objectForKey:@"my_award"] intValue];
//        int referee_award = [[root objectForKey:@"referee_award"] intValue];
        if (delegate)
        {
            [delegate setRefereeSucess];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message:[root objectForKey:@"text"]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        alert.tag = kTagSetRefereeSuccess;
        [alert show];
        [alert release];
        
        [self.tableView reloadData];
    }
    else
    {
        CCLog(@"error=%@", [root objectForKey:@"text"]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message:[root objectForKey:@"text"]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        alert.tag = kTagSetRefereeSuccess;
        [alert show];
        [alert release];
    }
}

- (void)responseWithFailed:(NSError *)error {
    _hud.labelText = @"提交失败";
    [self hideHUD];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
//                                                    message:[error localizedDescription]
//                                                   delegate:nil
//                                          cancelButtonTitle:nil
//                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
//    [alert show];
//    [alert release];
}

#pragma mark -
#pragma mark 定义UIAlertTableView的委托，buttonindex就是按下的按钮的index值

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case kTagSetRefereeSuccess:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }

}

@end
