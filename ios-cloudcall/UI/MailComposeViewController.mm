/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "MailComposeViewController.h"
#import "CloudCall2AppDelegate.h"

@implementation MailComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)mailComposeController:(MFMailComposeViewController*)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	//[self becomeFirstResponder];    
	[self dismissModalViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(int) Sendmail: (NSArray*)recvs Subject:(NSString*)subj MessageBody:(NSString*)msgbody isHTML:(BOOL)html attach:(NSString*)filepath attachDispName:(NSString*)dispname {
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	mailController.mailComposeDelegate = self;
    [mailController setToRecipients:recvs];
	[mailController setSubject: subj ? subj : @""];
	[mailController setMessageBody:msgbody?msgbody:@"" isHTML:html];
    
    // Attach file to the email.
    NSData *myData = [NSData dataWithContentsOfFile:filepath];
    [mailController addAttachmentData:myData mimeType:@"" fileName:dispname?dispname:@"no-name"];
    
	[self presentModalViewController:mailController animated:YES];
	[mailController release];
    return 0;
}

- (void)dealloc {
    [super dealloc];
}


@end
