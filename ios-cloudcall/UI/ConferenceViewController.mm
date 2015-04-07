/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "CloudCall2Constants.h"

#import "ConferenceViewController.h"
#import "ConferencingViewController.h"
#import "CloudCall2AppDelegate.h"
#import "ParticipantCell.h"
#import "ConferenceGridViewCell.h"
#import "GMGridViewCell+Extended.h"
#import "GMGridView.h"
#import "MobClick.h"
#import <ShareSDK/ShareSDK.h>
#import "HttpRequest.h"
#import "JSONKit.h"
#import "StaticUtils.h"

#import "ConferenceScheduledViewController.h"
#import "GroupCallOrderViewController.h"

#import "MBProgressHUD.h"
#import "MobClick.h"

@implementation ConferenceViewController
@synthesize conffavorite;
@synthesize isCreateGroup;
@synthesize isOrderGroupCall;

@synthesize viewToolbar;
@synthesize toolbar;
@synthesize labelTitle;
@synthesize labelMaxconfMembers;

@synthesize buttonGroup;
@synthesize buttonSave;
@synthesize buttonCall;
@synthesize buttonPick;
@synthesize buttonSelectedAll;

@synthesize txtFieldAdd;

@synthesize viewKeys;

@synthesize confStatus;
@synthesize uuid;
@synthesize cmMyNumber;
@synthesize popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)cancelNumberPad{
    if ([self.txtFieldAdd isFirstResponder])
        [self.txtFieldAdd resignFirstResponder];
    txtFieldAdd.text = @"";
}

-(void)doneWithNumberPad {
    NSString *strNum = [self.txtFieldAdd text];
    do {
        if ([strNum length]) {
            if (![strNum cStringUsingEncoding:NSASCIIStringEncoding]) {
                NSString* strPrompt = NSLocalizedString(@"Invalid phone number", @"Invalid phone number");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                message: strPrompt
                                                               delegate: self
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                
                break;
            }
            
            if ([strNum isEqualToString:mynum]) {
                NSString* strPrompt = NSLocalizedString(@"This number already exist in conference.", @"This number already exist in conference.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                message: strPrompt
                                                               delegate: self
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                
                break;
            }
            
            for (int i=0; i<[participants count]; i++) {
                ConferenceMember* cm = [participants objectAtIndex:i];
                if ([cm.participant.Number isEqualToString:strNum]) {
                    NSString* strPrompt = NSLocalizedString(@"This number already exist in conference.", @"This number already exist in conference.");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                    message: strPrompt
                                                                   delegate: self
                                                          cancelButtonTitle: nil
                                                          otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                    [alert show];
                    [alert release];
                    
                    return;
                }
            }
            
            ParticipantInfo* participant = [[ParticipantInfo alloc] init];
            
            NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber: strNum];
            participant.Number = strNum;
            if (contact && contact.displayName && [contact.displayName length]) {
                participant.Name = contact.displayName;
                participant.picture = contact.picture;
                
                for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers) {
                    if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number) {
                        NSString* tmpPhoneNum = [phoneNumber.number phoneNumFormat];
                        
                        if ([tmpPhoneNum isEqualToString:strNum]) {
                            participant.Description = phoneNumber.description;
                            break;
                        }
                    }
                }
            } else {
                participant.Name = NSLocalizedString(@"No Name", @"No Name");
            }
            participant->selected = YES;
            
            ConferenceMember* cm = [[ConferenceMember alloc] initWithParticipant:participant andStatus:CONF_MEMBER_STATUS_NONE];
            [participants addObject:cm];
            [participantsWillCall addObject:cm];
            [cm release];
            
            [participant release];
            
            [_gmGridView insertObjectAtIndex:[participants count] - 1 withAnimation:(GMGridViewItemAnimation)(GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll)];
            [self updateTitleText];
            
            self.txtFieldAdd.text = @"";
            
            if ([participantsWillCall count] == [participants count]-1)
            {
                isSelectedAll = YES;
                [buttonSelectedAll setTitle:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Cancel", @"Cancel"), NSLocalizedString(@"Select All", @"Select All")] forState:UIControlStateNormal];
            }
        }
    } while (0);
    
    if ([self.txtFieldAdd isFirstResponder])
        [self.txtFieldAdd resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    //    if ([participants count] + 1 == appDelegate.maxconfmembers) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
    //                                                        message: NSLocalizedString(@"Reach the max participants limit!", @"Reach the max participants limit!")
    //                                                       delegate: self
    //                                              cancelButtonTitle: nil
    //                                              otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
    //        [alert show];
    //        [alert release];
    //
    //        return NO;
    //    }
    return YES;
}

- (void)alertView:(UIAlertView *)_alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

- (void) GroupCallResponseStatus:(NSNotification *)notification {
    GroupCallResponseStatusNotificationArgs* gcgrsna = (GroupCallResponseStatusNotificationArgs *)notification.object;
    CCLog(@"GroupCallResponseStatus: %d, %d, %d", gcgrsna.success, gcgrsna.type, gcgrsna.errorcode);
    
    if (gcgrsna.type == GroupCallRequsetType_Update) {
        if (!gcgrsna.success) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") message:gcgrsna.text delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CheckUserRight];
    
    if(iPhone5)
    {
        self.viewKeys.frame = CGRectMake(viewKeys.frame.origin.x, viewKeys.frame.origin.y+88, viewKeys.frame.size.width, viewKeys.frame.size.height);
    }
    
    mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    mypwd = [[CloudCall2AppDelegate sharedInstance] getUserPassword];
    CCLog(@"mynum=%@, %@", mynum, mypwd);
    
    ///////////////////////////////////////
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image = [UIImage imageNamed:@"toolbar_bg.png"];
    [self.toolbar addSubview:imageview];
    [imageview release];
    ///////////////////////////////////////
    
    /*  显示群呼引导
     if ([[[NgnEngine sharedInstance].configurationService getStringWithKey:SHOW_NEW_FOR_GROUPCALL] length] != 0)
    {
        [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FOR_GROUPCALL andValue:nil];
        
        UIButton *guideGroupCall = [UIButton buttonWithType:UIButtonTypeCustom];
        guideGroupCall.frame = CGRectMake(0, 20, 320, 548);
        
        guideGroupCall.tag = 1002;
        [guideGroupCall setImage:[UIImage imageNamed:@"groupCallGuide"] forState:UIControlStateNormal];
        [guideGroupCall setImage:[UIImage imageNamed:@"groupCallGuide"] forState:UIControlStateHighlighted];
        [guideGroupCall addTarget:self action:@selector(guidViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [[CloudCall2AppDelegate sharedInstance].window.rootViewController.view addSubview:guideGroupCall];
    }*/
    
    confStatus = CONF_STATUS_NONE;
    
    if (cmMyNumber == nil)
    {
        ParticipantInfo* pi = [[ParticipantInfo alloc] init];
        pi.Number = [[CloudCall2AppDelegate sharedInstance] getUserName];
        pi.Name = NSLocalizedString(@"My Number", @"My Number");
        cmMyNumber = [[ConferenceMember alloc] initWithParticipant:pi andStatus:CONF_MEMBER_STATUS_NONE];
        [pi release];
    }
    
    if (!participants) {
		participants = [[NSMutableArray alloc] init];
        [self LoadFavorite];
	}
    
    if (!participantsWillCall) {
		participantsWillCall = [[NSMutableArray alloc] init];
	}
    
    self.labelMaxconfMembers.text = NSLocalizedString(@"Out of range", @"Out of range");
    self.txtFieldAdd.placeholder = NSLocalizedString(@"Enter the participant number", @"Enter the participant number");
    
    [self.txtFieldAdd setDelegate:self];
    
    [buttonCall setBackgroundImage:[UIImage imageNamed:@"conference_start_normal.png"] forState:UIControlStateNormal];
    [buttonCall setBackgroundImage:[UIImage imageNamed:@"conference_start_down.png"] forState:UIControlStateHighlighted];
    
    self->barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [self->barButtonItemBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonItemBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonItemBack];
    
    self->barButtonItemMore = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonItemMore.frame = CGRectMake(266, 0, 44, 44);
    [self->barButtonItemMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self->barButtonItemMore setBackgroundImage:[UIImage imageNamed:@"groupcall_more_up.png"] forState:UIControlStateNormal];
    [self->barButtonItemMore setBackgroundImage:[UIImage imageNamed:@"groupcall_more_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonItemMore addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonItemMore];
    
    [self.buttonSave setTitle:NSLocalizedString(@"Save", @"Save") forState:UIControlStateNormal];
    [self.buttonSelectedAll setTitle:NSLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    [self.buttonCall setTitle:NSLocalizedString(@"Start GroupCall", @"Start GroupCall") forState:UIControlStateNormal];
    [self.buttonPick setTitle:NSLocalizedString(@"Contacts", @"Contacts") forState:UIControlStateNormal];
    [self.buttonGroup setTitle:NSLocalizedString(@"Group", @"Group") forState:UIControlStateNormal];
    
    ////////////////////////////////////////////////////////
    keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.items = [NSArray arrayWithObjects:
                             [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)] autorelease],
                             [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                             [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Add", @"Add") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)] autorelease],
                             nil];
    [keyboardToolbar sizeToFit];
    txtFieldAdd.inputAccessoryView = keyboardToolbar;
    ////////////////////////////////////////////////////////
    
    NSInteger spacing = INTERFACE_IS_PHONE ? 10 : 15;
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 84, 320, 326)];
    
    if (SystemVersion >= 7.0)
    {
        self.viewKeys.frame = CGRectMake(self.viewKeys.frame.origin.x, self.viewKeys.frame.origin.y + 20, self.viewKeys.frame.size.width, self.viewKeys.frame.size.height);
        self.viewToolbar.frame = CGRectMake(self.viewToolbar.frame.origin.x, self.viewToolbar.frame.origin.y + 20, self.viewToolbar.frame.size.width, self.viewToolbar.frame.size.height);
    }
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:gmGridView belowSubview:viewKeys];
    _gmGridView = gmGridView;
    
    _gmGridView.style = GMGridViewStyleSwap;
    _gmGridView.itemSpacing = spacing;
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _gmGridView.centerGrid = NO;
    _gmGridView.actionDelegate = self;
    _gmGridView.sortingDelegate = self;
    _gmGridView.transformDelegate = self;
    _gmGridView.dataSource = self;
    
    _gmGridView.mainSuperView = self.view;
    [self updateTitleText];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(updateTitleText) name:@"updateTitleText" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(GroupCallResponseStatus:) name:kGroupCallResponseStatusNotification object: nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"GroupCall_Edit"];
    
    [self.navigationController setNavigationBarHidden: YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"GroupCall_Edit"];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onButtonToolBarItemClick: (id)sender {
    if (sender == barButtonItemBack) {
        if (isOrderGroupCall == YES)
        {
            [self dismissModalViewControllerAnimated:YES];
        }
        else
        {
            if (isCreateGroup == YES)
                [self.navigationController popToRootViewControllerAnimated:YES];
            else
                [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (sender == barButtonItemMore) {
        if (_gmGridView.editing == NO)
        {
            MoreBtnTableViewController *contentView = [[MoreBtnTableViewController alloc] init];
            contentView.delegate = self;
            self.popoverController = [[[WEPopoverController alloc] initWithContentViewController:contentView] autorelease];
            CGRect popFrame = CGRectMake(barButtonItemMore.frame.origin.x, barButtonItemMore.frame.origin.y-18, barButtonItemMore.frame.size.width, barButtonItemMore.frame.size.height);
            [popoverController presentPopoverFromRect:popFrame
                                               inView:self.view
                             permittedArrowDirections:UIPopoverArrowDirectionUp
                                             animated:YES];
            [contentView release];
        }
        else
        {
            _gmGridView.editing = NO;
            self.buttonSave.hidden = NO;
            self.buttonSelectedAll.hidden = NO;
            [self->barButtonItemMore setBackgroundImage:[UIImage imageNamed:@"groupcall_more_up.png"] forState:UIControlStateNormal];
            [self->barButtonItemMore setBackgroundImage:[UIImage imageNamed:@"groupcall_more_down.png"] forState:UIControlStateHighlighted];
            if (oldGroupCallMembers != [participants count])
                [self saveConferenceMembers];
        }
        [_gmGridView layoutSubviewsWithAnimation:GMGridViewItemAnimationFade];
    }
}

- (void)guidViewClick:(id)sender
{
    UIButton *Btn = (UIButton *)sender;
    if (Btn.tag == 1002)
    {
        [Btn removeFromSuperview];
    }
}

- (void) hideProgressView{
    [progressView dismissWithClickedButtonIndex:0 animated:NO];
}

-(void)CheckUserRight {
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    [appDelegate CheckUserRight];
}

- (void)saveConferenceMembers
{
    int index = [participants indexOfObject:cmMyNumber];
    
    NSMutableArray* members = [[NSMutableArray alloc] init];
    
    [participants removeObject:cmMyNumber];
    [[NgnEngine sharedInstance].storageService dbClearConfParticipants:uuid];
    for (int i=0; i<[participants count]; i++) {
        ConferenceMember* cm = [participants objectAtIndex:i];
        if (cm && cm.participant && cm.participant.Number && [cm.participant.Number length]) {
            [[NgnEngine sharedInstance].storageService dbAddConfParticipant:uuid andPhoneNum:cm.participant.Number];
        }
        
        GroupCallMember* m = [[GroupCallMember alloc] initWithName:cm.participant.Name andNumber:cm.participant.Number];
        [members addObject:m];
        [m release];
    }
    [participants insertObject:cmMyNumber atIndex:index];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    conffavorite.updatetime = time;
    conffavorite.status = conffavorite.status;
    [[NgnEngine sharedInstance].storageService dbUpdateConfFavorite:conffavorite];
    
    /////////////////////////////////////////////////////////////////////////////////////
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    GroupCallRecord* r = [[GroupCallRecord alloc] initWithUserNumber:mynum andName:self.conffavorite.name andGroupId:uuid andType:self.conffavorite.type andUpdateTime:conffavorite.updatetime andMembers:members];
    [appDelegate UpdateGroupCallRecords:[NSArray arrayWithObject:r]];
    [r release];
    [members release];
    /////////////////////////////////////////////////////////////////////////////////////
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"Save Successfully", @"Save Successfully");
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
    [HUD release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kConferenceFavTableReload object:nil];
}

- (void)ButtonCallEvent
{
    if (confStatus == CONF_STATUS_NONE || confStatus == CONF_STATUS_STOP) { // start conference
        if ([participantsWillCall count] == 0) {
            NSString* strMsg = NSLocalizedString(@"No other participant", @"No other participant");
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") message:strMsg delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            return;
        }
        
        ConferencingViewController *conferencingView = [[ConferencingViewController alloc] initWithNibName:@"ConferenceView" bundle:nil];
        conferencingView.participantsCall = [NSMutableArray arrayWithArray:participantsWillCall];
        conferencingView.conffavorite = self.conffavorite;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:conferencingView animated:YES];
        
        [conferencingView release];
    }
}

- (void)updateTitleText
{
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    NSString *tempTitleString = nil;
    tempTitleString = [NSString stringWithFormat:@"%@ (%d/%d)", conffavorite.name, [participantsWillCall count]+1, appDelegate.maxconfmembers];
    if ([participantsWillCall count] + 1 <= appDelegate.maxconfmembers)
    {
        self.labelMaxconfMembers.hidden = YES;
        self.labelTitle.textColor = [UIColor whiteColor];
    }
    else
    {
        self.labelMaxconfMembers.hidden = NO;
        self.labelTitle.textColor = [UIColor redColor];
    }
    self.labelTitle.text = tempTitleString;
}

- (IBAction) onButtonClick: (id)sender {
    if (sender == buttonSave) {
        if ([participants count] == 0) {
            NSString* strMsg = NSLocalizedString(@"No other participant", @"No other participant");
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add to Conference Favorites", @"Add to Conference Favorites") message:strMsg delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            return;
        }
        [self saveConferenceMembers];
    } else if (sender == buttonGroup) {
        ConferenceFavoritesViewController* cfv = [[ConferenceFavoritesViewController alloc] initWithNibName:@"ConferenceFavoritesView" bundle:[NSBundle mainBundle]];
        cfv.isFromConferenceView = YES;
        cfv.GroupName = [NSString stringWithString:conffavorite.name];
        [cfv SetDelegate:self];
        [self.navigationController pushViewController:cfv animated:YES];
        [cfv release];
    } else if (sender == buttonCall) {
        CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
        if ([participantsWillCall count] + 1 > appDelegate.maxconfmembers) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                            message: NSLocalizedString(@"Reach the max participants limit!", @"Reach the max participants limit!")
                                                           delegate: self
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            
            return;
        }
        else
        {
            [self ButtonCallEvent];
        }
    } else if (sender == buttonSelectedAll) {
        if (isSelectedAll == NO)
        {
            if ([participants count] > 1)
            {
                isSelectedAll = YES;
                [buttonSelectedAll setTitle:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Cancel", @"Cancel"), NSLocalizedString(@"Select All", @"Select All")] forState:UIControlStateNormal];
                [participantsWillCall removeAllObjects];
                for (int index=0; index<[participants count]; index++)
                {
                    GMGridViewCell *ViewCell = [_gmGridView cellForItemAtIndex:index];
                    ConferenceGridViewCell *gridViewCell = (ConferenceGridViewCell *)ViewCell.contentView;
                    ConferenceMember *cm = [participants objectAtIndex:index];
                    if (![cm.participant.Number isEqualToString:mynum])
                    {
                        gridViewCell.selectedImage.image = [UIImage imageNamed:@"group_member_selected.png"];
                        cm.participant->selected = YES;
                        [participantsWillCall addObject:cm];
                    }
                }
            }
            else
            {
                NSString* strMsg = NSLocalizedString(@"No other participant", @"No other participant");
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") message:strMsg delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                return;
            }
        }
        else
        {
            isSelectedAll = NO;
            [buttonSelectedAll setTitle:NSLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
            [participantsWillCall removeAllObjects];
            for (int index=0; index< [participants count]; index++)
            {
                GMGridViewCell *ViewCell = [_gmGridView cellForItemAtIndex:index];
                ConferenceGridViewCell *gridViewCell = (ConferenceGridViewCell *)ViewCell.contentView;
                ConferenceMember *cm = [participants objectAtIndex:index];
                gridViewCell.selectedImage.image = [UIImage imageNamed:@"group_member_unselected.png"];
                cm.participant->selected = NO;
            }
        }
        CCLog(@"participantsWillCall count= %d", [participantsWillCall count]);
        [self updateTitleText];
    } else if (sender == buttonPick) {
        
        if ([self.txtFieldAdd isFirstResponder])
            [self.txtFieldAdd resignFirstResponder];
        
        SelectParticipantViewController* sp = [[SelectParticipantViewController alloc] initWithNibName:@"SelectParticipantView" bundle:[NSBundle mainBundle]];
        [sp SetDelegate: self];
        
        [self.navigationController pushViewController:sp animated:YES];
        [sp release];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    [self updateTitleText];
    return participants ? [participants count] : 0;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        return CGSizeMake(145, 80);
    }
    else
    {
        return CGSizeMake(145, 80);
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //CCLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[[GMGridViewCell alloc] init] autorelease];
        cell.deleteButtonIcon = [UIImage imageNamed:@"delete_member.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        ConferenceGridViewCell *gridViewCell = [[ConferenceGridViewCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        cell.contentView = gridViewCell;
        [gridViewCell release];
    }
    ConferenceGridViewCell *gridViewCell = (ConferenceGridViewCell*)cell.contentView;
    ConferenceMember *cm = [participants objectAtIndex:index];
    if ([cm.participant.Number isEqualToString:mynum])
    {
        gridViewCell.selectedImage.hidden = YES;
        cell.deleteButton.hidden = YES;
        
        //显示本机号码头像
        NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber: mynum];
        
        dispatch_queue_t queue = dispatch_queue_create (DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
        dispatch_async(queue, ^{
            if (contact && contact.picture != nil)
            {
                UIImage *avatarImage = [StaticUtils createRoundedRectImage:[UIImage imageWithData:contact.picture] size:CGSizeMake(80, 80)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    gridViewCell.headPortrait.image = avatarImage;
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    gridViewCell.headPortrait.image = [StaticUtils createRoundedRectImage:[UIImage imageNamed:@"contact_head.png"] size:CGSizeMake(80, 80)];
                });
            }
        });
        dispatch_release(queue);
    }
    else
    {
        gridViewCell.selectedImage.hidden = NO;
        cell.deleteButton.hidden = NO;
        
        dispatch_queue_t queue = dispatch_queue_create (DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
        dispatch_async(queue, ^{
            if ([cm.participant.picture bytes] != nil)
            {
                UIImage *avatarImage = [StaticUtils createRoundedRectImage:[UIImage imageWithData:cm.participant.picture] size:CGSizeMake(80, 80)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    gridViewCell.headPortrait.image = avatarImage;
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    gridViewCell.headPortrait.image = [StaticUtils createRoundedRectImage:[UIImage imageNamed:@"contact_head.png"] size:CGSizeMake(80, 80)];
                });
            }
        });
        dispatch_release(queue);
        
    }
    
    if (cm.participant->selected == YES)
    {
        gridViewCell.selectedImage.image = [UIImage imageNamed:@"group_member_selected.png"];
    }
    else
    {
        gridViewCell.selectedImage.image = [UIImage imageNamed:@"group_member_unselected.png"];
    }
    
    gridViewCell.name.text = cm.participant.Name;
    gridViewCell.name.adjustsFontSizeToFitWidth = YES;
    gridViewCell.phoneNumber.text = cm.participant.Number;
    
    return cell;
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    ConferenceMember *cm = [participants objectAtIndex:index];
    
    if (cm.participant->selected == YES)
    {
        [participantsWillCall removeObject:cm];
    }
    [participants removeObjectAtIndex:index];
    [_gmGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
    
    if ([participantsWillCall count] == [participants count]-1)
    {
        isSelectedAll = YES;
        [buttonSelectedAll setTitle:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Cancel", @"Cancel"), NSLocalizedString(@"Select All", @"Select All")] forState:UIControlStateNormal];
    }
    else
    {
        isSelectedAll = NO;
        [buttonSelectedAll setTitle:NSLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    }
    
    [self updateTitleText];
    [[NSNotificationCenter defaultCenter] postNotificationName:kConferenceFavTableReload object:nil];
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if (isLongPress == NO)
    {
        GMGridViewCell *ViewCell = [_gmGridView cellForItemAtIndex:position];
        ConferenceGridViewCell *gridViewCell = (ConferenceGridViewCell *)ViewCell.contentView;
        
        ConferenceMember *cm = [participants objectAtIndex:position];
        
        if(![cm.participant.Number isEqualToString:mynum])
        {
            if (cm.participant->selected == NO)
            {
                [participantsWillCall addObject:cm];
                gridViewCell.selectedImage.image = [UIImage imageNamed:@"group_member_selected.png"];
                cm.participant->selected = YES;
            }
            else
            {
                [participantsWillCall removeObject:cm];
                gridViewCell.selectedImage.image = [UIImage imageNamed:@"group_member_unselected.png"];
                cm.participant->selected = NO;
            }
            
            if ([participantsWillCall count] == [participants count]-1)
            {
                isSelectedAll = YES;
                [buttonSelectedAll setTitle:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Cancel", @"Cancel"), NSLocalizedString(@"Select All", @"Select All")] forState:UIControlStateNormal];
            }
            else
            {
                isSelectedAll = NO;
                [buttonSelectedAll setTitle:NSLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
            }
            CCLog(@"phoneNumber=%@", gridViewCell.phoneNumber.text);
            CCLog(@"position=%d", position);
            CCLog(@"participantsWillCall=%d", [participantsWillCall count]);
        }
        [self updateTitleText];
    }
    else
    {
        isLongPress = NO;
    }
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor orangeColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    isLongPress = YES;
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    NSObject *object = [participants objectAtIndex:oldIndex];
    [participants removeObject:object];
    [participants insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [participants exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}


//////////////////////////////////////////////////////////////
#pragma mark DraggableGridViewTransformingDelegate
//////////////////////////////////////////////////////////////

- (CGSize)GMGridView:(GMGridView *)gridView sizeInFullSizeForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index inInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (INTERFACE_IS_PHONE)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(310, 310);
        }
        else
        {
            return CGSizeMake(310, 310);
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(700, 530);
        }
        else
        {
            return CGSizeMake(700, 530);
        }
    }
}

- (UIView *)GMGridView:(GMGridView *)gridView fullSizeViewForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    UIView *fullView = [[[UIView alloc] init] autorelease];
    fullView.backgroundColor = [UIColor yellowColor];
    fullView.layer.masksToBounds = NO;
    fullView.layer.cornerRadius = 8;
    
    CGSize size = [self GMGridView:gridView sizeInFullSizeForCell:cell atIndex:index inInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    fullView.bounds = CGRectMake(0, 0, size.width, size.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:fullView.bounds];
    label.text = [NSString stringWithFormat:@"Fullscreen View for cell at index %d", index];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (INTERFACE_IS_PHONE)
    {
        label.font = [UIFont boldSystemFontOfSize:15];
    }
    else
    {
        label.font = [UIFont boldSystemFontOfSize:20];
    }
    
    [fullView addSubview:label];
    [label release];
    
    return fullView;
}

- (void)GMGridView:(GMGridView *)gridView didStartTransformingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor blueColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEndTransformingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell
{
    
}

#pragma mark -
#pragma mark MoreBtnTableViewDelegate
- (void)MoreBtnTableViewDidSelectRowAtIndexPath:(NSInteger)optionClick
{
    [self.popoverController dismissPopoverAnimated:YES];
    switch (optionClick)
    {
        case kTagMoreBtn_Order:
        {
            if ([participantsWillCall count] == 0)
            {
                NSString* strMsg = NSLocalizedString(@"No other participant", @"No other participant");
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall") message:strMsg delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
            }
            else
            {
                [self saveConferenceMembers];
                GroupCallOrderViewController *orderView = [[GroupCallOrderViewController alloc] initWithNibName:@"GroupCallOrderViewController" bundle:nil];
                orderView.participantsOrder = participantsWillCall;
                orderView.conffavorite = conffavorite;
                [self.navigationController pushViewController:orderView animated:YES];
                [orderView release];
            }
            break;
        }
        case kTagMoreBtn_MassTexting:
        {
            NSMutableArray *massTextingPhoneNumbers = [NSMutableArray arrayWithCapacity:10];
            NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
            for (ConferenceMember *cm in participantsWillCall)
            {
                if (![cm.participant.Number isEqualToString:num])
                    [massTextingPhoneNumbers addObject:cm.participant.Number];
            }
            [self massTexting:massTextingPhoneNumbers];
            break;
        }
        case kTagMoreBtn_Edit:
        {
            _gmGridView.editing = YES;
            self.buttonSave.hidden = YES;
            self.buttonSelectedAll.hidden = YES;
            [self->barButtonItemMore setBackgroundImage:[UIImage imageNamed:@"submit_up.PNG"] forState:UIControlStateNormal];
            [self->barButtonItemMore setBackgroundImage:[UIImage imageNamed:@"submit_down.PNG"] forState:UIControlStateHighlighted];
            oldGroupCallMembers = [participants count];
            break;
        }
        case kTagMoreBtn_Share:
        {
            NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
            
            NSDictionary *jsonDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"conference", @"type",
                                     num, @"user_number", nil];
            
            NSData *jsonData = [jsonDic JSONData];
            
            [[HttpRequest instance] addRequest:kGroupCallShareContentUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                                 successTarget:self successAction:@selector(responseWithSucceeded:)
                                 failureTarget:self failureAction:@selector(responseWithFailed:) userInfo:nil];
            [self shareOnline:nil];
            break;
        }
        default:
            break;
    }
}

- (void)shareOnline:(id)sender
{
    CloudCall2AppDelegate *_appDelegate = [CloudCall2AppDelegate sharedInstance];
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeSinaWeibo, ShareTypeTencentWeibo, ShareTypeSMS, ShareTypeQQSpace, ShareTypeWeixiSession, ShareTypeWeixiTimeline, ShareTypeDouBan, nil];

    
    NSString *shareString = [[NgnEngine sharedInstance].configurationService getStringWithKey:GROUPCALL_SHARE_TEXT];
    if ([shareString length] == 0)
    {
        shareString = @"推荐一个比微信猛的软件，不用在线都可以一起聊天打电话。群主仰天一吼，发起拨号邀请，接听马上侃大山，忒牛X。微信还耗流量！云通这货直接用无线电波，就耗你电量！#云通网络电话#这里可以下载：http://www.ybt88.com/download/autodownload.php";
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:shareString
                                       defaultContent:@""
                                                image:nil
                                                title:@"云通免费网络电话"
                                                  url:kAppRedirectURI
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeText];
    
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:(id<ISSViewDelegate>)_appDelegate.viewDelegate];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"云通免费网络电话"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"云通免费网络电话"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                          oneKeyShareList:shareList
                                                           qqButtonHidden:NO
                                                    wxSessionButtonHidden:NO
                                                   wxTimelineButtonHidden:NO
                                                     showKeyboardOnAppear:NO
                                                        shareViewDelegate:(id<ISSShareViewDelegate>)_appDelegate.viewDelegate
                                                      friendsViewDelegate:(id<ISSViewDelegate>)_appDelegate.viewDelegate
                                                    picViewerViewDelegate:nil]
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    CCLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    CCLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

- (void)massTexting:(NSArray*) phonenums {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init]; //autorelease];
        controller.recipients = phonenums;
//        controller.body = NSLocalizedString(@"Invite Message Content", @"Invite Message Content");
        controller.messageComposeDelegate = self;
        
        [self presentModalViewController:controller animated:YES];
        //        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"SomethingElse"];//修改短信界面标题
        [controller release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Note Info", @"Note Info")
                                                        message:NSLocalizedString(@"No SMS Support", @"No SMS Support")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

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

#pragma mark -
#pragma mark HttpRequest API

- (void)responseWithSucceeded:(NSData *)data {
	if (data == nil)
        return;
    
    NSMutableDictionary *root = [data mutableObjectFromJSONData];
    NSString* result   = [root objectForKey:@"result"];
    if ([result isEqualToString:@"success"])
    {
        NSString *shareText = [root objectForKey:@"sharetext"];
        NSString *smsText = [root objectForKey:@"smstext"];
        
        [[NgnEngine sharedInstance].configurationService setStringWithKey:GROUPCALL_SHARE_TEXT andValue:shareText];
        [[NgnEngine sharedInstance].configurationService setStringWithKey:GROUPCALL_SMS_TEXT andValue:smsText];
        
    }
    else
    {
        CCLog(@"error=%@", [root objectForKey:@"text"]);
    }
}

- (void)responseWithFailed:(NSError *)error {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
//                                                    message:[error localizedDescription]
//                                                   delegate:nil
//                                          cancelButtonTitle:nil
//                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
//    [alert show];
//    [alert release];
}

- (void)dealloc {
    _gmGridView = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [popoverController release];
    [viewToolbar release];
    [toolbar release];
    [labelTitle release];
    [labelMaxconfMembers release];
    
    [buttonGroup release];
    [buttonSave release];
    [buttonCall release];
    [buttonPick release];
    
    [txtFieldAdd release];
    
    [cmMyNumber release];
    [self->cellMyNum release];
    
    [viewKeys release];
    
    [participants release];
    [participantsWillCall release];
    
    [keyboardToolbar release];
    
    [progressView release];
    
    [super dealloc];
}

// ParticipantPickerDelegate
-(void) shouldContinueAfterPickingContacts: (NSMutableArray*) contacts{
    CCLog(@"shouldContinueAfterPickingContacts");
    for (int i=0; i<[contacts count]; i++) {
        ParticipantInfo* pi = [contacts objectAtIndex:i];
        
        if ([pi.Number isEqualToString:mynum]) {
            NSString* strPrompt = [NSString stringWithFormat:@"%@ %@", pi.Name, NSLocalizedString(@"already exist in conference.", @"already exist in conference.")];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                            message: strPrompt
                                                           delegate: self
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            
            continue;
        }
        
        BOOL found = NO;
        for (int i=0; i<[participants count]; i++) {
            ConferenceMember* c = [participants objectAtIndex:i];
            if ([c.participant.Number isEqualToString:pi.Number]) {
                found = YES;
                break;
            }
        }
        if (found) {
            continue;
        }
        
        ConferenceMember* cm = [[ConferenceMember alloc] initWithParticipant:pi andStatus:CONF_MEMBER_STATUS_NONE];
        [participants addObject:cm];
        [participantsWillCall addObject:cm];
        [cm release];
    }
    if ([participantsWillCall count] == [participants count]-1)
    {
        isSelectedAll = YES;
        [buttonSelectedAll setTitle:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Cancel", @"Cancel"), NSLocalizedString(@"Select All", @"Select All")] forState:UIControlStateNormal];
    }
    [_gmGridView reloadData];
    
}

// ParticipantPickerFromGroupDelegate
-(void) shouldContinueAfterPickingFromGroup:(NSMutableArray *)contacts{
    CCLog(@"shouldContinueAfterPickingFromGroup");
    for (int i=0; i<[contacts count]; i++) {
        ParticipantInfo* pi = [contacts objectAtIndex:i];
        
        if ([pi.Number isEqualToString:mynum]) {
            NSString* strPrompt = [NSString stringWithFormat:@"%@ %@", pi.Name, NSLocalizedString(@"already exist in conference.", @"already exist in conference.")];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                            message: strPrompt
                                                           delegate: self
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            
            continue;
        }
        
        BOOL found = NO;
        for (int i=0; i<[participants count]; i++) {
            ConferenceMember* c = [participants objectAtIndex:i];
            if ([c.participant.Number isEqualToString:pi.Number]) {
                found = YES;
                break;
            }
        }
        if (found) {
            //            NSString* strPrompt = [NSString stringWithFormat:@"%@ %@", pi.Name, NSLocalizedString(@"already exist in conference.", @"already exist in conference.")];
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
            //                                                            message: strPrompt
            //                                                           delegate: self
            //                                                  cancelButtonTitle: nil
            //                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
            //            [alert show];
            //            [alert release];
            
            continue;
        }
        
        ConferenceMember* cm = [[ConferenceMember alloc] initWithParticipant:pi andStatus:CONF_MEMBER_STATUS_NONE];
        [participants addObject:cm];
        [participantsWillCall addObject:cm];
        [cm release];
    }
    
    if ([participantsWillCall count] == [participants count]-1)
    {
        isSelectedAll = YES;
        [buttonSelectedAll setTitle:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Cancel", @"Cancel"), NSLocalizedString(@"Select All", @"Select All")] forState:UIControlStateNormal];
    }
    [_gmGridView reloadData];
}

-(void) LoadFavorite {
    NSMutableArray *phonenumbers = [[[NSMutableArray alloc] init] autorelease];
    [[NgnEngine sharedInstance].storageService dbLoadConfParticipants:phonenumbers Uuid:conffavorite.uuid];
    [participants removeAllObjects];
    [participants addObject:cmMyNumber];
    
    for (int i=0; i<[phonenumbers count]; i++) {
        NSString* strNum = [phonenumbers objectAtIndex:i];
        
        ParticipantInfo* pi = [[ParticipantInfo alloc] init];
        NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber: strNum];
        pi.Number = strNum;
        
        if (contact && contact.displayName && [contact.displayName length]) {
            pi.Name = contact.displayName;
            pi.picture = contact.picture;
            for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers) {
                if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number) {
                    NSString* tmpPhoneNum = [phoneNumber.number phoneNumFormat];
                    
                    if ([tmpPhoneNum isEqualToString:strNum]) {
                        pi.Description = phoneNumber.description;
                        break;
                    }
                }
            }
        } else {
            pi.Name = NSLocalizedString(@"No Name", @"No Name");
        }
        
        ConferenceMember* cm = [[ConferenceMember alloc] initWithParticipant:pi andStatus:CONF_MEMBER_STATUS_NONE];
        [participants addObject:cm];
        [cm release];
        
        [pi release];
    }
    [_gmGridView reloadData];
    
}

//
//	UIActionSheetDelegate
//

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		switch (actionSheet.tag) {
                
        }
    }
}

@end