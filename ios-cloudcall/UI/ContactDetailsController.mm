/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import "ContactDetailsController.h"
#import "PhoneEntryCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CallViewController.h"

#import "iOSNgnStack.h"

#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"

#import "PersonViewController.h"

#import "MobClick.h"
#import "FMDatabase.h"
#import "RecentCell.h"
#import "ContactViewCell.h"
#import "SelectContactViewController.h"

#define kTagActionSheetTextMessage				1
#define kTagActionSheetVideoCall				2
#define kTagActionSheetAddToFavorites			3
#define kTagActionSheetChooseFavoriteMediaType	4
#define kTagActionSheetCallOut  				5

#define kTagAlertCallOutViaCellPhone		11
#define kTagAlertInvite     12

#define kTagTableAlertInvite    100
#define kTagTableAlertSendMsg   101

#define kContentTypeDefault 0

#define kRecentCellIdentifier	@"RecentCellIdentifier"

@interface ContactDetailsController(Private)
- (BOOL) showCallOptView:(NSString*)num andVideoCall:(BOOL)videocall;
- (BOOL) Mailto:(NSString*)dest;
// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
@end

@implementation ContactDetailsController(Private)
-(BOOL) showCallOptView:(NSString*)num andVideoCall:(BOOL)videocall{
    if (dialNum) {
        [dialNum release];
        dialNum = nil;
    }
    dialNum = [num retain];
    videocallout = videocall;
    // 'Vincent' is (not) a WeiCall user, call out via:
    
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

- (BOOL) Mailto:(NSString*)dest {
    NSString* a = [@"mailto:" stringByAppendingString:dest];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:a]];
    return YES;
}

@end


@interface ContactDetailsController(Recent)
/**
 *	@brief	查询拨打该联系人的通话记录
 *
 *	@param 	phoneNumbers 	号码
 */
- (void)loadRecentByPerson:(NSMutableArray *)phoneNumbers;
- (NSString *)getDocumentPath;
- (FMDatabase *)getManageDB;

@end

@implementation ContactDetailsController(Recent)
- (void)loadRecentByPerson:(NSMutableArray *)phoneNumbers
{    
    if ([phoneNumbers count] <= 0)
        return;
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSMutableString *condition = [NSMutableString stringWithCapacity:10];
    
    int phoneNumbersLength = [phoneNumbers count];
    for (int i = 0;i < phoneNumbersLength;i++)
    {
        NgnPhoneNumber *phoneNumber = [phoneNumbers objectAtIndex:i];
        NSString *number = [phoneNumber.number phoneNumFormat];
        
        [condition appendFormat:@" remoteParty = '%@' ", number];
        if (i < phoneNumbersLength - 1) {
            [condition appendString:@" or "];
        }
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT id,seen,status,mediaType,remoteParty,start,end,CallMode FROM hist_event where %@ ORDER BY start DESC", condition];
    
    //CCLog(@"--- sql: %@ ---",sql);

    FMResultSet *dbresult = [db executeQuery:sql];
    
    while([dbresult next])
    {
        NgnHistoryEvent *event = nil;
        int _id = [dbresult intForColumnIndex:0];
        BOOL seen = [dbresult boolForColumnIndex:1];
        HistoryEventStatus_t status = (HistoryEventStatus_t)[dbresult intForColumnIndex:2];
        NgnMediaType_t mediaType = (NgnMediaType_t)[dbresult intForColumnIndex:3];
        NSString *remoteParty = [dbresult stringForColumnIndex:4];
        double start = [dbresult doubleForColumnIndex:5];
        double end = [dbresult doubleForColumnIndex:6];
        int callmode = [dbresult intForColumnIndex:7];;
        
        CALL_OUT_MODE calloutmode = CALL_OUT_MODE_NONE;
        switch (callmode) {
            case 0:
                calloutmode = CALL_OUT_MODE_INNER;
                break;
            case 1:
                calloutmode = CALL_OUT_MODE_LNAD;
                break;
            case 2:
                calloutmode = CALL_OUT_MODE_CALL_BACK;
                break;
            default:
                calloutmode = CALL_OUT_MODE_NONE;
                break;
        }
        
        switch (mediaType) {
            case MediaType_Audio:
            case MediaType_Video:
            case MediaType_AudioVideo:
                event = [(NgnHistoryEvent*)[NgnHistoryEvent createAudioVideoEventWithRemoteParty: remoteParty andVideo: isVideoType(mediaType) andCalloutMode:calloutmode] retain];
                break;
            case MediaType_SMS:
            case MediaType_Chat:
            case MediaType_FileTransfer:
            case MediaType_Msrp:
            default:
                break;
        }
        
        // add events
        if(event){
            event.id = _id;
            event.seen = seen;
            event.status = status;
            event.start = start;
            event.end = end;
			
            [recentArray addObject:event];
            [event release];
        }
        
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
    
}

- (NSString *)getDocumentPath
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [pathArray objectAtIndex:0];
    
    return documentPath;
}

- (FMDatabase *)getManageDB
{
    NSString *dbPath = [[self getDocumentPath] stringByAppendingPathComponent:kDefaultDB];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    return db;
}

@end

@implementation ContactDetailsController

@synthesize reuseIdentifier;
@synthesize labelDisplayName;
@synthesize imageViewAvatar;
@synthesize tableView;
@synthesize viewToolbar;
@synthesize toolbar;
@synthesize labelTitle;

@synthesize viewHeader;

@synthesize buttonInvite;
@synthesize buttonVideoCall;
@synthesize buttonTextMessage;
@synthesize buttonAddToFavorites;
@synthesize buttonSendMsg;

@synthesize contact;
@synthesize buttonAd;

@synthesize isHideBtnEdit;
@synthesize isInContact;
@synthesize recentArray;

@synthesize sendMessageNum;

@synthesize isHightLight;
@synthesize hightNumber;
@synthesize fromIMChatView;

#pragma mark
#pragma mark View Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labelTitle.text = NSLocalizedString(@"ContactDetails", @"ContactDetails");
    self.labelTitle.textColor = [UIColor colorWithRed:130.0f/255.0f green:140.0f/255.0f blue:150.0f/255.0f alpha:1.0];
    
    ///////////////////////////////////////
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image = [UIImage imageNamed:@"toolbar_bg.png"];
    [self.toolbar addSubview:imageview];
    [imageview release];
    ///////////////////////////////////////
    
    //从云信会话页面进入联系人详情 , 不显示发送免费信息按钮 , table上移
    if (fromIMChatView)
    {
        buttonSendMsg.hidden = YES;
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y - 31, tableView.frame.size.width, tableView.frame.size.height);
    }
    
    [self.viewHeader setImage:[UIImage imageNamed:@"contact_bg.png"]];
    
    calloption = [[NSMutableArray alloc] init];
    self.recentArray = [NgnHistoryEventMutableArray arrayWithCapacity:15];
    
    self->msgContactsArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    //myEditBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(setEdit:)];
    //self.navigationItem.rightBarButtonItem = myEditBarButtonItem;
    
    self->barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonItemBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonItemBack];
    
    if (!isHideBtnEdit) {
        self->barButtonItemEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        //self->barButtonItemEdit.frame = CGRectMake(260, 10, 45, 25);
        self->barButtonItemEdit.frame = CGRectMake(273, 0, 44, 44);
        [self->barButtonItemEdit setBackgroundImage:[UIImage imageNamed:@"Edit_Btn_normal"] forState:UIControlStateNormal];
        [self->barButtonItemEdit setBackgroundImage:[UIImage imageNamed:@"Edit_Btn_down"] forState:UIControlStateHighlighted];
        //[self->barButtonItemEdit setBackgroundImage:[UIImage imageNamed:@"sync_normal.png"] forState:UIControlStateNormal];
        //self->barButtonItemEdit.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        //[self->barButtonItemEdit setTitle:NSLocalizedString(@"Edit", @"Edit") forState:UIControlStateNormal];
        [self->barButtonItemEdit addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
        [self.toolbar addSubview:self->barButtonItemEdit];
    }
    
	self.imageViewAvatar.layer.cornerRadius = 8.f;
	self.buttonInvite.layer.cornerRadius = 8.f;
	
//    UIImageView *contactBg = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact_detail_bg.png"]] autorelease];
//    [self.tableView setBackgroundView:contactBg];
    
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"contact_detail_bg.png"]]];
    CCLog(@"%f, %f", self.view.frame.origin.y, self.view.frame.size.height);
    [self.buttonInvite setTitle:NSLocalizedString(@"Invite Friends to Join YunTong", @"Invite Friends to Join YunTong, Enjoy Wonderful Life") forState:UIControlStateNormal];
    [self.buttonInvite setTitle:NSLocalizedString(@"Invite Friends to Join YunTong", @"Invite Friends to Join YunTong, Enjoy Wonderful Life") forState:UIControlStateHighlighted];
    [self.buttonVideoCall setTitle:NSLocalizedString(@"Voide Call", @"Voide Call") forState:UIControlStateNormal];
    [self.buttonTextMessage setTitle:NSLocalizedString(@"Text Message", @"Text Message") forState:UIControlStateNormal];
    [self.buttonAddToFavorites setTitle:NSLocalizedString(@"Add to Favorites", @"Add to Favorites") forState:UIControlStateNormal];
    
    if (SystemVersion >= 7.0)
    {
        self.viewToolbar.frame = CGRectMake(self.viewToolbar.frame.origin.x, self.viewToolbar.frame.origin.y + 20, self.viewToolbar.frame.size.width, self.viewToolbar.frame.size.height);
        self.viewHeader.frame = CGRectMake(self.viewHeader.frame.origin.x, self.viewHeader.frame.origin.y + 20, self.viewHeader.frame.size.width, self.viewHeader.frame.size.height);
        self.buttonSendMsg.frame = CGRectMake(self.buttonSendMsg.frame.origin.x, self.buttonSendMsg.frame.origin.y + 20, self.buttonSendMsg.frame.size.width, self.buttonSendMsg.frame.size.height);
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + 20, self.tableView.frame.size.width, self.tableView.frame.size.height);
        
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
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

- (void)viewWillAppear:(BOOL)animated {    
	[super viewWillAppear: animated];
    
    [self.navigationController setNavigationBarHidden: YES];
    
    [MobClick beginLogPageView:@"ContactDetails"];    
	self.navigationItem.title = NSLocalizedString(@"ContactDetails", @"ContactDetails");

	if (self.contact) {
        if([PersonViewController switchValue]){
            [self updateContactData:[self.contact myid]];
            [PersonViewController setSwitchValue:NO];
        }
        
        if (isAddContact) {
            NgnContact *addContact = [self getContactAfterAdd];
            if (addContact){
                [self updateContactData:[addContact myid]];
                isInContact = YES;
            }
            isAddContact = NO;
        }
        
		self.labelDisplayName.text = self.contact.displayName;
        if (self.contact.picture != NULL)
            self.imageViewAvatar.image = [UIImage imageWithData:self.contact.picture];
        else
            self.imageViewAvatar.image = [UIImage imageNamed:@"default_head.png"];
	}
    
    self.buttonInvite.hidden = NO;
    //是否显示邀请好友按钮
    for (NgnPhoneNumber *phoneNumber in self.contact.phoneNumbers)
    {
        if ([[NgnEngine sharedInstance].contactService dbIsWeiCallUser:phoneNumber.number])
        {
            self.buttonInvite.hidden = YES;
            break;
        }
    }
    
    [self.recentArray removeAllObjects];
    [self loadRecentByPerson:contact.phoneNumbers];
    [self.tableView reloadData];
    
    [[CloudCall2AppDelegate sharedInstance] viewChanged:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    [MobClick endLogPageView:@"ContactDetails"];
    
    [self.navigationController setNavigationBarHidden: NO];
    
    if ([PersonViewController didDeleteValue]){
        [PersonViewController setDidDeleteValue:NO];
        return;
    }
    
    
}

- (void)dealloc {
    [contact release];
	[sendMessageNum release];
    
	[labelDisplayName release];
	[imageViewAvatar release];
	[tableView release];
	[viewHeader release];
	
	[buttonInvite release];
	[buttonVideoCall release];
	[buttonTextMessage release];
	[buttonAddToFavorites release];
    [buttonSendMsg release];
    
    [buttonAd release];
    
    [lblTitle release];
    
    [calloption release];
    
    if (myNewContactDelegate)
        [myNewContactDelegate release];
    
    [recentArray release];
	
    if (hightNumber) {
        [hightNumber release];
        hightNumber = nil;
    }
    
    if (msgContactsArray) {
        [msgContactsArray release];
        msgContactsArray = nil;
    }
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods
- (IBAction)onButtonToolBarItemClick: (id)sender {
    if (sender == barButtonItemBack)
    {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (sender == barButtonItemEdit) {
        
        ABAddressBookRef addressBook = ABAddressBookCreate();
        
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        ABRecordRef person = nil;
        person = ABAddressBookGetPersonWithRecordID(addressBook, [self.contact myid]);
        
        if (SystemVersion >= 7.0)
        {
            ABPersonViewController *myABPersonViewController = [[ABPersonViewController alloc] init];
            myABPersonViewController.displayedPerson = person;
            myABPersonViewController.addressBook = addressBook;
            [myABPersonViewController setAllowsEditing:YES];
            [myABPersonViewController setEditing:YES];
            myABPersonViewController.allowsActions = YES;
            myABPersonViewController.personViewDelegate = self;
            CFRelease(allPeople);
            CFRelease(addressBook);
            myABPersonViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:myABPersonViewController animated:YES];
        }
        else
        {
            PersonViewController* myABPersonViewController = [[PersonViewController alloc] init];
            myABPersonViewController.displayedPerson = person;
            myABPersonViewController.addressBook = addressBook;
            [myABPersonViewController setAllowsEditing:YES];
            [myABPersonViewController setEditing:YES];
            myABPersonViewController.personViewDelegate = self;
            CFRelease(allPeople);
            CFRelease(addressBook);
            myABPersonViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:myABPersonViewController animated:YES];
        }
    }
}

- (IBAction) onButtonClicked: (id)sender{
	UIActionSheet *sheet = nil;
	
	if(sender == self.buttonTextMessage){
		if(self.contact){
			int count = [self.contact.phoneNumbers count];
			if(count > 1){
				sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Send a text message", @"Send a text message")
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
				sheet.tag = kTagActionSheetTextMessage;
			}
			else if(count == 1){
				CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
				appDelegate.chatViewController.remoteParty = ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:0]).number;
				[self.navigationController pushViewController:appDelegate.chatViewController  animated:YES];
			}
		}
	}
	else if(sender == self.buttonVideoCall){
		if(self.contact){
			int count = [self.contact.phoneNumbers count];
			if(count > 1){
				sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Make Video call", @"Make Video call")
													delegate:self
										   cancelButtonTitle:nil
									  destructiveButtonTitle:nil
										   otherButtonTitles:nil];
				sheet.tag = kTagActionSheetVideoCall;
			}
			else if(count == 1){
                NgnPhoneNumber* ngnphonenum = (NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:0];
                if (ngnphonenum.type == NgnPhoneNumberType_Number) {
                    [self showCallOptView:ngnphonenum.number andVideoCall:YES];
                } else if (ngnphonenum.type == NgnPhoneNumberType_Email) {
                    [self Mailto:ngnphonenum.number];
                }
			}
		}
	}
	else if(sender == self.buttonAddToFavorites){
		if(self.contact){
			int count = [self.contact.phoneNumbers count];
			if(count > 1){
				sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Add to Favorites", @"Add to Favorites")
													delegate:self
										   cancelButtonTitle:nil
									  destructiveButtonTitle:nil
										   otherButtonTitles:nil];
				sheet.tag = kTagActionSheetAddToFavorites;
			}
			else if(count == 1){
				sheet = [[UIActionSheet alloc] initWithTitle:[@"" stringByAppendingFormat:NSLocalizedString(@"Add %@ to Favorites as:", @"Add %@ to Favorites as:"),
                                                              ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:0]).number]
                                                    delegate:self
                                           cancelButtonTitle:nil
									  destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
				addToFavoritesLastIndex = 0;
				sheet.tag = kTagActionSheetChooseFavoriteMediaType;
			}
		}
	}
    else if(sender == self.buttonInvite)
    {
        sheet = nil;
        
        if ([self.contact.phoneNumbers count] >= 2)
        {
            CCTableAlert *sbalert	= [[CCTableAlert alloc] initWithTitle:NSLocalizedString(@"Please a number", @"Please a number")
                                                      cancelButtonTitle:NSLocalizedString(@"Canel", @"Canel")
                                                          messageFormat:nil];
            [sbalert setStyle:CCTableAlertStyleApple];
            sbalert.tag = kTagTableAlertInvite;
            [sbalert setDelegate:self];
            [sbalert setDataSource:self];
            
            [sbalert show];
        }
        else if([self.contact.phoneNumbers count] == 1)
        {
            NgnPhoneNumber* phoneNumber = [self.contact.phoneNumbers objectAtIndex:0];
            [self showInviteMessageView:phoneNumber.number andContentType:kContentTypeDefault];
        }
    }
	else if (sender == buttonSendMsg)
    {
        sheet = nil;
        
        if ([self.contact.phoneNumbers count] >= 2)
        {
            [msgContactsArray removeAllObjects];
            for (NgnPhoneNumber *phoneNumber in self.contact.phoneNumbers)
            {
                if ([[NgnEngine sharedInstance].contactService dbIsWeiCallUser:phoneNumber.number])
                    [msgContactsArray addObject:phoneNumber];
            }
            
            if ([msgContactsArray count] >= 2) {
                CCTableAlert *sbalert	= [[CCTableAlert alloc] initWithTitle:NSLocalizedString(@"Please a number", @"Please a number")
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                              messageFormat:nil];
                [sbalert setStyle:CCTableAlertStyleApple];
                sbalert.tag = kTagTableAlertSendMsg;
                [sbalert setDelegate:self];
                [sbalert setDataSource:self];
                
                [sbalert show];
            }
            else
            {
                NgnPhoneNumber* phoneNumber = [msgContactsArray objectAtIndex:0];
                [self sendFreeMessage:phoneNumber.number];
            }
        }
        else if([self.contact.phoneNumbers count] == 1)
        {
            NgnPhoneNumber* phoneNumber = [self.contact.phoneNumbers objectAtIndex:0];
            [self sendFreeMessage:phoneNumber.number];
        }

    }
    
	if(sheet){
		sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		
		switch (sheet.tag) {
//			case kTagActionSheetTextMessage:
			case kTagActionSheetVideoCall:
			case kTagActionSheetAddToFavorites:
			{
				for(NgnPhoneNumber* phoneNumber in self.contact.phoneNumbers){
					[sheet addButtonWithTitle: [phoneNumber.description stringByAppendingFormat:@" %@",  phoneNumber.number]];
				}
				break;
			}
			case kTagActionSheetChooseFavoriteMediaType:
			{
				for(int i=0; i< sizeof(kFavoriteMediaEntries)/sizeof(FavoriteMediaEntry_t); i++){
					[sheet addButtonWithTitle:kFavoriteMediaEntries[i].description];
				}
				break;
			}
		}
		
		int cancelIdex = [sheet addButtonWithTitle: NSLocalizedString(@"Cancel", @"Cancel")];
		sheet.cancelButtonIndex = cancelIdex;
		
		[sheet showInView:self.parentViewController.tabBarController.view];
		[sheet release];
	}
}

- (IBAction)onBtnMsgClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableViewCell *buttonCell = (UITableViewCell *)[button superview];
    NSUInteger butttonRow = [[self.tableView indexPathForCell:buttonCell] row];
    NgnPhoneNumber* phoneNumber = [self.contact.phoneNumbers objectAtIndex:butttonRow];
    [self showInviteMessageView:phoneNumber.number andContentType:123];

    /*UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                        delegate:self
                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                          destructiveButtonTitle:NSLocalizedString(@"Send a text message", @"Send a text message")
                               otherButtonTitles:nil, nil];
    sheet.tag = kTagActionSheetTextMessage;
    [sheet showInView:self.parentViewController.tabBarController.view];
    [sheet release];
    self.sendMessageNum = phoneNumber.number;*/
}


- (void)sendFreeMessage:(NSString *)sendNum
{
    if ([[NgnEngine sharedInstance].contactService dbIsWeiCallUser:sendNum])
    {
        
        NSString *smsgNum = [NSString stringWithString:sendNum];
        smsgNum = [smsgNum phoneNumFormat];
        
        //不能发信息给自己
        NSString *selfNumber = [NSString stringWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
        if ([smsgNum isEqualToString:selfNumber]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:NSLocalizedString(@"You can't send message yourself", @"You can't send message yourself")
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            return ;
        }
        [[CloudCall2AppDelegate sharedInstance] GoBackToRootViewFirst];
        [[CloudCall2AppDelegate sharedInstance] EnterMessagesView:smsgNum];

    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message:@"他还不是你们云通好友,赶紧邀请他开通,就可以发送免费短信啦"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        alert.tag = kTagAlertInvite;
        [alert show];
        [alert release];
        self.sendMessageNum = sendNum;
    }
}
/**
 *	@brief	邀请好友加入云通
 */
- (void)showInviteMessageView:(NSString*)phonenum andContentType:(int)contentType
{
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init]; //autorelease];
        controller.recipients = [NSArray arrayWithObject:phonenum];
        if (contentType == kContentTypeDefault)
            controller.body = [NSString stringWithFormat:NSLocalizedString(@"Invite Message Content", @"Invite Message Content"), RootUrl];
        else
            controller.body = @"";
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

-(void)updateContactData:(int32_t)contact_myid {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    if (!addressBook)
    {
        CFRelease(allPeople);
        return;
    }
    ABRecordRef person = nil;
    person = ABAddressBookGetPersonWithRecordID(addressBook, contact_myid);
    if (!person)
    {
        CFRelease(allPeople);
        CFRelease(addressBook);
        return;
    }
    [contact release];
    contact=[[NgnContact alloc] initWithABRecordRef:person];
    CFRelease(allPeople);
    CFRelease(addressBook);
}

- (NgnContact *)getContactAfterAdd
{
    NSMutableArray *phoneNumbers = [self.contact phoneNumbers];
    NgnPhoneNumber *phoneNumber = [phoneNumbers objectAtIndex:0];
    NgnContact *aContact =  phoneNumber.number? [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:phoneNumber.number] : nil;
    
    return aContact;
}

#pragma mark
#pragma mark UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isInContact)
        return 2;
    else
        return 3;
}

- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return self.contact ? [self.contact.phoneNumbers count] : 0;
            break;
        case 1:
            if (isInContact)
            {
                int recentArrayLen = [recentArray count];
                if (recentArrayLen < 1) {
                    return 1;
                }
                else
                    return [recentArray count];
            }
            else
                return 2;
            break;
        case 2:
        {
            int recentArrayLen = [recentArray count];
            if (recentArrayLen < 1) {
                return 1;
            }
            else
                return [recentArray count];
            break;
        }
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)] autorelease];
    label.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:15.0f];
    label.contentMode = UIControlContentVerticalAlignmentTop;
    UIView *ls = [[UIView alloc] initWithFrame:CGRectMake(0, 29, 300, 1)];
    ls.backgroundColor = [UIColor lightGrayColor];
    [label addSubview:ls];
    [ls release];
    
    switch (section) {
        case 0:
            label.text = [NSString stringWithFormat:@"    %@",NSLocalizedString(@"Phones", @"Phones")];
            break;
        case 1:
            if (isInContact)
                label.text = [NSString stringWithFormat:@"    %@",NSLocalizedString(@"History", @"History")];
            else
                label.text = [NSString stringWithFormat:@"    %@",NSLocalizedString(@"Maybe you can", @"Maybe you can")];
            break;
        case 2:
            label.text = [NSString stringWithFormat:@"    %@",NSLocalizedString(@"History", @"History")];
            break;
        default:
            return 0;
            break;
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 13.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *emptyView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 13)] autorelease];
    return emptyView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    switch (section) {
        case 0:
        {
            PhoneEntryCell* cell = (PhoneEntryCell*)[tableView_ dequeueReusableCellWithIdentifier: kPhoneEntryCellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"PhoneEntryCell" owner:self options:nil] lastObject];
            }
            NgnPhoneNumber* num = [self.contact.phoneNumbers objectAtIndex: indexPath.row];
            cell.number = num;
            
            if (isHightLight && ![NgnStringUtils isNullOrEmpty:hightNumber])
            {
                hightNumber = [hightNumber phoneNumFormat];
                
                NSString *tmpString = [num.number phoneNumFormat];
                
                if ([hightNumber isEqualToString:tmpString])
                    cell.labelPhoneValue.textColor = [UIColor colorWithRed:0 green:160.0/255.0 blue:233.0/255.0 alpha:1];
                else
                    cell.labelPhoneValue.textColor = [UIColor blackColor];
            }
                
            UIButton *btnMsg = [UIButton buttonWithType:UIButtonTypeCustom];
            btnMsg.frame = CGRectMake(0, 0, 50, 35);
            [btnMsg setImage:[UIImage imageNamed:@"btn_msg_up.png"] forState:UIControlStateNormal];
            [btnMsg setImage:[UIImage imageNamed:@"btn_msg_down.png"] forState:UIControlStateHighlighted];
            [btnMsg addTarget:self action:@selector(onBtnMsgClick:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.accessoryView = btnMsg;
            if ([[NgnEngine sharedInstance].contactService dbIsWeiCallUser:num.number]){
                [cell setFriend:YES];
            } else {
                [cell setFriend:NO];
            }
            return cell;
            break;
        }
        case 1:
        {
            if (isInContact)
            {
                if ([recentArray count] < 1)
                {
                    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"recentContactCellIdentifier"];
                    if (cell == nil)
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recentContactCellIdentifier"] autorelease];
                    cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
                    cell.textLabel.text = NSLocalizedString(@"No record with this contact", @"No record with this contact");
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    cell.backgroundColor = [UIColor clearColor];
                    return cell;
                }
                else
                {
                    RecentDetailCell *cell = (RecentDetailCell*)[tableView dequeueReusableCellWithIdentifier: kRecentDetailCellIdentifier];
                    if (cell == nil) {
                        cell = [[[NSBundle mainBundle] loadNibNamed:@"RecentDetailCell" owner:self options:nil] lastObject];
                    }
                    
                    [cell setEvent:[recentArray objectAtIndex:row]];
                    
                    return cell;
                    break;
                }
            }
            else
            {
                UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"addToContactCell"];
                
                if (cell == nil)
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addToContactCell"] autorelease];
                
                cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
                switch (row) {
                    case 0:
                        cell.textLabel.text = NSLocalizedString(@"New contact", @"New contact");
                        break;
                    case 1:
                        cell.textLabel.text = NSLocalizedString(@"Add to exist contact", @"Add to exist contact");
                        break;
                    default:
                        break;
                }
                return cell;
            }
            break;
        }
        case 2:
        {
            if ([recentArray count] < 1)
            {
                UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"recentContactCellIdentifier"];
                if (cell == nil)
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recentContactCellIdentifier"] autorelease];
                cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
                cell.textLabel.text = NSLocalizedString(@"No record with this contact", @"No record with this contact");
                cell.textLabel.textColor = [UIColor lightGrayColor];
                return cell;
            }
            else
            {
                RecentDetailCell *cell = (RecentDetailCell*)[tableView dequeueReusableCellWithIdentifier: kRecentDetailCellIdentifier];
                if (cell == nil) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"RecentDetailCell" owner:self options:nil] lastObject];
                }
                
                [cell setEvent:[recentArray objectAtIndex:row]];
                
                return cell;
                break;
            }
        }
        default:
            return nil;
            break;
    }
}

#pragma mark
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    if (section == 0)
    {
        BOOL ret = NO;
        if ([[NgnEngine sharedInstance].sipService isRegistered]) {
            
            BOOL on3G = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
            BOOL use3G = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
            if (on3G && !use3G) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message:NSLocalizedString(@"Only 3G network is available. Please enable 3G and try again.", @"Only 3G network is available. Please enable 3G and try again.")
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                
                return ;
            }
            
            NgnPhoneNumber* ngnphonenum = ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:indexPath.row]);
            
            NSString *dialNumber = [ngnphonenum.number phoneNumFormat];
            
            //不能拨打本机号码
            NSString *selfNumber = [NSString stringWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
            if ([dialNumber isEqualToString:selfNumber]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message:NSLocalizedString(@"You can't call yourself", @"You can't call yourself")
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                
                return ;
            }
            
            if (ngnphonenum.type == NgnPhoneNumberType_Number) {
                ret = [self showCallOptView:dialNumber andVideoCall:NO];
                /*ret = [CallViewController makeAudioCallWithRemoteParty: ngnphonenum.number
                 andSipStack:[[NgnEngine sharedInstance].sipService getSipStack]];
                 */
            } else if (ngnphonenum.type == NgnPhoneNumberType_Email) {
                [self Mailto:ngnphonenum.number];
            }
            if (ret == YES){
                return;
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
        [self.tableView resignFirstResponder];
    }
    else if(section == 1 && !isInContact)
    {
        NgnPhoneNumber *phoneNumber = [self.contact.phoneNumbers objectAtIndex: 0];
        
        if (row == 0)
        {            
            ABNewPersonViewController *view = [[ABNewPersonViewController alloc] init];
            ABRecordRef newPerson = ABPersonCreate();
            CFErrorRef error = NULL;
            ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            ABMultiValueAddValueAndLabel(multiValue, phoneNumber.number, kABPersonPhoneMobileLabel, NULL);
            ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiValue , &error);
            NSAssert(!error, @"Something bad happened here.");
            view.displayedPerson = newPerson;
            
            if (!myNewContactDelegate)
                myNewContactDelegate = [[NewContactDelegate alloc] init];
            [view setNewPersonViewDelegate:myNewContactDelegate];
            [self.navigationController setNavigationBarHidden:NO];
            view.hidesBottomBarWhenPushed = YES;
            isAddContact = YES;
            [self.navigationController pushViewController:view animated:YES];
            [view release];
            CFRelease(multiValue);
            CFRelease(newPerson);
        }
        else
        {
            SelectContactViewController *selectContactViewController = [[SelectContactViewController alloc] initWithNibName:@"SelectContactViewController" bundle:nil];
            selectContactViewController.strAddNumber = phoneNumber.number;
            [self.navigationController pushViewController:selectContactViewController animated:YES];
            [selectContactViewController release];
        }
    }
    else
    {
    
    }
}

#pragma mark
#pragma mark UIAlertView Delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) // Cancel - Do Nothing
        return;
    
    if (buttonIndex == 1) { // OK
        switch (alertView.tag) {
            case kTagAlertCallOutViaCellPhone: {
                NSString* dialurl = [@"tel://" stringByAppendingString:dialNum];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialurl]];
                break;
            }
            case kTagAlertInvite:
            {
                [self showInviteMessageView:sendMessageNum andContentType:kContentTypeDefault];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark
#pragma mark UIActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != actionSheet.cancelButtonIndex){
		switch (actionSheet.tag) {
			case kTagActionSheetVideoCall:
			{
                NgnPhoneNumber* ngnphonenum = (NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:buttonIndex];
                if (ngnphonenum.type == NgnPhoneNumberType_Number) {
                    [self showCallOptView:ngnphonenum.number andVideoCall:YES];
                    /*[CallViewController makeAudioVideoCallWithRemoteParty: ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:buttonIndex]).number
                     andSipStack:[[NgnEngine sharedInstance].sipService getSipStack]];*/
                } else if (ngnphonenum.type == NgnPhoneNumberType_Email) {
                    [self Mailto:ngnphonenum.number];
                }
				break;
			}
			case kTagActionSheetTextMessage:
			{
                /*if (buttonIndex == actionSheet.destructiveButtonIndex)
                {
                    [self showInviteMessageView:sendMessageNum andContentType:123];
                }
                else
                {
                    [self sendFreeMessage:self.sendMessageNum];
                }
                
				CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
				appDelegate.chatViewController.remoteParty = ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:buttonIndex]).number;
				[self.navigationController pushViewController:appDelegate.chatViewController  animated:YES];*/
				break;
			}
				
			case kTagActionSheetAddToFavorites:
			{
				addToFavoritesLastIndex =  buttonIndex;
				UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:[@"" stringByAppendingFormat:NSLocalizedString(@"Add %@ to Favorites as:", @"Add %@ to Favorites as:"),
                                                                             ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:buttonIndex]).number]
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:nil];
				sheet.tag = kTagActionSheetChooseFavoriteMediaType;
				sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
				for(int i=0; i< sizeof(kFavoriteMediaEntries)/sizeof(FavoriteMediaEntry_t); i++){
					[sheet addButtonWithTitle:kFavoriteMediaEntries[i].description];
				}
				int cancelIdex = [sheet addButtonWithTitle: NSLocalizedString(@"Cancel", @"Cancel")];
				sheet.cancelButtonIndex = cancelIdex;
				
				[sheet showInView:self.parentViewController.tabBarController.view];
				[sheet release];
				break;
			}
				
			case kTagActionSheetChooseFavoriteMediaType:
			{
				if(self.contact && [self.contact.phoneNumbers count] > addToFavoritesLastIndex){
					NgnMediaType_t mediaType = kFavoriteMediaEntries[buttonIndex].mediaType;
					NgnPhoneNumber* phoneNumber = ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:addToFavoritesLastIndex]);
					
					NgnFavorite* favorite = [[NgnFavorite alloc] initWithNumber:phoneNumber.number andMediaType:mediaType];
					[[NgnEngine sharedInstance].storageService addFavorite: favorite];
					[favorite release];
				}
				
				break;
			}
                
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
                            [self showInviteMessageView:dialNum andContentType:kContentTypeDefault];
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
                    [self showInviteMessageView:dialNum andContentType:kContentTypeDefault];
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

#pragma mark
#pragma mark MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:NO];
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

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property
                  identifier:(ABMultiValueIdentifier)identifier
{
    return true;
}

#pragma mark
#pragma mark CCTableAlertDataSource
- (NSInteger)tableAlert:(CCTableAlert *)tableAlert numberOfRowsInSection:(NSInteger)section
{
	return [msgContactsArray count];
}

- (UITableViewCell *)tableAlert:(CCTableAlert *)tableAlert cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	UITableViewCell *cell = [[[CCTableAlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    NgnPhoneNumber* phoneNumber = [msgContactsArray objectAtIndex: indexPath.row];
	[cell.textLabel setText:[NSString stringWithFormat:@"%@" , phoneNumber.number]];
	cell.textLabel.textAlignment = UITextAlignmentCenter;
    
	return cell;
}

#pragma mark
#pragma mark CCTableAlertDelegate
- (void)tableAlert:(CCTableAlert *)tableAlert didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableAlert.tag) {
        case kTagTableAlertInvite:
        {
            NgnPhoneNumber* phoneNumber = [msgContactsArray objectAtIndex:indexPath.row];
            [self showInviteMessageView:phoneNumber.number andContentType:kContentTypeDefault];
            break;
        }
        case kTagTableAlertSendMsg:
        {
            NgnPhoneNumber* phoneNumber = [msgContactsArray objectAtIndex:indexPath.row];
            [self sendFreeMessage:phoneNumber.number];
            break;
        }
        default:
            break;
    }

}

@end
