/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import "CallViewController.h"

#import "CloudCall2AppDelegate.h"

//
// private implementation
//
@interface CallViewController(Private)
+(BOOL) presentSession: (NgnAVSession*)session;
@end

@implementation CallViewController(Private)

+(BOOL) presentSession: (NgnAVSession*)session{
#ifdef WeiCall_SUPPORT_VIDEO
	if(session){
		if(isVideoType(session.mediaType)){
			[CloudCall2AppDelegate sharedInstance].videoCallController.sessionId = session.id;
			[[CloudCall2AppDelegate sharedInstance].tabBarController presentModalViewController: [CloudCall2AppDelegate sharedInstance].videoCallController animated: YES];
			return YES;
		}
		else if(isAudioType(session.mediaType)){
			[CloudCall2AppDelegate sharedInstance].audioCallController.sessionId = session.id;
			[[CloudCall2AppDelegate sharedInstance].tabBarController presentModalViewController: [CloudCall2AppDelegate sharedInstance].audioCallController animated: YES];
			return YES;
		}
	}
#else   //gary only support audio in this release
    if(isAudioType(session.mediaType)){        
        if ([[CloudCall2AppDelegate sharedInstance].tabBarController presentedViewController] == [CloudCall2AppDelegate sharedInstance].audioCallController)
        {
            CCLog(@"Active Call already exist!");
            return NO;
        }
        NSString *remoteParty = session ? session.historyEvent.remoteParty : nil;
        NgnContact* contact = remoteParty ? [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:remoteParty] : nil;
        
        [CloudCall2AppDelegate sharedInstance].audioCallController.contact = contact;
        [CloudCall2AppDelegate sharedInstance].audioCallController.sessionId = session.id;
        [[CloudCall2AppDelegate sharedInstance].tabBarController presentModalViewController: [CloudCall2AppDelegate sharedInstance].audioCallController animated: YES];
        return YES;
    }    
#endif
	return NO;
}

@end

@implementation CallViewController

@synthesize sessionId;
@synthesize contact;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

+(BOOL) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andCalloutMode:(CALL_OUT_MODE)mode{
    CCLog(@"makeAudioCallWithRemoteParty=%@", remoteUri);
	if(![NgnStringUtils isNullOrEmpty:remoteUri]){
		NgnAVSession* audioSession = [[NgnAVSession makeAudioCallWithRemoteParty: remoteUri
																 andSipStack: [[NgnEngine sharedInstance].sipService getSipStack]
                                                                      andCalloutMode:mode] retain];
		if(audioSession){
            NgnContact* contact = remoteUri ? [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:remoteUri] : nil;
            
            [CloudCall2AppDelegate sharedInstance].audioCallController.contact = contact;            
			[CloudCall2AppDelegate sharedInstance].audioCallController.sessionId = audioSession.id;
			[[CloudCall2AppDelegate sharedInstance].tabBarController presentModalViewController: [CloudCall2AppDelegate sharedInstance].audioCallController animated: YES];
			[audioSession release];
			return YES;
		}
	}
	return NO;
}

+(BOOL) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andCalloutMode:(CALL_OUT_MODE)mode{
    CCLog(@"makeAudioVideoCallWithRemoteParty=%@, mode %d", remoteUri, mode);
   
	if(![NgnStringUtils isNullOrEmpty:remoteUri]){
		NgnAVSession* videoSession = [[NgnAVSession makeAudioVideoCallWithRemoteParty: remoteUri
																	 andSipStack: [[NgnEngine sharedInstance].sipService getSipStack]
                                                                           andCalloutMode:mode] retain];
		if(videoSession){
            CCLog(@"makeAudioVideoCallWithRemoteParty  videosession  create");
            NgnContact* contact = remoteUri ? [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:remoteUri] : nil;
            
            [CloudCall2AppDelegate sharedInstance].audioCallController.contact = contact;
			[CloudCall2AppDelegate sharedInstance].videoCallController.sessionId = videoSession.id;
			[[CloudCall2AppDelegate sharedInstance].tabBarController presentModalViewController: [CloudCall2AppDelegate sharedInstance].videoCallController animated: YES];
			[videoSession release];
			return YES;
		}
	}
	return NO;
}

+(BOOL) receiveIncomingCall: (NgnAVSession*)session{
	return [CallViewController presentSession:session];
}

+(BOOL) displayCall: (NgnAVSession*)session{
	if(session){
		return [CallViewController presentSession:session];
	}
	return NO;
}

- (void)dealloc {
    [super dealloc];
}


@end
