/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MailComposeViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    NSString* attachfilepath;
}

-(int) Sendmail: (NSArray*)recvs Subject:(NSString*)subj MessageBody:(NSString*)msgbody isHTML:(BOOL)html attach:(NSString*)filepath attachDispName:(NSString*)dispname;

@end
