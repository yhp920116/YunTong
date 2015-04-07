//
//  SelectTableViewController.m
//  CloudCall
//
//  Created by Sergio on 13-3-5.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import "SelectTableViewController.h"
#import "CloudCall2AppDelegate.h"

@implementation SelectTableViewController
@synthesize pointTableView;
@synthesize delegate;
@synthesize pointArray;

#pragma mark
#pragma mark view lifecycle
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
- (id)initWithFiltertype:(NSMutableArray *)array andViewType:(PopViewType)type andSize:(CGSize)size
{
    self = [super init];
    if (self) {
        CGFloat height = 32;
        
        self.contentSizeForViewInPopover = size;
        
        self.pointArray = array;
        self->popViewType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //pointArray = [[NSArray alloc] initWithObjects:@"100",@"200",@"300",@"400",@"500", nil];
    
    self.pointTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.contentSizeForViewInPopover.width, self.contentSizeForViewInPopover.height) style:UITableViewStylePlain] autorelease];
    pointTableView.dataSource = self;
    pointTableView.delegate = self;
    [self.view addSubview:self.pointTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [pointTableView release];
    [pointArray release];
    
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
    return [self.pointArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell"];
    UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
    UITableViewCell *cell = [self.pointTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    switch (popViewType)
    {
        case kTagTableViewForSlotMachine:
        {
            cell.textLabel.text = [pointArray objectAtIndex:indexPath.row];
            break;
        }
        case kTagTableAlertSendMsg:
        case kTagTableAlertInvite:
        {
            NgnPhoneNumber* phoneNumber = [pointArray objectAtIndex:indexPath.row];
            cell.textLabel.text = phoneNumber.number;
            break;
        }
        default:
            break;
    }
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.font = [UIFont fontWithName:@"System" size:15.0];
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
        [delegate selectTableViewDidSelected:indexPath.row andType:popViewType];
    }
}
@end
