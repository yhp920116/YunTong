/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import "ConferenceScheduledViewController.h"
#import "CloudCall2AppDelegate.h"
#import "NgnEngine.h"

@interface ConferenceScheduledViewController(Private)
-(void) getConferenceScheduleFromNet;
@end

@implementation ConferenceScheduledViewController(Private)
-(void) getConferenceScheduleFromNet {
    NSString* myNum = nil;
}
@end

@implementation ConferenceScheduledViewController

@synthesize tableView;


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

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    if (!scheduled) {
		scheduled = [[NSMutableArray alloc] init];
	}
    //[[NgnEngine sharedInstance].storageService dbLoadConfFavorites:conferences];  
        
    self.navigationItem.title = NSLocalizedString(@"Conference Scheduled", @"Conference Scheduled");
    tableView.delegate = self;
    tableView.dataSource = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


/*- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden: YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden: NO];
}*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) onButtonClick: (id)sender {
}


//
//	UITableViewDelegate
//

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {    
    if (self->scheduled == nil) 
        return 0;
	NSInteger rows = [self->scheduled count];
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSString* name = [self->scheduled objectAtIndex:[indexPath row]];
    [cell.textLabel setText: name];
    
	return cell;
}


- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        CCLog(@"commitEditingStyle");
		[self->scheduled removeObjectAtIndex:[indexPath row]];
		
		NSArray *indexPathsToRemove = [NSArray arrayWithObject:indexPath];        
		[_tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationRight];
	}
}

- (void)tableView:(UITableView *)_tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    CCLog(@"moveRowAtIndexPath");
	NSString *contentsToMove = [[self->scheduled objectAtIndex:[fromIndexPath row]] retain];
	
	[self->scheduled removeObjectAtIndex:[fromIndexPath row]];
	[self->scheduled insertObject:contentsToMove atIndex:[toIndexPath row]];
	
	[contentsToMove release];
}

- (void)dealloc {
    [tableView release];
    
    [scheduled release];

    [super dealloc];
}


@end
