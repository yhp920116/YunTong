/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "NumpadViewController.h"
#import "CallViewController.h"
#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"
#import "AreaOfPhoneNumber.h"
#import "WebBrowser.h"
#import "RegexKitLite.h"

#define kTagActionSheetClear   0
#define kTagActionSheetCallOut 1
#define kTagActionSheetAddContact 2

#define kTagAlertCallOutViaCellPhone 11

#import "RecentCell.h"
#import "NetWorkExcCell.h"

#import "NewContactDelegate.h"

#import "MobClick.h"
//
//	Private
//


@interface NumpadViewController(Private)
-(void) refreshData;
-(void) refreshDataAndReload;
-(void) onHistoryEvent:(NSNotification*)notification;
-(void) onRegistrationEvent:(NSNotification*)notification;
-(void) isShowNetworkError;
-(BOOL) showCallOptView:(NSString*)num andVideoCall:(BOOL)videocall;
// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
- (void)layoutForCurrentOrientation:(BOOL)animated;
@end

@implementation NumpadViewController(Private)

-(void) refreshData{
    NSString *searchText = self.labelNumber.text;
    if ([searchText length]) {
        @synchronized(contactArray){
            NSArray *mContactServiceArray = [[mContactService contacts] retain];
            NSMutableArray *tmpContactArray1 = [NgnContactMutableArray arrayWithCapacity:10];
            NSMutableArray *tmpContactArray2 = [NgnContactMutableArray arrayWithCapacity:10];
            NSString *tmpFirstNum = [searchText substringWithRange:NSMakeRange(0, 1)];
            for (NgnContact *contact in mContactServiceArray)
            {
                contact.displayMsg = @"";
                contact.displayMsgRange = NSMakeRange(0, 0);
                contact.lettersCount = 0;
                NSRange displayNameRange;
                
                //拼音匹配
                if (![tmpFirstNum isEqualToString:@"0"] &&![tmpFirstNum isEqualToString:@"1"] && ![tmpFirstNum isEqualToString:@"*"] && ![tmpFirstNum isEqualToString:@"#"])
                {
                    //首字母匹配,勿删,留待后用
//                    NSArray *abArray = [contact.abDisplayName componentsSeparatedByString:@" "];
//                    if ([searchText length] <= [abArray count]) {
//                        NSMutableString *numString = [NSMutableString stringWithCapacity:8];
//                        for (NSString *pinyin in abArray) {
//                            NSString *firstLetter = [pinyin substringToIndex:1];
//                            NSString *convertNum = [self getNumerByLetter:firstLetter];
//                            [numString appendString:convertNum];
//                        }
//                        if ([numString hasPrefix:searchText]) {
//                            contact.displayMsg = contact.abDisplayName;
//                            contact.lettersCount = [searchText length];
//                            [tmpContactArray1 addObject:contact];
//                        }
//                        else
//                        {
//                            contact.lettersCount = 0;
//                        }
//                    }
                    
                    //全匹配
                    NSString *tmpString = [contact.abDisplayName stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSMutableString *allNumString = [NSMutableString stringWithCapacity:8];
                    
                    //将字母转为数字
                    for (int j = 0;j < [tmpString length];j++)
                    {
                        NSString *letter = [tmpString substringWithRange:NSMakeRange(j, 1)];
                        NSString *convertNum = [self getNumerByLetter:letter];
                        [allNumString appendString:convertNum];
                    }
                    displayNameRange = [allNumString rangeOfString:searchText];
                    if (displayNameRange.location != NSNotFound)
                    {
                        NgnContact *newContact = [[NgnContact alloc] initWithDisplayName:contact.displayName andFirstName:contact.firstName andLastName:contact.lastName andPhoneNumbers:contact.phoneNumbers andPicture:contact.picture andDisplayMsg:tmpString andDisplayMsgRange:displayNameRange];
                        
                        if ([contact.displayName isEqualToString:tmpString])
                        {
                            newContact.displayNameRange = displayNameRange;
                            NSMutableArray *phoneNumbersArray = contact.phoneNumbers;
                            if ([phoneNumbersArray count] > 0) {
                                NgnPhoneNumber *ngnphonenumber = [phoneNumbersArray objectAtIndex:0];
                                newContact.displayMsg = [ngnphonenumber.number phoneNumFormat];
                                newContact.displayMsgRange = NSMakeRange(0, 0);
                            }
                            else
                            {
                                newContact.displayMsg = contact.displayName;
                                newContact.displayMsgRange = NSMakeRange(0, 0);
                            }
                        }
                        
                        [tmpContactArray1 addObject:newContact];
                        [newContact release];
                    }
                }
                
                //号码匹配
                NSMutableArray *phoneNumbersArray = contact.phoneNumbers;
                for (int k=0; k < [phoneNumbersArray count]; k++)
                {
                    NgnPhoneNumber *ngnphonenumber = [phoneNumbersArray objectAtIndex:k];
                    NSString *aNumber = [NSString stringWithString:ngnphonenumber.number];
                    NSString *aReplNumber = [aNumber phoneNumFormat];
                    displayNameRange = [aReplNumber rangeOfString:searchText];
                    if (displayNameRange.location != NSNotFound)
                    {
                        NgnContact *newContact = [[NgnContact alloc] initWithDisplayName:contact.displayName andFirstName:contact.firstName andLastName:contact.lastName andPhoneNumbers:contact.phoneNumbers andPicture:contact.picture andDisplayMsg:aReplNumber andDisplayMsgRange:displayNameRange];
                        [tmpContactArray2 addObject:newContact];
                        [newContact release];
                    }
                }
            }
            [mContactServiceArray release];
            
            //对数据进行排序
            NSArray *tmpArray1 = [tmpContactArray1 sortedArrayUsingComparator:
                                  ^NSComparisonResult(id a, id b){
                                      NSString *msg1 = [(NgnContact *)a displayMsg];
                                      NSString *msg2 = [(NgnContact *)b displayMsg];
                                      return [msg1 localizedCaseInsensitiveCompare:msg2];
                                  }];
            NSArray *tmpArray2 = [tmpContactArray2 sortedArrayUsingComparator:
                                  ^NSComparisonResult(id a, id b){
                                      NSString *msg1 = [(NgnContact *)a displayMsg];
                                      NSString *msg2 = [(NgnContact *)b displayMsg];
                                      return [msg1 localizedCaseInsensitiveCompare:msg2];
                                  }];
            
            [contactArray removeAllObjects];
            [contactArray addObjectsFromArray:tmpArray1];
            [contactArray addObjectsFromArray:tmpArray2];
        }
    }
	@synchronized(mEvents){
		[mEvents removeAllObjects];
		NSArray* events = [[[mHistoryService events] allValues] sortedArrayUsingSelector:@selector(compareHistoryEventByDateASC:)];
		for (NgnHistoryEvent* event in events) {
			if(!event || !(event.mediaType & MediaType_AudioVideo) || !(event.status & mStatusFilter)){
				continue;
			}
			[mEvents addObject:event];
		}
	}
}

-(void) refreshDataAndReload
{
    //减缓tableview刷新频率
    //用户开始输入1~3数字可能只是头几个,没必要立即响应,延迟0.3秒刷新,当输入超过3个数字时
    if([self.labelNumber.text length] <= 3)
    {
        [self performSelector:@selector(refreshAndReloadData) withObject:nil afterDelay:0.3f];
    }
    else if([self.labelNumber.text length] > 3)
    {
        [self refreshAndReloadData];
    }
}

/**
 *	@brief	刷新匹配数据并重新加载TableView
 */
- (void)refreshAndReloadData
{
    if ([self.labelNumber.text length] == 0 && [mEvents count] == 0)
    {
        [contactArray removeAllObjects];
    }
    [self refreshData];
	[tableView reloadData];
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

-(void) onHistoryEvent:(NSNotification*)notification{
	NgnHistoryEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case HISTORY_EVENT_ITEM_ADDED:
		{
			if ((eargs.mediaType & MediaType_AudioVideo)) {
				NgnHistoryEvent* event = [[mHistoryService events] objectForKey: [NSNumber numberWithLongLong: eargs.eventId]];
				if (event) {
                    [lastnumber release];
                    lastnumber = [event.remoteParty retain];
                    if (event.status & mStatusFilter) {
                        [mEvents insertObject:event atIndex:0];
                        [tableView reloadData];
                    }
				}
			}
			break;
		}
		
		case HISTORY_EVENT_ITEM_MOVED:
		case HISTORY_EVENT_ITEM_UPDATED:
		{
			[tableView reloadData];
			break;
		}
		
		case HISTORY_EVENT_ITEM_REMOVED:
		{
			if((eargs.mediaType & MediaType_AudioVideo)){
				for (NgnHistoryEvent* event in mEvents) {
					if (event.id == eargs.eventId) {
                        if (event.status & mStatusFilter) {
                            [mEvents removeObject: event];
                            [tableView reloadData];
                        }
						break;
					}
				}
			}
			break;
		}
		
		case HISTORY_EVENT_RESET:
		default:
		{
			[self refreshDataAndReload];
			break;
		}
	}
}

//== REGISTER events == //
-(void) onRegistrationEvent:(NSNotification*)notification {
	NgnRegistrationEventArgs* eargs = [notification object];
	CCLog(@"NumpadView: Reg notify: %d, %d, %@", eargs.eventType, eargs.sipCode, eargs.sipPhrase ? eargs.sipPhrase : @"");
    
	switch (eargs.eventType) {
			// provisional responses
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_INPROGRESS:
        {
			isConnecting = YES;
			break;
			// final responses
        }
		case REGISTRATION_OK:
        {
            isConnecting = NO;
            break;
        }
        case REGISTRATION_NOK: {
            isConnecting = NO;
            break;
        }
		case UNREGISTRATION_OK:
		case UNREGISTRATION_NOK:
		default:
        {
			isConnecting = NO;
			break;
        }
	}
    [self isShowNetworkError];
}

- (void)isShowNetworkError
{
//    if ([mSipService isRegistered])
        isShowNetWorkPromptFlag = NO;
//    else
//        isShowNetWorkPromptFlag = YES;
    [tableView reloadData];
}

-(BOOL) showCallOptView:(NSString*)num andVideoCall:(BOOL)videocall{
    if (dialNum) {
        [dialNum release];
        dialNum = nil;
    }
    dialNum = [num retain];
    videocallout = videocall;
    
    
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
        [sheet showInView:tableView];
        [sheet release];
    }
    
    return YES;
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
    bannerOrigin.y = self.buttonAd.bounds.origin.y;//44;
    
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
    else if (lmbanner) {        
        [UIView animateWithDuration:animationDuration
                         animations:^{                         
                             lmbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, lmbanner.frame.size.width, lmbanner.frame.size.height);
                         }];
    }
}

@end

#pragma mark
#pragma mark Default implementation
@implementation NumpadViewController
@synthesize tableView;
@synthesize numpadView;
@synthesize dialView;
@synthesize labelNumber;
@synthesize labelNumberArea;
@synthesize delNum;
@synthesize keypad_0;
@synthesize keypad_1;
@synthesize keypad_2;
@synthesize keypad_3;
@synthesize keypad_4;
@synthesize keypad_5;
@synthesize keypad_6;
@synthesize keypad_7;
@synthesize keypad_8;
@synthesize keypad_9;
@synthesize keypad_sharp;
@synthesize keypad_del;
@synthesize keypad_dial;
@synthesize keypad_star;
@synthesize toContact;
@synthesize lblContact;

@synthesize btnClear;
@synthesize buttonAd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Numpad", @"Numpad") image:[UIImage imageNamed:@"tab_numpad_normal"] tag:0];
        if (SystemVersion >= 5.0)
            [item setFinishedSelectedImage:[UIImage imageNamed:@"tab_numpad_down"]
               withFinishedUnselectedImage:[UIImage imageNamed:@"tab_numpad_normal"]];
        
        self.tabBarItem = item;
        [item release];
    }
    return self;
}

#pragma mark
#pragma mark Private Methods
- (IBAction)onButtonClick: (id)sender
{
    NSInteger tag = ((UIButton*)sender).tag;
	if(tag == kTAGViewNewworkExcDetail)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        NSString *currentLanguage = [languages objectAtIndex:0];
        
        //本地化
        NSString *path;
        if (![currentLanguage isEqualToString:@"zh-Hans"]) {
            path = [[NSBundle mainBundle] pathForResource:@"networkexc_en.html" ofType:nil];
        }
        else
        {
            path = [[NSBundle mainBundle] pathForResource:@"networkexc_cn.html" ofType:nil];
        }
        NSURL *url = [NSURL URLWithString:path];
        WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:url];
        webBrowser.mode = TSMiniWebBrowserModeNavigation;
        webBrowser.type = TSMiniWebBrowserTypeNetworkExc;
        
        [webBrowser setFixedTitleBarText:NSLocalizedString(@"Network is unreachable",@"Network is unreachable")];
        webBrowser.barStyle = UIStatusBarStyleDefault;
        webBrowser.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webBrowser animated:YES];
        
        [webBrowser release];
	}
    else if(sender == btnClear)
    {
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                  destructiveButtonTitle:NSLocalizedString(@"Clear All History", @"Clear All History")
                                                       otherButtonTitles:nil];
		popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        popupQuery.tag = kTagActionSheetClear;
		[popupQuery showInView: tableView];
		[popupQuery release];
    }
}

- (IBAction) onButtonNumpadDown: (id) sender event: (UIEvent*) e{
	NSInteger tag = ((UIButton*)sender).tag;
	
	switch (tag)
    {
		case kTAGMessages:
		{
			CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
			[appDelegate.tabBarController presentModalViewController: appDelegate.messagesViewController animated: NO];
			break;
		}
			
		case kTAGAudioCall:
            //case kTAGVideoCall:
		{
            if ([mSipService isRegistered])
            {
                if ([labelNumber.text length])
                {
                    //不能拨打本机号码
                    NSString *selfNumber = [[CloudCall2AppDelegate sharedInstance] getUserName];
                    
                    if ([self.labelNumber.text isEqualToString:selfNumber]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                        message:NSLocalizedString(@"You can't call yourself", @"You can't call yourself")
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                        [alert show];
                        [alert release];
                        
                        return ;
                    }
                    
                    //是否允许使用手机网络
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
                    
                    NSString *dialNumber = [[NSString alloc] initWithString:self.labelNumber.text];
                    
                    isExist = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:dialNumber] != nil;
                    [self showCallOptView:dialNumber andVideoCall:NO];
                    
                    [dialNumber release];
                    
                } else if (lastnumber && [lastnumber length]) {
                    labelNumber.text = lastnumber;
                }
                videocallout = (tag == kTAGToContact);
                /*if(tag == kTAGVideoCall){
                 [CallViewController makeAudioVideoCallWithRemoteParty: labelNumber.text  andSipStack: [mSipService getSipStack]];
                 }
                 else{
                 [CallViewController makeAudioCallWithRemoteParty: labelNumber.text  andSipStack: [mSipService getSipStack]];
                 }*/
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
            //lastnumber = [labelNumber.text retain];
			//labelNumber.text = @"";
			break;
		}
        case kTAGToContact: // temporary using as addcontact
		{
            /*if ([mSipService isRegistered]){
             [CallViewController makeAudioCallWithRemoteParty: lastnumber  andSipStack: [mSipService getSipStack] andCalloutMode:lastcalloutmode];
             
             }*/
//            if ([labelNumber.text length]) {
//                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
//                                                     destructiveButtonTitle:NSLocalizedString(@"Create New Contact", @"Create New Contact")
//                                                          otherButtonTitles:/*NSLocalizedString(@"Add to Existing Contact", @"Add to Existing Contact"),*/ nil];
//                sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//                sheet.tag = kTagActionSheetAddContact;
//                [sheet showInView:self.tabBarController.view];
//                [sheet release];
//            }
//            else
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                                message:NSLocalizedString(@"Please input the phone number first", @"Please input the phone number first")
//                                                               delegate:self
//                                                      cancelButtonTitle:nil
//                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
//                [alert show];
//                [alert release];
//            }
            [self.tabBarController setSelectedIndex:2]; //到联系人tab
            
			break;
		}
            
		case kTAGDelete:
		{
			NSString* number = labelNumber.text;
			if([number length] >0){
				labelNumber.text = [number substringToIndex:([number length]-1)];
			}
            BOOL dten = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_DIAL_TONE_ENABLE];
            if (dten)
                [[NgnEngine sharedInstance].soundService playDtmf:kTAGStar];
            [self performSelector:@selector(onLongClick:) withObject:sender afterDelay:.2];
            [self onNumPadClickEvent];
            [self refreshDataAndReload];
			break;
		}
			
		case kTAGStar:
		{
			labelNumber.text = [NSString stringWithFormat:@"%@*", labelNumber.text?labelNumber.text:@""];
			BOOL dten = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_DIAL_TONE_ENABLE];
            if (dten)
                [[NgnEngine sharedInstance].soundService playDtmf:kTAGStar];
            [self onNumPadClickEvent];
            [self refreshDataAndReload];
            
			break;
		}
			
		case kTAGPound:
		{
			labelNumber.text = [NSString stringWithFormat:@"%@#", labelNumber.text?labelNumber.text:@""];
            BOOL dten = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_DIAL_TONE_ENABLE];
            if (dten)
                [[NgnEngine sharedInstance].soundService playDtmf:kTAGPound];
            
            if ([labelNumber.text isEqualToString:@"*#2846#"]) {
                labelNumber.text = @"";
                BOOL oldEn = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_LANDS_CALL_ENABLE];
                BOOL enabled = !oldEn;
                [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_LANDS_CALL_ENABLE andValue:enabled];
                
                NSString* strMsg = enabled ?
                NSLocalizedString(@"Lands Call Feature Enabled.", @"Lands Call Feature Enabled.")
                : NSLocalizedString(@"Lands Call Feature Disabled.", @"Lands Call Feature Disabled.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                                message: strMsg
                                                               delegate: nil
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
            } else if ([labelNumber.text isEqualToString:@"*#266344#"]) {
                labelNumber.text = @"";
                //////////////////////////////////////////////////////////////////////////
                NSString* strMsg = [[[NSString alloc] init] autorelease];
                NSString* strtmp = nil;
                
                strtmp = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_HOST];
                strMsg = [strMsg stringByAppendingFormat:@"server: %@\n", strtmp];
                
                int val = [[NgnEngine sharedInstance].configurationService getIntWithKey:NETWORK_PCSCF_PORT];
                strMsg = [strMsg stringByAppendingFormat:@"server port: %d\n", val];
                
                strtmp = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_BACKUP_PCSCF_HOST];
                strMsg = [strMsg stringByAppendingFormat:@"backup server: %@\n", strtmp];
                
                val = [[NgnEngine sharedInstance].configurationService getIntWithKey:NETWORK_BACKUP_PCSCF_PORT];
                strMsg = [strMsg stringByAppendingFormat:@"backup server port: %d\n", val];
                
                strtmp = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_REG_HOST];
                strMsg = [strMsg stringByAppendingFormat:@"register server: %@\n", strtmp];
                
                val = [[NgnEngine sharedInstance].configurationService getIntWithKey:NETWORK_PCSCF_REG_PORT];
                strMsg = [strMsg stringByAppendingFormat:@"register port: %d\n", val];
                
                val = [[NgnEngine sharedInstance].configurationService getIntWithKey:NETWORK_REGISTRATION_TIMEOUT];
                strMsg = [strMsg stringByAppendingFormat:@"registration period: %d\n", val];
                
                bool enable = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_LANDS_CALL_ENABLE];
                strMsg = [strMsg stringByAppendingFormat:@"landcall enable: %@\n", enable ? @"Enabled" : @"Disabled"];
                
                enable = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_CALLBACK_ENABLE];
                strMsg = [strMsg stringByAppendingFormat:@"callback enable: %@\n", enable ? @"Enabled" : @"Disabled"];
                
                enable = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_INNET_CALL_ENABLE];
                strMsg = [strMsg stringByAppendingFormat:@"innetcall enable: %@\n", enable ? @"Enabled" : @"Disabled"];
                
                enable = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_PHONE_CALL_ENABLE];
                strMsg = [strMsg stringByAppendingFormat:@"phonecall enable: %@\n", enable ? @"Enabled" : @"Disabled"];
                
                enable = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NATT_USE_STUN];
                strMsg = [strMsg stringByAppendingFormat:@"stun enable: %@\n", enable ? @"Enabled" : @"Disabled"];
                
                strtmp = [[NgnEngine sharedInstance].configurationService getStringWithKey:NATT_STUN_SERVER];
                strMsg = [strMsg stringByAppendingFormat:@"stun server: %@\n", strtmp];
                
                val = [[NgnEngine sharedInstance].configurationService getIntWithKey:NATT_STUN_PORT];
                strMsg = [strMsg stringByAppendingFormat:@"stun port: %d\n", val];
                
                //////////////////////////////////////////////////////////////////////////
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Configuration"
                                                                message: strMsg
                                                               delegate: nil
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
            } else if ([labelNumber.text isEqualToString:@"*#26332#"]) {
                labelNumber.text = @"";
                //////////////////////////////////////////////////////////////////////////
                
                tdav_codec_id_t codecs[20];
                memset(codecs, 0, sizeof(codecs));
                int n = SipStack::getCodecPriority(codecs);
                NSString* strMsg = @"";
                for (int i=0; i<n; i++) {
                    strMsg = [strMsg stringByAppendingFormat:@"%s\n", SipStack::getCodecName(codecs[i])];
                }
                //////////////////////////////////////////////////////////////////////////
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Codec"
                                                                message: strMsg
                                                               delegate: nil
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
            } else if ([labelNumber.text isEqualToString:@"*#627538#"]) { // market
                labelNumber.text = @"";
                //////////////////////////////////////////////////////////////////////////
                CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                NSString* strMsg = [[[NSString alloc] initWithFormat:@"%@, %d", [appDelegate MarketTypeName], [appDelegate MarkCode]] autorelease];
                //////////////////////////////////////////////////////////////////////////
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Market Info."
                                                                message: strMsg
                                                               delegate: nil
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
            } else if ([labelNumber.text isEqualToString:@"*#2663#"]) {
                labelNumber.text = @"";
                
                CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                appDelegate.useSecondConfServ = !appDelegate.useSecondConfServ;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                                message: appDelegate.useSecondConfServ?@"Use 2nd Conf Server.":@"Use 1st Conf Server."
                                                               delegate: nil
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
            } else if ([labelNumber.text isEqualToString:@"*#564#"]) { // Log Management
                labelNumber.text = @"";
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                                message: @"Start Log"
                                                               delegate: self
                                                      cancelButtonTitle: @"Cancel"
                                                      otherButtonTitles: @"OK", nil];
                alert.tag = kTAGSetLog;
                [alert show];
                [alert release];
            } else if ([labelNumber.text isEqualToString:@"*#427#"]) { // iap
                labelNumber.text = @"";
                
                CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                NSMutableArray *products = [[[NSMutableArray alloc] init] autorelease];
                [products addObject:@"cloudtechcloudcalliosrate1"];
                [products addObject:@"cloudtechcloudcalliosrate2"];
                [products addObject:@"cloudtechcloudcalliosrate3"];
                [appDelegate SetIAPProductIds:products];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                                message: @"Get IAP product from local"
                                                               delegate: self
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: @"OK", nil];
                [alert show];
                [alert release];
            } else if ([labelNumber.text isEqualToString:@"*#68878866#"]) {
                labelNumber.text = @"";
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                                message: @"Output on"
                                                               delegate: self
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: @"OK", nil];
                [alert show];
                [alert release];
                
                OutputOn();
            } else if ([labelNumber.text isEqualToString:@"*#688788633#"]) {
                labelNumber.text = @"";
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                                message: @"Output off"
                                                               delegate: self
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: @"OK", nil];
                [alert show];
                [alert release];
                
                OutputOff();
            } else if ([labelNumber.text isEqualToString:@"*#7469255#"])
            {
                labelNumber.text = @"";
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                                message: @"Show all"
                                                               delegate: self
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: @"OK", nil];
                [alert show];
                [alert release];
                
                [[CloudCall2AppDelegate sharedInstance] setCurrentRelease];
            }
            [self onNumPadClickEvent];
            [self refreshDataAndReload];
            
			break;
		}
            
        case kTAGHideNumpad:
        {
            isShowNumpad = NO;
            [self isShowOrHideNumpad];
            break;
        }
            
		case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9:
		{
			labelNumber.text = [NSString stringWithFormat:@"%@%d", labelNumber.text?labelNumber.text:@"", tag];
			if(tag == 0){
				[self performSelector:@selector(onLongClick:) withObject:sender afterDelay:.5];
			}
            BOOL dten = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_DIAL_TONE_ENABLE];
            if (dten)
                [[NgnEngine sharedInstance].soundService playDtmf:tag];
            
            [self onNumPadClickEvent];
            [self refreshDataAndReload];
			
            break;
		}
	}
}

- (IBAction) onButtonNumpadUp: (id) sender event: (UIEvent*) e{
	if(((UIButton*)sender).tag == 0 || ((UIButton*)sender).tag == kTAGDelete){
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onLongClick:) object:sender];
	}
}

/**
 *	@brief	按钮长按事件
 *
 *	@param 	sender 	按钮
 */
- (void)onLongClick:(UIButton*)sender
{
	if(sender.tag == 0){
		if([labelNumber.text hasSuffix: @"0"]){
			labelNumber.text = [NSString stringWithFormat:@"%@+", [labelNumber.text substringToIndex: [labelNumber.text length] - 1]];
		}
	}
	if(sender.tag == kTAGDelete){
        NSString *number = labelNumber.text;
        if([number length] > 0){
            labelNumber.text = [number substringToIndex:([number length] - 1)];
            [self performSelector:@selector(onLongClick:) withObject:sender afterDelay:.01];
        }
        else
        {
        }
        [self onNumPadClickEvent];
        [self refreshDataAndReload];
	}
}

- (void)showOrHideDialWayIntroduce
{
    if ([contactArray count] == 0 && [mEvents count] == 0 && [self.labelNumber.text length] == 0 && !isShowNetWorkPromptFlag)
    {
        self.tableView.hidden = YES;

        UIScrollView *introduceView = (UIScrollView *)[self.view viewWithTag:10001];
        if (!introduceView)
        {
            UIScrollView *introduceView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, iPhone5?448:360)];
            introduceView.tag = 10001;
            introduceView.delegate = self;
            introduceView.scrollEnabled = YES;
            introduceView.contentSize = CGSizeMake(320, 950);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 950)];
            imageView.image = [UIImage imageNamed:@"dial_way_introduce"];
            [introduceView addSubview:imageView];
            [imageView release];
            [self.view insertSubview:introduceView belowSubview:self.tableView];
            [introduceView release];
        }

        self.btnClear.frame = CGRectMake(380, self.btnClear.frame.origin.y, self.btnClear.frame.size.width, self.btnClear.frame.size.height);
    }
    else
    {
        self.tableView.hidden = NO;

        UIScrollView *introduceView = (UIScrollView *)[self.view viewWithTag:10001];
        if (introduceView)
        {
            [introduceView removeFromSuperview];
            introduceView = nil;
        }
    }
}

/**
 *	@brief	是否显示拨号盘
 */
- (void)isShowOrHideNumpad
{
    if (isShowNumpad)
    {
        //显示拨号盘
        if (SystemVersion > 5.0)
            [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_numpad_down"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_numpad_normal"]];
        CGRect tempFrame = self.numpadView.frame;
        //[self.tabBarController.view addSubview:self.dialView];
        [UIView beginAnimations:@"EditMsgChildViewShowAndHide"context:nil];//动画开始
        [UIView setAnimationDuration:0.30];
        
        if (iPhone5) {
            tempFrame.origin.y = 161 + OriginYofiPhone5;
            if (SystemVersion >= 7.0)
            {
                tempFrame.origin.y = 161 + OriginYofiPhone5 + 20;
            }
            [self.dialView setFrame:CGRectMake(self.dialView.frame.origin.x, 431 + OriginYofiPhone5, self.dialView.frame.size.width, self.dialView.frame.size.height)];
        }
        else
        {
            tempFrame.origin.y = 161;
            if (SystemVersion >= 7.0)
            {
                tempFrame.origin.y = 161+ 20;
            }
            [self.dialView setFrame:CGRectMake(self.dialView.frame.origin.x, 431, self.dialView.frame.size.width, self.dialView.frame.size.height)];
        }
        if ([self.labelNumber.text length]) {
            //显示拨号按钮
            //隐藏广告等

//            [self.buttonAd setFrame:CGRectMake(0, -50, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height)];

            if ([CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_BAIDU  || [CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_91DIANJIN) {
                bdbanner.frame=CGRectMake(0, -100 , 320, 50);
            }
            
            if (SystemVersion >= 7.0)
            {
                [self.tableView setFrame:CGRectMake(0, 20, self.tableView.frame.size.width, self.tableView.frame.size.height)];
            }
            else
                [self.tableView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
            
            
            [self.tabBarController.view addSubview:self.dialView];
        }
        else
        {
            if (SystemVersion >= 7.0)
            {
                [self.tableView setFrame:CGRectMake(0, 70, self.tableView.frame.size.width, self.tableView.frame.size.height)];
            }
            else
                [self.tableView setFrame:CGRectMake(0, 50, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        }
        [self.numpadView setFrame:tempFrame];
        
        
        [UIView commitAnimations];
        
        self.btnClear.frame = CGRectMake(380, self.btnClear.frame.origin.y, self.btnClear.frame.size.width, self.btnClear.frame.size.height);
        
        isShowNumpad = YES;
    }
    else
    {
        //隐藏拨号盘
        if (SystemVersion > 5.0)
            [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_numpad_up"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_numpad_normal"]];
        
        CGRect tempFrame = self.numpadView.frame;
        tempFrame.origin.y = 245 + self.view.frame.size.height;
        [UIView beginAnimations:@"EditMsgChildViewShowAndHide"context:nil];//动画开始
        [UIView setAnimationDuration:0.30];
        
        if (![self.labelNumber.text length] && !self.tableView.hidden) {
            self.btnClear.frame = CGRectMake(250, self.btnClear.frame.origin.y, self.btnClear.frame.size.width, self.btnClear.frame.size.height);
        }
        
        //tabbar图标的更改
        [self.numpadView setFrame:tempFrame];
        
        [UIView commitAnimations];
        
        //显示广告等
        [self.buttonAd setFrame:CGRectMake(0, 0, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height)];
        if ([CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_BAIDU || [CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_91DIANJIN) {
            if (SystemVersion >= 7.0)
                bdbanner.frame = CGRectMake(0, 20, 320, 50);
            else
                bdbanner.frame=CGRectMake(0, 0, 320, 50);
        }

        if (SystemVersion >= 7.0)
        {
            [self.buttonAd setFrame:CGRectMake(0, 20, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height)];
            [self.tableView setFrame:CGRectMake(0, 70, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        }
        else
        {
            [self.buttonAd setFrame:CGRectMake(0, 0, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height)];
            [self.tableView setFrame:CGRectMake(0, 50, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        }
        
        
        
        isShowNumpad = NO;
        if ([self.labelNumber.text length]) {
            //隐藏拨号按钮
            [self.dialView removeFromSuperview];
        }
    }
}

- (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (value) [dict setObject:value forKey:@"value"];
	if (label) [dict setObject:(NSString *)label forKey:@"label"];
	return dict;
}

/**
 *	@brief	根据字母返回对应数字
 *
 *	@param 	aLetter 	字母
 *
 *	@return	对应数字
 */
- (NSString *)getNumerByLetter:(NSString *)aLetter
{
    if(NSOrderedSame == [aLetter caseInsensitiveCompare:@"a"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"b"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"c"])
    {
        return @"2";
    }
    else if(NSOrderedSame == [aLetter caseInsensitiveCompare:@"d"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"e"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"f"])
    {
        return @"3";
    }
    else if(NSOrderedSame == [aLetter caseInsensitiveCompare:@"g"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"h"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"i"])
    {
        return @"4";
    }
    else if(NSOrderedSame == [aLetter caseInsensitiveCompare:@"j"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"k"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"l"])
    {
        return @"5";
    }
    else if(NSOrderedSame == [aLetter caseInsensitiveCompare:@"m"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"n"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"o"])
    {
        return @"6";
    }
    else if(NSOrderedSame == [aLetter caseInsensitiveCompare:@"p"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"q"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"r"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"s"])
    {
        return @"7";
    }
    else if(NSOrderedSame == [aLetter caseInsensitiveCompare:@"t"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"u"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"v"])
    {
        return @"8";
    }
    else if(NSOrderedSame == [aLetter caseInsensitiveCompare:@"w"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"x"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"y"] || NSOrderedSame == [aLetter caseInsensitiveCompare:@"z"])
    {
        return @"9";
    }
    else
    {
        return @"1";
    }
}

/**
 *	@brief	获取号码归属地
 */
- (void)setAreaOfNumber
{
    if ([self.labelNumber.text length])
    {
        AreaOfPhoneNumber *areaOfPhoneNumber = [[AreaOfPhoneNumber alloc] initWithPhoneNumber:self.labelNumber.text];
        self.labelNumberArea.text = [areaOfPhoneNumber getAreaByPhoneNumber];
        [areaOfPhoneNumber release];
    }
    else
    {
        self.labelNumberArea.text = @"";
    }
}

/**
 *	@brief	键盘输入号码时显示的号码归属地以及是否显示拨打按钮
 */
- (void)onNumPadClickEvent
{
    [self setAreaOfNumber];
    if ([self.labelNumber.text length] && isShowNumpad)
    {
        
        //直接消失，不参与动画
        [self.buttonAd setFrame:CGRectMake(0, -50, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height)];
        
        [UIView beginAnimations:@"EditMsgChildViewShowAndHide"context:nil];//动画开始
        [UIView setAnimationDuration:0.30];
        //隐藏拨号按钮,显示广告等
        
        if ([CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_BAIDU ||
            [CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_91DIANJIN)
        {
            bdbanner.frame=CGRectMake(0, -100, 320, 50);
        }
        
        if (SystemVersion >= 7.0) {
            [self.tableView setFrame:CGRectMake(0, 20, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        }
        else
        {
            [self.tableView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        }
        
        if (iPhone5) {
            [self.dialView setFrame:CGRectMake(self.dialView.frame.origin.x, 431 + OriginYofiPhone5, self.dialView.frame.size.width, self.dialView.frame.size.height)];
        }
        else
        {
            [self.dialView setFrame:CGRectMake(self.dialView.frame.origin.x, 431, self.dialView.frame.size.width, self.dialView.frame.size.height)];
        }
        [self.tabBarController.view addSubview:self.dialView];
        
        [UIView commitAnimations];
    }
    else
    {
        
        [UIView beginAnimations:@"EditMsgChildViewShowAndHide"context:nil];//动画开始
        [UIView setAnimationDuration:0.30];
        //隐藏拨号按钮,显示广告等
        
        if ([CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_BAIDU ||
            [CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_91DIANJIN)
        {
            if (SystemVersion >= 7.0)
                bdbanner.frame=CGRectMake(0, 20, 320, 50);
            else
                bdbanner.frame=CGRectMake(0, 0, 320, 50);
        }
        
        if (SystemVersion >= 7.0)
        {
            [self.buttonAd setFrame:CGRectMake(0, 20, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height)];
            [self.tableView setFrame:CGRectMake(0, 70, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        }
        else
        {
            [self.buttonAd setFrame:CGRectMake(0, 0, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height)];
            [self.tableView setFrame:CGRectMake(0, 50, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        }
        [self.dialView removeFromSuperview];
        
        [UIView commitAnimations];
    }
}

- (IBAction)onBtnContactDetailClick:(id)sender
{
    
    if ([self.labelNumber.text length] <= 0)
    {
        UIButton *button = (UIButton *)sender;
        UITableViewCell *buttonCell = (UITableViewCell *)[button superview];
        NSUInteger butttonRow = [[self.tableView indexPathForCell:buttonCell] row];
        //NgnPhoneNumber* phoneNumber = [self.contact.phoneNumbers objectAtIndex:butttonRow];
        
        NgnHistoryEvent *historyEvent = nil;
        if (isShowNetWorkPromptFlag)
            historyEvent = [mEvents objectAtIndex: butttonRow - 1];
        else
            historyEvent = [mEvents objectAtIndex: butttonRow];
        
        NgnContact *contact = nil;
        contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:historyEvent.remoteParty];
        
        BOOL inContact = YES;
        if (!contact)
        {
            //该号码不在通讯录
            inContact = NO;
            CFStringRef phoneNumberLabelValue = ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel);
            NSMutableArray *phoneNumbers = [NSMutableArray arrayWithCapacity:2];
            NgnPhoneNumber* ngnPhoneNumber = [[[NgnPhoneNumber alloc] initWithNumber:historyEvent.remoteParty
                                                                                      andDescription:(NSString *)phoneNumberLabelValue
                                                                                             andType: NgnPhoneNumberType_Number] autorelease];
            [phoneNumbers addObject: ngnPhoneNumber];
            CFRelease(phoneNumberLabelValue);
            contact = [[[NgnContact alloc] initWithDisplayName:historyEvent.remoteParty andFirstName:@"" andLastName:@"" andPhoneNumbers:phoneNumbers andPicture:nil andDisplayMsg:nil andDisplayMsgRange:NSMakeRange(0, 0)] autorelease];
        }
        
        if(!contactDetailsController){
            contactDetailsController = [[ContactDetailsController alloc] initWithNibName: @"ContactDetails" bundle:nil];
        }
        [contactDetailsController setIsHideBtnEdit:YES];
        contactDetailsController.contact = contact;
        contactDetailsController.isInContact = inContact;
        contactDetailsController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController: contactDetailsController animated: YES];
    }
}



#pragma mark
#pragma mark view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
    
    isShowNumpad = YES;
    
    //检查网络状态
	mSipService = [[[NgnEngine sharedInstance] getSipService] retain];
//    if ([mSipService isRegistered])
        isShowNetWorkPromptFlag = NO;
//    else
//        isShowNetWorkPromptFlag = YES;
    
    calloption = [[NSMutableArray alloc] init];
    self.tabBarController.delegate = self;

    
    //调整拨号盘的高度
    CGRect tempFrame = self.numpadView.frame;
    if (iPhone5) {
        self.btnClear.frame = CGRectMake(self.btnClear.frame.origin.x, self.btnClear.frame.origin.y + OriginYofiPhone5, self.btnClear.frame.size.width, self.btnClear.frame.size.height);
        tempFrame.origin.y = 161 + OriginYofiPhone5;
        [self.dialView setFrame:CGRectMake(self.dialView.frame.origin.x, 431 + OriginYofiPhone5, self.dialView.frame.size.width, self.dialView.frame.size.height)];
    }
    else
    {
        tempFrame.origin.y = 161;
        [self.dialView setFrame:CGRectMake(self.dialView.frame.origin.x, 431, self.dialView.frame.size.width, self.dialView.frame.size.height)];
    }
    

    
    [self.numpadView setFrame:tempFrame];
    [self.numpadView setContentMode:UIViewContentModeScaleToFill];

    [self.numpadView setImage:[UIImage imageNamed:@"new_numpad_bg.png"]];
    [self.dialView setImage:[UIImage imageNamed:@"tab_dialpad_bg.png"]];

    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image=[UIImage imageNamed:@"toolbar_bg.png"];
    [imageview release];
    
    //中英文适配
    self.keypad_dial.titleLabel.text = [NSString stringWithFormat:@"%@%@",@"    ",NSLocalizedString(@"Start AudioC all", @"Start AudioC all")];
    
    self.labelNumber.placeholder = NSLocalizedString(@"Search by number or letters", @"Search by number or letters");
    self.labelNumber.delegate = self;

    self.lblContact.text = NSLocalizedString(@"Contacts", @"Contacts");
    
	if (!contactArray) {
        contactArray = [[NgnContactMutableArray alloc] initWithCapacity:10];
    }
    
	if(!mEvents){
		mEvents = [[NgnHistoryEventMutableArray alloc] init];
	}
	mStatusFilter = HistoryEventStatus_All;
	
	// get contact service instance
	mContactService = [[NgnEngine sharedInstance].contactService retain];
	mHistoryService = [[NgnEngine sharedInstance].historyService retain];
	
	// refresh data
    [self refreshData];
	
	tableView.delegate = self;
	tableView.dataSource = self;
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHistoryEvent:) name:kNgnHistoryEventArgs_Name object:nil];
    
    //iOS7适配
    if (SystemVersion >= 7.0)
    {
        self.buttonAd.frame = CGRectMake(self.buttonAd.frame.origin.x, self.buttonAd.frame.origin.y + 20, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height);
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + 20, self.tableView.frame.size.width, self.tableView.frame.size.height-(50+20));
        self.btnClear.frame = CGRectMake(self.btnClear.frame.origin.x, self.btnClear.frame.origin.y + 20, self.btnClear.frame.size.width, self.btnClear.frame.size.height);
        self.numpadView.frame = CGRectMake(self.numpadView.frame.origin.x, self.numpadView.frame.origin.y + 20, self.numpadView.frame.size.width, self.numpadView.frame.size.height);
        self.dialView.frame = CGRectMake(self.dialView.frame.origin.x, self.dialView.frame.origin.y + 20, self.dialView.frame.size.width, self.dialView.frame.size.height);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[CloudCall2AppDelegate sharedInstance] viewChanged:self];
    if (isShowNumpad && [self.labelNumber.text length]) {
        //显示拨号按钮
        if (iPhone5) {
            [self.dialView setFrame:CGRectMake(self.dialView.frame.origin.x, 431 + OriginYofiPhone5, self.dialView.frame.size.width, self.dialView.frame.size.height)];
        }
        else
        {
            [self.dialView setFrame:CGRectMake(self.dialView.frame.origin.x, 431, self.dialView.frame.size.width, self.dialView.frame.size.height)];
        }
        [self.tabBarController.view addSubview:self.dialView];
        
    }
    //设置inputView为CGRectZero，点击texfield不会弹出键盘
    UIView *view = [[UIView alloc] init];
    view.bounds = CGRectZero;
    self.labelNumber.inputView = view;
    [view release];
    
    //清除未接来电的Badge
    [UIApplication sharedApplication].applicationIconBadgeNumber -= [CloudCall2AppDelegate sharedInstance].missedCalls;
    [CloudCall2AppDelegate sharedInstance].missedCalls = 0;
    
    [MobClick beginLogPageView:@"Numpad_Recents"];
	[self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear: animated];
    
    [self layoutForCurrentOrientation:NO];
}   

- (void)viewWillDisappear:(BOOL)animate{
	[super viewWillDisappear: animate];
    [MobClick endLogPageView:@"Numpad_Recents"];
	[self.navigationController setNavigationBarHidden: NO];
    
    //隐藏拨号盘
    if (SystemVersion > 5.0)
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_numpad_up"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_numpad_normal"]];
    CGRect tempFrame = self.numpadView.frame;
    tempFrame.origin.y = 245 + self.view.frame.size.height;
    //tabbar图标的更改
    [self.numpadView setFrame:tempFrame];
    //显示广告等
    [self.buttonAd setFrame:CGRectMake(0, 0, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height)];
    if ([CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_BAIDU || [CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_91DIANJIN) {
        if (SystemVersion >= 7.0)
            bdbanner.frame=CGRectMake(0, 20, 320, 50);
        else
            bdbanner.frame=CGRectMake(0, 0, 320, 50);
    }
    if (SystemVersion >= 7.0)
    {
        [self.buttonAd setFrame:CGRectMake(0, 20, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height)];
        [self.tableView setFrame:CGRectMake(0, 70, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    }
    else
    {
        [self.buttonAd setFrame:CGRectMake(0, 0, self.buttonAd.frame.size.width, self.buttonAd.frame.size.height)];
        [self.tableView setFrame:CGRectMake(0, 50, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    }
    [self.dialView removeFromSuperview];
    isShowNumpad = NO;

}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[mEvents release], mEvents = nil;
	[mContactService release];
	[mHistoryService release];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    CCLog(@"RecentsView didReceiveMemoryWarning");
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
    if (mSipService) {
        [mSipService release];
    }
    [tableView release];
    [btnClear release];
    [numpadView release];
    [dialView release];
    [labelNumber release];
    [labelNumberArea release];
    [delNum release];
    [keypad_0 release];
    [keypad_1 release];
    [keypad_2 release];
    [keypad_3 release];
    [keypad_4 release];
    [keypad_5 release];
    [keypad_6 release];
    [keypad_7 release];
    [keypad_8 release];
    [keypad_9 release];
    [keypad_sharp release];
    [keypad_del release];
    [keypad_dial release];
    [keypad_star release];
    [toContact release];
    [lblContact release];
    if (lastnumber) {
        [lastnumber release];
    }
    
    [myNewContactDelegate release];
    [buttonAd release];
    
    [calloption release];
    
    if (contactArray) {
        [contactArray release];
        contactArray = nil;
    }
    if (contactDetailsController) {
        [contactDetailsController release];
        contactDetailsController = nil;
    }

    [super dealloc];
}

#pragma mark
#pragma mark UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) // Cancel - Do Nothing
        return;
    
    if (buttonIndex == 1) { // OK
        switch (alertView.tag) {
            case kTagAlertCallOutViaCellPhone:
            {
                NSString* dialurl = [@"tel://" stringByAppendingString:dialNum];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialurl]];
                break;
            }
            case kTAGSetLog:
            {
                CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                [appDelegate StartLog];
                break;
            }
        }
    }
}

#pragma mark - textFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length];
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    //判断输入的释放数字
    if ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0 || [string isEqualToString:@""]) {
//        labelNumber.text = [labelNumber.text stringByAppendingString:[string phoneNumFormat]];
    
        if (![string haveChSymbol] ) {
            if (iPhone5) {
                [self.dialView setFrame:CGRectMake(self.dialView.frame.origin.x, 431 + OriginYofiPhone5, self.dialView.frame.size.width, self.dialView.frame.size.height)];
            }
            else
            {
                [self.dialView setFrame:CGRectMake(self.dialView.frame.origin.x, 431, self.dialView.frame.size.width, self.dialView.frame.size.height)];
            }
            
            [self.tabBarController.view addSubview:self.dialView];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:@"请输入数字"
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return NO;
        }
        
        return YES;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message:@"请输入数字"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return NO;
    }
    return nil;
}


#pragma mark
#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != actionSheet.cancelButtonIndex && ![CloudCall2AppDelegate sharedInstance].incomingCall){
		switch (actionSheet.tag) {
			case kTagActionSheetClear:
            {
                [mHistoryService deleteEvents: MediaType_AudioVideo];
                [self refreshAndReloadData];
                // will be notified by the history service
                break;
            }
            
            case kTagActionSheetCallOut:
            {
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

                if (videocallout) {
                    [CallViewController makeAudioVideoCallWithRemoteParty:dialNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] andCalloutMode:mode];
                } else {
                    isShowNumpad = NO;
                    self.labelNumber.text = @"";
                    [self isShowOrHideNumpad];
                    [CallViewController makeAudioCallWithRemoteParty:dialNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] andCalloutMode:mode];
                    self.labelNumber.text = @"";
                    self.labelNumberArea.text = @"";
                }
                
                break;
            }
                
            case kTagActionSheetAddContact: {
                if (buttonIndex == 1) {
                    // do nothing
                    return;
                }
                ABNewPersonViewController *view = [[ABNewPersonViewController alloc] init];
                
                ////////////////////////////////////
                ABRecordRef newPerson = ABPersonCreate();
//                ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
                CFErrorRef error = NULL;
                ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                ABMultiValueAddValueAndLabel(multiValue, self.labelNumber.text, kABPersonPhoneMobileLabel, NULL);
                ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiValue , &error);
                NSAssert(!error, @"Something bad happened here.");
                view.displayedPerson = newPerson;
                ////////////////////////////////////
                
                if (!myNewContactDelegate)
                    myNewContactDelegate = [[NewContactDelegate alloc] init];
                [view setNewPersonViewDelegate:myNewContactDelegate];
                [self.navigationController setNavigationBarHidden:NO];

                view.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:view animated:YES];
                [view release];
                CFRelease(multiValue);
                CFRelease(newPerson);
                break;
            }
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
#pragma mark UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self showOrHideDialWayIntroduce];

    if ([self.labelNumber.text length]) {
        @synchronized(contactArray){
            if ([contactArray count] == 0)
                if (isShowNetWorkPromptFlag)
                    return 2;
                else
                    return 1;
            else
                if (isShowNetWorkPromptFlag)
                    return [contactArray count] + 1;
                else
                    return [contactArray count];
        }
    }
    else
    {
        @synchronized(mEvents){
            if (isShowNetWorkPromptFlag)
                return [mEvents count] + 1;
            else
                return [mEvents count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//网络异常Cell
    if (isShowNetWorkPromptFlag && indexPath.row == 0)
    {
        static NSString *networkExcCellIdentifier = @"networkExcCellIdentifier";
        NetWorkExcCell *networkExcCell = (NetWorkExcCell*)[_tableView dequeueReusableCellWithIdentifier: networkExcCellIdentifier];
        if (networkExcCell == nil) {
            networkExcCell = [[[NSBundle mainBundle] loadNibNamed:@"NetworkExcCell" owner:self options:nil] lastObject];
        }
        NSString *networkMsg;
        
        if (isConnecting) {
            networkMsg = NSLocalizedString(@"Connecting...", @"Connecting...");
        }
        else
        {
            networkMsg = NSLocalizedString(@"Network is unreachable", @"Network is unreachable");
        }
        isConnecting = NO;
        
        [networkExcCell setNetworkExcCell:networkMsg];
        
        UIButton *btnNetwortExcDetail = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNetwortExcDetail.frame = CGRectMake(0, 0, 51, 20);
        [btnNetwortExcDetail setBackgroundImage:[UIImage imageNamed:@"btn_viewnetworkexc_detail.png"] forState:UIControlStateNormal];
        [btnNetwortExcDetail setBackgroundImage:[UIImage imageNamed:@"btn_viewnetworkexc_detail.png"] forState:UIControlStateHighlighted];
        [btnNetwortExcDetail setTitle:NSLocalizedString(@"Details", @"Details") forState:UIControlStateNormal];
        btnNetwortExcDetail.titleLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        [btnNetwortExcDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnNetwortExcDetail.tag = kTAGViewNewworkExcDetail;
        [btnNetwortExcDetail addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        networkExcCell.accessoryView = btnNetwortExcDetail;
            
        return networkExcCell;
    }
    
    //拨号盘查找Cell
    if ([self.labelNumber.text length]) {
        NewContactViewCell *cell = (NewContactViewCell *)[_tableView dequeueReusableCellWithIdentifier: kNewContactViewCellIdentifier];
        if (cell == nil) {
            //cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactViewCell" owner:self options:nil] lastObject];
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewContactViewCell" owner:self options:nil];
            for(id oneObject in nib){
                if([oneObject isKindOfClass:[NewContactViewCell class]]){
                    cell = (NewContactViewCell *)oneObject;
                }
            }
            
        }
        @synchronized(contactArray){
            if ([contactArray count] == 0)
            {
                static NSString *addContactCellIdentifier = @"addContactCellIdentifier";
                UITableViewCell *addContactCell = [tableView dequeueReusableCellWithIdentifier:addContactCellIdentifier];
                if (addContactCell == nil) {
                    addContactCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addContactCellIdentifier] autorelease];
                    addContactCell.textLabel.text = NSLocalizedString(@"Add Contact", @"Add Contact");
                    addContactCell.textLabel.font = [UIFont systemFontOfSize:16.0f];
                    addContactCell.textLabel.textAlignment = NSTextAlignmentCenter;
                }
                return addContactCell;
            }
            else
            {
                NgnContact* contact;
                if (isShowNetWorkPromptFlag)
                    contact = [contactArray objectAtIndex: indexPath.row - 1];
                else
                    contact = [contactArray objectAtIndex: indexPath.row];
                if (contact) {
                    [cell setDisplayName:contact.displayName andRange:contact.displayNameRange];
                    cell.contact = contact;
                    cell.navigationController = self.navigationController;
                    //[contact InitDisplayAreaInfo];
                    [cell setDisplayMsg:contact.displayMsg andRange:contact.displayMsgRange];
                }
                cell.accessoryType = UITableViewCellAccessoryDetailButton;
                
                return cell;
            }
        }
        
    }
    else    //通话记录Cell
    {
        RecentCell *cell = (RecentCell*)[_tableView dequeueReusableCellWithIdentifier: kRecentCellIdentifier];
        if (cell == nil) {		
            cell = [[[NSBundle mainBundle] loadNibNamed:@"RecentCell" owner:self options:nil] lastObject];
        }
        
        @synchronized(mEvents){
            if (isShowNetWorkPromptFlag)
                [cell setEvent:[mEvents objectAtIndex: indexPath.row - 1]];
            else
                [cell setEvent:[mEvents objectAtIndex: indexPath.row]];
        }
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        
        return cell;
    }
}

#pragma mark
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    if (isShowNetWorkPromptFlag && indexPath.row == 0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        NSString *currentLanguage = [languages objectAtIndex:0];
        
        //本地化
        NSString *path;
        if (![currentLanguage isEqualToString:@"zh-Hans"]) {
            path = [[NSBundle mainBundle] pathForResource:@"networkexc_en.html" ofType:nil];
        }
        else
        {
            path = [[NSBundle mainBundle] pathForResource:@"networkexc_cn.html" ofType:nil];
        }
        NSURL *url = [NSURL URLWithString:path];
        WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:url];
        webBrowser.mode = TSMiniWebBrowserModeNavigation;
        webBrowser.type = TSMiniWebBrowserTypeNetworkExc;
        
        [webBrowser setFixedTitleBarText:NSLocalizedString(@"Network is unreachable",@"Network is unreachable")];
        webBrowser.barStyle = UIStatusBarStyleDefault;
        webBrowser.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webBrowser animated:YES];
        
        [webBrowser release];
    }
    else if ([self.labelNumber.text length])
    {
        @synchronized(contactArray)
        {
            if ([contactArray count] == 0)
            {
                if ([labelNumber.text length]) {
                    ABNewPersonViewController *view = [[ABNewPersonViewController alloc] init];
                    
                    ////////////////////////////////////
                    ABRecordRef newPerson = ABPersonCreate();
                    CFErrorRef error = NULL;
                    ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                    ABMultiValueAddValueAndLabel(multiValue, self.labelNumber.text, kABPersonPhoneMobileLabel, NULL);
                    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiValue , &error);
                    NSAssert(!error, @"Something bad happened here.");
                    view.displayedPerson = newPerson;
                    ////////////////////////////////////
                    
                    if (!myNewContactDelegate)
                        myNewContactDelegate = [[NewContactDelegate alloc] init];
                    [view setNewPersonViewDelegate:myNewContactDelegate];
                    [self.navigationController setNavigationBarHidden:NO];

                    view.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:view animated:YES];
                    [view release];
                    CFRelease(multiValue);
                    CFRelease(newPerson);
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:NSLocalizedString(@"Please input the phone number first", @"Please input the phone number first")
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                    [alert show];
                    [alert release];
                }
            }
            else
            {
                NgnContact *contact;
                if (isShowNetWorkPromptFlag)
                    contact = [contactArray objectAtIndex:indexPath.row - 1];
                else
                    contact = [contactArray objectAtIndex:indexPath.row];
                
                if (![contact.displayMsg isMatchedByRegex:@"[0-9]"] && [contact.phoneNumbers count] != 1) {
                    if(!contactDetailsController){
                        contactDetailsController = [[ContactDetailsController alloc] initWithNibName: @"ContactDetails" bundle:nil];
                    }
                    [contactDetailsController setIsHideBtnEdit:YES];
                    contactDetailsController.contact = contact;
                    contactDetailsController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController: contactDetailsController animated: YES];
                }
                else
                {
                    NSString *dialNumber = contact.displayMsg;
                    if ([contact.phoneNumbers count] == 1) {
                        NgnPhoneNumber *aPhoneNumber = [contact.phoneNumbers objectAtIndex:0];
                        dialNumber = [NSString stringWithString:[aPhoneNumber.number phoneNumFormat]];
                    }
                    
                    if ([[NgnEngine sharedInstance].sipService isRegistered]) {
                        if(dialNumber && [dialNumber length])
                        {
                            //不能拨打本机号码
                            NSString *selfNumber = [[CloudCall2AppDelegate sharedInstance] getUserName];
                            
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
                            
                            isExist = YES;
                            [self showCallOptView:dialNumber andVideoCall:NO];
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
            }
        }
    }
    else
    {
        isShowNumpad = NO;
        [self isShowOrHideNumpad];
        @synchronized(mEvents){
            NgnHistoryEvent* event;
            if (isShowNetWorkPromptFlag)
                event = [mEvents objectAtIndex: indexPath.row - 1];
            else
                event = [mEvents objectAtIndex: indexPath.row];
            
            if (event && (event.mediaType == MediaType_Audio || event.mediaType == MediaType_Video) && [[NgnEngine sharedInstance].sipService isRegistered])
            {
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
                
                NSString *dialNumber = [NSString stringWithString:event.remoteParty];
                
                //不能拨打本机号码
                NSString *selfNumber = [[CloudCall2AppDelegate sharedInstance] getUserName];
                
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
                
                isExist = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:dialNumber] != nil;
                [self showCallOptView:dialNumber andVideoCall:NO];
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
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)_tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.labelNumber.text length] || (isShowNetWorkPromptFlag && indexPath.row == 0))
        return UITableViewCellEditingStyleNone;
    else
        return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete && [self.labelNumber.text length] == 0)
    {
		NgnHistoryEvent *event;
        if (isShowNetWorkPromptFlag) {
            event = [mEvents objectAtIndex: indexPath.row - 1];
        }
        else
        {
            event = [mEvents objectAtIndex: indexPath.row];
        }
        
        if (event) {
			[[NgnEngine sharedInstance].historyService deleteEvent: event];
            [self showOrHideDialWayIntroduce];
		}
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if ([self.labelNumber.text length]) {
        @synchronized(contactArray){
            NgnContact* contact;
            
            if (isShowNetWorkPromptFlag)
                contact = [contactArray objectAtIndex: indexPath.row - 1];
            else
                contact = [contactArray objectAtIndex: indexPath.row];
            
            if(contact && contact.displayName){
                if(!contactDetailsController){
                    contactDetailsController = [[ContactDetailsController alloc] initWithNibName: @"ContactDetails" bundle:nil];
                }
                [contactDetailsController setIsHideBtnEdit:YES];
                contactDetailsController.contact = contact;
                contactDetailsController.isInContact = YES;
                contactDetailsController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController: contactDetailsController animated: YES];
            }
        }
    }
    else
    {
        NgnHistoryEvent *historyEvent = nil;
        if (isShowNetWorkPromptFlag)
            historyEvent = [mEvents objectAtIndex: indexPath.row - 1];
        else
            historyEvent = [mEvents objectAtIndex: indexPath.row];
        
        NgnContact *contact = nil;
        contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:historyEvent.remoteParty];
        
        BOOL inContact = YES;
        if (!contact)
        {
            //该号码不在通讯录
            inContact = NO;
            CFStringRef phoneNumberLabelValue = ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel);
            NSMutableArray *phoneNumbers = [NSMutableArray arrayWithCapacity:2];
            NgnPhoneNumber* ngnPhoneNumber = [[[NgnPhoneNumber alloc] initWithNumber:historyEvent.remoteParty
                                                                     andDescription:(NSString *)phoneNumberLabelValue
                                                                            andType: NgnPhoneNumberType_Number] autorelease];
            [phoneNumbers addObject: ngnPhoneNumber];
            CFRelease(phoneNumberLabelValue);
            
            contact = [[[NgnContact alloc] initWithDisplayName:historyEvent.remoteParty andFirstName:@"" andLastName:@"" andPhoneNumbers:phoneNumbers andPicture:nil andDisplayMsg:nil andDisplayMsgRange:NSMakeRange(0, 0)] autorelease];
        }
        
        if(!contactDetailsController){
            contactDetailsController = [[ContactDetailsController alloc] initWithNibName: @"ContactDetails" bundle:nil];
        }
        [contactDetailsController setIsHideBtnEdit:YES];
        contactDetailsController.contact = contact;
        contactDetailsController.isInContact = inContact;
        contactDetailsController.isHightLight = YES;
        contactDetailsController.hightNumber = historyEvent.remoteParty;
        contactDetailsController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController: contactDetailsController animated: YES];
    }
}

#pragma mark
#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isShowNumpad = NO;
    [self isShowOrHideNumpad];
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

#pragma mark
#pragma mark BannerViewContainer
- (void)showBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
//    if (nil == bannerView && (type != AD_TYPE_BAIDU || type != AD_TYPE_91DIANJIN)) {
//        return;
//    }
    
    if (type == AD_TYPE_IAD) {
        iadbanner = (ADBannerView*)bannerView;        
        [self.view addSubview:iadbanner];
        [self layoutForCurrentOrientation:animated];
    } else if (type == AD_TYPE_LIMEI) {
        lmbanner = (immobView*)bannerView;
        [self.view addSubview:lmbanner];
    } else if (type == AD_TYPE_BAIDU || type == AD_TYPE_91DIANJIN){
        bdbanner = (BaiduMobAdView *)bannerView;
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

#pragma mark
#pragma mark tabBar delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 0) {
        if (isShowNumpad) {
            isShowNumpad = NO;
        }
        else
        {
            isShowNumpad = YES;
        }
        
        [self isShowOrHideNumpad];
    }
    else
    {
        isShowNumpad = NO;
        [self isShowOrHideNumpad];
    }
}



@end
