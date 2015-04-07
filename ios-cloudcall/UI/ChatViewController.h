/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface ChatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, UITextViewDelegate> {
@private
	UITableView *tableView;
	UIView *viewTableHeader;
	UITextView *textView;
	UIView *viewFooter;
	UIBarButtonItem *barBtnMessagesOrClear;
	UIButton *buttonSend;
	UIButton *buttonAudioCall;
	UIButton *buttonVideoCall;
	UIButton *buttonContactInfo;
	
	NSMutableArray* messages;
	NgnContact* contact;
	NSString* remoteParty;
	NSString* remotePartyUri;
    
    int keyboardheight;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIView *viewTableHeader;
@property(nonatomic,retain) IBOutlet UITextView *textView;
@property(nonatomic,retain) IBOutlet UIView *viewFooter;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barBtnMessagesOrClear;
@property(nonatomic,retain) IBOutlet UIButton* buttonSend;
@property(nonatomic,retain) IBOutlet UIButton* buttonAudioCall;
@property(nonatomic,retain) IBOutlet UIButton* buttonVideoCall;
@property(nonatomic,retain) IBOutlet UIButton* buttonContactInfo;

@property(nonatomic,retain) NSString *remoteParty;

- (IBAction) onBarBtnMessagesOrClearClick: (id)sender;
- (IBAction) onBarBtnEditOrDoneClick: (id)sender;
- (IBAction) onButtonClick: (id)sender;

-(void)setRemoteParty:(NSString *)remoteParty andContact:(NgnContact*)contact;

@end
