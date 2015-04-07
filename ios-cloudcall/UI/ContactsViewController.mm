/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Projectw
 *
 */
 
#import "ContactsViewController.h"
#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"
#import "AreaOfPhoneNumber.h"

#import "NewContactDelegate.h"
#import "PersonViewController.h"
#import "NotificationViewController.h"
#import "UIBadgeView.h"

#import "MobClick.h"

#define kTagActionAlertSyncContacts             1
#define kTagActionAlertAccessContactsApproved   2
#define kTagActionSheetCallOut  				3

#define kTagAlertCallOutViaCellPhone            11

//
// private implementation
//

@interface ContactsViewController(Private)
-(void) refreshData;
-(void) reloadData;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (void)ContactsSync;

-(void) onContactEvent:(NSNotification*)notification;
-(void) onMessagingEvent:(NSNotification*)notification;

// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
- (void)layoutForCurrentOrientation:(BOOL)animated;

-(BOOL) showCallOptView:(NSString*)num andVideoCall:(BOOL)videocal;
- (void) showInviteMessageView:(NSString*) phonenum;
@end

@implementation ContactsViewController(Private)

-(void) refreshData{
    //CCLog(@"refreshData");
	@synchronized(contacts) {
        [contacts removeAllObjects];
        [friendDic removeAllObjects];
 
        NgnContactMutableArray* contacts_ = (NgnContactMutableArray*)[[[NgnEngine sharedInstance].contactService contacts] retain];
        
        NSMutableDictionary* weicallusers = [[NSMutableDictionary alloc] init];
        [[NgnEngine sharedInstance].contactService dbLoadWeiCallUserContacts:weicallusers];           
        
		NSString *lastGroup = @"$$", *group;
        NSMutableArray* lastArray = nil;
        //int num = [contacts_ count];
        int filterNum = 0;
        //CCLog(@"refreshData count=%d, search=%@", [contacts_ count], self.searchBar.text);
		for (NgnContact* contact in contacts_) {
            //CCLog(@"refreshData name='%@', '%@', '%@'", contact.displayName, contact.abDisplayName, contact.cIndex);
            
            BOOL isFriend = NO;
            for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers) {
                if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number) {
                    NSString* tmpPhoneNum1 = [phoneNumber.number phoneNumFormat];
                    
                    //使用正则表达式
                    NSString* tmpPhoneNum2 = [tmpPhoneNum1 phoneNumFormat];
                    NSObject *object = [weicallusers objectForKey:tmpPhoneNum2];
                    if (object) {
                        isFriend = YES;
                        break;
                    }
                }
            }
            
            if (FilterGroupOnline == filterGroup && isFriend == NO) {
                continue;
            }
        
            NSRange displayNameRange,abDisplayNameRange,displayNumberRange;
            if (![NgnStringUtils isNullOrEmpty:self.searchBar.text]) {
                displayNameRange = [contact.displayName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];                
                abDisplayNameRange = [contact.abDisplayName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                contact.displayNameRange = displayNameRange;
                
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
            } else {
                contact.displayNameRange = NSMakeRange(0, 0);
            }
            
			if (!contact || [NgnStringUtils isNullOrEmpty: contact.displayName]
                || (![NgnStringUtils isNullOrEmpty: self.searchBar.text] && (displayNameRange.location == NSNotFound)
                    && (abDisplayNameRange.location == NSNotFound) && (displayNumberRange.location == NSNotFound)))
            {
				continue;
			}
            
            if (isFriend) {
                [friendDic setObject:@"Y" forKey:[NSString stringWithFormat:@"%p", contact]];
            }

            group = contact.cIndex;
            if ([group caseInsensitiveCompare: lastGroup] != NSOrderedSame) {			
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
            [lastArray addObject: contact];
            filterNum++;
		}
        
        if (weicallusers) {
			[weicallusers release];
			weicallusers = nil;
		}
        
		[lastArray release];
		[contacts_ release];
        
		[orderedSections release];        
		orderedSections = [[[contacts allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] retain];
        //CCLog(@"orderedSections count=%d", orderedSections.count);
   
        if ([NgnStringUtils isNullOrEmpty: self.searchBar.text]) {
            if (filterNum == 0 && filterGroup == FilterGroupOnline)
                labelContactsNum.text = NSLocalizedString(@"No YunTong Friends, Pull down refresh.", @"No YunTong Friends, Pull down refresh.");
            else
                labelContactsNum.text = [NSString stringWithFormat:@"%d %@", filterNum, NSLocalizedString(@"Contact Number", @"Contact Number")];
        } else {
        	labelContactsNum.text = @"";
        }
	}
}

-(void) reloadData{
    //CCLog(@"contactsviewcontroller reloadData");
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews data source model to reload
	_reloading = YES;
    
    if (filterGroup == FilterGroupOnline) {
        [self ContactsSync];
    }
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)ContactsSync {
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    [appDelegate uploadContacts2Server:NO];
    
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:3];
}


-(void) onContactEvent:(NSNotification*)notification{
	NgnContactEventArgs* eargs = [notification object];
	switch (eargs.eventType) {
		case CONTACT_RESET_ALL:
		{
            if (filterGroup == FilterGroupAll) {
                [self refreshDataAndReload];
            } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
                switch ([UIApplication sharedApplication].applicationState) {
                    case UIApplicationStateActive:                    
                    case UIApplicationStateInactive:
                        [self refreshDataAndReload];
                        break;
                    case UIApplicationStateBackground:
                        self->nativeContactsChangedWhileInactive = YES;
                        break;
                }
#else
                [self refreshDataAndReload];
#endif
            }
			break;
		}
        case CONTACT_SYNC_UPDATE:
		{
            if (filterGroup == FilterGroupOnline) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
                switch ([UIApplication sharedApplication].applicationState) {
                    case UIApplicationStateActive:
                        [self refreshDataAndReload];
                        break;
                    case UIApplicationStateInactive:
                    case UIApplicationStateBackground:
                        self->nativeContactsChangedWhileInactive = YES;
					break;
                }
#else
                [self refreshDataAndReload];
#endif
            }
			break;
		}
		default:
			break;
	}
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
    }
    else if (lmbanner) 
    {
        [UIView animateWithDuration:animationDuration
                         animations:^{                         
                             lmbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, lmbanner.frame.size.width, lmbanner.frame.size.height);
                         }];
    }
    else if (bdbanner)
    {
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

//== PagerMode IM (MESSAGE) events == //
-(void) onMessagingEvent:(NSNotification*)notification {
	NgnMessagingEventArgs* eargs = [notification object];
#if 1
	switch (eargs.eventType) {
		case MESSAGING_EVENT_CONNECTING:
		case MESSAGING_EVENT_CONNECTED:
		case MESSAGING_EVENT_TERMINATING:
		case MESSAGING_EVENT_TERMINATED:
		case MESSAGING_EVENT_FAILURE:
		case MESSAGING_EVENT_SUCCESS:
		case MESSAGING_EVENT_OUTGOING:
		default:
		{
			break;
		}
			
		case MESSAGING_EVENT_INCOMING:
		{
            CCLog(@"Incoming message: content:\n%s",  eargs.payload?[eargs.payload bytes]:"<NULL>");
			if(eargs.payload){
				// The payload is a NSData object which means that it could contain binary data
				// here I consider that it's utf8 text message
				NSString* contentType = [eargs getExtraWithKey: kExtraMessagingEventArgsContentType];
				//NSString* from = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUri];
				//NSString* userName = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUserName];
				//content-transfer-encoding: base64\r\n
				//NSString* content = [NSString stringWithUTF8String: (const char*)[eargs.payload bytes]];
				
				// default content: e.g. plain/text
				//NSData *content = eargs.payload;
				//CCLog(@"Incoming message: from:%@\n with ctype:%@\n and content:\n%s", userName, contentType, [content bytes]);
                
                if (contentType) {
                    if ([[contentType lowercaseString] hasPrefix:@"text/contacts"]) {
                        self->synctimeout = NO;
                        break;
                    }
                }
			}
			break;
		}
	}
#endif
}

-(BOOL) showCallOptView:(NSString*)num andVideoCall:(BOOL)videocall{
    if (dialNum) {
        [dialNum release];
        dialNum = nil;
    }
    dialNum = [num retain];
    videocallout = videocall;
    
    BOOL found = [[NgnEngine sharedInstance].contactService dbIsWeiCallUser:dialNum];
    
    if ([calloption count])
    {
        [calloption removeAllObjects];
    }
    
    BOOL landsenabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_LANDS_CALL_ENABLE];
    BOOL callbackenabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_CALLBACK_ENABLE];
    BOOL innetCallEnabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_INNET_CALL_ENABLE];
    BOOL phoneCallenabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_PHONE_CALL_ENABLE];
    if (innetCallEnabled)
        [calloption addObject: [NSNumber numberWithInt:CallOptionInnerCall]];
    if (landsenabled)
        [calloption addObject: [NSNumber numberWithInt:CallOptionLandCall]];
    if (callbackenabled)
        [calloption addObject: [NSNumber numberWithInt:CallOptionCallback]];
    if (phoneCallenabled)
        [calloption addObject: [NSNumber numberWithInt:CallOptionDialViaCellphone]];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"call out via", @"call out via")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                         destructiveButtonTitle:innetCallEnabled ? NSLocalizedString(@"YunTong Friends Call", @"YunTong Friends Call") : nil
                                              otherButtonTitles:landsenabled ? NSLocalizedString(@"YunTong Direct Call", @"YunTong Direct Call") : nil,
                            callbackenabled ? NSLocalizedString(@"YunTong Callback", @"YunTong Callback") : nil,
                            phoneCallenabled ? NSLocalizedString(@"Cell Phone", @"Cell Phone") : nil, nil];
    
    
    //#if 1
    //            if (videocallout) {
    //                [CallViewController makeAudioVideoCallWithRemoteParty:dialNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] andCalloutMode:CALL_OUT_MODE_INNER];
    //            } else {
    //                [CallViewController makeAudioCallWithRemoteParty:dialNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] andCalloutMode:CALL_OUT_MODE_INNER];
    //            }
    //#else
    //            [calloption addObject: [NSNumber numberWithInt:CallOptionInnerCall]];
    //            sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
    //                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
    //                                  destructiveButtonTitle:NSLocalizedString(@"YunTong Friends Call", @"YunTong Friends Call")
    //                                       otherButtonTitles:nil,/*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil];
    //#endif
    
    if (sheet) {
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        sheet.tag = kTagActionSheetCallOut;
        [sheet showInView:self.parentViewController.tabBarController.view];
        [sheet release];
    }
    
    return YES;
}

- (void)showInviteMessageView:(NSString*) phonenum
{
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init]; //autorelease];
        controller.recipients = [NSArray arrayWithObject:phonenum];
        controller.body = [NSString stringWithFormat:NSLocalizedString(@"Invite Message Content", @"Invite Message Content"), RootUrl];
        controller.messageComposeDelegate = self;
        
        [self presentModalViewController:controller animated:YES];
        //        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"SomethingElse"];//–ﬁ∏ƒ∂Ã–≈ΩÁ√Ê±ÍÃ‚
        [controller release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Note Info", @"Note Info")
                                                        message:NSLocalizedString(@"No SMS Support", @"No SMS Support")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    }
}


@end


//
// default implementation
//

@implementation ContactsViewController
@synthesize badgeView;
@synthesize tableView;
@synthesize toolBar;
@synthesize searchBar;
@synthesize viewToolbar;
@synthesize headView;
@synthesize secretaryBtn;
@synthesize secretaryLabel;

//@synthesize labelDisplayMode;
@synthesize labelContactsNum;
@synthesize barButtonItemAll;
//@synthesize barButtonItemWiphone;
@synthesize barButtonItemOnline;
//@synthesize barButtonItemSync;
@synthesize barButtonItemAdd;
@synthesize buttonAd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Contacts", @"Contacts") image:[UIImage imageNamed:@"tab_contacts_normal"] tag:1];
        if (SystemVersion >= 5.0)
            [item setFinishedSelectedImage:[UIImage imageNamed:@"tab_contacts_down"]
               withFinishedUnselectedImage:[UIImage imageNamed:@"tab_contacts_normal"]];
        
        self.tabBarItem = item;
        [item release];
    }
    return self;
}

-(void) refreshDataAndReload{
	[self refreshData];
	[self reloadData];
}


//同步完成
- (void)contactsLoaded
{
    [self doneLoadingTableViewData];

    [self reloadData];
}

//超时
- (void)timeout:(id)arg {
    if (!synctimeout) {
        [self contactsLoaded];
    } else {
        [self doneLoadingTableViewData];
        
        [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contacts", @"Contacts")
                                                    message:NSLocalizedString(@"Connection timed out, please try again later.", @"Connection timed out, please try again later.")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                          otherButtonTitles: nil];
        [a show];
        [a release];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!calloption) {
        calloption = [[NSMutableArray alloc] init];
    }
    
    if (!friendDic) {
        friendDic = [[NSMutableDictionary alloc] init];
    }
    
    ///////////////////////////////////////
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image=[UIImage imageNamed:@"toolbar_bg.png"];
    [self.toolBar addSubview:imageview];
    [imageview release];
    
    
    if (!contacts) {
		contacts = [[NSMutableDictionary alloc] init];
	}
	
	// load data and register for notifications
	[self refreshData];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactEvent:) name:kNgnContactEventArgs_Name object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
	
    self.navigationItem.title = NSLocalizedString(@"Contacts", @"Contacts");
    
    //云通好友按钮
    self.barButtonItemOnline = [UIButton buttonWithType:UIButtonTypeCustom];
    barButtonItemOnline.frame = CGRectMake(90, 7, 72, 30);
    [self.barButtonItemOnline setTitle:NSLocalizedString(@"YunTong Friends", @"YunTong Friends") forState:UIControlStateNormal];
    [self.barButtonItemOnline setTitleColor:[UIColor colorWithRed:130.0f/255.0f green:140.0f/255.0f blue:150.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    barButtonItemOnline.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [self.barButtonItemOnline setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_up.png"] forState:UIControlStateNormal];
    [self.barButtonItemOnline setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_down.png"] forState:UIControlStateHighlighted];
    [barButtonItemOnline addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolBar addSubview:barButtonItemOnline];
    
    //全部联系人按钮
    self.barButtonItemAll = [UIButton buttonWithType:UIButtonTypeCustom];
    barButtonItemAll.frame = CGRectMake(162, 7, 72, 30);
    [self.barButtonItemAll setTitle:NSLocalizedString(@"Address Book", @"Address Book") forState:UIControlStateNormal];
    [self.barButtonItemAll setTitleColor:[UIColor colorWithRed:130.0f/255.0f green:140.0f/255.0f blue:150.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    barButtonItemAll.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:13.0];
    [self.barButtonItemAll setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_down.png"] forState:UIControlStateNormal];
    [self.barButtonItemAll setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_down.png"] forState:UIControlStateHighlighted];
    [barButtonItemAll addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolBar addSubview:barButtonItemAll];
    
    //同步联系人按钮
//    self.barButtonItemSync = [UIButton buttonWithType:UIButtonTypeCustom];
//    barButtonItemSync.frame = CGRectMake(256, 0, 60, 44);
//    [self.barButtonItemSync setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    barButtonItemSync.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
//    [self.barButtonItemSync setBackgroundImage:[UIImage imageNamed:@"SyncContact_up.png"] forState:UIControlStateNormal];
//    [self.barButtonItemSync setBackgroundImage:[UIImage imageNamed:@"SyncContact_down.png"] forState:UIControlStateHighlighted];
//    [barButtonItemSync addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
//    [self.toolBar addSubview:barButtonItemSync];
//    
//    [barButtonItemSync setHidden:YES];
    
    //增加联系人按钮
    self.barButtonItemAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    barButtonItemAdd.frame = CGRectMake(273, 0, 44, 44);

    [self.barButtonItemAdd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.barButtonItemAdd setBackgroundImage:[UIImage imageNamed:@"addcontact_up.png"] forState:UIControlStateNormal];
     [barButtonItemAdd addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolBar addSubview:barButtonItemAdd];
    
    self.secretaryLabel.text = NSLocalizedString(@"Customer Service", @"Customer Service");
    self.secretaryLabel.adjustsFontSizeToFitWidth = YES;
    [self.secretaryBtn setBackgroundImage:[UIImage imageNamed:@"toolbar_bg.png"] forState:UIControlStateHighlighted];
    
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.tableHeaderView = headView;
    tableView.tableFooterView = labelContactsNum;

	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
	searching = NO;
	letUserSelectRow = YES;
    self.searchBar.showsCancelButton = NO;
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"searchBar_bg.png"]];
    
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [self.tableView addSubview:_refreshHeaderView];
        
        [_refreshHeaderView setHidden:YES];
    }
    // update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
    self.badgeView = [[[UIBadgeView alloc] initWithFrame:CGRectMake(250, 55, 30, 30)] autorelease];
    badgeView.badgeColor = [UIColor redColor];
    [self.headView addSubview:badgeView];
    
    if (SystemVersion >= 7.0)
    {
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        self.buttonAd.frame = CGRectMake(0, 20, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height);
        self.viewToolbar.frame = CGRectMake(self.viewToolbar.frame.origin.x, self.viewToolbar.frame.origin.y + 20, self.viewToolbar.frame.size.width, self.viewToolbar.frame.size.height);
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + 20, self.tableView.frame.size.width, self.tableView.frame.size.height-(50+20));
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kTagActionAlertSyncContacts:            
            if (buttonIndex == 0) { // Why?
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                                message: NSLocalizedString(@"To determine which of your contacts are using WeiCall service, WeiCall needs to access your contacts. Then you can call your WeiCall contacts for free.", @"To determine which of your contacts are using WeiCall service, WeiCall needs to access your contacts. Then you can call your WeiCall contacts for free.")
                                                               delegate: self
                                                      cancelButtonTitle: NSLocalizedString(@"Not Allow", @"Not Allow")
                                                      otherButtonTitles: NSLocalizedString(@"Allow", @"Allow"), nil];
                alert.tag = kTagActionAlertAccessContactsApproved;
                [alert show];
                [alert release];
            } else if (buttonIndex == 1) { // OK
                [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:GENERAL_ACCESS_CONTACTS_LIST_ALLOW];                
                
                [self ContactsSync];
                return;
            }
            break;
        case kTagActionAlertAccessContactsApproved:
            if (buttonIndex == 0) { // Not Allow
                [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:GENERAL_ACCESS_CONTACTS_LIST_NOT_ALLOW];
                
                [self doneLoadingTableViewData];
            } else if (buttonIndex == 1) { // Allow
                [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_ACCESS_CONTACTS_LIST andValue:GENERAL_ACCESS_CONTACTS_LIST_ALLOW];
                
                [self ContactsSync];
            }
            break;

        case kTagAlertCallOutViaCellPhone: {
            NSString* dialurl = [@"tel://" stringByAppendingString:dialNum];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialurl]];
            break;
        }
            
        default:
            break;
    }
}

- (void) onButtonToolBarItemClick: (id)_sender
{
    UIButton *Btn = (UIButton*)_sender;
        
    if(Btn == barButtonItemAll)
    {
        [barButtonItemOnline setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_up.png"] forState:UIControlStateNormal];
        [barButtonItemAll setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_down.png"] forState:UIControlStateNormal];
        filterGroup = FilterGroupAll;
        
        [_refreshHeaderView setHidden:YES];
    }
    else if(Btn == barButtonItemOnline)
    {
        filterGroup = FilterGroupOnline;
        [_refreshHeaderView setHidden:NO];
        //首次安装,或切换用户的时候,点击云通好友的时候自动同步一次.
        BOOL once = [[NgnEngine sharedInstance].configurationService getBoolWithKey:@"click_reload_once"];
        if (!once)
        {
            [[NgnEngine sharedInstance].configurationService setBoolWithKey:@"click_reload_once" andValue:YES];
            //  update the last update date
            [_refreshHeaderView refreshLastUpdatedDate];
            [_refreshHeaderView startRefreshLoading:self.tableView];
        }
        [barButtonItemOnline setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_down.png"] forState:UIControlStateNormal];
        [barButtonItemAll setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_up.png"] forState:UIControlStateNormal];
    }
    else if(Btn == barButtonItemAdd)
    {
        //[[NgnEngine sharedInstance].contactService reload:YES];
        ABNewPersonViewController *view = [[ABNewPersonViewController alloc] init];

        if (!myNewContactDelegate)
            myNewContactDelegate = [[NewContactDelegate alloc] init];
        [view setNewPersonViewDelegate:myNewContactDelegate];
        view.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:view animated:YES];
        [view release];

        return;
    }
    
    [self refreshDataAndReload];
}

- (IBAction)onButtonClick:(id)sender
{
    UIButton *Btn = (UIButton *)sender;
    if (Btn == secretaryBtn)
    {
        NotificationViewController* nv = [[NotificationViewController alloc] initWithNibName:@"NotificationView" bundle:[NSBundle mainBundle]];
        nv.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:nv animated:YES];
        [nv release];

    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    CCLog(@"Contactview didReceiveMemoryWarning");

    //[contacts removeAllObjects];  gary remove for losing contacts
	//[self reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear: animated];    
    [MobClick beginLogPageView:@"Contacts"];
    [[CloudCall2AppDelegate sharedInstance] viewChanged:self];
    int unreadNofifyNum = [[CloudCall2AppDelegate sharedInstance] unreadSysNofifyNum];
    if (unreadNofifyNum != 0)
    {
        badgeView.hidden = NO;
        badgeView.badgeString = [NSString stringWithFormat:@"%d", unreadNofifyNum];
    }
    else
    {
        badgeView.hidden = YES;
    }
    
	[self.navigationController setNavigationBarHidden: YES];
    
    if (needtoreload) {
        needtoreload = NO;
        [self reloadData];    
    }
    
    if (filterGroup == FilterGroupOnline)
    {
        BOOL once = [[NgnEngine sharedInstance].configurationService getBoolWithKey:@"click_reload_once"];
        if (!once)
        {
            [[NgnEngine sharedInstance].configurationService setBoolWithKey:@"click_reload_once" andValue:YES];
            //  update the last update date
            [_refreshHeaderView refreshLastUpdatedDate];
            [_refreshHeaderView startRefreshLoading:self.tableView];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear: animated];
	[self layoutForCurrentOrientation:NO];
    
	if(self->nativeContactsChangedWhileInactive){
		self->nativeContactsChangedWhileInactive = NO;
		[self refreshDataAndReload];
	}      
}

- (void)viewWillDisappear:(BOOL)animate{
	[super viewWillDisappear: animate];    
    [MobClick endLogPageView:@"Contacts"];
	[self.navigationController setNavigationBarHidden: NO];
}

- (void)dealloc {
	[tableView release];
	[toolBar release];
	[searchBar release];
	[viewToolbar release];

	//[self.labelDisplayMode release];
	[barButtonItemAll release];
	[barButtonItemOnline release];
    [labelContactsNum release];
    [barButtonItemAdd release];
    [myNewContactDelegate release];
	[contactDetailsController release], contactDetailsController = nil;
	[contacts release];
	[orderedSections release];
    [buttonAd release];
    
    [calloption release];
    
//    [secretary release];
    
    [friendDic release];
	
    [super dealloc];
}

//
//	Searching
//

#pragma mark - Search Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searching = YES;
	letUserSelectRow = NO;
    
//    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
//    if (appDelegate.adType == AD_TYPE_IAD) {
//        [self hideBannerView:iadbanner adtype:appDelegate.adType animated:NO];
//    } else if (appDelegate.adType == AD_TYPE_91DIANJIN) {
//        [self hideBannerView:djbanner adtype:appDelegate.adType animated:NO];
//    }
//    else if (appDelegate.adType == AD_TYPE_LIMEI)
//    {
//        [self hideBannerView:lmbanner adtype:appDelegate.adType animated:NO];
//    }
//    if (buttonAd) 
//        buttonAd.hidden=YES;
   // [buttonAd removeFromSuperview];
	//tableView.scrollEnabled = NO;
	tableView.frame = CGRectMake(tableView.frame.origin.x, 
								 viewToolbar.frame.origin.y,
								 tableView.frame.size.width, 
								 tableView.frame.size.height + viewToolbar.frame.size.height);
//	viewToolbar.hidden = YES;
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

//    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
//    if (appDelegate.adType == AD_TYPE_IAD) {
//        [self showBannerView:iadbanner adtype:appDelegate.adType animated:NO];
//    } else if (appDelegate.adType == AD_TYPE_91DIANJIN) {
//        [self showBannerView:djbanner adtype:appDelegate.adType animated:NO];
//    }
//    else if (appDelegate.adType == AD_TYPE_LIMEI)
//    {
//        [self showBannerView:lmbanner adtype:appDelegate.adType animated:NO];
//    }
//    if (buttonAd) buttonAd.hidden=NO;
   // [self.view addSubview:buttonAd];
//	tableView.frame = CGRectMake(tableView.frame.origin.x, 
//								 tableView.frame.origin.y+toolBar.frame.size.height+6,
//								 tableView.frame.size.width, 
//								 tableView.frame.size.height - viewToolbar.frame.size.height);
	viewToolbar.hidden = NO;
    tableView.frame = CGRectMake(tableView.frame.origin.x,
                                 viewToolbar.frame.origin.y+viewToolbar.frame.size.height,
                                 tableView.frame.size.width,
                                 tableView.frame.size.height - viewToolbar.frame.size.height);
    self.searchBar.showsCancelButton = NO;
	//self.searchBar.text = @"";
	[self.searchBar resignFirstResponder];
	
	tableView.scrollEnabled = YES;
	
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[self.searchBar resignFirstResponder];
    self.searchBar.text = nil;
    [self refreshDataAndReload];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	[self refreshDataAndReload];
}


//
//	UITableView
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [orderedSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	@synchronized(contacts){
		if([orderedSections count] > section){
			NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: section]];
			return [values count];
		}
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	@synchronized(contacts){
		return [orderedSections objectAtIndex: section];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[[UIView alloc] init] autorelease];
    myView.backgroundColor = [UIColor colorWithRed:210.0f/255.0f green:210/255.0 blue:210/255.0 alpha:0.7];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
    titleLabel.textColor=[UIColor blueColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text=[orderedSections objectAtIndex:section];
    [myView addSubview:titleLabel];
    [titleLabel release];
    return myView;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return [ContactViewCell getHeight];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ContactViewCell *cell = (ContactViewCell*)[_tableView dequeueReusableCellWithIdentifier: kContactViewCellIdentifier];
	if (cell == nil) {		
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactViewCell" owner:self options:nil] lastObject];
//        NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"ContactViewCell" owner:self options:nil];
//        for (id oneObject in nib) {
//            if ([oneObject isKindOfClass:[ContactViewCell class]]) {
//                cell = (ContactViewCell *)oneObject;
//            }
//        }
	}
	@synchronized(contacts) {
		if ([orderedSections count] > indexPath.section) {
			NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
			NgnContact* contact = [values objectAtIndex: indexPath.row];
            if (contact) {                
                [cell setDisplayName:contact.displayName];
                cell.contact = contact;
                cell.navigationController = self.navigationController;
                
                [cell SetDelegate:self];
                
                [contact InitDisplayAreaInfo];
                [cell setDisplayArea:contact.displayArea];
                
                if (filterGroup == FilterGroupOnline) {
                    [cell setIsFriend:YES];
                } else {
                    NSObject* obj = [friendDic objectForKey:[NSString stringWithFormat:@"%p", contact]];
                    if (obj) {
                        [cell setIsFriend:YES];
                    } else {
                        [cell setIsFriend:NO];
                    }
                }
                
                /*if (contact == secretary) {
                    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                    int num = [appDelegate UnreadSysNofifyNum];                    
                    [cell setBadgeString: num?[NSString stringWithFormat:@"%d", num]:nil];
                } else {
                    [cell setBadgeString: nil];
                }*/
			}
		}
	}
	
	return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (searching  || [self.searchBar.text length]) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	@synchronized(contacts){
		if([orderedSections count] > indexPath.section){
			NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
			NgnContact* contact = [values objectAtIndex: indexPath.row];
			if(contact && contact.displayName){
				if(!contactDetailsController){
					contactDetailsController = [[ContactDetailsController alloc] initWithNibName: @"ContactDetails" bundle:nil];
				}
				contactDetailsController.contact = contact;
                contactDetailsController.isInContact = YES;
                contactDetailsController.hidesBottomBarWhenPushed = YES;
				[self.navigationController pushViewController: contactDetailsController animated: YES];
			}
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
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
    
    if (filterGroup != FilterGroupOnline)
        return;
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (filterGroup != FilterGroupOnline)
        return;
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    if (filterGroup != FilterGroupOnline)
        return;
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}


//
//	UIActionSheetDelegate
//

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != actionSheet.cancelButtonIndex) {
		switch (actionSheet.tag) {                
            case kTagActionSheetCallOut:
			{
                /*if (buttonIndex == (landsenabled ? 2 : 1)) {
                    NSString* dialurl = [@"tel://" stringByAppendingString:dialNum];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialurl]];
                    break;
                }*/
                CALL_OUT_MODE mode = CALL_OUT_MODE_NONE;
                if ([calloption count])
                {
                    int opt = [[calloption objectAtIndex:buttonIndex] integerValue];
                    [calloption removeAllObjects];
                    switch (opt)
                    {
                        case CallOptionInviteFriend:
                        {
                            [self showInviteMessageView:dialNum];
                            return;
                        }
                        case CallOptionInnerCall:
                            mode = CALL_OUT_MODE_INNER;
                            break;
                        case CallOptionLandCall:
                            mode = CALL_OUT_MODE_LNAD;
                            break;
                        case CallOptionCallback:
                            mode = CALL_OUT_MODE_CALL_BACK;
                            break;
                        case CallOptionAddToContacts:
                            break;
                        case CallOptionDialViaCellphone:
                        {
                            BOOL ftime = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_FIRST_TIME_DIAL_VIA_CELL_PHONE];
                            if (ftime) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Note Info", @"Note Info")
                                                                                message:NSLocalizedString(@"The call will go out via your cell phone and you would be charged by your mobile service provide for this call.", @"The call will go out via your cell phone and you would be charged by your mobile service provide for this call.")
                                                                               delegate:self
                                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                                alert.tag = kTagAlertCallOutViaCellPhone;
                                [alert show];
                                [alert release];
                                
                                [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_FIRST_TIME_DIAL_VIA_CELL_PHONE andValue:NO];
                                return;
                            }
                            
                            NSString* dialurl = [@"tel://" stringByAppendingString:dialNum];
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialurl]];
                            return;
                        }
                    }
                    
                }
#if 0
                BOOL found = [[NgnEngine sharedInstance].contactService dbIsWeiCallUser:dialNum];
                if (weicall && !found) {
                    // No WeiCall User, could not make WeiCall call
                    [self showInviteMessageView:dialNum];
                    break;
                }
#endif
                if (videocallout) {
                    [CallViewController makeAudioVideoCallWithRemoteParty:dialNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] andCalloutMode:mode];
                } else {
                    [CallViewController makeAudioCallWithRemoteParty:dialNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] andCalloutMode:mode];
                }
                
                break;
            }
				
			default:
				break;
		}
	}
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet{
    if (SystemVersion < 7.0)
    {
    int i = 0;
        NSArray *subviews = [actionSheet subviews];
        for (UIView *v in subviews) {
            if ([v isKindOfClass:[UIButton class]]) {
                UIButton *b = (UIButton*)v;
                [b setBackgroundImage:[UIImage imageNamed:(i==actionSheet.cancelButtonIndex) ? @"Action_Sheet_BG_Red.png" : @"Action_Sheet_BG_Blue.png"] forState:UIControlStateNormal];
                [b setBackgroundImage:[UIImage imageNamed:(i==actionSheet.cancelButtonIndex) ? @"Action_Sheet_BG_Red_Pressed.png" : @"Action_Sheet_BG_Blue_Pressed.png"] forState:UIControlStateHighlighted];
                b.titleLabel.textColor = [UIColor whiteColor];
                i++;
            }
        }
    }
}

// ContactDialDelegate
-(void) shouldContinueAfterContactDialClick:(NSString*)_dialNum {
    if ([[NgnEngine sharedInstance].sipService isRegistered])
    {
        if (_dialNum && [_dialNum length])
        {
            _dialNum = [_dialNum phoneNumFormat];
            
            //不能拨打本机号码
            NSString *selfNumber = [NSString stringWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
            
            if ([_dialNum isEqualToString:selfNumber]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message:NSLocalizedString(@"You can't call yourself", @"You can't call yourself")
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                
                return ;
            }
            
            [self showCallOptView:_dialNum andVideoCall:NO];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Call out error", @"Call out error")
                                                        message:NSLocalizedString(@"Could not make call, server not ready", @"Could not make call, server not ready")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    }
}

//MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:NO];//πÿº¸µƒ“ªæ‰   ≤ªƒ‹Œ™YES
    switch ( result ) {
        case MessageComposeResultCancelled:
        {
            //click cancel button
        }
            break;
        case MessageComposeResultFailed:// send failed
            
            break;
        case MessageComposeResultSent:
        {
            
            //do something
        }
            break;
        default:
            break;
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
    }  else if (type == AD_TYPE_LIMEI) {
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
