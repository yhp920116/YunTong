//
//  SelectParticipantFromGroupViewController.m
//  CloudCall
//
//  Created by CloudCall on 13-2-20.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import "SelectParticipantFromGroupViewController.h"
#import "SelectParticipantViewController.h"
#import "CloudCall2AppDelegate.h"
#import "ConferenceMember.h"

@interface SelectParticipantFromGroupViewController ()

@end

@implementation SelectParticipantFromGroupViewController
@synthesize tableView;
@synthesize viewToolbar;
@synthesize toolbar;
@synthesize labelTitle;
@synthesize conffavorite;
@synthesize uuid;
@synthesize toolBtnSelectAll;

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
    
    ///////////////////////////////////////
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageview.image = [UIImage imageNamed:@"toolbar_bg.png"];
    [self.toolbar addSubview:imageview];
    [imageview release];
    ///////////////////////////////////////
    
    self.labelTitle.text = @"";
    
    self->barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [self->barButtonItemBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonItemBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonItemBack];
    
    NSString* strSelectAll   = NSLocalizedString(@"Select All", @"Select All");
    NSString* strDeselectAll = NSLocalizedString(@"Deselect All", @"Deselect All");
    NSString* strAll = [strSelectAll length] > [strDeselectAll length] ? strSelectAll : strDeselectAll;
    CGSize strAllSize = [strAll sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(280, 100) lineBreakMode:UILineBreakModeCharacterWrap];
    self.toolBtnSelectAll = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBtnSelectAll.frame = CGRectMake(135, 7, 72, 30);
    [self.toolBtnSelectAll setTitle:IsSelectAll ? NSLocalizedString(@"Deselect All", @"Deselect All") : NSLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    [self.toolBtnSelectAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    toolBtnSelectAll.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self.toolBtnSelectAll setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_up.png"] forState:UIControlStateNormal];
    [self.toolBtnSelectAll setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_down.png"] forState:UIControlStateHighlighted];
    [toolBtnSelectAll addTarget:self action:@selector(selectAll) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:toolBtnSelectAll];
    
    self->barButtonDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonDone.frame = CGRectMake(276, 0, 44, 44);
    self->barButtonDone.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [self->barButtonDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self->barButtonDone setBackgroundImage:[UIImage imageNamed:@"submit_up.PNG"] forState:UIControlStateNormal];
    [self->barButtonDone setBackgroundImage:[UIImage imageNamed:@"submit_down.PNG"] forState:UIControlStateHighlighted];
    [self->barButtonDone addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.toolbar addSubview:self->barButtonDone];
    // Do any additional setup after loading the view from its nib.
    
    if (!participants) {
		participants = [[NSMutableArray alloc] init];
	}
    [self LoadFavorite];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden: YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden: NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [super dealloc];
    
    [tableView release];
    [viewToolbar release];
    [toolbar release];
    [labelTitle release];
    
    [conffavorite release];
    [uuid release];
}

-(void) SetDelegate:(UIViewController<ParticipantPickerFromGroupDelegate> *)_delegate {
    delegate = _delegate;
}

-(void)selectDone {
    if (delegate) {
        NSMutableArray *selected = [[NSMutableArray alloc] init];        
            for (ConferenceMember *cm in participants) {
                if (cm.participant->selected) {
                    CCLog(@"selectDone: %@, %@\n", cm.participant.Name, cm.participant.Number);
                    [selected addObject: cm.participant];
                }
            }
        
        if ([selected count]) {
            CCLog(@"select %d", [selected count]);
            [delegate shouldContinueAfterPickingFromGroup:selected];
            NSArray *viewArray = [self.navigationController viewControllers];
            int viewIndex = [viewArray count]-3;
            [self.navigationController popToViewController:[viewArray objectAtIndex:viewIndex<0 ? 0 : viewIndex] animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                            message:NSLocalizedString(@"No selected contact", @"No selected contact")
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
        }
        
        [selected release];
    }
}

- (IBAction)onButtonToolBarItemClick: (id)sender {
    if (sender == barButtonItemBack) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (sender == barButtonDone) {
        [self selectDone];
    }
}

-(void)selectAll {
    IsSelectAll = !IsSelectAll;
    
    for (ConferenceMember *cm in participants)
    {
        cm.participant->selected = IsSelectAll;
    }
    
	[self.tableView reloadData];
    
    NSString* strAll = IsSelectAll ? NSLocalizedString(@"Deselect All", @"Deselect All") : NSLocalizedString(@"Select All", @"Select All");

    [self.toolBtnSelectAll setTitle:strAll forState:UIControlStateNormal];
}

-(void) LoadFavorite {
    NSMutableArray *phonenumbers = [NSMutableArray arrayWithCapacity:20];
    [[NgnEngine sharedInstance].storageService dbLoadConfParticipants:phonenumbers Uuid:conffavorite.uuid];
    [participants removeAllObjects];
    
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

}

#pragma mark - IBActions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return participants ? [participants count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    ConferenceMember *cm = [participants objectAtIndex:indexPath.row];
    
    cell.textLabel.text = cm.participant.Name;;
    cell.detailTextLabel.text = cm.participant.Number;
    
    [cell setAccessoryType: cm.participant->selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
	return cell;
}

- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ConferenceMember *cm = [participants objectAtIndex:indexPath.row];
    cm.participant->selected = !cm.participant->selected;
    
    UITableViewCell *selectedCell = [tableView_ cellForRowAtIndexPath:indexPath];
    [selectedCell setAccessoryType: cm.participant->selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    
    [tableView_ deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

@end
