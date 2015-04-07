//
//  CreateGroupViewController.m
//  CloudCall
//
//  Created by CloudCall on 13-6-19.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "ConferenceFavoritesViewController.h"
#import "SelectParticipantViewController.h"
#import "CloudCall2AppDelegate.h"

#import "NgnEngine.h"
@interface CreateGroupViewController ()

@end

@implementation CreateGroupViewController
@synthesize addGroupMembersBtn;
@synthesize groupNameField;
@synthesize inputGroupNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"Create Group", @"Create Group");
    
    //本地化
    self.inputGroupNameLabel.text = NSLocalizedString(@"Please input group name", @"Please input group name");
    [addGroupMembersBtn setTitle:NSLocalizedString(@"Add Group Members >>", @"Add Group Members >>") forState:UIControlStateNormal];
    
    //判断设备的版本
    if (SystemVersion >= 5.0)
    {    //ios5 新特性
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"toolbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:56.0/255.0 green:163.0/255.0 blue:253.0/255.0 alpha:1.0];
    }
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(back:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [groupNameField release];
    [inputGroupNameLabel release];
    [addGroupMembersBtn release];
    [super dealloc];
}

#pragma mark Action
- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)ButtonClick:(id)sender
{
    if (sender == addGroupMembersBtn)
    {
        [self addGroupMember];
    }
}

#pragma mark customized Methods
-  (int)convertToInt:(NSString*)strtemp {
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}

- (NSString*)Getuuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFStringCreateCopy( NULL, uuidString);
    CFRelease(puuid);
    CFRelease(uuidString);
    return [result autorelease];
}

- (void)addGroupMember
{
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSString* strName = groupNameField.text;
    int length = [self convertToInt:strName];
    
    if (!strName || [strName length] == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                         message:NSLocalizedString(@"Group name is required", @"Group name is required")
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    } else if (length > 7) {
        NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Beyond character limit, please enter again(Chinese is %d,English is %d)", @"Beyond character limit, please enter again(Chinese is %d,English is %d)"), 7, 14];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                         message:[NSString stringWithFormat:@"%@%@",alertMessage,SystemVersion >= 5?nil:@"\n\n"]
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    } else {
        if ([mynum length] && [mynum isEqualToString:DEFAULT_IDENTITY_IMPI] == NO) {
            BOOL found = [[NgnEngine sharedInstance].storageService dbCheckConfFavorite:mynum andName:strName];
            if (found) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                 message:NSLocalizedString(@"Group name already exist", @"Group name already exist")
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                return;
            }
            
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            NSString *uuid = [self Getuuid];
            
            NgnConferenceFavorite* nf = [[NgnConferenceFavorite alloc] initWithMynumber:mynum andName:strName andUuid:uuid andType:Conf_Type_Private andUpdateTime:time andStatus:Conf_Edit_Status_Add];
            [[NgnEngine sharedInstance].storageService dbAddConfFavorite:nf];
            
            //////////////////////////////////////////////////////////////////////////
            CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
            GroupCallRecord* r = [[GroupCallRecord alloc] initWithUserNumber:mynum andName:strName andGroupId:uuid andType:Conf_Type_Private andUpdateTime:time andMembers:nil];
            [appDelegate AddGroupCallRecords:[NSArray arrayWithObject:r]];
            [r release];
            //////////////////////////////////////////////////////////////////////////

            [[NSNotificationCenter defaultCenter] postNotificationName:kConferenceFavTableReload object:[NSNumber numberWithBool:YES]];
            
            SelectParticipantViewController* sp = [[SelectParticipantViewController alloc] initWithNibName:@"SelectParticipantView" bundle:[NSBundle mainBundle]];
            sp.isNewGroup = YES;
            sp.conffavorite = nf;
            sp.uuid = uuid;
            [self.navigationController pushViewController:sp animated:YES];
            [sp release];
            [nf release];
        }
    }
}

@end
