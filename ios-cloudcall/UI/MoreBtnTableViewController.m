//
//  MoreBtnTableViewController.m
//  CloudCall
//
//  Created by CloudCall on 13-6-20.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "MoreBtnTableViewController.h"

@interface MoreBtnTableViewController ()

@end

@implementation MoreBtnTableViewController
@synthesize optionsArray;
@synthesize optionsTableView;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.contentSizeForViewInPopover = CGSizeMake(100, 127);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.optionsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 127) style:UITableViewStylePlain] autorelease];
    optionsTableView.dataSource = self;
    optionsTableView.delegate = self;
    [self.view addSubview:self.optionsTableView];
    
    self.optionsArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"Reservation", @"Reservation"), NSLocalizedString(@"Mass SMS", @"Mass SMS"), NSLocalizedString(@"Edit", @"Edit"), NSLocalizedString(@"Share", @"Share"), nil];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [optionsTableView release];
    [optionsArray release];
    [delegate release];
    
    [super dealloc];
}

#pragma mark
#pragma mark table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section
{
    return [optionsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell"];
    UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
    UITableViewCell *cell = [optionsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumFontSize = 1.0f; 
    cell.textLabel.text = [optionsArray objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"System Bold" size:15.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    [cell.backgroundView setFrame:CGRectMake(0, 0, 80, 32)];
    cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:180.0f/255.0f blue:100.0f/255.0f alpha:1];
    return cell;
}

#pragma mark
#pragma mark table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (delegate)
    {
        [delegate MoreBtnTableViewDidSelectRowAtIndexPath:indexPath.row];
    }
//    self.slotMachineViewController.bet.text = [NSString stringWithFormat:@"%@",[pointArray objectAtIndex:indexPath.row]];
//    [self.slotMachineViewController.popoverController dismissPopoverAnimated:YES];
}

@end
