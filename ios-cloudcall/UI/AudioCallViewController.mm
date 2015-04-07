/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import "AudioCallViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"

#import "MobClick.h"
#import "WebBrowser.h"


enum {
    Center_View_Type_None,
    Center_View_Type_NumPad,
    Center_View_Type_SecondCall
};

/*=== AudioCallViewController (Private) ===*/
@interface AudioCallViewController(Private)
+(void) applyGradienWithColors: (NSArray*)colors forView: (UIView*)view_ withBorder:(BOOL)border;
-(void) closeView;
-(void) updateViewAndState;
-(void) updateViewAndState:(int)code;
-(void) animateViewCenter:(int)viewType;
// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
- (void)layoutForCurrentOrientation:(BOOL)animated;
@end
/*=== AudioCallViewController (Timers) ===*/
@interface AudioCallViewController (Timers)
-(void)timerInCallTick:(NSTimer*)timer;
-(void)timerSuicideTick:(NSTimer*)timer;
-(void)waitCallBack:(NSTimer*)timer;

@end
/*=== AudioCallViewController (SipCallbackEvents) ===*/
@interface AudioCallViewController(SipCallbackEvents)
-(void) onInviteEvent:(NSNotification*)notification;
-(void) onSoundServiceEvent:(NSNotification*)notification;
@end

//
//	AudioCallViewController(Private)
//
@implementation AudioCallViewController(Private)

+(void) applyGradienWithColors: (NSArray*)colors forView: (UIView*)view_ withBorder:(BOOL)border{
	for(CALayer *ly in view_.layer.sublayers){
		if([ly isKindOfClass: [CAGradientLayer class]]){
			[ly removeFromSuperlayer];
			break;
		}
	}
	
	if(colors){
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.colors = colors;
		gradient.frame = CGRectMake(0.f, 0.f, view_.frame.size.width, view_.frame.size.height);
		if(border){
			gradient.cornerRadius = 8.f;
			gradient.borderWidth = 2.f;
			gradient.borderColor = [[UIColor grayColor] CGColor];
		}
		
		view_.backgroundColor = [UIColor clearColor];
		[view_.layer insertSublayer:gradient atIndex:0];
	}
}

-(void) closeView{
    [[CloudCall2AppDelegate sharedInstance].tabBarController dismissModalViewControllerAnimated:NO];
    
    if (callconnected) {
        NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
        NSString* clgnum = nil;
        NSString* cldnum = nil;
        int type = 1;
        if (incomingcall) {
            clgnum = remotenum;
            cldnum = mynum;
            type = 2;
        } else {
            clgnum = mynum;
            cldnum = remotenum;
        }
        
        int icalltype = calltype == CALL_OUT_MODE_LNAD ? 1 : 2; // 通话类型(直拨:1，好友之间的通话:2)
        CallFeedbackData* data = [[[CallFeedbackData alloc] initWithCallingNum:clgnum andCalledNum:cldnum andDuration:duration andType:type
                                                                   andCallTime:calltime andConnTime:conntiontime andCallType:icalltype andNetType:nettype] autorelease];
        [[CloudCall2AppDelegate sharedInstance] ShowCallFeedbackView:data];
        callconnected = NO;
    }
    
    [CloudCall2AppDelegate sharedInstance].incomingCall = NO;
}

-(void) updateOptionViewKeyStatus : (UIButton*) btn
{
    NSString *buttonBgString;
    if (btn == buttonMute)
    {
        self.buttonMute.selected = [audioSession isMuted];
        
//        [AudioCallViewController applyGradienWithColors: [audioSession isMuted] ? kColorsBlue : nil
//                                                forView:self.buttonMute withBorder:YES];
        
    }
    else if (btn == buttonSpeaker)
    {
        self.buttonSpeaker.selected = [audioSession isSpeakerEnabled];
        buttonBgString = [NSString stringWithFormat:@"%@", [audioSession isSpeakerEnabled] ? @"kp_speakerSel.png" : @"kp_speaker.png"];
        [self.buttonSpeaker setImage:[UIImage imageNamed:buttonBgString] forState:UIControlStateNormal];
//        [AudioCallViewController applyGradienWithColors: [audioSession isSpeakerEnabled] ? kColorsBlue : nil
//                                                forView:self.buttonSpeaker withBorder:YES];
    }
    else if (btn == buttonHold)
    {
        self.buttonHold.selected = [audioSession isLocalHeld];
        buttonBgString = [NSString stringWithFormat:@"%@", [audioSession isLocalHeld] ? @"hold_on_continue.png" : @"hold_on.png"];
        [self.buttonHold setImage:[UIImage imageNamed:buttonBgString] forState:UIControlStateNormal];
//		[AudioCallViewController applyGradienWithColors: [audioSession isLocalHeld] ? kColorsBlue : nil
//												forView:self.buttonHold withBorder:YES];
    }
}

/*
 400 - Bad Request
 401 - Unauthorized
 402 - Payment Required
 403 - Forbidden
 404 - Not Found
 405 - Method Not Allowed
 406 - Not Acceptable
 407 - Proxy Authentication Required
 408 - Request Timeout
 409 - Conflict
 410 - Gone
 411 - Length Required
 413 - Request Entity Too Large
 414 - Request URI Too Long
 415 - Unsupported Media Type
 416 - Unsupported URI Scheme
 420 - Bad Extension
 421 - Extension Required
 423 - Interval Too Brief
 480 - Temporarily Unavailable
 481 - Call/Transaction Does Not Exist
 482 - Loop Detected
 483 - Too Many Hops
 484 - Address Incomplete
 485 - Ambiguous
 486 - Busy Here
 487 - Request Terminated
 488 - Not Acceptable Here
 491 - Request Pending
 493 - Undecipherable
 500 - Server Internal Error
 501 - Not Implemented
 502 - Bad Gateway
 503 - Service Unavailable
 504 - Server Time-Out
 505 - Version Not Supported
 513 - Message Too Large
 600 - Busy Everywhere
 603 - Declined
 604 - Does Not Exist Anywhere
 605 - Not Acceptable
 */
+(NSString*)getSIPCodeName: (int) code{
    switch (code) {
        case 400: // Bad Request
            return NSLocalizedString(@"Bad Request", @"Bad Request");
        case 401: // Unauthorized
            return NSLocalizedString(@"Unauthorized", @"Unauthorized");
        case 402: // Payment Required
            return NSLocalizedString(@"Payment Required", @"Payment Required");
        case 403: // Forbidden
            return NSLocalizedString(@"Forbidden", @"Forbidden");
        case 404: // Not Found
            return NSLocalizedString(@"Not Found", @"Not Found");
        case 405: // Method Not Allowed
            return NSLocalizedString(@"Method Not Allowed", @"Method Not Allowed");
        case 406: // Not Acceptable
            return NSLocalizedString(@"Not Acceptable", @"Not Acceptable");
        case 407: // Proxy Authentication Required
            return NSLocalizedString(@"Proxy Authentication Required", @"Proxy Authentication Required");
        case 408: // Request Timeout
            return NSLocalizedString(@"Request Timeout", @"Request Timeout");
        case 409: // Conflict
            return NSLocalizedString(@"Conflict", @"Conflict");
        case 410: // Gone
            return NSLocalizedString(@"Gone", @"Gone");
        case 411: // Length Required
            return NSLocalizedString(@"Length Required", @"Length Required");
        case 413: // Request Entity Too Large
            return NSLocalizedString(@"Request Entity Too Large", @"Request Entity Too Large");
        case 414: // Request URI Too Long
            return NSLocalizedString(@"Request URI Too Long", @"Request URI Too Long");
        case 415: // Unsupported Media Type
            return NSLocalizedString(@"Unsupported Media Type", @"Unsupported Media Type");
        case 416: // Unsupported URI Scheme
            return NSLocalizedString(@"Unsupported URI Scheme", @"Unsupported URI Scheme");
        case 420: // Bad Extension
            return NSLocalizedString(@"Bad Extension", @"Bad Extension");
        case 421: // Extension Required
            return NSLocalizedString(@"Extension Required", @"Extension Required");
        case 423: // Interval Too Brief
            return NSLocalizedString(@"Interval Too Brief", @"Interval Too Brief");
        case 480: // Temporarily Unavailable
            return NSLocalizedString(@"Temporarily Unavailable", @"Temporarily Unavailable");
        case 481: // Call/Transaction Does Not Exist
            return NSLocalizedString(@"Call/Transaction Does Not Exist", @"Call/Transaction Does Not Exist");
        case 482: // Loop Detected
            return NSLocalizedString(@"Loop Detected", @"Loop Detected");
        case 483: // Too Many Hops
            return NSLocalizedString(@"Too Many Hops", @"Too Many Hops");
        case 484: // Address Incomplete
            return NSLocalizedString(@"Address Incomplete", @"Address Incomplete");
        case 485: // Ambiguous
            return NSLocalizedString(@"Ambiguous", @"Ambiguous");
        case 486: // Busy Here
            return NSLocalizedString(@"Busy Here", @"Busy Here");
        case 487: // Request Terminated
            return NSLocalizedString(@"Request Terminated", @"Request Terminated");
        case 488: // Not Acceptable Here
            return NSLocalizedString(@"Not Acceptable Here", @"Not Acceptable Here");
        case 491: // Request Pending
            return NSLocalizedString(@"Request Pending", @"Request Pending");
        case 492:
            return NSLocalizedString(@"Offline", @"Offline");
        case 493: // Undecipherable
            return NSLocalizedString(@"Undecipherable", @"Undecipherable");
        case 500: // Server Internal Error
            return NSLocalizedString(@"Server Internal Error", @"Server Internal Error");
        case 501: // Not Implemented
            return NSLocalizedString(@"Not Implemented", @"Not Implemented");
        case 502: // Bad Gateway
            return NSLocalizedString(@"Bad Gateway", @"Bad Gateway");
        case 503: // Service Unavailable
            return NSLocalizedString(@"Service Unavailable", @"Service Unavailable");
        case 504: // Server Time-Out
            return NSLocalizedString(@"Server Time-Out", @"Server Time-Out");
        case 505: // Version Not Supported
            return NSLocalizedString(@"Version Not Supported", @"Version Not Supported");
        case 513: // Message Too Large
            return NSLocalizedString(@"Message Too Large", @"Message Too Large");
        case 600: // Busy Everywhere
            return NSLocalizedString(@"Busy Everywhere", @"Busy Everywhere");
        case 603: // Declined
            return NSLocalizedString(@"Declined", @"Declined");
        case 604: // Does Not Exist Anywhere
            return NSLocalizedString(@"Does Not Exist Anywhere", @"Does Not Exist Anywhere");
        case 605: // Not Acceptable
            return NSLocalizedString(@"Not Acceptable", @"Not Acceptable");
    }    
    return nil;
}

-(void) updateViewAndState{
    [self updateViewAndState:-1];
}

-(void) updateViewAndState: (int) code{
    CCLog(@"updateViewAndState: %d, %d", audioSession.state, code);
    if (audioSession) {
//        int setcenterviewtype = centerViewType;
        switch (audioSession.state) {
            case INVITE_STATE_INPROGRESS: {
                //CCLog(@"-------------------------------------5");
                NSString* rmtype = audioSession.historyEvent.remoteNumType;
                if (rmtype && [rmtype length]) {
                    self.labelStatus.text = [NSString stringWithFormat:@"%@'%@'...", NSLocalizedString(@"Calling", @"Calling"), rmtype];
                } else {
                    self.labelStatus.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Calling", @"Calling")];
                }

                viewBottom.hidden = NO;
                buttonMute.hidden = NO;
                buttonSpeaker.hidden = NO;
                self.buttonAccept.hidden = YES;
                self.buttonDecline.hidden = YES;
                self.buttonHangup.hidden = NO;
                self.buttonNumpad.hidden = NO;
                self.buttonHold.hidden = NO;
                isCallTypeCallBack = NO;
                btnCallbackWait.hidden = YES;
                
                break;
            }
            case INVITE_STATE_INCOMING:	{
                //CCLog(@"-------------------------------------6");
                NSString* rmtype = audioSession.historyEvent.remoteNumType;
                self.labelStatus.text = (rmtype && [rmtype length]) ? rmtype : NSLocalizedString(@"Incoming call...", @"Incoming call...");                

//                CGFloat pad = self->bottomButtonsPadding;			
                viewBottom.hidden = NO;
                self.buttonHangup.hidden = YES;
                self.buttonNumpad.hidden = YES;
                self.buttonHold.hidden = YES;
                isCallTypeCallBack = NO;
                btnCallbackWait.hidden = YES;

                [self.buttonDecline setTitle:NSLocalizedString(@"Decline", @"Decline") forState:UIControlStateNormal];
                self.buttonDecline.hidden = NO;
                //				self.buttonDecline.frame = CGRectMake(pad/2,
                //													 self.buttonDecline.frame.origin.y, 
                //													 self.viewBottom.frame.size.width/2 - pad, 
                //													 self.buttonHangup.frame.size.height);

                [self.buttonAccept setTitle:NSLocalizedString(@"Answer", @"Answer") forState:UIControlStateNormal];
                self.buttonAccept.hidden = NO;
                //				self.buttonAccept.frame = CGRectMake(pad/2 + self.buttonHangup.frame.size.width + pad/2, 
                //												self.buttonAccept.frame.origin.y, 
                //												self.buttonHangup.frame.size.width, 
                //												self.buttonAccept.frame.size.height);

                //CCLog(@"INVITE_STATE_INCOMING audioSession isSpeakerEnabled %d", [audioSession isSpeakerEnabled]);
                [[NgnEngine sharedInstance].soundService setSpeakerEnabled: YES];   /*gary play ringtone on speaker*/
                [[NgnEngine sharedInstance].soundService playRingTone];

                break;
            }
            case INVITE_STATE_REMOTE_RINGING:
            case INVITE_STATE_EARLY_MEDIA: {
                if (audioSession.historyEvent.calloutmode == CALL_OUT_MODE_CALL_BACK)  {
//                    CCLog(@"-------------------------------------7");
                    //hidden view
                    viewBottom.hidden = YES;
                    buttonMute.hidden = YES;
                    buttonSpeaker.hidden = YES;
                    if (iPhone5)
                        btnCallbackWait.frame = CGRectMake(35, 400 + 85, btnCallbackWait.frame.size.width, self.btnCallbackWait.frame.size.height);
                    else
                        btnCallbackWait.frame = CGRectMake(35, 400, btnCallbackWait.frame.size.width, btnCallbackWait.frame.size.height);
                    
                    [btnCallbackWait setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    
                    [self.view addSubview:self.btnCallbackWait];
                    
                    //挂断通话
                    isCallTypeCallBack = YES;
                    [audioSession hangUpCall];
                    
                    //提示用户
                    NSString *localNumber = [[CloudCall2AppDelegate sharedInstance] getUserName];
                    NSString *strLblRemoteParty = [NSString stringWithFormat:NSLocalizedString(@"Success to request, then your phone %@","Success to request, then your phone %@"),localNumber];
                    
                    NSString *strLblStatus = [NSString stringWithFormat:NSLocalizedString(@"will be call, please receive it and we 'll be call %@ for you.","will be call, please receive it and we 'll be call %@ for you."),audioSession.historyEvent.remoteParty];
                    
                    self.labelRemoteParty.text = strLblRemoteParty;
                    self.labelStatus.text = strLblStatus;
                    labelRemoteParty.font = [UIFont systemFontOfSize:12.0f];
                    labelStatus.font = [UIFont systemFontOfSize:12.0f];
                    
                    if (isAdClick == NO)
                    {
                        incallSec = 15;
                    }

                    if (incallTimer) {
                        [incallTimer invalidate];
                        incallTimer = nil;
                    }
                    
                    btnCallbackWait.hidden = NO;
                    [btnCallbackWait setTitle:[NSString stringWithFormat:NSLocalizedString(@"Back/Wait(%ld sec)", @"Back/Wait(%ld sec)"),incallSec] forState:UIControlStateNormal];
                    incallTimer = [NSTimer scheduledTimerWithTimeInterval: 1 target:self selector:@selector(waitCallBack:) userInfo:nil repeats:YES];

                } else {
                    //CCLog(@"-------------------------------------8");
                    NSString* rmtype = audioSession.historyEvent.remoteNumType;
                    if (rmtype && [rmtype length]) {
                        self.labelStatus.text = [NSString stringWithFormat:@"%@'%@'(%@)...", NSLocalizedString(@"Calling", @"Calling"), rmtype, NSLocalizedString(@"ringing", @"ringing")];
                    } else {
                        self.labelStatus.text = [NSString stringWithFormat:@"%@(%@)...", NSLocalizedString(@"Calling", @"Calling"), NSLocalizedString(@"ringing", @"ringing")];
                    }
                    
                    isCallTypeCallBack = NO;
                    btnCallbackWait.hidden = YES;
                }

                self.buttonAccept.hidden = YES;
                self.buttonDecline.hidden = YES;
                self.buttonHangup.hidden = NO;
                self.buttonNumpad.hidden = NO;
                self.buttonHold.hidden = NO;
                
                if (audioSession.state == INVITE_STATE_REMOTE_RINGING)
                    [[NgnEngine sharedInstance].soundService playRingBackTone];
                break;
            }
            case INVITE_STATE_INCALL: {
                //CCLog(@"-------------------------------------9");
                //self.labelStatus.text = NSLocalizedString(@"In Call", @"In Call");
                //[self.labelStatus.text stringByAppendingFormat:(@"%s"), audioSession->getAudioCodec())];
                // 1 second
                if (isAdClick == NO)
                {
                    incallSec = 0;
                }
                else
                {
                    if (incallTimer) {
                        [incallTimer invalidate];
                        incallTimer = nil;
                    }
                }
                
                incallTimer = [NSTimer scheduledTimerWithTimeInterval: 1 target:self selector:@selector(timerInCallTick:) userInfo:nil repeats:YES];

                viewBottom.hidden = NO;
                buttonMute.hidden = NO;
                buttonSpeaker.hidden = NO;
                self.buttonAccept.hidden = YES;
                self.buttonDecline.hidden = YES;
                self.buttonHangup.hidden = NO;
                self.buttonNumpad.hidden = NO;
                self.buttonHold.hidden = NO;
                btnCallbackWait.hidden = YES;
                isCallTypeCallBack = NO;

                //CCLog(@"INVITE_STATE_INCALL audioSession isSpeakerEnabled %d", [audioSession isSpeakerEnabled]);
                [[NgnEngine sharedInstance].soundService stopRingBackTone];
                [[NgnEngine sharedInstance].soundService stopRingTone];
                [audioSession setSpeakerEnabled:NO];
                [[NgnEngine sharedInstance].soundService setSpeakerEnabled: NO];   /*gary restore speaker*/

                duration = 0;
                callconnected = YES;                
                conntiontime = [[NSDate date] timeIntervalSince1970];
                remotenum = [audioSession.historyEvent.remoteParty retain];
                incomingcall = audioSession.historyEvent.status == HistoryEventStatus_Incoming;
                if (incomingcall) {
                    calltype = CALL_OUT_MODE_INNER;
                } else {
                    calltype = audioSession.mMode;
                }
                
                NgnNetworkType_t nt = [NgnEngine sharedInstance].networkService.networkType;
                if (nt & NetworkType_WLAN) {
                    nettype = @"WiFi";
                } else if (nt & NetworkType_WLAN) {
                    nettype = @"WiFi";
                } else if (nt & NetworkType_2G) {
                    nettype = @"2G";
                } else if (nt & NetworkType_EDGE) {
                    nettype = @"EDGE";
                } else if (nt & NetworkType_3G) {
                    nettype = @"3G";
                } else if (nt & NetworkType_4G) {
                    nettype = @"4G";
                } else {
                    nettype = @"Unknown";
                }
                
                break;
            }
            case INVITE_STATE_TERMINATED:
            case INVITE_STATE_TERMINATING: {
                //CCLog(@"-------------------------------------10");
                if (0 == duration && callconnected) {
                    duration = [[NSDate date] timeIntervalSince1970] - conntiontime;
                }
                
                if (!isCallTypeCallBack) {
                    if (incallTimer) {
                        [incallTimer invalidate];
                        incallTimer = nil;
                    }
                    NSString* sipcstatuscode = [AudioCallViewController getSIPCodeName:code];
                    if (sipcstatuscode) {
                        self.labelStatus.text = sipcstatuscode;
                    } else {
                        self.labelStatus.text = NSLocalizedString(@"Terminating...", @"Terminating...");
                    }
//                    btnCallbackWait.hidden = YES;
//                    isCallTypeCallBack = NO;
                    incallSec = 0;
                }
                else
                {
//                    btnCallbackWait.hidden = YES;
//                    isCallTypeCallBack = NO;
                    incallSec = 15;
                }
                
                self.buttonAccept.hidden = YES;
                self.buttonDecline.hidden = YES;

                [[NgnEngine sharedInstance].soundService stopRingBackTone];
                [[NgnEngine sharedInstance].soundService stopRingTone];
                [[NgnEngine sharedInstance].soundService setSpeakerEnabled: NO];
                [audioSession setSpeakerEnabled: NO];

                self.labelCodec.text = @"";

                break;
            }
            default:
                break;
        }

        [self updateOptionViewKeyStatus: buttonSpeaker];
        [self updateOptionViewKeyStatus: buttonHold];
        [self updateOptionViewKeyStatus: buttonMute];
    }
}

-(void) animateViewCenter:(int)viewType{
    BOOL hideAdView = NO;
    UIView* centerView = nil;
    switch (viewType) {
        case Center_View_Type_NumPad:
            centerView = self.viewNumpad;
            hideAdView = YES;
            break;
        case Center_View_Type_SecondCall:
            centerView = self.viewSecondCall;
            hideAdView = YES;
            break;
        case Center_View_Type_None:
        default:
            break;
    }

    [self.imageViewAd setHidden:hideAdView];
    CATransition* trans = [CATransition animation];
    [trans setType:kCATransitionFade];
    [trans setDuration:0.5];
    [trans setSubtype:kCATransitionFromBottom];    
    [self.imageViewAd.layer addAnimation:trans forKey:nil];

    NSArray* array = [self.viewCenter subviews];
    if (array && [array count] && [array objectAtIndex:0] == centerView)
        return;
    
    oldCenterViewType = centerViewType;
    centerViewType = viewType;
    
    [UIView beginAnimations:@"animateViewCenter" context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.viewCenter cache:YES];
	for (UIView *view in self.viewCenter.subviews) {
		[view removeFromSuperview];
	}
    
    self.buttonIncallAd.hidden = centerView == self.viewNumpad;
    
    if (centerView)
        [self.viewCenter addSubview: centerView];
    [UIView commitAnimations];
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
// AudioCallViewController (SipCallbackEvents)
//
@implementation AudioCallViewController(SipCallbackEvents)

-(void) onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
    CCLog(@"onInviteEvent: %d, %ld, %ld", eargs.eventType, audioSession ? audioSession.id : -1, eargs.sessionId);
    
    if (audioSession && audioSession.id != eargs.sessionId && audioSession.state == INVITE_STATE_INCALL) {
#if 1
        secondAudioSession = [[NgnAVSession getSessionWithId: eargs.sessionId] retain];
        if (secondAudioSession) {
            [secondAudioSession hangUpCall];
            return;
        }
#else
        if (secondAudioSession && secondAudioSession.id == eargs.sessionId) {
            switch (eargs.eventType) {
                case INVITE_EVENT_TERMINATED:
                case INVITE_EVENT_TERMWAIT: {
                    // releases session
                    [NgnAVSession releaseSession: &secondAudioSession];
                    
                    [self animateViewCenter:oldCenterViewType];
     
                    break;
                }
                case INVITE_EVENT_INPROGRESS:
                case INVITE_EVENT_INCOMING:
                case INVITE_EVENT_RINGING:
                case INVITE_EVENT_EARLY_MEDIA:
                case INVITE_EVENT_LOCAL_HOLD_OK:
                case INVITE_EVENT_REMOTE_HOLD:
                case INVITE_EVENT_MEDIA_UPDATING:
                case INVITE_EVENT_MEDIA_UPDATED:
                default: {
                    // do nothing
                    break;
                }
            }
            
            return;
        }
        
        secondAudioSession = [[NgnAVSession getSessionWithId: eargs.sessionId] retain];
        if (secondAudioSession) {
            labelRemoteParty.text = (audioSession.historyEvent) ? audioSession.historyEvent.remotePartyDisplayName : [NgnStringUtils nullValue];
            
            [self animateViewCenter:Center_View_Type_SecondCall];
            
            return;
        }
#endif
    }
    
	if (!audioSession || audioSession.id != eargs.sessionId) {
		return;
	}
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INPROGRESS:
		case INVITE_EVENT_INCOMING:
		case INVITE_EVENT_RINGING:
        case INVITE_EVENT_EARLY_MEDIA:
		case INVITE_EVENT_LOCAL_HOLD_OK:
		case INVITE_EVENT_REMOTE_HOLD:
		default:
		{
			// updates view and state
			[self updateViewAndState];
			break;
		}
            
        /*case INVITE_EVENT_LOCAL_HOLD_OK: {
            if (secondAudioSession) {
                [secondAudioSession acceptCall];
            
                NgnAVSession* tmp = audioSession;
                audioSession = secondAudioSession;
                secondAudioSession = tmp;
            }
            break;
        }*/
		
		// transilient events
		case INVITE_EVENT_MEDIA_UPDATING: {
			self.labelStatus.text = NSLocalizedString(@"Updating...", @"Updating...");
			break;
		}
		
		case INVITE_EVENT_MEDIA_UPDATED: {
			self.labelStatus.text = NSLocalizedString(@"Updated", @"Updated");
			break;
		}

		case INVITE_EVENT_TERMINATED:
		case INVITE_EVENT_TERMWAIT: {
            CCLog(@"onInviteEvent: %d %@", eargs.sipCode, eargs.sipPhrase);
            int code = eargs.sipCode;
            
            // updates view and state
            [self updateViewAndState:code];
            // releases session
			[NgnAVSession releaseSession: &audioSession];
            
            if (!isCallTypeCallBack) {
                // starts timer suicide
                [NSTimer scheduledTimerWithTimeInterval: kCallTimerSuicide
                                                 target: self
                                               selector: @selector(timerSuicideTick:)
                                               userInfo: nil 
                                                repeats: NO];
            }
            
			break;
		}
	}
}

-(void) onSoundServiceEvent:(NSNotification*)notification{
	NgnSoundServiceEventArgs* eargs = [notification object];
	//CCLog(@"Audioview onSoundServiceEvent %d", eargs.eventType);
	switch (eargs.eventType) {
		case SOUND_SERVICE_EVENT_AUDIO_ROUTE_SPEAKER:
            if (audioSession) {  
                [[NgnEngine sharedInstance].soundService setSpeakerEnabled: YES];
                [audioSession setSpeakerEnabled: YES];
                [self updateOptionViewKeyStatus: buttonSpeaker];
            }
            break;
        case SOUND_SERVICE_EVENT_AUDIO_ROUTE_HEADPHONES:
            if (audioSession) {
                [[NgnEngine sharedInstance].soundService setSpeakerEnabled: NO];
                [audioSession setSpeakerEnabled: NO];
                [self updateOptionViewKeyStatus: buttonSpeaker];
            }
            break;
        case SOUND_SERVICE_EVENT_AUDIO_ROUTE_RECEIVER:
            if (audioSession) {
                [[NgnEngine sharedInstance].soundService setSpeakerEnabled: NO];
                [audioSession setSpeakerEnabled: NO];
                [self updateOptionViewKeyStatus: buttonSpeaker];
            }
            break;
		default:            
			break;
	}
}

@end


//
// AudioCallViewController (Timers)
//
@implementation AudioCallViewController (Timers)

-(void)timerInCallTick:(NSTimer*)timer{
	// to be implemented for the call time display
    if (audioSession.state != INVITE_STATE_INCALL && isAdClick != YES) {
        if (incallTimer) {
            [incallTimer invalidate];
            incallTimer = nil;
        }
        
        return;
    }
    incallSec++;
    NSString *t;
    if (incallSec < 3600)
        t = [[NSString alloc] initWithFormat:@"%02ld:%02ld", (incallSec)/60, (incallSec)%60];
    else
        t = [[NSString alloc] initWithFormat:@"%02ld:%02ld:%02ld", incallSec/3600, (incallSec%3600)/60, (incallSec)%60];
    labelStatus.text = t;
    [t release];

#if 0
    if (labelCodec.text == nil || labelCodec.text.length == 0) {
        NgnCodecInfoDef codec;
        BOOL getcodec = [audioSession getSessionCodec: &codec];
        if (getcodec) {
            NSString* str = [[NSString alloc] initWithFormat:@"%@: %s %@: %lu", NSLocalizedString(@"Codec", @"Codec"), codec.name, NSLocalizedString(@"Rate", @"Rate"), codec.rate];
            self.labelCodec.text = str;
            [str release];
        }
    }
#endif
}

-(void)timerSuicideTick:(NSTimer*)timer{
    [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO ];
}

-(void)waitCallBack:(NSTimer*)timer
{
    if (incallSec < 1) {
        if (incallTimer) {
            [incallTimer invalidate];
            incallTimer = nil;
        }
        if (isAdClick)
            [btnCallbackWait setTitle:[NSString stringWithFormat:NSLocalizedString(@"Back", @"Back")] forState:UIControlStateNormal];
        else
        {
            [self timerSuicideTick:nil];
            [btnCallbackWait setTitle:[NSString stringWithFormat:NSLocalizedString(@"Back/Wait(%ld sec)", @"Back/Wait(%ld sec)"),15] forState:UIControlStateNormal];
        }
    }
    else
    {
        incallSec--;
        [btnCallbackWait setTitle:[NSString stringWithFormat:NSLocalizedString(@"Back/Wait(%ld sec)", @"Back/Wait(%ld sec)"),incallSec] forState:UIControlStateNormal];
    }
    //CCLog(@"wait call back : --- %d ---",incallSec);
}

@end

//
//	AudioCallViewController
//

@implementation AudioCallViewController

@synthesize isAdClick;

@synthesize buttonHangup;
@synthesize buttonAccept;
@synthesize buttonDecline;
@synthesize buttonHideNumpad;
@synthesize buttonMute;
@synthesize buttonNumpad;
@synthesize buttonSpeaker;
@synthesize buttonHold;
@synthesize buttonVideo;
@synthesize labelStatus;
@synthesize labelRemoteParty;
@synthesize labelAccount;
@synthesize labelCodec;
@synthesize viewContact;
@synthesize imageViewContact;
@synthesize viewNumpad;
@synthesize viewCenter;
@synthesize viewTop;
@synthesize viewBottom;

@synthesize imageViewAd;
@synthesize buttonIncallAd;

@synthesize viewSecondCall;
@synthesize buttonIgnore;
@synthesize buttonHoldAndAnswer;

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
@synthesize keypad_star;
@synthesize btnCallbackWait;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {		
		self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		self.modalPresentationStyle = UIModalPresentationFullScreen;
		
        oldCenterViewType = Center_View_Type_None;
        centerViewType = Center_View_Type_None;
    }
    return self;
}

- (void) GotoWebSite {
    if (imgAdUrl && [imgAdUrl length] && adid != 9999) {
        AdResourceManager *manager = [[[AdResourceManager alloc] init] autorelease];
        [manager updateData:adid andType:ADStatisticsUpdateTypeClick];
        
        if (actionType == ADActionTypeOpenInnerBrowser) {
            [self OpenWebBrowser:imgAdUrl];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[imgAdUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
}

- (void)OpenWebBrowser:(NSString *)url
{
    WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
    webBrowser.mode = TSMiniWebBrowserModeModal;
    
    webBrowser.barStyle = UIStatusBarStyleDefault;
    webBrowser.hidesBottomBarWhenPushed = YES;
    [self presentModalViewController:webBrowser animated:YES];
    
    [webBrowser release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(iPhone5)
    {
        [self.buttonMute setFrame:CGRectMake(self.buttonMute.frame.origin.x, self.buttonMute.frame.origin.y + 83, self.buttonMute.frame.size.width, self.buttonMute.frame.size.height)];
        [self.buttonSpeaker setFrame:CGRectMake(self.buttonSpeaker.frame.origin.x, self.buttonSpeaker.frame.origin.y + 83, self.buttonSpeaker.frame.size.width, self.buttonSpeaker.frame.size.height)];
        [self.viewBottom setFrame:CGRectMake(self.viewBottom.frame.origin.x, self.viewBottom.frame.origin.y + 83, self.viewBottom.frame.size.width, self.viewBottom.frame.size.height)];
    }

    [keypad_0 setImage:[UIImage imageNamed:@"audioKeyPad_press_0.png"] forState:UIControlStateHighlighted];
    [keypad_1 setImage:[UIImage imageNamed:@"audioKeyPad_press_1.png"] forState:UIControlStateHighlighted];
    [keypad_2 setImage:[UIImage imageNamed:@"audioKeyPad_press_2.png"] forState:UIControlStateHighlighted];
    [keypad_3 setImage:[UIImage imageNamed:@"audioKeyPad_press_3.png"] forState:UIControlStateHighlighted];
    [keypad_4 setImage:[UIImage imageNamed:@"audioKeyPad_press_4.png"] forState:UIControlStateHighlighted];
    [keypad_5 setImage:[UIImage imageNamed:@"audioKeyPad_press_5.png"] forState:UIControlStateHighlighted];
    [keypad_6 setImage:[UIImage imageNamed:@"audioKeyPad_press_6.png"] forState:UIControlStateHighlighted];
    [keypad_7 setImage:[UIImage imageNamed:@"audioKeyPad_press_7.png"] forState:UIControlStateHighlighted];
    [keypad_8 setImage:[UIImage imageNamed:@"audioKeyPad_press_8.png"] forState:UIControlStateHighlighted];
    [keypad_9 setImage:[UIImage imageNamed:@"audioKeyPad_press_9.png"] forState:UIControlStateHighlighted];
    [keypad_sharp setImage:[UIImage imageNamed:@"audioKeyPad_press_sharp.png"] forState:UIControlStateHighlighted];
    [keypad_star setImage:[UIImage imageNamed:@"audioKeyPad_press_star.png"] forState:UIControlStateHighlighted];

    [buttonDecline setBackgroundImage:[UIImage imageNamed:@"decline_press.png"] forState:UIControlStateHighlighted];
    [buttonAccept setBackgroundImage:[UIImage imageNamed:@"answer_press.png"] forState:UIControlStateHighlighted];

    self->oldCenterViewType = Center_View_Type_None;
    [self animateViewCenter:Center_View_Type_None];

    self->bottomButtonsPadding = self.buttonHangup.frame.origin.x;

    [self.viewTop setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"audioCall_top_bg.png"]]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"audio_View_Bg.png"]]];
    self.labelAccount.text = @"";
    self.labelCodec.text = @"";

    [self.buttonIgnore setTitle: NSLocalizedString(@"Ignore", @"Ignore") forState:UIControlStateNormal];
    [self.buttonHoldAndAnswer setTitle: NSLocalizedString(@"Hold Call + Answer", @"Hold Call + Answer") forState:UIControlStateNormal];

    [AudioCallViewController applyGradienWithColors:kColorsLightBlack forView:self.viewNumpad withBorder:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSoundServiceEvent:) name:kNgnSoundServiceEventArgs_Name object:nil];
    
    if (SystemVersion >= 7.0)
    {
        self.viewTop.frame = CGRectMake(self.viewTop.frame.origin.x, self.viewTop.frame.origin.y+20, self.viewTop.frame.size.width, self.viewTop.frame.size.height);
        self.viewBottom.frame = CGRectMake(self.viewBottom.frame.origin.x, self.viewBottom.frame.origin.y+20, self.viewBottom.frame.size.width, self.viewBottom.frame.size.height);
        self.imageViewAd.frame = CGRectMake(self.imageViewAd.frame.origin.x, self.imageViewAd.frame.origin.y+20, self.imageViewAd.frame.size.width, self.imageViewAd.frame.size.height);
        self.viewCenter.frame = CGRectMake(self.viewCenter.frame.origin.x, self.viewCenter.frame.origin.y+20, self.viewCenter.frame.size.width, self.viewCenter.frame.size.height);
        self.buttonIncallAd.frame = CGRectMake(self.buttonIncallAd.frame.origin.x, self.buttonIncallAd.frame.origin.y+20, self.buttonIncallAd.frame.size.width, self.buttonIncallAd.frame.size.height);
        self.buttonMute.frame = CGRectMake(self.buttonMute.frame.origin.x, self.buttonMute.frame.origin.y+20, self.buttonMute.frame.size.width, self.buttonMute.frame.size.height);
        self.buttonSpeaker.frame = CGRectMake(self.buttonSpeaker.frame.origin.x, self.buttonSpeaker.frame.origin.y+20, self.buttonSpeaker.frame.size.width, self.buttonSpeaker.frame.size.height);
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"AudioCall"];
    
    [secondAudioSession release];
    
	[audioSession release];
	audioSession = [[NgnAVSession getSessionWithId: self.sessionId] retain];
	if(audioSession){
		labelRemoteParty.text = (audioSession.historyEvent) ? audioSession.historyEvent.remotePartyDisplayName : [NgnStringUtils nullValue];
        labelRemoteParty.font = [UIFont systemFontOfSize:18.0f];
        labelStatus.font = [UIFont systemFontOfSize:15.0f];
		[self updateViewAndState];
	}
    
    NSString* t = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"YunTong", @"YunTong"), [[NgnEngine sharedInstance].sipService getCurrentAccount]];
    self.labelAccount.text = t;
    [t release];
    self.labelAccount.hidden = YES;
    self.labelCodec.hidden = YES;
    
    incomingcall = NO;
    calltime = [[NSDate date] timeIntervalSince1970];
    
//    if (contact && contact.picture != NULL){
//        self.imageViewContact.image = [UIImage imageWithData:contact.picture];
//    } else{
//        self.imageViewContact.image = [UIImage imageNamed:@"noavatar_icon_180.png"];
//    }
    adid = 9999;
    actionType = 1;
    if ([[CloudCall2AppDelegate sharedInstance] ShowAllFeatures]) {
        if (CCAdsData *adsData = [[CloudCall2AppDelegate sharedInstance] GetCurrIncallAdData]) {
            if (NSData* imgData = [[CloudCall2AppDelegate sharedInstance] GetIncallImage:[adsData.image lastPathComponent]]) {
                adid = adsData.adid;
                actionType = adsData.clickAction;
                UIImage *image = [UIImage imageWithData:imgData];
                [imageViewAd setImage:image];
                
                if (imgAdUrl) {
                    [imgAdUrl release];
                    imgAdUrl = nil;
                }
                imgAdUrl = [[NSString alloc] initWithString:adsData.clickurl];
                
                //签到广告统计计数
                AdResourceManager *manager = [[[AdResourceManager alloc] init] autorelease];
                [manager updateData:adid andType:ADStatisticsUpdateTypeShow];
            }
        }
    }
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    [appDelegate sendRequestToCloudCall];
}

-(void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    [self layoutForCurrentOrientation:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"AudioCall"];
	[NgnAVSession releaseSession: &audioSession];
    
    self->oldCenterViewType = Center_View_Type_None;
    [self animateViewCenter:Center_View_Type_None];
    
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction) onButtonClick: (id)sender{
	if(audioSession && sender != btnCallbackWait){
		if(sender == buttonHangup){
			[audioSession hangUpCall];
		}
		else if(sender == buttonAccept)
        {
			[audioSession acceptCall];
		}
        else if (sender == buttonDecline)
        {
            [audioSession hangUpCall];
        }
		else if(sender == buttonMute)
        {
			if([audioSession setMute:![audioSession isMuted]]){
				//self.buttonMute.selected = [audioSession isMuted];
				//[AudioCallViewController applyGradienWithColors: [audioSession isMuted] ? kColorsBlue : nil
				//									forView:self.buttonMute withBorder:NO];
			}
            [self updateOptionViewKeyStatus: sender];
		}
		else if(sender == buttonSpeaker){
            [audioSession setSpeakerEnabled:![audioSession isSpeakerEnabled]];
			if([[NgnEngine sharedInstance].soundService setSpeakerEnabled:[audioSession isSpeakerEnabled]]){
				//self.buttonSpeaker.selected = [audioSession isSpeakerEnabled];
				//[AudioCallViewController applyGradienWithColors: [audioSession isSpeakerEnabled] ? kColorsBlue : nil
				//									forView:self.buttonSpeaker withBorder:NO];
			}
            [self updateOptionViewKeyStatus: sender];
		}
		else if(sender == buttonHold){
			[audioSession toggleHoldResume];
            [self updateOptionViewKeyStatus: sender];
		}
		else if(sender == buttonVideo){
			// [audioSession updateSession:MediaType_AudioVideo];
		}
		else if(sender == buttonNumpad) {            
            [self animateViewCenter: centerViewType == Center_View_Type_NumPad ? Center_View_Type_None : Center_View_Type_NumPad];
		}
        else if(sender == buttonIgnore) {
            if (secondAudioSession)
                [secondAudioSession hangUpCall];
		} else if(sender == buttonHoldAndAnswer) {
            if (secondAudioSession) {
                [audioSession toggleHoldResume];
                [self updateOptionViewKeyStatus: sender];
            }
		} else if (sender == buttonIncallAd) {
            [self GotoWebSite];
            isAdClick = YES;
        } 
	}
    else if (!audioSession && sender == buttonIncallAd) {
        [self GotoWebSite];
        isAdClick = YES;
    }
    else if(!audioSession && sender == buttonHangup)
    {
        [self closeView];
    }
    
    if(sender == btnCallbackWait)
    {
        if (incallTimer) {
            [incallTimer invalidate];
            incallTimer = nil;
        }
        [self timerSuicideTick:nil];
        [btnCallbackWait setTitle:[NSString stringWithFormat:NSLocalizedString(@"Back/Wait(%ld sec)", @"Back/Wait(%ld sec)"),15] forState:UIControlStateNormal];
    }
}

- (IBAction) onButtonNumpadClick: (id)sender{
	if(audioSession){
		int tag = ((UIButton*)sender).tag;
		[audioSession sendDTMF:tag];
		[[NgnEngine sharedInstance].soundService playDtmf:tag];

        /*gary display 2nd time dialer number*/
        if (tag < 10){
            labelRemoteParty.text = [labelRemoteParty.text stringByAppendingString:[NSString stringWithFormat:@"%d", tag]];
        }
        else if (tag == 10){
            labelRemoteParty.text = [labelRemoteParty.text stringByAppendingString:@"*"];
        }
        else if (tag == 11){
            labelRemoteParty.text = [labelRemoteParty.text stringByAppendingString:@"#"];
        }
	}
}

- (void)dealloc {
    if (imgAdUrl) {
        [imgAdUrl release];
        imgAdUrl = nil;
    }
    
	[labelStatus release];
	[labelRemoteParty release];
    [labelAccount release];
    [labelCodec release];
	[buttonHangup release];
	[buttonAccept release];
	[buttonHideNumpad release];
	[buttonMute release];
	[buttonNumpad release];
	[buttonSpeaker release];
	[buttonHold release];
	[buttonVideo release];
	[viewCenter release];
	[viewTop release];
	[viewBottom release];
	[viewNumpad release];
    [viewContact release];
    [imageViewContact release];

    if (incallTimer) {
        [incallTimer invalidate];
        incallTimer = nil;
    }
	[btnCallbackWait release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	//[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //lableName.hidden = NO;
    //lableDescription.hidden = NO;
    //lableContact.hidden = NO;

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	//[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //lableName.hidden = YES;
    //lableDescription.hidden = YES;
    //lableContact.hidden = YES;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

// BannerViewContainer
- (void)showBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
    return; // 大屏广告，不显示力美广告
    if (type == AD_TYPE_IAD) {
        iadbanner = (ADBannerView*)bannerView;        
        [self.view addSubview:iadbanner];
        [self layoutForCurrentOrientation:animated];
    } else if (type == AD_TYPE_LIMEI) {
        lmbanner = (immobView*)bannerView;
        [self.view addSubview:lmbanner];
    } else if (type == AD_TYPE_BAIDU){
        bdbanner = (BaiduMobAdView*)bannerView;
        [self.view addSubview:bdbanner];
    }
}

- (void)hideBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated
{
    return; // 大屏广告，不显示力美广告
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
