/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "MessagesViewController.h"
#import "SelectIMContactViewController.h"
#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"

#import "IMChatViewController.h"
#import "IMWebInterface.h"
#import "IMGroupViewController.h"
#import "UIBadgeView.h"
#import "SqliteHelper.h"
#import "MessageCell.h"
#import "StaticUtils.h"

#import "MobClick.h"

#define kTagAlertLogin 1000

//
//	Private
//

@interface MessagesViewController(Private)
-(void) refreshData;

-(void) onReceiveNewMsg;
-(void)reloadTableView;

// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
- (void)layoutForCurrentOrientation:(BOOL)animated;
@end

@implementation MessagesViewController(Private)

-(void) refreshData{
    //CCLog(@"refreshData");    
	@synchronized(friendArray) {
        NSString* searchTxt = self.searchBar.text;
        NSMutableArray* newFriends = [[NSMutableArray alloc] init];
		for (IMFriendInfo *imf in friendArray) {
            if (imf.contact)
            {
                imf.contact = nil;
            }
    
            NgnContact *contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:imf.number];
            if (!contact)
                continue;

            imf.contact = contact;
            
            if ([NgnStringUtils isNullOrEmpty:searchTxt])
                continue;
    
            NSRange displayNameRange, abDisplayNameRange, displayNumberRange;
            displayNameRange = [contact.displayName rangeOfString:searchTxt options:NSCaseInsensitiveSearch];
            abDisplayNameRange = [contact.abDisplayName rangeOfString:searchTxt options:NSCaseInsensitiveSearch];            
            if (abDisplayNameRange.location == NSNotFound && contact.abDisplayName && [contact.abDisplayName length]) {
                // 首字母匹配
                NSArray *abArray = [contact.abDisplayName componentsSeparatedByString:@" "];
                if ([searchTxt length] <= [abArray count]) {
                    NSString *nameString = [NSMutableString stringWithCapacity:20];
                    for (NSString *str in abArray) {
                        if ([str length]) {
                            NSString *firstLetter = [str substringToIndex:1];
                            nameString = [nameString stringByAppendingString:firstLetter];
                        }
                    }
                    if ([nameString length]) {
                        abDisplayNameRange = [nameString rangeOfString:searchTxt options:NSCaseInsensitiveSearch];
                    }
                }
            }
            if (abDisplayNameRange.location == NSNotFound && contact.abDisplayName && [contact.abDisplayName length]) {
                NSString *abname = [contact.abDisplayName stringByReplacingOccurrencesOfString:@" " withString:@""];
                if ([abname length]) {
                    abDisplayNameRange = [abname rangeOfString:searchTxt options:NSCaseInsensitiveSearch];
                }
            }
            
            if (displayNameRange.location == NSNotFound && abDisplayNameRange.location == NSNotFound) {
                //号码匹配
                NSString* tmpPhoneNum = [imf.number phoneNumFormat];
                
                if (tmpPhoneNum && [tmpPhoneNum length]) {
                    displayNumberRange = [tmpPhoneNum rangeOfString:searchTxt];
                }
            }
            
			if ([NgnStringUtils isNullOrEmpty: contact.displayName]
                || ((displayNameRange.location == NSNotFound) && (abDisplayNameRange.location == NSNotFound) && (displayNumberRange.location == NSNotFound)))
            {
				continue;
			}
            
            [newFriends addObject:imf];
		}
        
        if (newFriends && [newFriends count]) {
            [friendArray release];
            friendArray = newFriends;
        } else {
            if (searchTxt && [searchTxt length]) {
                [friendArray removeAllObjects];
            }
            [newFriends release];
        }
        
	}
}

- (void) onReceiveNewMsg {
    [self reloadTableView];
}


- (void)reloadTableView
{
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    [helper selectFriendsRecords:friendArray];
    [helper closeDatabase];
    [helper release];
    
    [self refreshData];
    [self.tableView reloadData];
}


-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    // by default content consumes the entire view area
    //CGRect contentFrame = self.view.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by the banner height to get the final position
	//CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    CGPoint bannerOrigin;
    bannerOrigin.x = 0;
    bannerOrigin.y = 50;
    
    if (iadbanner) {
        // First, setup the banner's content size and adjustment based on the current orientation
        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
            iadbanner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifierPortrait;
        else {
            if (SystemVersion < 4.2) {
                iadbanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
            } else {
                iadbanner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierPortrait;
            }
        }
        
        // Depending on if the banner has been loaded, we adjust the content frame and banner location
        // to accomodate the ad being on or off screen.
        // This layout is for an ad at the bottom of the view.
        
        // And finally animate the changes, running layout for the content view if required.
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             iadbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, iadbanner.frame.size.width, iadbanner.frame.size.height);
                         }];
    }
    else if (lmbanner) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             lmbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, lmbanner.frame.size.width, lmbanner.frame.size.height);
                         }];
    }
    else if (bdbanner) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             bdbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, bdbanner.frame.size.width, bdbanner.frame.size.height);
                         }];
    }
}


@end


//
//	Default
//

// default implementation
@implementation MessagesViewController

@synthesize searchBar;
@synthesize tableView;
@synthesize toolBar;
@synthesize viewToolbar;
@synthesize labelTitle;
@synthesize buttonAd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Messages", @"Messages") image:[UIImage imageNamed:@"tab_im_normal"] tag:3];
        if (SystemVersion >= 5.0)
            [item setFinishedSelectedImage:[UIImage imageNamed:@"tab_im_down"]
               withFinishedUnselectedImage:[UIImage imageNamed:@"tab_im_normal"]];
        
        self.tabBarItem = item;
        [item release];
        
        //friendArray = [[NSMutableArray alloc] init];
        // 订阅消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNewMsg) name:@"IMReceiveNewMessageNotification" object:nil];
        
    }
    return self;
}



#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) // Cancel - Do Nothing
        return;
    
    if (buttonIndex == 1) { // OK
        switch (alertView.tag) {

//            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ///////////////////////////////////////
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image=[UIImage imageNamed:@"toolbar_bg.png"];
    [self.toolBar addSubview:imageview];
    [imageview release];
    ///////////////////////////////////////
    
    self.labelTitle.text = NSLocalizedString(@"Messages", @"Messages");
    self.labelTitle.textColor = [UIColor colorWithRed:130.0f/255.0f green:140.0f/255.0f blue:150.0f/255.0f alpha:1.0];
    
    //判断设备的版本
//    if (SystemVersion >= 5.0)
//    {    //ios5 新特性
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"toolbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
//        NSLog(@"222222");
//    }
//    else
//    {
//        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:56.0/255.0 green:163.0/255.0 blue:253.0/255.0 alpha:1.0];
//    }
    
    
    
    // 群组 
    UIButton* barButtonItemGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    barButtonItemGroup.frame = CGRectMake(276, 0, 44, 44);
    [barButtonItemGroup setBackgroundImage:[UIImage imageNamed:@"addChat_up"] forState:UIControlStateNormal];
    [barButtonItemGroup setBackgroundImage:[UIImage imageNamed:@"addChat_down"] forState:UIControlStateHighlighted];
    [barButtonItemGroup addTarget:self action:@selector(addChat:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolBar addSubview:barButtonItemGroup];
    
	self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	self.modalPresentationStyle = UIModalPresentationPageSheet;
    
    tableView.delegate = self;
	tableView.dataSource = self;
    tableView.tableHeaderView = searchBar;
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"searchBar_bg.png"]];
    self.searchBar.showsCancelButton = NO;
    
    friendArray = [[NSMutableArray alloc] init];
    
    /*UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableFooterView = footerView;
    [footerView release];*/
    
    //[MBProgressHUD showHUDAddedTo:[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] animated:YES];
    
    if (SystemVersion >= 7.0)
    {
        self.buttonAd.frame = CGRectMake(0, 20, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height);
        self.viewToolbar.frame = CGRectMake(self.viewToolbar.frame.origin.x, self.viewToolbar.frame.origin.y + 20, self.viewToolbar.frame.size.width, self.viewToolbar.frame.size.height);
        self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y + 20, self.tableView.frame.size.width, self.tableView.frame.size.height-70);
        self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x, self.searchBar.frame.origin.y + 20, self.searchBar.frame.size.width, self.searchBar.frame.size.height);
    }
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
    [self setButtonAd:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: YES];
    [[CloudCall2AppDelegate sharedInstance] viewChanged:self];
    
    [MobClick beginLogPageView:@"Messages"];
    [self reloadTableView];
    
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    int unreadnum = [helper selectAllUnReadCountByReceiver:mynum];
    [helper closeDatabase];
    [helper release];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*)[[UIApplication sharedApplication] delegate]);
    [appDelegate UnreadIMNum:unreadnum];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden: NO];
    [MobClick endLogPageView:@"Messages"];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [searchBar release];
	[tableView release];
	[toolBar release];
	[viewToolbar release];
    [labelTitle release];
    
    [friendArray release], friendArray = nil;
    
    [buttonAd release];
    [super dealloc];
}

#pragma mark - customized methos
- (void)addChat:(id)sender
{
    SelectIMContactViewController *viewController = [[SelectIMContactViewController alloc] initWithNibName:@"SelectIMContactViewController" bundle:nil];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (void)EnterIMChatView:(NSString *)friendAccount
{  
    IMChatViewController *viewController = [[IMChatViewController alloc] init];
    viewController.friendAccount = friendAccount;
    viewController.isGroup = NO;
    viewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

#pragma mark - searchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
	
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
	//self.searchBar.text = @"";
	[self.searchBar resignFirstResponder];
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    [self reloadTableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [friendArray count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MessageCell height];
}

- (UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = (MessageCell*)[_tableView dequeueReusableCellWithIdentifier: kMessageCellIdentifier];

    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil] lastObject];
                
        UIBadgeView *badgeView = [[UIBadgeView alloc] initWithFrame:CGRectMake(40, 0, 28, 28)];
        badgeView.badgeColor = [UIColor redColor];
        badgeView.tag = 111;
        [cell.contentView addSubview:badgeView];
        [badgeView release];        
    }
    
    IMFriendInfo* imfriend = [friendArray objectAtIndex:indexPath.row];
                              
    UIBadgeView *badgeView = (UIBadgeView *)[cell.contentView viewWithTag:111];
    
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    int unReadCount = [helper selectUnReadCount:imfriend.number];
    if (unReadCount == 0)
    {
        badgeView.hidden = YES;
    }
    else
    {
        badgeView.hidden = NO;
        if (unReadCount < 10)
        {
            badgeView.badgeString = [NSString stringWithFormat:@"%d", unReadCount];
            badgeView.frame = CGRectMake(40, 0, 28, 28);
        }
        else if (unReadCount >= 10 && unReadCount < 100)
        {
            badgeView.badgeString = [NSString stringWithFormat:@"%d", unReadCount];
            badgeView.frame = CGRectMake(30, 0, 28, 28);
        }
        else if (unReadCount >= 100 && unReadCount < 1000)
        {
            badgeView.badgeString = [NSString stringWithFormat:@"%d", unReadCount];
            badgeView.frame = CGRectMake(25, 0, 35, 28);
        }
        else if (unReadCount >= 1000)
        {
            badgeView.badgeString = @"...";
            badgeView.frame = CGRectMake(35, 0, 28, 28);
        }
    }
    [helper closeDatabase];
    [helper release];
    
    imfriend.unreadnum = unReadCount;
    
    NSString *friendNum = imfriend.number;

    NgnContact *contact = (NgnContact*)imfriend.contact;
    if (contact) {
        imfriend.contact = contact;
        
        if (contact.displayName) friendNum = contact.displayName;
    }
    
    cell.labelDisplayName.text = friendNum;
    
    UIView *tmpView = [cell.labelContent viewWithTag:kTagFaceView];
    if (tmpView)
        [tmpView removeFromSuperview];
    
    NSString* strContent = @"";
    if (imfriend.fileType == FileType_Text)
    {
        strContent = imfriend.message;
        
        NSRange range_left = [imfriend.message rangeOfString:@"["];
        NSRange range_right = [imfriend.message rangeOfString:@"]"];
        if (range_left.location != NSNotFound && range_right.location != NSNotFound && range_right.location - range_left.location <= 4)
        {
            NSBubbleData *bubbleData = [[NSBubbleData alloc] init];
            UIView *faceView = [bubbleData assembleMessageAtIndex:strContent from:NO];
            [faceView setFrame:CGRectMake(0, -1, faceView.frame.size.width, faceView.frame.size.height)];
            faceView.tag = kTagFaceView;
            [cell.labelContent addSubview:faceView];
            [bubbleData release];
            cell.labelContent.text = @"";
        }
        else
        {
            cell.labelContent.text = strContent;
        }
        
    } else if (imfriend.fileType == FileType_Photo) {
        strContent = NSLocalizedString(@"[Photo]", @"[Photo]");
        cell.labelContent.text = strContent;
    } else if (imfriend.fileType == FileType_Audio) {
        strContent = NSLocalizedString(@"[Audio]", @"[Audio]");
        cell.labelContent.text = strContent;
    } else if (imfriend.fileType == FileType_MedialURL) {
        strContent = NSLocalizedString(@"[Medial URL]", @"[Medial URL]");
        cell.labelContent.text = strContent;
    }
    cell.labelDate.text = [StaticUtils transformMessageViewDate: imfriend.time];
    
    //异步显示图片,防止消息列表过多时滑动会卡
    dispatch_queue_t queue = dispatch_queue_create (DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
    dispatch_async(queue, ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        if (contact && contact.picture)
        {
            UIImage *avatarImage = [StaticUtils createRoundedRectImage:[UIImage imageWithData:contact.picture] size:CGSizeMake(80, 80)];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.headImage.image = avatarImage;
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.headImage.image = [StaticUtils createRoundedRectImage:[UIImage imageNamed:@"contact_noavatar_icon"] size:CGSizeMake(80, 80)];
            });
        }
        [pool release];
    });
    dispatch_release(queue);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMFriendInfo* imf = [friendArray objectAtIndex:indexPath.row];
    
    IMChatViewController *viewController = [[IMChatViewController alloc] init];
    viewController.friendAccount = imf.number;
    viewController.isGroup = NO;
    viewController.initNumberOfMsg = imf.unreadnum;
    viewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];    

}

/**
 *	@brief	是否允许滑动删除
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)_tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	IMFriendInfo* imfriend = [friendArray objectAtIndex:indexPath.row];
    NSString *userNumber = imfriend.number;
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];

    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    
    [helper deleteFriendWithUserId:userNumber];
    //更新tab上的badge
    int unreadAllnum = [helper selectAllUnReadCountByReceiver:mynum];
    
    [helper closeDatabase];
    [helper release];
    
    [[CloudCall2AppDelegate sharedInstance] UnreadIMNum:unreadAllnum];
    [friendArray removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPathsToRemove = [NSArray arrayWithObject:indexPath];
    [_tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationRight];
}

// BannerViewContainer
- (void)showBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
    //    if (nil == bannerView && (type != AD_TYPE_BAIDU || type != AD_TYPE_91DIANJIN)) {
    //        return;
    //    }
    
    if (type == AD_TYPE_IAD) {
        iadbanner = (ADBannerView*)bannerView;
        [self.view addSubview:iadbanner];
        [self layoutForCurrentOrientation:animated];
    }
    else if (type == AD_TYPE_LIMEI) {
           lmbanner = (immobView*)bannerView;
           [self.view addSubview:lmbanner];
    }
    else if (type == AD_TYPE_BAIDU || type == AD_TYPE_91DIANJIN){
           bdbanner = (BaiduMobAdView*)bannerView;
           [self.view addSubview:bdbanner];
       }
}

- (void)hideBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
    if (type == AD_TYPE_IAD) {
        iadbanner = nil;
        [self layoutForCurrentOrientation:animated];
    }else if (type == AD_TYPE_LIMEI) {
        if (lmbanner) {
            [lmbanner removeFromSuperview];
            lmbanner = nil;
        }
    } else if (type == AD_TYPE_BAIDU) {
        if (bdbanner) {
            [bdbanner removeFromSuperview];
            bdbanner = nil;
        }
    }
}


@end
