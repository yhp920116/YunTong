/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "CloudCall2AppDelegate.h"
#import "ConferenceViewController.h"
#import "ConferenceFavoritesViewController.h"
#import "CreateGroupViewController.h"

#import "NgnEngine.h"
#import "MobClick.h"

#define kTagActionSheetDetail 1
#define kTagAlertDelete 2
#define kTagAlertRename 3
#define kTagAlertAddToFavorite 4
#define kTagAlertFavoriteNameRequired 5

@interface ConferenceFavoritesViewController(Private)
- (void)layoutForCurrentOrientation:(BOOL)animated;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)GroupCallResponseStatus:(NSNotification *)notification;
@end

@implementation ConferenceFavoritesViewController(Private)

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
    bannerOrigin.y = self.buttonAd.bounds.origin.y;
    
    if (iadbanner) {
        // First, setup the banner's content size and adjustment based on the current orientation
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
            iadbanner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifierPortrait;
        else {
            iadbanner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
            
        }
        
        // Depending on if the banner has been loaded, we adjust the content frame and banner location
        // to accomodate the ad being on or off screen.
        // This layout is for an ad at the bottom of the view.
        
        // And finally animate the changes, running layout for the content view if required.
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             iadbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, iadbanner.frame.size.width, iadbanner.frame.size.height);
                         }];
    } else if (lmbanner) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             lmbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, lmbanner.frame.size.width, lmbanner.frame.size.height);
                         }];
    } else if (bdbanner) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             if (SystemVersion >= 7.0)
                             {
                                 bdbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y + 20, bdbanner.frame.size.width, bdbanner.frame.size.height);
                             }
                             else
                             {
                                 bdbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, bdbanner.frame.size.width, bdbanner.frame.size.height);
                             }
                         }];
    }
}
//////////////////////

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews data source model to reload
    _reloading = YES;    
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    
    NSMutableArray* delConfs = [[NSMutableArray alloc] init];
    [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:delConfs andMyNumber:mynum andStatus:Conf_Edit_Status_Delete];
    for (NgnConferenceFavorite* f in delConfs) {
        [appDelegate DeleteGroupCallRecord:f.uuid];
    }
    [delConfs release];    
    
    [appDelegate GetGroupCallRecords];
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void) GroupCallResponseStatus:(NSNotification *)notification {    
    GroupCallResponseStatusNotificationArgs* gcgrsna = (GroupCallResponseStatusNotificationArgs *)notification.object;
    CCLog(@"GroupCallResponseStatus: %d, %d, %d", gcgrsna.success, gcgrsna.type, gcgrsna.errorcode);
    
    if (gcgrsna.type == GroupCallRequsetType_Add) {
        if (gcgrsna.success) {
            for (NSString* groupid in gcgrsna.records) {
                CCLog(@"GroupCallResponseStatus: add '%@'", groupid);
                
                for (NgnConferenceFavorite* f in favorites) {
                    if ([f.uuid isEqualToString:groupid]) {
                        f.status = Conf_Edit_Status_Default;
                        [[NgnEngine sharedInstance].storageService dbUpdateConfFavorite:f];
                        
                        break;
                    }
                }
            }
        } else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") message:gcgrsna.text delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
        }
    } else if (gcgrsna.type == GroupCallRequsetType_Delete) {
        if (gcgrsna.success) {
            for (NSString* groupid in gcgrsna.records) {
                CCLog(@"GroupCallResponseStatus: delete '%@'", groupid);
                [[NgnEngine sharedInstance].storageService dbDeleteConfFavorite:groupid];
            }
        } else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") message:gcgrsna.text delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
        }
    } else if (gcgrsna.type == GroupCallRequsetType_Get) {
        [self doneLoadingTableViewData];
        
        if (0 == [mynum length] || [mynum isEqualToString:DEFAULT_IDENTITY_IMPI])
            return;

        if (gcgrsna.success) {
            NSMutableArray* addConfs    = [[NSMutableArray alloc] init];
            NSMutableArray* updateConfs = [[NSMutableArray alloc] init];
            NSMutableArray* deleteConfs = [[NSMutableArray alloc] init];
            for (GroupCallRecord* r in gcgrsna.records) {
                CCLog(@"GroupCallResponseStatus: '%@', '%@', '%@'", r.usernumber, r.name, r.groupid);
                BOOL found = NO;
                for (NgnConferenceFavorite* f in favorites) {
                    if ([r.groupid isEqualToString:f.uuid]) {
                        found = YES;
                        CCLog(@"GroupCallResponseStatus: '%@', '%@', '%@', %f, %f", r.name, f.name, r.groupid, r.updatetime, f.updatetime);
                        if ((unsigned long)r.updatetime > (unsigned long)f.updatetime) {
                            f.name = r.name;
                            f.updatetime = r.updatetime;
                            f.type = r.type;
                            f.status = Conf_Edit_Status_Default;
                            [[NgnEngine sharedInstance].storageService dbUpdateConfFavorite:f];
                            
                            [[NgnEngine sharedInstance].storageService dbClearConfParticipants:f.uuid];
                            for (GroupCallMember* m in r.members) {
                                CCLog(@"GroupCallResponseStatus: member='%@'", m.number);
                                [[NgnEngine sharedInstance].storageService dbAddConfParticipant:f.uuid andPhoneNum:m.number];
                            }
                        } else if ((unsigned long)r.updatetime < (unsigned long)f.updatetime && f.status != Conf_Edit_Status_Delete) {
                                [updateConfs addObject:f];
                        } else if((unsigned long)r.updatetime < (unsigned long)f.updatetime && f.status == Conf_Edit_Status_Delete)
                        {
                            [deleteConfs addObject:f];
                        }
                        
                        break;
                    }
                }
                
                if (!found) {
                    NgnConferenceFavorite* nf = [[NgnConferenceFavorite alloc] initWithMynumber:mynum andName:r.name andUuid:r.groupid andType:r.type andUpdateTime:r.updatetime andStatus:Conf_Edit_Status_Default];
                    if (nf) {
                        [[NgnEngine sharedInstance].storageService dbAddConfFavorite:nf];
                        [[NgnEngine sharedInstance].storageService dbClearConfParticipants:r.groupid];
                        for (GroupCallMember* m in r.members) {
                            [[NgnEngine sharedInstance].storageService dbAddConfParticipant:r.groupid andPhoneNum:m.number];
                        }
                        [nf release];
                    }
                }
            }

            [self addDefultGroup:mynum];
            
            for (NgnConferenceFavorite* f in favorites) {                
                BOOL found = NO;
                for (GroupCallRecord* r in gcgrsna.records) {
                    if ([f.uuid isEqualToString:r.groupid]) {
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    if (f.status == Conf_Edit_Status_Add) {
                        [addConfs addObject:f];
                    } else {
                        [[NgnEngine sharedInstance].storageService dbDeleteConfFavorite:f.uuid];
                    }
                }
            }
            
            [favorites removeAllObjects];
            [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:favorites andMyNumber:mynum andStatus:Conf_Edit_Status_Default];
            [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:favorites andMyNumber:mynum andStatus:Conf_Edit_Status_Add];
            [self.tableView reloadData];
            
            CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
            
            //delete
            NSMutableArray* deleteRecords = [[NSMutableArray alloc] init];
            for (NgnConferenceFavorite* f in deleteConfs)
            {
                GroupCallRecord* r = [[GroupCallRecord alloc] initWithUserNumber:mynum andName:f.name andGroupId:f.uuid andType:f.type andUpdateTime:f.updatetime andMembers:nil];
                [deleteRecords addObject:r];
                [r release];
            }
            [appDelegate DeleteGroupCallRecords:deleteRecords];
            [deleteRecords release];
            
            // add
            NSMutableArray* addRecords = [[NSMutableArray alloc] init];
            for (NgnConferenceFavorite* f in addConfs) {
                NSMutableArray* members = [[NSMutableArray alloc] init];
                NSMutableArray *phonenumbers = [[NSMutableArray alloc] init];
                [[NgnEngine sharedInstance].storageService dbLoadConfParticipants:phonenumbers Uuid:f.uuid];
                for (int i=0; i<[phonenumbers count]; i++) {
                    NSString* strNum = [phonenumbers objectAtIndex:i];
                    
                    NSString* name = NSLocalizedString(@"No Name", @"No Name");
                    NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber: strNum];
                    if (contact && contact.displayName && [contact.displayName length]) {
                        name = contact.displayName;
                    }
                    
                    GroupCallMember* m = [[GroupCallMember alloc] initWithName:name andNumber:strNum];
                    [members addObject:m];
                    [m release];
                 }
                GroupCallRecord* r = [[GroupCallRecord alloc] initWithUserNumber:mynum andName:f.name andGroupId:f.uuid andType:f.type andUpdateTime:f.updatetime andMembers:members];
                [addRecords addObject:r];
                [r release];
                [phonenumbers release];
                [members release];
            }
            [appDelegate AddGroupCallRecords:addRecords];
            [addRecords release];
            
            // update
            NSMutableArray* updateRecords = [[NSMutableArray alloc] init];
            for (NgnConferenceFavorite* f in updateConfs) {
                NSMutableArray* members = [[NSMutableArray alloc] init];
                NSMutableArray *phonenumbers = [[NSMutableArray alloc] init];
                [[NgnEngine sharedInstance].storageService dbLoadConfParticipants:phonenumbers Uuid:f.uuid];
                for (int i=0; i<[phonenumbers count]; i++) {
                    NSString* strNum = [phonenumbers objectAtIndex:i];
                    
                    NSString* name = NSLocalizedString(@"No Name", @"No Name");
                    NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber: strNum];
                    if (contact && contact.displayName && [contact.displayName length]) {
                        name = contact.displayName;
                    }
                    
                    GroupCallMember* m = [[GroupCallMember alloc] initWithName:name andNumber:strNum];
                    [members addObject:m];
                    [m release];
                }
                GroupCallRecord* r = [[GroupCallRecord alloc] initWithUserNumber:mynum andName:f.name andGroupId:f.uuid andType:f.type andUpdateTime:f.updatetime andMembers:members];
                [updateRecords addObject:r];
                [r release];
                [phonenumbers release];
                [members release];
            }
            [appDelegate UpdateGroupCallRecords:updateRecords];
            [updateRecords release];
            
            [addConfs release];
            [updateConfs release];
            [deleteConfs release];
        } else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") message:NSLocalizedString(@"Refresh failed, try again later!", @"Refresh failed, try again later!") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
        }
    }
}
@end

@implementation ConferenceFavoritesViewController

@synthesize isFromConferenceView;
@synthesize GroupName;

@synthesize buttonAd;
@synthesize tableView;
@synthesize viewToolbar;
@synthesize toolbar;
@synthesize labelTitle;

@synthesize cellCreateGroup;
@synthesize m_nameTextField;

-(void) SetDelegate:(UIViewController<ParticipantPickerFromGroupDelegate> *)_delegate {
    self->delegate = _delegate;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") image:[UIImage imageNamed:@"tab_groupcall_normal"] tag:2];
        if (SystemVersion >= 5.0)
            [item setFinishedSelectedImage:[UIImage imageNamed:@"tab_groupcall_down"]
               withFinishedUnselectedImage:[UIImage imageNamed:@"tab_groupcall_normal"]];
        
        self.tabBarItem = item;
        [item release];
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

    ///////////////////////////////////////
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image=[UIImage imageNamed:@"toolbar_bg.png"];
    [self.toolbar addSubview:imageview];
    [imageview release];
    ///////////////////////////////////////
    
    /* //显示群呼引导
     if ([[[NgnEngine sharedInstance].configurationService getStringWithKey:SHOW_NEW_FOR_GROUP] length] != 0)
    {
        [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FOR_GROUP andValue:nil];
        
        UIButton *guideGroupCall = [UIButton buttonWithType:UIButtonTypeCustom];
        guideGroupCall.frame = CGRectMake(0, 20, 320, 548);
        
        guideGroupCall.tag = 1001;
        [guideGroupCall setImage:[UIImage imageNamed:@"groupGuide"] forState:UIControlStateNormal];
        [guideGroupCall setImage:[UIImage imageNamed:@"groupGuide"] forState:UIControlStateHighlighted];
        [guideGroupCall addTarget:self action:@selector(guidViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [[CloudCall2AppDelegate sharedInstance].window.rootViewController.view addSubview:guideGroupCall];
    }*/
    
    if (isFromConferenceView == YES) {
        self->barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
        self->barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
        [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
        [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
        [self->barButtonItemBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
        [self.toolbar addSubview:self->barButtonItemBack];
    }

    self->barButtonAddGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonAddGroup.frame = CGRectMake(276, 0, 44, 44);
    [self->barButtonAddGroup setBackgroundImage:[UIImage imageNamed:@"addGroup_normal.png"] forState:UIControlStateNormal];
    [self->barButtonAddGroup setBackgroundImage:[UIImage imageNamed:@"addGroup_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonAddGroup addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonAddGroup];
    
    self.labelTitle.text = NSLocalizedString(@"GroupCall", @"GroupCall");
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    if (!favorites) {
		favorites = [[NSMutableArray alloc] init];
	}
    
    mynum = [[NSString alloc] initWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
    if ([mynum length] && [mynum isEqualToString:DEFAULT_IDENTITY_IMPI] == NO) {
        [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:favorites andMyNumber:mynum andStatus:Conf_Edit_Status_Default];
        [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:favorites andMyNumber:mynum andStatus:Conf_Edit_Status_Add];
        for (NgnConferenceFavorite* f in favorites) {
            if (f.updatetime == 0) {
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                
                f.updatetime = time;
                [[NgnEngine sharedInstance].storageService dbUpdateConfFavorite:f];
            }
        }
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewReloadData:) name:kConferenceFavTableReload object:nil];
    
    if (isFromConferenceView == YES)
    {
        self.viewToolbar.frame = CGRectMake(0, 0, viewToolbar.frame.size.width, viewToolbar.frame.size.height);
        self.tableView.frame = CGRectMake(0, 44, tableView.frame.size.width, tableView.frame.size.height+44);
        self->barButtonAddGroup.hidden = YES;
    }
    else
    {
        UILongPressGestureRecognizer *longPressReger = [[UILongPressGestureRecognizer alloc]
                                                        initWithTarget:self action:@selector(handleLongPress:)];
        longPressReger.minimumPressDuration = 1.0;
        [self.tableView addGestureRecognizer:longPressReger];
        
        [longPressReger release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(GroupCallResponseStatus:) name:kGroupCallResponseStatusNotification object: nil];

        if (_refreshHeaderView == nil) {            
            _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
            _refreshHeaderView.delegate = self;
            [self.tableView addSubview:_refreshHeaderView];            
        }
        
        //  update the last update date
        [_refreshHeaderView refreshLastUpdatedDate];
        [_refreshHeaderView startRefreshLoading:self.tableView];
    }
    if (m_nameTextField == nil && SystemVersion < 5)
    {
        m_nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(27.0, 60.0, 230.0, 30.0)];
        //[m_nameTextField setBackgroundColor:[UIColor clearColor]];
        m_nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    }
    
    if (SystemVersion >= 7.0)
    {
        self.buttonAd.frame = CGRectMake(0, 20, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height);
        self.viewToolbar.frame = CGRectMake(self.viewToolbar.frame.origin.x, self.viewToolbar.frame.origin.y + 20, self.viewToolbar.frame.size.width, self.viewToolbar.frame.size.height);
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + 20, self.tableView.frame.size.width, self.tableView.frame.size.height-(50+20));
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self layoutForCurrentOrientation:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"GroupCall_group"];
    
    NSString* newmynum = [[NSString alloc] initWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
    if ([mynum isEqualToString:newmynum] == NO) {
        if (mynum) {
            [mynum release];
            mynum = nil;
        }
        mynum = [newmynum retain];
        
        [self addDefultGroup:mynum];
    }
    [newmynum release];
    
    if (isFromConferenceView == NO)
        [[CloudCall2AppDelegate sharedInstance] viewChanged:self];
    
    [self.navigationController setNavigationBarHidden: YES];    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"GroupCall_group"];
    
    [self.navigationController setNavigationBarHidden: NO];
}

#pragma mark - customized methods
- (void)tableViewReloadData:(NSNotification *)notification
{
    NSNumber *number = (NSNumber *)notification.object;
    if ([number boolValue] == YES)
    {
        [favorites removeAllObjects];
        [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:favorites andMyNumber:mynum andStatus:Conf_Edit_Status_Default];
        [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:favorites andMyNumber:mynum andStatus:Conf_Edit_Status_Add];
        [self.tableView reloadData];
        return;
    }
    
    if (!favorites || !mynum)
        return;
    
    NSString* mynum2 = [[NSString alloc] initWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
    if ([mynum isEqualToString:mynum2] == NO) {
        [mynum release];
        mynum = [mynum2 retain];
        
        [_refreshHeaderView refreshLastUpdatedDate];
        [_refreshHeaderView startRefreshLoading:self.tableView];
        
        if ([mynum length] && [mynum isEqualToString:DEFAULT_IDENTITY_IMPI] == NO) {            
            [favorites removeAllObjects];
            [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:favorites andMyNumber:mynum andStatus:Conf_Edit_Status_Default];
            [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:favorites andMyNumber:mynum andStatus:Conf_Edit_Status_Add];
        }
    }
    [mynum2 release];
    [self.tableView reloadData];
}

- (void)enterGroupDetailedView:(NSString *)_uuid
{
    for (NgnConferenceFavorite* conffavorite in self->favorites)
    {
        if ([conffavorite.uuid isEqualToString:_uuid])
        {
            //这里如果使用[self.navigationController pushViewController:＊＊＊ animated:YES]的话，会使用界面混乱
            ConferenceViewController *conferenceController = [[ConferenceViewController alloc] initWithNibName: @"ConferenceView" bundle:nil];
            conferenceController.conffavorite = conffavorite;
            conferenceController.isOrderGroupCall = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:conferenceController];
            [self presentModalViewController:nav animated:YES];
            conferenceController.uuid = conffavorite.uuid;
            [conferenceController release];
            [nav release];
            break;
        }
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{	
	return _reloading; // should return if data source model is reloading	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{	
	return [NSDate date]; // should return date data source was last changed	
}

- (void)addDefultGroup:(NSString *)myMumber
{
    CCLog(@"addDefultGroup_myNumber=%@", myMumber);
    if (0  == [mynum length] || [mynum isEqualToString:DEFAULT_IDENTITY_IMPI])
        return;
        
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSDate *date = [dateFormatter dateFromString:@"2013-01-01 00:00:00"];
    [dateFormatter release];
    
    NSTimeInterval time = [date timeIntervalSince1970];
        
    if (myfamilygrpid) {
        [myfamilygrpid release];
        myfamilygrpid = nil;
    }
    myfamilygrpid = [[NSString alloc] initWithFormat:@"%@%@", myMumber, @"1"];
    if ([[NgnEngine sharedInstance].storageService dbCheckConfFavoriteWithUUID:myfamilygrpid andMyNumber:myMumber] == NO) {

        NgnConferenceFavorite* nf = [[NgnConferenceFavorite alloc] initWithMynumber:myMumber andName:NSLocalizedString(@"My Family", @"My Family") andUuid:myfamilygrpid andType:Conf_Type_Private andUpdateTime:time andStatus:Conf_Edit_Status_Add];
        [[NgnEngine sharedInstance].storageService dbAddConfFavorite:nf];
        [nf release];
    }
    
    if (myfriendsgrpid) {
        [myfriendsgrpid release];
        myfriendsgrpid = nil;
    }
    myfriendsgrpid = [[NSString alloc] initWithFormat:@"%@%@", myMumber, @"2"];
    if ([[NgnEngine sharedInstance].storageService dbCheckConfFavoriteWithUUID:myfriendsgrpid andMyNumber:myMumber] == NO) {
        NgnConferenceFavorite* nf = [[NgnConferenceFavorite alloc] initWithMynumber:myMumber andName:NSLocalizedString(@"My Friends", @"My Friends") andUuid:myfriendsgrpid andType:Conf_Type_Private andUpdateTime:time andStatus:Conf_Edit_Status_Add];
        [[NgnEngine sharedInstance].storageService dbAddConfFavorite:nf];
        [nf release];
    }
}

- (IBAction)onButtonToolBarItemClick: (id)sender {
    if (sender == barButtonItemBack) {
        if (isFromConferenceView == YES)
        {
            isFromConferenceView = NO;
        }

        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender == barButtonAddGroup)
    {
        /*UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add to Conference Favorites", @"Add to Conference Favorites")
                                                         message:SystemVersion >= 5?nil:@"\n\n"
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        if (SystemVersion >= 5)
        {
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        else
        {
            [alert addSubview:m_nameTextField];
        }
        alert.tag = kTagAlertAddToFavorite;
        [alert show];
        [alert release];*/
        CreateGroupViewController *createGroupView = [[CreateGroupViewController alloc] initWithNibName:@"CreateGroupViewController" bundle:nil];
        createGroupView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:createGroupView animated:YES];
        [createGroupView release];
    }
}

- (void)guidViewClick:(id)sender
{
    UIButton *Btn = (UIButton *)sender;
    if (Btn.tag == 1001)
    {
        [Btn removeFromSuperview];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {    
    if (self->favorites == nil) 
        return 0;
    CCLog(@"favorites num=%d", [self->favorites count]);
	NSInteger rows = [self->favorites count];
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    NgnConferenceFavorite* conffavorite = [self->favorites objectAtIndex:indexPath.row];
    if (!conffavorite)
        return cell;
    
    NSMutableArray* participantNumbers = [[NSMutableArray alloc] init];
    [[NgnEngine sharedInstance].storageService dbLoadConfParticipants:participantNumbers Uuid:conffavorite.uuid];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ (%d)", conffavorite.name, [participantNumbers count]+1]];
    cell.imageView.image = [UIImage imageNamed:@"group_head.png"];
    /*[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:conffavorite.updatetime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *strCallTime = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    cell.detailTextLabel.text = strCallTime;*/
    
    [participantNumbers release];
	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isFromConferenceView == YES)
        return UITableViewCellEditingStyleNone;
    else {
        return UITableViewCellEditingStyleDelete;
    }
    
}

- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        CCLog(@"commitEditingStyle %d", indexPath.row);
        longPressRow = indexPath.row;
        
        NgnConferenceFavorite* conffavorite = [favorites objectAtIndex:indexPath.row];        
        if ((conffavorite.type == Conf_Type_Private)
            && ([conffavorite.uuid isEqualToString:myfamilygrpid] || [conffavorite.uuid isEqualToString:myfriendsgrpid]))
        {
            NSString* strPrompt = [NSString stringWithFormat:NSLocalizedString(@"The default GroupCall can be renamed or edited, but not deleted", @"The default GroupCall can be renamed or edited, but not deleted"), conffavorite.name];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                            message:strPrompt
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            
            return;
        }

        NSString* strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Do you want to delete template \"%@\"?", @"Do you want to delete template \"%@\"?"), conffavorite.name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                        message:strPrompt
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        alert.tag = kTagAlertDelete;
        [alert show];
        [alert release];        
	}
}

- (void)tableView:(UITableView *)_tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    CCLog(@"moveRowAtIndexPath");
	NSString *contentsToMove = [[self->favorites objectAtIndex:[fromIndexPath row]] retain];
    
    NgnConferenceFavorite* conffavorite = [favorites objectAtIndex:fromIndexPath.row];
    conffavorite.status = Conf_Edit_Status_Delete;
    [[NgnEngine sharedInstance].storageService dbUpdateConfFavorite:conffavorite];
	
	[self->favorites removeObjectAtIndex:[fromIndexPath row]];
	[self->favorites insertObject:contentsToMove atIndex:[toIndexPath row]];
	
	[contentsToMove release];
}

- (void)tableView:(UITableView *)tableView_ accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self tableView:tableView_ didSelectRowAtIndexPath:indexPath];
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//	return UITableViewCellAccessoryDetailDisclosureButton;
//}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isFromConferenceView == YES)
    {
        NgnConferenceFavorite* conffavorite = [self->favorites objectAtIndex:indexPath.row];
        
        SelectParticipantFromGroupViewController *selectParticipantFromGroup = [[SelectParticipantFromGroupViewController alloc] initWithNibName:@"SelectParticipantFromGroupViewController" bundle:nil];
        selectParticipantFromGroup.conffavorite = conffavorite;
        [selectParticipantFromGroup SetDelegate:delegate];
        [self.navigationController pushViewController:selectParticipantFromGroup animated:YES];
        
        selectParticipantFromGroup.uuid = conffavorite.uuid;
        
        [selectParticipantFromGroup release];
    }
    else
    {
        NgnConferenceFavorite* conffavorite = [self->favorites objectAtIndex:indexPath.row];
        ConferenceViewController *conferenceController = [[ConferenceViewController alloc] initWithNibName: @"ConferenceView" bundle:nil];
        conferenceController.conffavorite = conffavorite;
        conferenceController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:conferenceController animated:YES];
        
        conferenceController.uuid = conffavorite.uuid;
        
        [conferenceController release];
    }
}

- (void)dealloc {    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [tableView release];
    [GroupName release];
    if(m_nameTextField != nil)
    	[m_nameTextField release];
    
    [viewToolbar release];
    [toolbar release];
    [labelTitle release];
    
    [favorites release];
    [buttonAd release];
    
    [mynum release];
    
    [_refreshHeaderView release];
    
    [myfamilygrpid release];
    [myfriendsgrpid release];
    
    [super dealloc];
}

- (NSString*)Getuuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFStringCreateCopy( NULL, uuidString);
    CFRelease(puuid);
    CFRelease(uuidString);
    return [result autorelease];
}

-  (int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) // Cancel - Do Nothing
        return;
    
    if (buttonIndex == 1) { // OK
        switch (alertView.tag) {
            case kTagAlertDelete: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:longPressRow inSection:0];
            
                NgnConferenceFavorite* conffavorite = [favorites objectAtIndex:indexPath.row];
                conffavorite.status = Conf_Edit_Status_Delete;
                [[NgnEngine sharedInstance].storageService dbUpdateConfFavorite:conffavorite];
                
                CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                [appDelegate DeleteGroupCallRecord:conffavorite.uuid];
                
                [self->favorites removeObjectAtIndex:[indexPath row]];
                
                NSArray *indexPathsToRemove = [NSArray arrayWithObject:indexPath];
                [self.tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationRight];
                break;
            }
            case kTagAlertRename: {                
                NSString* strName = SystemVersion>=5?[[alertView textFieldAtIndex:0] text]:m_nameTextField.text;
                int length = [self convertToInt:strName];
                if (length > 7)
                {
                    NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Beyond character limit, please enter again(Chinese is %d,English is %d)", @"Beyond character limit, please enter again(Chinese is %d,English is %d)"), 7, 14];
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                     message:[NSString stringWithFormat:@"%@%@",alertMessage,SystemVersion >= 5?nil:@"\n\n"]
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                           otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                    if (SystemVersion >= 5)
                    {
                        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                        [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
                    }
                    else
                    {
                        [alert addSubview:m_nameTextField];
                    }
                    alert.tag = kTagAlertRename;
                    [[alert textFieldAtIndex:0] setText:strName];
                    [alert show];
                    [alert release];
                }
                else if (strName && [strName length])
                {
                    BOOL found = [[NgnEngine sharedInstance].storageService dbCheckConfFavorite:mynum andName:strName];
                    if (found) {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") message:NSLocalizedString(@"Group name already exist", @"Group name already exist") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                        alert.tag = kTagAlertFavoriteNameRequired;
                        [alert show];
                        [alert release];
                        return;
                    }

                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:longPressRow inSection:0];
                    
                    NgnConferenceFavorite* conffavorite = [favorites objectAtIndex:indexPath.row];                                        
                    
                    ConfTypeDef type = conffavorite.type;
                    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                   
                    NgnConferenceFavorite* newconffav = [[NgnConferenceFavorite alloc] initWithMynumber:mynum andName:strName andUuid:conffavorite.uuid andType:type andUpdateTime:time andStatus:conffavorite.status];
                    if (newconffav) {
                        [favorites insertObject:newconffav atIndex:indexPath.row];                    
                        [favorites removeObject:conffavorite];
                        
                        [[NgnEngine sharedInstance].storageService dbUpdateConfFavorite:newconffav];
                        
                        CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                        NSMutableArray* members = [[NSMutableArray alloc] init];
                        NSMutableArray *phonenumbers = [[NSMutableArray alloc] init];
                        [[NgnEngine sharedInstance].storageService dbLoadConfParticipants:phonenumbers Uuid:newconffav.uuid];
                        for (int i=0; i<[phonenumbers count]; i++) {
                            NSString* strNum = [phonenumbers objectAtIndex:i];
                            
                            NSString* name = NSLocalizedString(@"No Name", @"No Name");
                            NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber: strNum];
                            if (contact && contact.displayName && [contact.displayName length]) {
                                name = contact.displayName;
                            }
                            
                            GroupCallMember* m = [[GroupCallMember alloc] initWithName:name andNumber:strNum];
                            [members addObject:m];
                            [m release];
                        }
                        GroupCallRecord* r = [[GroupCallRecord alloc] initWithUserNumber:mynum andName:strName andGroupId:newconffav.uuid andType:type andUpdateTime:time andMembers:members];                    ;
                        [appDelegate UpdateGroupCallRecords:[NSArray arrayWithObject:r]];
                        [r release];
                        [phonenumbers release];
                        [members release];
                    
                        [newconffav release];
                    }
                
                    [self.tableView reloadData];
                }
                
                break;
            }
            case kTagAlertAddToFavorite:
            {
                NSString* strName = SystemVersion>=5?[[alertView textFieldAtIndex:0] text]:m_nameTextField.text;
                int length = [self convertToInt:strName];
                
                if (!strName || [strName length] == 0) {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                     message:NSLocalizedString(@"Group name is required", @"Group name is required")
                                                                    delegate:self
                                                           cancelButtonTitle:nil
                                                           otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                    alert.tag = kTagAlertFavoriteNameRequired;
                    [alert show];
                    [alert release];
                } else if (length > 7) {
                    NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Beyond character limit, please enter again(Chinese is %d,English is %d)", @"Beyond character limit, please enter again(Chinese is %d,English is %d)"), 7, 14];
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                     message:[NSString stringWithFormat:@"%@%@",alertMessage,SystemVersion >= 5?nil:@"\n\n"]
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                           otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                    if (SystemVersion >= 5)
                    {
                        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                        [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
                    }
                    else
                    {
                        [alert addSubview:m_nameTextField];
                    }
                    alert.tag = kTagAlertRename;
                    [alert show];
                    [alert release];
                } else {
                    if ([mynum length] && [mynum isEqualToString:DEFAULT_IDENTITY_IMPI] == NO) {
                        BOOL found = [[NgnEngine sharedInstance].storageService dbCheckConfFavorite:mynum andName:strName];
                        if (found) {
                            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") message:NSLocalizedString(@"Group name already exist", @"Group name already exist") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                            alert.tag = kTagAlertFavoriteNameRequired;
                            [alert show];
                            [alert release];
                            return;
                        }
                        
                        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                        NSString *uuid = [self Getuuid];
                        
                        NgnConferenceFavorite* nf = [[NgnConferenceFavorite alloc] initWithMynumber:mynum andName:strName andUuid:uuid andType:Conf_Type_Private andUpdateTime:time andStatus:Conf_Edit_Status_Add];
                        [[NgnEngine sharedInstance].storageService dbAddConfFavorite:nf];
                        [nf release];
                        
                        CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                        GroupCallRecord* r = [[GroupCallRecord alloc] initWithUserNumber:mynum andName:strName andGroupId:uuid andType:Conf_Type_Private andUpdateTime:time andMembers:nil];
                        [appDelegate AddGroupCallRecords:[NSArray arrayWithObject:r]];
                        [r release];
                    }
                }
                [favorites removeAllObjects];
                [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:favorites andMyNumber:mynum andStatus:Conf_Edit_Status_Default];
                [[NgnEngine sharedInstance].storageService dbLoadConfFavorites:favorites andMyNumber:mynum andStatus:Conf_Edit_Status_Add];
                [self.tableView reloadData];
                break;
            }
            case kTagAlertFavoriteNameRequired:
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add to Conference Favorites", @"Add to Conference Favorites")
                                                                 message:SystemVersion >= 5?nil:@"\n\n"
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                if (SystemVersion >= 5)
                {
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
                }
                else
                {
                    [alert addSubview:m_nameTextField];
                }
                alert.tag = kTagAlertAddToFavorite;
                [alert show];
                [alert release];
                break;
            }
            default:
                break;
        }
    }
}

//
//	UIActionSheetDelegate
//

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    actionSheetShowed = NO;
	if(buttonIndex != actionSheet.cancelButtonIndex) {
		switch (actionSheet.tag) {
			case kTagActionSheetDetail: {                
                switch (buttonIndex) {
                    case 0: { // rename
                        NgnConferenceFavorite* conffavorite = [favorites objectAtIndex:longPressRow];
                        
                        NSString* strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Rename template \"%@\" to", @"Rename template \"%@\" to"), conffavorite.name];
                        
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:strPrompt
                                                                         message:SystemVersion >= 5?nil:@"\n\n"
                                                                        delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                               otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                        if (SystemVersion >= 5)
                        {
                            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                            [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
                            [[alert textFieldAtIndex:0] setText: conffavorite.name];
                        }
                        else
                        {
                            [alert addSubview:m_nameTextField];
                            m_nameTextField.text = conffavorite.name;
                        }
                        alert.tag = kTagAlertRename;
                        [alert show];
                        [alert release];
                        
                        break;
                    }
                    case 1: { // delete
                        NgnConferenceFavorite* conffavorite = [favorites objectAtIndex:longPressRow];
                        
                        if ((conffavorite.type == Conf_Type_Private)
                            && ([conffavorite.uuid isEqualToString:myfamilygrpid] || [conffavorite.uuid isEqualToString:myfriendsgrpid]))
                        {
                            NSString* strPrompt = [NSString stringWithFormat:NSLocalizedString(@"The default GroupCall can be renamed or edited, but not deleted", @"The default GroupCall can be renamed or edited, but not deleted"), conffavorite.name];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                            message:strPrompt
                                                                           delegate:self
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                            [alert show];
                            [alert release];
                            
                            return;
                        }                        
                        
                        NSString* strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Do you want to delete template \"%@\"?", @"Do you want to delete template \"%@\"?"), conffavorite.name];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") 
                                                                        message:strPrompt
                                                                       delegate:self 
                                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                        alert.tag = kTagAlertDelete;
                        [alert show];
                        [alert release];
                    
                        break;
                    }
                    default:
                        break;
                }

                break;
            }
        }
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        
    }
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (indexPath == nil) {
        CCLog(@"not in tableView");
    }
    else
    {
        longPressRow = [indexPath row];
        if (actionSheetShowed == NO)
        {
            actionSheetShowed = YES;
            CCLog(@"conffavorites didSelectRowAtIndexPath %d", indexPath.row);
            UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                      destructiveButtonTitle:NSLocalizedString(@"Rename", @"Renames")
                                                           otherButtonTitles:NSLocalizedString(@"Delete", @"Delete"), nil];
            popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            popupQuery.tag = kTagActionSheetDetail;
            [popupQuery showInView:tableView];
            [popupQuery release];
        }
    }
    
}

// BannerViewContainer
- (void)showBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{  
    if (type == AD_TYPE_IAD) {
        iadbanner = (ADBannerView*)bannerView;
        [self.view addSubview:iadbanner];
        [self layoutForCurrentOrientation:animated];
    }else if (type == AD_TYPE_LIMEI) {
        lmbanner = (immobView*)bannerView;
        [self.view addSubview:lmbanner];
    } else if (type == AD_TYPE_BAIDU || type == AD_TYPE_91DIANJIN){
        bdbanner = (BaiduMobAdView*)bannerView;
        [self.view addSubview:bdbanner];
    }
}

- (void)hideBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
    if (type == AD_TYPE_IAD) {
        iadbanner = nil;
        [self layoutForCurrentOrientation:animated];
    } else if (type == AD_TYPE_LIMEI) {
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
