//
//  IMGroupViewController.m
//

#import "IMGroupViewController.h"
#import "MBProgressHUD.h"

#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"

#import "IMWebInterface.h"
#import "UIBadgeView.h"
#import "SqliteHelper.h"
#import "IMChatViewController.h"

@interface IMGroupViewController ()

@end

@implementation IMGroupViewController
@synthesize tableView;

- (void) onReceiveNewMsg
{
    [tableView reloadData];
}

- (void) onLoadFriendListSuccessful:(NSNotification *) notification
{
    //[MBProgressHUD hideHUDForView:[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] animated:YES];
    [groupArray addObjectsFromArray:[notification object]];
    [tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Groups", @"Groups");
    
    //判断设备的版本
    if (SystemVersion >= 5.0)
    {    //ios5 新特性
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"toolbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:56.0/255.0 green:163.0/255.0 blue:253.0/255.0 alpha:1.0];
    }
    
    self->barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonItemBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self->barButtonItemBack] autorelease];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableFooterView = footerView;
    [footerView release];
    
    groupArray = [[NSMutableArray alloc] init];
    
    // 订阅消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNewMsg) name:@"IMReceiveNewMessageNotification" object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadFriendListSuccessful:) name:LoadGroupListSuccessful object:nil];
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];

    //[MBProgressHUD showHUDAddedTo:[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] animated:YES];
    [[IMWebInterface sharedInstance] sendLoadGroupListRequest:username];
}

- (void) viewWillAppear:(BOOL)animated
{
    [tableView reloadData];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
	[tableView release];
    
    [groupArray release], groupArray = nil;
    
    [super dealloc];
}


- (IBAction)onButtonToolBarItemClick: (id)sender {
    if (sender == barButtonItemBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groupArray count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *friendCell = @"FriendCell_";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:friendCell];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendCell] autorelease];
        
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        headImageView.image = [UIImage imageNamed:@"test"];
        [cell.contentView addSubview:headImageView];
        [headImageView release];
        
        UIBadgeView *badgeView = [[UIBadgeView alloc] initWithFrame:CGRectMake(35, 4, 38, 30)];
        badgeView.badgeColor = [UIColor redColor];
        badgeView.tag = 111;
        [cell.contentView addSubview:badgeView];
        [badgeView release];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 200, 60)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.tag = 222;
        [cell.contentView addSubview:nameLabel];
        [nameLabel release];
    }
    
    UIBadgeView *badgeView = (UIBadgeView *)[cell.contentView viewWithTag:111];
    
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    if ([helper selectUnReadCount:[[groupArray objectAtIndex:indexPath.row] objectForKey:@"groupId"]] == 0)
    {
        badgeView.hidden = YES;
    }
    else
    {
        badgeView.hidden = NO;
        badgeView.badgeString = [NSString stringWithFormat:@"%d", [helper selectUnReadCount:[[groupArray objectAtIndex:indexPath.row] objectForKey:@"groupId"]]];
    }
    [helper closeDatabase];
    [helper release];
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:222];
    nameLabel.text = [[groupArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMChatViewController *viewController = [[IMChatViewController alloc] init];
    viewController.friendAccount = [[groupArray objectAtIndex:indexPath.row] objectForKey:@"groupId"];
    viewController.isGroup = YES;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentModalViewController:nav animated:YES];
    [viewController release];
    [nav release];
}

@end
