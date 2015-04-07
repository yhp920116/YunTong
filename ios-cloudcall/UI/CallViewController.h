/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface CallViewController : UIViewController {
	long sessionId;    
    NgnContact* contact;
}

@property (nonatomic) long sessionId;
@property (nonatomic, assign) NgnContact* contact;

+(BOOL) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andCalloutMode:(CALL_OUT_MODE)mode;
+(BOOL) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andCalloutMode:(CALL_OUT_MODE)mode;
+(BOOL) receiveIncomingCall: (NgnAVSession*)session;
+(BOOL) displayCall: (NgnAVSession*)session;

@end
