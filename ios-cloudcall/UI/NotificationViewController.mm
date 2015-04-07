/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "NotificationViewController.h"
#import "NgnEngine.h"
#import "CloudCall2AppDelegate.h"
#import "BaloonCell.h"

#import "MobClick.h"

#define kTagAlertClear 1
#define kOnNotifyMsgResponseStatusFinished          @"kOnNotifyMsgResponseStatusFinished"

static NSString* defaultNotificationMsg =
@"云通官网：http://www.callwine.net\n\
新浪微博：http://weibo.com/yuntong2013\n\
微信公众账号：云通";


@implementation NotificationViewController

@synthesize tableView;
@synthesize viewToolbar;
@synthesize labelNum;
@synthesize buttonAd;
@synthesize labelTitle;
@synthesize toolbar;

/*delete   from   table   where   rowid   in 
( 
 select   rowid   from 
 ( 
  select   time   from   table   order   by   time 
  ) 
 where   rownum   =   1 
 ); */

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
#pragma mark
#pragma mark Private Methods
-(void)AddDefaultMessage {
    @synchronized(sysnotification)
    {
        if ([sysnotification count] == 0) {
//            showDefaultMsg = YES;
            
            NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
            NgnSystemNotification* n = [[NgnSystemNotification alloc] initWithContent:defaultNotificationMsg andMyNumber:mynum andReceiveTime:[[NSDate date] timeIntervalSince1970] andRead:YES];
            [sysnotification addObject:n];
            [n release];
        }
    }
}

- (void) onButtonToolBarItemClick: (id)sender
{
    if (sender == self->barButtonBack) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (sender == self->barButtonClear) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message:NSLocalizedString(@"Clear All Messages", @"Clear All Messages")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        alert.tag = kTagAlertClear;
        [alert show];
        [alert release];
    }
}

- (void)reloadDataOnFinishedLoading
{
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    [[NgnEngine sharedInstance].storageService dbLoadSystemNofitication:sysnotification andMyNumber:mynum];
    
    for (int i=0; i<[sysnotification count]; i++) {
        NgnSystemNotification* sysnotify = [self->sysnotification objectAtIndex:i];
        if (sysnotify.read == NO) {
            sysnotify.read = YES;
            [[NgnEngine sharedInstance].storageService updateSystemNofitication:sysnotify.myid andRead:YES];
        }
    }
    
//    [self AddDefaultMessage];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    
    [appDelegate UnreadSysNofifyNum:0];
    
    [self.tableView reloadData];
}

#pragma mark
#pragma mark View Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NotificationMessageManager *ntymsgMgr = [[[NotificationMessageManager alloc] init] autorelease];
    [ntymsgMgr GetNotificationMessages];
    
    self.labelTitle.text = NSLocalizedString(@"Customer Service", @"Customer Service");
    
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image=[UIImage imageNamed:@"toolbar_bg.png"];
    [self.toolbar addSubview:imageview];
    [imageview release];
    
    self->barButtonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonBack.frame = CGRectMake(0, 0, 44, 44);
    [self->barButtonBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self->barButtonBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [self->barButtonBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonBack];
    
    self->barButtonClear = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonClear.frame = CGRectMake(250, 8, 61, 28);
    [self->barButtonClear setTitle:NSLocalizedString(@"Clear", @"Clear") forState:UIControlStateNormal];
    [self->barButtonClear setBackgroundImage:[UIImage imageNamed:@"reconnect_up.png"] forState:UIControlStateNormal];
    [self->barButtonClear setBackgroundImage:[UIImage imageNamed:@"reconnect_down.png"] forState:UIControlStateHighlighted];
    self->barButtonClear.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    self->barButtonClear.titleLabel.textColor = [UIColor colorWithRed:130.0/255 green:140.0/255 blue:150.0/255 alpha:1];
    [self->barButtonClear addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonClear];
    
    //self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = labelNum;
    
    if (SystemVersion >= 7.0)
    {
        self.viewToolbar.frame = CGRectMake(self.viewToolbar.frame.origin.x, self.viewToolbar.frame.origin.y + 20, self.viewToolbar.frame.size.width, self.viewToolbar.frame.size.height);
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + 20, self.tableView.frame.size.width, self.tableView.frame.size.height);
    }
    
    if (!sysnotification) {
		sysnotification = [[NSMutableArray alloc] init];
	}
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    [[NgnEngine sharedInstance].storageService dbLoadSystemNofitication:sysnotification andMyNumber:mynum];
    
    for (int i=0; i<[sysnotification count]; i++) {
        NgnSystemNotification* sysnotify = [self->sysnotification objectAtIndex:i];
        if (sysnotify.read == NO) {
            sysnotify.read = YES;
            [[NgnEngine sharedInstance].storageService updateSystemNofitication:sysnotify.myid andRead:YES];
        }
    }
    
//    [self AddDefaultMessage];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);

    [appDelegate UnreadSysNofifyNum:0];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [tableView release];
    [viewToolbar release];
    [labelNum release];
    [buttonAd release];
    [toolbar release];
    [labelTitle release];
    
    [sysnotification release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: YES];
    [[CloudCall2AppDelegate sharedInstance] viewChanged:self];
    self.labelNum.text = [sysnotification count] ? @"" : NSLocalizedString(@"No System Notification", @"No System Notification");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataOnFinishedLoading) name:kOnNotifyMsgResponseStatusFinished object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark
#pragma mark UITableView Datasource
- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	@synchronized(sysnotification){

        return [BaloonCell getSysNotifyHeight:[sysnotification objectAtIndex: indexPath.row] constrainedWidth:_tableView.frame.size.width];
	}
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    CCLog(@"sysnotification num=%d", [self->sysnotification count]);
	@synchronized(sysnotification)
    {
		return [sysnotification count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaloonCell *cell = (BaloonCell*)[_tableView dequeueReusableCellWithIdentifier: kBaloonCellIdentifier];
	if (cell == nil)
    {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"BaloonCell" owner:self options:nil] lastObject];
        cell.backgroundColor = [UIColor clearColor];
         @synchronized(sysnotification)
        {
            [cell setSysNotify:[sysnotification objectAtIndex: indexPath.row] andImage:[UIImage imageNamed:@"xiaomishu.png"] forTableView:_tableView];
        }
	}
	
	return cell;
}

- (void)tableView:(UITableView *)_tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    CCLog(@"moveRowAtIndexPath");
	NSString *contentsToMove = [[self->sysnotification objectAtIndex:[fromIndexPath row]] retain];
    
    NgnSystemNotification* sysnotify = [sysnotification objectAtIndex:fromIndexPath.row];
    [[NgnEngine sharedInstance].storageService deleteSystemNofitication:sysnotify.myid];
	
	[self->sysnotification removeObjectAtIndex:[fromIndexPath row]];
	[self->sysnotification insertObject:contentsToMove atIndex:[toIndexPath row]];
	
	[contentsToMove release];
}

/*- (void)tableView:(UITableView *)tableView_ accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {	
	[self tableView:tableView_ didSelectRowAtIndexPath:indexPath];
}*/

#pragma mark
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CCLog(@"systemnotification didSelectRowAtIndexPath %d", indexPath.row);
}

/**
 *	@brief	是否允许滑动删除
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)_tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NgnSystemNotification* sysnotify = [sysnotification objectAtIndex:indexPath.row];
        [[NgnEngine sharedInstance].storageService deleteSystemNofitication:sysnotify.myid];
        
		[self->sysnotification removeObjectAtIndex:[indexPath row]];
		
		NSArray *indexPathsToRemove = [NSArray arrayWithObject:indexPath];
		[_tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationRight];
	}
}

#pragma mark
#pragma mark UIAlertView Delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) // Cancel - Do Nothing
        return;
    else if (buttonIndex == 1) { // OK
        switch (alertView.tag) {
            case kTagAlertClear: {
//                if (!showDefaultMsg)
//                {
                    @synchronized(sysnotification){
                        [sysnotification removeAllObjects];
                        NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
                        [[NgnEngine sharedInstance].storageService deleteSystemNofiticationWithMyNum:mynum];
                        
//                        showDefaultMsg = YES;
//                        NgnSystemNotification* n = [[NgnSystemNotification alloc] initWithContent:defaultNotificationMsg andMyNumber:mynum andReceiveTime:[[NSDate date] timeIntervalSince1970] andRead:YES];
//                        [sysnotification addObject:n];
//                        [n release];
                        
                        [self.tableView reloadData];
//                    }
                    //[self AddDefaultMessage];
                }
                break;
            }
        }
    }
}

@end
