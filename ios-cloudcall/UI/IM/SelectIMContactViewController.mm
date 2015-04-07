//
//  SelectIMContactViewController.m
//  CloudCall
//
//  Created by CloudCall on 13-7-19.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "SelectIMContactViewController.h"
#import "CloudCall2Constants.h"
#import "CloudCall2AppDelegate.h"
#import "IMChatViewController.h"

#define kFriend_name @"cloudcall_friend_name"
#define kFriend_number @"cloudcall_friend_number"


@implementation CloudCallFriend

@synthesize Name;
@synthesize Number;

-(void) dealloc
{
    [Name release];
    [Number release];
    [super dealloc];
}

@end

@interface SelectIMContactViewController(Private)
-(void) refreshData;
-(void) reloadData;
-(void) refreshDataAndReload;
@end

@implementation SelectIMContactViewController(Private)

-(void) refreshData {
	@synchronized(contacts){
		[contacts removeAllObjects];
        
        NgnContactMutableArray* contacts_ = (NgnContactMutableArray*)[[[NgnEngine sharedInstance].contactService contacts] retain];
        NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
        
        NSMutableDictionary* weicallusers = [[NSMutableDictionary alloc] init];
        [[NgnEngine sharedInstance].contactService dbLoadWeiCallUserContacts:weicallusers];

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
                    
                    //使用正则表达式
                    NSString* tmpPhoneNum2 = [tmpPhoneNum phoneNumFormat];
                    NSObject *object = [weicallusers objectForKey:tmpPhoneNum2];
                    if (!object) {
                        continue;
                    }
                    if ([tmpPhoneNum2 isEqualToString:mynum])
                        continue;
                    
                    if (IsPureNumber(tmpPhoneNum)) {
                        CloudCallFriend *ccf = [[CloudCallFriend alloc] init];
                        ccf.Name   = contact.displayName;
                        ccf.Number = tmpPhoneNum;
                        
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
                        [lastArray addObject: ccf];
                        [ccf release];
                    }
                }
            }
		}
		[lastArray release];
		[contacts_ release];
        
        [weicallusers release];
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

@end

@implementation SelectIMContactViewController
@synthesize tableView;
@synthesize searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Select Contact", @"Select Contact");
    
    UIButton *barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [barButtonItemBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [barButtonItemBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:barButtonItemBack] autorelease];
    
    if (!contacts) {
		contacts = [[NSMutableDictionary alloc] init];
	}
    [self refreshData];
    
    tableView.delegate = self;
	tableView.dataSource = self;
    self.tableView.tableHeaderView = self.searchView;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"searchBar_bg.png"]];
    self.searchBar.showsCancelButton = NO;
    
    //设置字母索引的背景颜色为透明
    if ([tableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        if (SystemVersion >= 7.) {
            tableView.sectionIndexBackgroundColor = [UIColor clearColor];

        }
        if (SystemVersion >= 6.) {
            tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        }
    }
    

    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden: NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [tableView release];
    [searchBar release];
    
    [contacts removeAllObjects];
    [contacts release];
    [orderedSections release];
    

    [_searchView release];
    [super dealloc];
}

- (IBAction)onButtonToolBarItemClick: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    myView.backgroundColor = [UIColor colorWithRed:158.0/255.0 green:193.0/255.0 blue:240.0/255.0 alpha:0.7];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
    titleLabel.textColor=[UIColor whiteColor];
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
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    
	@synchronized(contacts) {
        if ([orderedSections count] > indexPath.section) {
            NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
            CloudCallFriend* ccf = [values objectAtIndex: indexPath.row];
            if (ccf) {
                //CCLog(@"select participant: %@, %@\n", pi.Name, pi.Number);
                [cell.textLabel setText: ccf.Name];
                [cell.detailTextLabel setText:ccf.Number];
                
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
- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView_ deselectRowAtIndexPath:indexPath animated:NO];
    
    if([orderedSections count] > indexPath.section){
        NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
        CloudCallFriend* ccf = [values objectAtIndex: indexPath.row];
        
        IMChatViewController *viewController = [[IMChatViewController alloc] init];
        viewController.friendAccount = ccf.Number;
        viewController.isAddChat = YES;
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];

    }
   
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}


#pragma mark - searchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searching = YES;
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}



- (void)viewDidUnload {
//    [self setToolBar:nil];
    [self setSearchView:nil];
    [super viewDidUnload];
}
@end
