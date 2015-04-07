/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "OldNumpadViewController.h"
#import "CallViewController.h"

#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"
#import "AderSDK.h"
#import "AderDelegateProtocal.h"

#import "NewContactDelegate.h"

#import "MobClick.h"

#define kTAGStar		10
#define kTAGPound		11
#define kTAGAudioCall	12
#define kTAGDelete		13
#define kTAGMessages	14
#define kTAGVideoCall	15

#define kTagActionSheetCallOut    101
#define kTagActionSheetAddContact 102

#define kTAGSetLog	200

#define NOT_CHECK_IS_WEICALL_USER


@interface OldNumpadViewController(Private)
- (void) updateStatus;
// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
- (void)layoutForCurrentOrientation:(BOOL)animated;
- (void)showInviteMessageView:(NSString*) phonenum;
@end

@interface OldNumpadViewController(SipCallbacks)
-(void) onRegistrationEvent:(NSNotification*)notification;
-(void) onMessagingEvent:(NSNotification*)notification;
-(void) onLongClick:(UIButton*)sender;
-(void) onHistoryEvent:(NSNotification*)notification;
-(void) onSoundServiceEvent:(NSNotification*)notification;
-(void) GotoWebSite;
@end

@implementation OldNumpadViewController(Private)

-(void) updateStatus{
	if ([mSipService isRegistered]) {
		//viewStatus.backgroundColor = [UIColor colorWithRed:.33 green:1 blue:1 alpha:1];
        self.labelStatus.text = NSLocalizedString(@"WeiCall Online", @"WeiCall Online");//@"WeiCall已连接";

        [imageStatus setImage:[UIImage imageNamed:@"status_online"]];        
	} else {
		//viewStatus.backgroundColor = [UIColor grayColor];
//        if ([mSipService getRegistrationState] == CONN_STATE_CONNECTING)
//            self.labelStatus.text = NSLocalizedString(@"Connecting", @"Connecting");
//        else
        self.labelStatus.text = NSLocalizedString(@"WeiCall Offline", @"WeiCall Offline");//@"WeiCall未连接";
        [imageStatus setImage:[UIImage imageNamed:@"status_offline"]];
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
    } else if (djbanner) {        
        [UIView animateWithDuration:animationDuration
                         animations:^{                         
                             djbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, djbanner.frame.size.width, djbanner.frame.size.height);
                         }];
    }
    else if (lmbanner) {        
        [UIView animateWithDuration:animationDuration
                         animations:^{                         
                             lmbanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, lmbanner.frame.size.width, lmbanner.frame.size.height);
                         }];
    }
}

- (void)showInviteMessageView:(NSString*) phonenum
{
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init]; //autorelease];
        controller.recipients = [NSArray arrayWithObject:phonenum];
        controller.body = NSLocalizedString(@"Invite Message Content", @"Invite Message Content");
        controller.messageComposeDelegate = self;
        
        [self presentModalViewController:controller animated:YES];
        //        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"SomethingElse"];//修改短信界面标题
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

@implementation OldNumpadViewController(SipCallbacks)

//== REGISTER events == //
-(void) onRegistrationEvent:(NSNotification*)notification {
	NgnRegistrationEventArgs* eargs = [notification object];
	CCLog(@"NumpadView: Reg notify: %d, %d, %@", eargs.eventType, eargs.sipCode, eargs.sipPhrase ? eargs.sipPhrase : @"");

	switch (eargs.eventType) {
			// provisional responses
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_INPROGRESS:
			[activityIndicator startAnimating];
			break;
			// final responses
		case REGISTRATION_OK:
            [activityIndicator stopAnimating];
            break;
        case REGISTRATION_NOK: {
            [activityIndicator stopAnimating];
            break;
        }
		case UNREGISTRATION_OK:
		case UNREGISTRATION_NOK:
		default:
			[activityIndicator stopAnimating];
			break;
	}
	[self updateStatus];
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
                    if ([[contentType lowercaseString] hasPrefix:@"text/userright"]) {
                        if (lastMsgCallId && [lastMsgCallId isEqualToString: eargs.callId]) {
                            CCLog(@"Incoming message: Error -- the same call-id as the last received %@", eargs.callId);
                            break;
                        }
                        if (lastMsgCallId) {
                            [lastMsgCallId release];
                            lastMsgCallId = nil;
                        }
                        lastMsgCallId = [eargs.callId retain];
                        
                        NSString *strContent = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
                        CCLog(@"strContent: %@", strContent);
                        
                        int userLevel = 0;
                        BOOL conferenceEnable = NO;
                        int maxconfmembers = 0;
                        
                        /*
                         服务器->客户端消息格式：
                         Content-Type:text/userright
                            userlevel:整数        //用户等级，数值越大等级越高；默认为0，大于0则显示VIP用户标识
                            conference:enable/disable  //会议权限
                            confmember:会议成员数量  //根据用户等级依次增加,取值 0,5,7,10
                        */                        
                        NSString* strTmp = [strContent stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                        NSArray *array = [strTmp componentsSeparatedByString:@"\n"];
                        CCLog(@"array:%@",array);
                        for (NSString* str in array) {
                            CCLog(@"item:%@", str);
                            NSString* item = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            if (!item || [item length] == 0)
                                continue;
                            NSArray *as = [item componentsSeparatedByString:@":"];
                            if (as && as.count == 2) {
                                NSString* strparameter = [as objectAtIndex:0];
                                NSString* strvalue     = [as objectAtIndex:1];
                                
                                strparameter = [strparameter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                strvalue     = [strvalue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                
                                CCLog(@"p=%@, v=%@\n", strparameter, strvalue);
                                if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"userlevel"]) {
                                    userLevel = [strvalue intValue];
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"conference"]) {                                    
                                    if (NSOrderedSame == [strvalue caseInsensitiveCompare:@"enable"]) {                                        
                                        conferenceEnable = YES;
                                    }
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"confmember"]) {
                                    maxconfmembers = [strvalue intValue];
                                }
                            }
                        }
                        
                        if (0 == userLevel) {
                            [imageVIP setHidden:YES];
                        } else {
                            [imageVIP setHidden:NO];
                            [imageVIP setImage:[UIImage imageNamed:[NSString stringWithFormat:@"vip%d.png", userLevel]]];                            
                        }
                        [[NgnEngine sharedInstance].configurationService setIntWithKey:ACCOUNT_LEVEL andValue:userLevel];
                        CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                        appDelegate.maxconfmembers = maxconfmembers;
                        
                        [buttonConference setHidden:(conferenceEnable == NO)];
                        
                        [strContent release];
                    }
                    else if ([[contentType lowercaseString] hasPrefix:@"text/adclick"])
                    {
                        if ([[CloudCall2AppDelegate sharedInstance] adType] == AD_TYPE_91DIANJIN)
                        {
                            if ([lastMsgCallId isEqualToString: eargs.callId]) {
                                CCLog(@"Incoming message: Error -- the same call-id as the last received %@", eargs.callId);
                                break;
                            }
                            if (lastMsgCallId) {
                                [lastMsgCallId release];
                                lastMsgCallId = nil;
                            }
                            lastMsgCallId = [eargs.callId retain];
                            
                            NSString *strContent = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
                            CCLog(@"strContent: %@", strContent);
                            
                            /*
                             advertiser:客户端发过来的advertiser
                             admtype: 客户端发过来的admtype,暂时不用，留空。
                             rechargemoney:
                             remainmoney:
                             errorcode: //0 – 成功；401 – 失败
                             */
                            int recharge = 0;
                            int balance = 0;
                            int errorcode = 0;
                            
                            NSString* strTmp = [strContent stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                            NSArray *array = [strTmp componentsSeparatedByString:@"\n"];
                            CCLog(@"array:%@",array);
                            for (NSString* str in array) {
                                CCLog(@"item:%@", str);
                                NSString* item = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                if (!item || [item length] == 0)
                                    continue;
                                NSArray *as = [item componentsSeparatedByString:@":"];
                                if (as && as.count == 2) {
                                    NSString* strparameter = [as objectAtIndex:0];
                                    NSString* strvalue     = [as objectAtIndex:1];
                                    strparameter = [strparameter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                    strvalue     = [strvalue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                    
                                    CCLog(@"p=%@, v=%@\n", strparameter, strvalue);
                                    if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"rechargemoney"]) {
                                        recharge = [strvalue intValue];
                                    } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"remainmoney"]) {
                                        balance = [strvalue intValue];
                                    } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"errorcode"]) {
                                        errorcode = [strvalue intValue];
                                    }
                                }
                            }
                            
                            NSMutableString* strbalance = nil;
                            if (errorcode == 0) { // succ
                                strbalance = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"Got %d CloudCall points, your balance is %d CloudCall points.", @"Got %d CloudCall points, your balance is %d CloudCall points."), recharge, balance];
                            } else if (errorcode == 401) { // fail
                                ;// do nothing
                            }
                            

                                UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CloudCall", @"CloudCall")
                                                                            message: strbalance
                                                                           delegate: self
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                                [a show];
                                [a release];
                            
                            
                            [strbalance release];
                            
                            [strContent release];
                            break;
                        }
                    }
                    else if ([[contentType lowercaseString] hasPrefix:@"text/balance"]) {
                        if ([lastMsgCallId isEqualToString: eargs.callId]) {
                            CCLog(@"Incoming message: Error -- the same call-id as the last received %@", eargs.callId);
                            break;
                        }
                        if (lastMsgCallId) {
                            [lastMsgCallId release];
                            lastMsgCallId = nil;
                        }
                        lastMsgCallId = [eargs.callId retain];                        
                        
                        NSString *strContent = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
                        CCLog(@"strContent: %@", strContent);
                        
                        int userLevel = 0;
                        BOOL conferenceEnable = NO;
                        int maxconfmembers = 0;                        
                        
                        NSString* strTmp = [strContent stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                        NSArray *array = [strTmp componentsSeparatedByString:@"\n"];
                        CCLog(@"array:%@",array);
                        for (NSString* str in array) {
                            CCLog(@"item:%@", str);
                            NSString* item = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            if (!item || [item length] == 0)
                                continue;
                            NSArray *as = [item componentsSeparatedByString:@":"];
                            if (as && as.count == 2) {
                                NSString* strparameter = [as objectAtIndex:0];
                                NSString* strvalue     = [as objectAtIndex:1];
                                strparameter = [strparameter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                strvalue     = [strvalue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                
                                CCLog(@"p=%@, v=%@\n", strparameter, strvalue);
                                if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"userlevel"]) {
                                    userLevel = [strvalue intValue];
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"conference"]) {
                                    if (NSOrderedSame == [strvalue caseInsensitiveCompare:@"enable"]) {
                                        conferenceEnable = YES;
                                    }
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"confmember"]) {
                                    maxconfmembers = [strvalue intValue];
                                }
                            }
                        }
                        
                        if (0 == userLevel) {
                            [imageVIP setHidden:YES];
                        } else {
                            [imageVIP setHidden:NO];
                            [imageVIP setImage:[UIImage imageNamed:[NSString stringWithFormat:@"vip%d.png", userLevel]]];
                        }
                        [[NgnEngine sharedInstance].configurationService setIntWithKey:ACCOUNT_LEVEL andValue:userLevel];
                        CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                        appDelegate.maxconfmembers = maxconfmembers;
                        
                        [buttonConference setHidden:(conferenceEnable == NO)];
                        
                        [strContent release];
                        
                        break;
                    }
                }
			}
			break;
		}
	}
#endif
}

-(void) onLongClick:(UIButton*)sender{
	if(sender.tag == 0){
		if([labelNumber.text hasSuffix: @"0"]){
			labelNumber.text = [NSString stringWithFormat:@"%@+", [labelNumber.text substringToIndex: [labelNumber.text length]-1]];
		}
	}
	if(sender.tag == kTAGDelete){
        NSString* number = labelNumber.text;
        if([number length] >0){
            labelNumber.text = [number substringToIndex:([number length]-1)];
            [self performSelector:@selector(onLongClick:) withObject:sender afterDelay:.2];
        }
	}
}

-(void) onHistoryEvent:(NSNotification*)notification{
	NgnHistoryEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case HISTORY_EVENT_ITEM_ADDED:
		{
			if((eargs.mediaType & MediaType_AudioVideo)){
				NgnHistoryEvent* event = [[mHistoryService events] objectForKey: [NSNumber numberWithLongLong: eargs.eventId]];
				if (event) {
                    [lastnumber release];
                    lastnumber = [event.remoteParty retain];
                    lastcalloutmode = event.calloutmode;
				}
			}
			break;
		}
            
		default:
		{
            
			break;
		}
	}
}

-(void) onSoundServiceEvent:(NSNotification*)notification{
	NgnSoundServiceEventArgs* eargs = [notification object];
	//CCLog(@"Numpad onSoundServiceEvent %d", eargs.eventType);
	switch (eargs.eventType) {
		case SOUND_SERVICE_EVENT_AUDIO_ROUTE_SPEAKER:
        case SOUND_SERVICE_EVENT_AUDIO_ROUTE_RECEIVER:
            if (showing && ![CloudCall2AppDelegate runInBackground]) {
                [[NgnEngine sharedInstance].soundService setSpeakerEnabled: YES];
            }
            break;
        case SOUND_SERVICE_EVENT_AUDIO_ROUTE_HEADPHONES:
            if (showing && ![CloudCall2AppDelegate runInBackground]) {
                [[NgnEngine sharedInstance].soundService setSpeakerEnabled: NO];
            }
            break;
		default:            
			break;
	}
}

- (void) GotoWebSite {
    if (adUrl && [adUrl length]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adUrl]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cloudcall.cn"]];
    }
}

@end


@implementation OldNumpadViewController

@synthesize activityIndicator;
@synthesize labelStatus;
@synthesize viewBackground;
@synthesize viewBackgroundi5;
@synthesize labelNumber;
@synthesize numberbg;
@synthesize buttonMakeAudioCall;
@synthesize buttonConference;
@synthesize imageStatus;
@synthesize imageVIP;
@synthesize buttonAd;

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
@synthesize keypad_del;
@synthesize keypad_dial;
@synthesize keypad_sharp;
@synthesize keypad_star;
@synthesize addContact;

@synthesize keypad_0i5;
@synthesize keypad_1i5;
@synthesize keypad_2i5;
@synthesize keypad_3i5;
@synthesize keypad_4i5;
@synthesize keypad_5i5;
@synthesize keypad_6i5;
@synthesize keypad_7i5;
@synthesize keypad_8i5;
@synthesize keypad_9i5;
@synthesize keypad_deli5;
@synthesize keypad_diali5;
@synthesize keypad_sharpi5;
@synthesize keypad_stari5;
@synthesize addContacti5;
@synthesize buttonMakeAudioCalli5;

/*
- (id)initWithCoder:(NSCoder *)decoder{
	self = [super initWithCoder:decoder];
    if (self) {
		for(UIView *v in self.view.subviews){
			if([v isKindOfClass: [UIButton class]]){
				switch (((UIButton*)v).tag) {
					case kTAGMessages: case kTAGAudioCall: case kTAGDelete: case kTAGStar: case kTAGPound:
					case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9:
						[((UIButton*)v) setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d_keypad", ((UIButton*)v).tag]] forState:UIControlStateNormal];
						[((UIButton*)v) setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d_keypad_pressed", ((UIButton*)v).tag]] forState:UIControlStateSelected];
						break;
				}
			}
		}
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    calloption = [[NSMutableArray alloc] init];
	
    showing = NO;
	NgnEngine* ngnEngine = [[NgnEngine sharedInstance] retain];
	mSipService = [[ngnEngine getSipService] retain];
	mConfigurationService = [[ngnEngine getConfigurationService] retain];
    mHistoryService = [[NgnEngine sharedInstance].historyService retain];
	[ngnEngine release];

	[self updateStatus];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHistoryEvent:) name:kNgnHistoryEventArgs_Name object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSoundServiceEvent:) name:kNgnSoundServiceEventArgs_Name object:nil];
    
    labelNumber.text = @"";
    
    [viewBackground setImage:[UIImage imageNamed:@"keypad_bg.png"]];
    [keypad_0 setImage:[UIImage imageNamed:@"keypad_0.png"] forState:UIControlStateHighlighted];
    [keypad_1 setImage:[UIImage imageNamed:@"keypad_1.png"] forState:UIControlStateHighlighted];
    [keypad_2 setImage:[UIImage imageNamed:@"keypad_2.png"] forState:UIControlStateHighlighted];
    [keypad_3 setImage:[UIImage imageNamed:@"keypad_3.png"] forState:UIControlStateHighlighted];
    [keypad_4 setImage:[UIImage imageNamed:@"keypad_4.png"] forState:UIControlStateHighlighted];
    [keypad_5 setImage:[UIImage imageNamed:@"keypad_5.png"] forState:UIControlStateHighlighted];
    [keypad_6 setImage:[UIImage imageNamed:@"keypad_6.png"] forState:UIControlStateHighlighted];
    [keypad_7 setImage:[UIImage imageNamed:@"keypad_7.png"] forState:UIControlStateHighlighted];
    [keypad_8 setImage:[UIImage imageNamed:@"keypad_8.png"] forState:UIControlStateHighlighted];
    [keypad_9 setImage:[UIImage imageNamed:@"keypad_9.png"] forState:UIControlStateHighlighted];
    [keypad_del setImage:[UIImage imageNamed:@"keypad_del.png"] forState:UIControlStateHighlighted];
    [keypad_dial setImage:[UIImage imageNamed:@"keypad_dial.png"] forState:UIControlStateHighlighted];
    [keypad_sharp setImage:[UIImage imageNamed:@"keypad_sharp.png"] forState:UIControlStateHighlighted];
    [keypad_star setImage:[UIImage imageNamed:@"keypad_star.png"] forState:UIControlStateHighlighted];
    [addContact setImage:[UIImage imageNamed:@"ketpad_add_contact.png"] forState:UIControlStateHighlighted];
    
    if(iPhone5)
    {
        [self.viewBackground setHidden:YES];
        [self.viewBackgroundi5 setHidden:NO];
        [viewBackgroundi5 setImage:[UIImage imageNamed:@"keybgfori5.png"]];
        [keypad_0i5 setImage:[UIImage imageNamed:@"keydown00i5.png"] forState:UIControlStateHighlighted];
        [keypad_1i5 setImage:[UIImage imageNamed:@"keydown01i5.png"] forState:UIControlStateHighlighted];
        [keypad_2i5 setImage:[UIImage imageNamed:@"keydown02i5.png"] forState:UIControlStateHighlighted];
        [keypad_3i5 setImage:[UIImage imageNamed:@"keydown03i5.png"] forState:UIControlStateHighlighted];
        [keypad_4i5 setImage:[UIImage imageNamed:@"keydown04i5.png"] forState:UIControlStateHighlighted];
        [keypad_5i5 setImage:[UIImage imageNamed:@"keydown05i5.png"] forState:UIControlStateHighlighted];
        [keypad_6i5 setImage:[UIImage imageNamed:@"keydown06i5.png"] forState:UIControlStateHighlighted];
        [keypad_7i5 setImage:[UIImage imageNamed:@"keydown07i5.png"] forState:UIControlStateHighlighted];
        [keypad_8i5 setImage:[UIImage imageNamed:@"keydown08i5.png"] forState:UIControlStateHighlighted];
        [keypad_9i5 setImage:[UIImage imageNamed:@"keydown09i5.png"] forState:UIControlStateHighlighted];
        [keypad_deli5 setImage:[UIImage imageNamed:@"keydowndeli5.png"] forState:UIControlStateHighlighted];
        [keypad_diali5 setImage:[UIImage imageNamed:@"keydowncalli5.png"] forState:UIControlStateHighlighted];
        [keypad_sharpi5 setImage:[UIImage imageNamed:@"keydownsharpi5.png"] forState:UIControlStateHighlighted];
        [keypad_stari5 setImage:[UIImage imageNamed:@"keydownstari5.png"] forState:UIControlStateHighlighted];
        [addContacti5 setImage:[UIImage imageNamed:@"keydownaddcontacti5.png"] forState:UIControlStateHighlighted];
        
        [self.activityIndicator setFrame:CGRectMake(self.numberbg.frame.origin.x, self.numberbg.frame.origin.y+6, self.numberbg.frame.size.width, self.numberbg.frame.size.height)];
        [self.labelNumber setFont:[UIFont fontWithName:@"Arial" size: 42.0]];
        [self.labelNumber setFrame:CGRectMake(self.labelNumber.frame.origin.x, self.labelNumber.frame.origin.y, self.labelNumber.frame.size.width, self.labelNumber.frame.size.height+15)];
        [self.numberbg setFrame:CGRectMake(self.numberbg.frame.origin.x, self.numberbg.frame.origin.y, self.numberbg.frame.size.width, self.numberbg.frame.size.height+15)];
        [self.numberbg setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"numberbgi5.png"]]];
    }
    else
    {
        [self.viewBackground setHidden:NO];
        [self.viewBackgroundi5 setHidden:YES];
    }
    
    [buttonConference setImage:[UIImage imageNamed:@"conference_normal.png"] forState:UIControlStateNormal];
    [buttonConference setImage:[UIImage imageNamed:@"conference_down.png"] forState:UIControlStateHighlighted];
    
    [buttonConference setHidden:YES];
    [imageVIP setHidden:YES];
    
    [labelStatus setHidden:YES];
    [buttonAd setEnabled:NO];
    
    // add targets and actions
    [buttonAd addTarget:self action:@selector(GotoWebSite) forControlEvents:UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[mSipService release];
	[mConfigurationService release];

    iadbanner.delegate = nil;
    //self.iadbanner = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [[CloudCall2AppDelegate sharedInstance] viewChanged:self];
    
    [MobClick beginLogPageView:@"Numpad"];
    
    showing = YES;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    AudioRouteTypes_t t = [[NgnEngine sharedInstance].soundService GetAudioRouteType];
    BOOL en = t==AUDIO_ROUTE_SPEAKER;
    if (en != [[NgnEngine sharedInstance].soundService isSpeakerEnabled])
        [[NgnEngine sharedInstance].soundService setSpeakerEnabled: en];
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
    
    if ([[[NgnEngine sharedInstance].configurationService getStringWithKey:SHOW_NEW_FOR_GROUP] length] != 0)
    {
        UIImageView *newFeatureShow = (UIImageView *)[buttonConference viewWithTag:3];
        if (newFeatureShow == nil)
        {
            UIImageView *newFeatureShow = [[UIImageView alloc] initWithFrame:CGRectMake(45, 8, 22, 12)];
            newFeatureShow.tag = 3;
            newFeatureShow.image = [UIImage imageNamed:@"new_Feature_Remind.png"];
            [buttonConference addSubview:newFeatureShow];
            [newFeatureShow release];
        }
    }
    else
    {
        UIImageView *newFeatureShow = (UIImageView *)[buttonConference viewWithTag:3];
        if (newFeatureShow != nil)
        {
            newFeatureShow.hidden = YES;
            [newFeatureShow removeFromSuperview];
            newFeatureShow = nil;
        }
    }
    [self layoutForCurrentOrientation:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"Numpad"];
    
    //CCLog(@"NumpadView viewWillDisappear %d", animated);  
    //[self.navigationController setNavigationBarHidden:NO];
    showing = NO;
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (actionSheet.tag) {
        case kTagActionSheetCallOut: {    
            if (buttonIndex != [actionSheet cancelButtonIndex]) {
                /*if (buttonIndex == (landsenabled ? 2 : 1)) {
                    NSString* dialurl = [@"tel://" stringByAppendingString:labelNumber.text];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialurl]];
                    return;
                }*/                
                
                CALL_OUT_MODE mode = CALL_OUT_MODE_NONE;
                if ([calloption count])
                {
                    int opt = [[calloption objectAtIndex:buttonIndex] integerValue];
                    [calloption removeAllObjects];
                    switch (opt)
                    {
                        case CallOptionInviteFriend:
                            break;
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
                            NSString* dialurl = [@"tel://" stringByAppendingString:labelNumber.text];
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialurl]];
                            return;
                        }
                    }
                    
                }
#ifdef NOT_CHECK_IS_WEICALL_USER
#else
                BOOL found = [[NgnEngine sharedInstance].contactService dbIsWeiCallUser:labelNumber.text];
                if (weicall && !found)
                {
                    // No a WeiCall User, could not make WeiCall call.
                    [self showInviteMessageView:labelNumber.text];
                    return;
                }
#endif
        
                if (videocallout) {
                    [CallViewController makeAudioVideoCallWithRemoteParty:labelNumber.text andSipStack:[mSipService getSipStack] andCalloutMode:mode];
                } else {
                    [CallViewController makeAudioCallWithRemoteParty:labelNumber.text andSipStack:[mSipService getSipStack] andCalloutMode:mode];
                }
                labelNumber.text = @"";
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
            if ([CloudCall2AppDelegate sharedInstance].adType == AD_TYPE_RENRENADER) {
                [AderSDK stopAdService];
            }
            view.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:view animated:YES];
            [view release];
            CFRelease(multiValue);
            CFRelease(newPerson);
            break;
        }         
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case kTAGSetLog: {
            if (buttonIndex == 1) {
                CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                [appDelegate StartLog];
            }
            break;
        }
    }
}

- (void) onButtonClick: (id)sender {
    if (sender == buttonConference) {
        
        ConferenceFavoritesViewController* cfv = [[ConferenceFavoritesViewController alloc] initWithNibName:@"ConferenceFavoritesView" bundle:[NSBundle mainBundle]];
//        [cfv SetDelegate:self];
        cfv.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:cfv animated:YES];
        [cfv release];
        
        /*if (!conferenceController) {
            conferenceController = [[ConferenceViewController alloc] initWithNibName: @"ConferenceView" bundle:nil];
        }        
        //[self.navigationController pushViewController:conferenceController animated:YES];
        
        CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
        [appDelegate.tabBarController presentModalViewController:conferenceController animated:YES];*/
    }
}

- (IBAction) onButtonNumpadDown: (id) sender event: (UIEvent*) e{
	NSInteger tag = ((UIButton*)sender).tag;
	
	switch (tag) {
		case kTAGMessages:
		{
			CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
			[appDelegate.tabBarController presentModalViewController: appDelegate.messagesViewController animated: NO];
			break;
		}
			
		case kTAGAudioCall:
        //case kTAGVideoCall:
		{
            if ([mSipService isRegistered]){
                if ([labelNumber.text length]) {
                    
                    //code by Sergio
                    //start
                    BOOL on3G = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
                    BOOL use3G = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
                    if (on3G && !use3G) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CloudCall", @"CloudCall")
                                                                        message:NSLocalizedString(@"Only 3G network is available. Please enable 3G and try again.", @"Only 3G network is available. Please enable 3G and try again.")
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                        [alert show];
                        [alert release];
                        
                        return ;
                    }
                    //end
                    
#ifdef NOT_CHECK_IS_WEICALL_USER // Do NOT check the dialed number if is a weicall user.                    
                    // 'Vincent' is (not) a WeiCall user, call out via:
                    NSString* strPrompt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"call out via", @"call out via")];
                    
                    if ([calloption count])
                    {
                        [calloption removeAllObjects];
                    }
                    
                    BOOL landsenabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_LANDS_CALL_ENABLE];
                    BOOL callbackenabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_CALLBACK_ENABLE];
                    UIActionSheet *sheet = nil;
                    if (landsenabled) {
                        if (callbackenabled)
                        {
                            [calloption addObject: [NSNumber numberWithInt:CallOptionInnerCall]];
                            [calloption addObject: [NSNumber numberWithInt:CallOptionLandCall]];
                            [calloption addObject: [NSNumber numberWithInt:CallOptionCallback]];
                            sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
                                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                  destructiveButtonTitle:NSLocalizedString(@"CloudCall Friends Call", @"CloudCall Friends Call")
                                                       otherButtonTitles:NSLocalizedString(@"CloudCall Direct Call", @"CloudCall Direct Call"),
                                     NSLocalizedString(@"CloudCall Callback", @"CloudCall Callback"), /*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil];
                        }
                        else
                        {
                            [calloption addObject: [NSNumber numberWithInt:CallOptionInnerCall]];
                            [calloption addObject: [NSNumber numberWithInt:CallOptionLandCall]];
                            sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
                                                            delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                destructiveButtonTitle:NSLocalizedString(@"CloudCall Friends Call", @"CloudCall Friends Call")
                                                    otherButtonTitles:NSLocalizedString(@"CloudCall Direct Call", @"CloudCall Direct Call"), /*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil];
                        }
                    } else {
                        [calloption addObject: [NSNumber numberWithInt:CallOptionInnerCall]];
                        sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
                                                            delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                destructiveButtonTitle:NSLocalizedString(@"CloudCall Friends Call", @"CloudCall Friends Call")
                                                    otherButtonTitles:/*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil];
                    }
#else
                    BOOL found = [[NgnEngine sharedInstance].contactService dbIsWeiCallUser:labelNumber.text];
                    NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:labelNumber.text];
                    
                    // 'Vincent' is (not) a WeiCall user, call out via:
                    NSString* strPrompt = [NSString  stringWithFormat:@"%@", NSLocalizedString(@"call out via", @"call out via")];
                    
                    if ([calloption count])
                    {
                        [calloption removeAllObjects];
                    }
                    
                    BOOL landsenabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_LANDS_CALL_ENABLE];
                    BOOL callbackenabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_CALLBACK_ENABLE];
                    UIActionSheet *sheet = nil;
                    if (landsenabled) {
                        if (found)
                        {
                            if (callbackenabled)
                            {
                                [calloption addObject: [NSNumber numberWithInt:CallOptionInnerCall]];
                                [calloption addObject: [NSNumber numberWithInt:CallOptionLandCall]];
                                [calloption addObject: [NSNumber numberWithInt:CallOptionCallback]];
                                sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
                                                                    delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                      destructiveButtonTitle:NSLocalizedString(@"CloudCall Friends Call", @"CloudCall Friends Call")
                                                           otherButtonTitles:NSLocalizedString(@"CloudCall Direct Call", @"CloudCall Direct Call"),
                                         NSLocalizedString(@"CloudCall Callback", @"CloudCall Callback"), /*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil];
                            }
                            else
                            {
                                [calloption addObject: [NSNumber numberWithInt:CallOptionInnerCall]];
                                [calloption addObject: [NSNumber numberWithInt:CallOptionLandCall]];
                                sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
                                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                  destructiveButtonTitle:NSLocalizedString(@"CloudCall Friends Call", @"CloudCall Friends Call")
                                                       otherButtonTitles:NSLocalizedString(@"CloudCall Direct Call", @"CloudCall Direct Call"), /*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil];
                            }
                        }
                        else
                        {
                            if (callbackenabled)
                            {
                                [calloption addObject: [NSNumber numberWithInt:CallOptionInviteFriend]];
                                [calloption addObject: [NSNumber numberWithInt:CallOptionLandCall]];
                                [calloption addObject: [NSNumber numberWithInt:CallOptionCallback]];
                                sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
                                                                    delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                      destructiveButtonTitle:NSLocalizedString(@"Invite WeiCall User", @"Invite WeiCall User")
                                                           otherButtonTitles:NSLocalizedString(@"CloudCall Direct Call", @"CloudCall Direct Call"),
                                         NSLocalizedString(@"CloudCall Callback", @"CloudCall Callback"), /*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil];
                            }
                            else
                            {
                                [calloption addObject: [NSNumber numberWithInt:CallOptionInviteFriend]];
                                [calloption addObject: [NSNumber numberWithInt:CallOptionLandCall]];
                                sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
                                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                  destructiveButtonTitle:NSLocalizedString(@"Invite WeiCall User", @"Invite WeiCall User")
                                                       otherButtonTitles:NSLocalizedString(@"CloudCall Direct Call", @"CloudCall Direct Call"), /*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil];
                            }
                        }
                    } else {
                        if(found)
                        {
                            [calloption addObject: [NSNumber numberWithInt:CallOptionInnerCall]];
                            sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
                                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                  destructiveButtonTitle:NSLocalizedString(@"CloudCall Friends Call", @"CloudCall Friends Call")
                                                       otherButtonTitles:/*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil];
                        }
                        else
                        {
                            [calloption addObject: [NSNumber numberWithInt:CallOptionInviteFriend]];
                            sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
                                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                  destructiveButtonTitle:NSLocalizedString(@"Invite WeiCall User", @"Invite WeiCall User")
                                                       otherButtonTitles:/*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil]; 
                        }
                    }
#endif
                    
					sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                    sheet.tag = kTagActionSheetCallOut;
                    [sheet showInView:self.tabBarController.view];
                    [sheet release];
                } else if (lastnumber && [lastnumber length]) {
                    labelNumber.text = lastnumber;
                }
                videocallout = (tag == kTAGVideoCall);
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
        case kTAGVideoCall: // temporary using as addcontact 
		{
            /*if ([mSipService isRegistered]){
                [CallViewController makeAudioCallWithRemoteParty: lastnumber  andSipStack: [mSipService getSipStack] andCalloutMode:lastcalloutmode];

            }*/
            if ([labelNumber.text length]) {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                          destructiveButtonTitle:NSLocalizedString(@"Create New Contact", @"Create New Contact")
                                               otherButtonTitles:/*NSLocalizedString(@"Add to Existing Contact", @"Add to Existing Contact"),*/ nil];
                sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                sheet.tag = kTagActionSheetAddContact;
                [sheet showInView:self.tabBarController.view];
                [sheet release];
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
            [self performSelector:@selector(onLongClick:) withObject:sender afterDelay:.5];
			break;
		}
			
		case kTAGStar:
		{
			labelNumber.text = [labelNumber.text stringByAppendingString:@"*"];
			BOOL dten = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_DIAL_TONE_ENABLE];
            if (dten)
                [[NgnEngine sharedInstance].soundService playDtmf:kTAGStar];
			break;
		}
			
		case kTAGPound:
		{
			labelNumber.text = [labelNumber.text stringByAppendingString:@"#"];
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
            }
    
			break;
		}

		case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9:
		{
			labelNumber.text = [labelNumber.text stringByAppendingString:[NSString stringWithFormat:@"%d", tag]];
			if(tag == 0){
				[self performSelector:@selector(onLongClick:) withObject:sender afterDelay:.5];
			}
            BOOL dten = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_DIAL_TONE_ENABLE];
            if (dten)
                [[NgnEngine sharedInstance].soundService playDtmf:tag];  
			break;
		}
	}
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet{
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

- (IBAction) onButtonNumpadUp: (id) sender event: (UIEvent*) e{
	if(((UIButton*)sender).tag == 0 || ((UIButton*)sender).tag == kTAGDelete){
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onLongClick:) object:sender];
	}
}

- (void)dealloc {
	[activityIndicator release];
	[labelStatus release];
	[viewBackground release];
    [viewBackgroundi5 release];
	[labelNumber release];
    [numberbg release];
	[buttonMakeAudioCall release];
    [buttonConference release];
    [imageStatus release];
    [imageVIP release];
    
    [conferenceController release];
    
    [adUrl release];
    
    [buttonAd release];
    
    [myNewContactDelegate release];
    
    [lastnumber release];
    
    [calloption release];
    
    [super dealloc];
}

//MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:NO];//关键的一句   不能为YES
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
//    if (nil == bannerView && type != AD_TYPE_RENRENADER) {
//        return;
//    }
    
    if (type == AD_TYPE_IAD) {
        iadbanner = (ADBannerView*)bannerView;
        [self.view addSubview:iadbanner];
        
        [self layoutForCurrentOrientation:animated];
    } else if (type == AD_TYPE_91DIANJIN) {
        djbanner = (DianJinOfferBanner*)bannerView;
        [self.view addSubview:djbanner];
    } else if (type == AD_TYPE_LIMEI) {
        lmbanner = (immobView*)bannerView;
        [self.view addSubview:lmbanner];
    } else if (type == AD_TYPE_RENRENADER){
        [AderSDK startAdService:[CloudCall2AppDelegate sharedInstance].window.rootViewController.view appID:RenrenAderKey adFrame:CGRectMake(0,20, 320, 50) model:MODEL_RELEASE];
//        [AderSDK setDelegate:self];
    }
    //[self layoutForCurrentOrientation:animated];
}

- (void)hideBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
    if (type == AD_TYPE_IAD) {
        iadbanner = nil;        
        [self layoutForCurrentOrientation:animated];
    }  else if (type == AD_TYPE_91DIANJIN) {
        if (djbanner) {
            [djbanner removeFromSuperview];
            djbanner = nil;
        }
    } else if (type == AD_TYPE_LIMEI) {
        if (lmbanner) {
            [lmbanner removeFromSuperview];
            lmbanner = nil;
        }
    } else if (type == AD_TYPE_RENRENADER) {
//        [AderSDK stopAdService];
    }
}

@end
