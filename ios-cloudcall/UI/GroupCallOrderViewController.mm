//
//  GroupCallOderViewController.m
//  CloudCall
//
//  Created by CloudCall on 13-6-20.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "GroupCallOrderViewController.h"
#import "ConferenceMember.h"
#import "CloudCall2AppDelegate.h"
#import "JSONKit.h"

@interface GroupCallOrderViewController ()

@end

@implementation GroupCallOrderViewController
@synthesize topicLabel;
@synthesize startTimeLabel;
@synthesize remindLabel;
@synthesize membersLabel;
@synthesize sendOrderSMS;
@synthesize orderTableView;
@synthesize participantsOrder;
@synthesize remindTimeField;
@synthesize remindTimePicker;
@synthesize remindSwitch;
@synthesize groupCallTopic;
@synthesize conffavorite;

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
    self.title = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"GroupCall", @"GroupCall"), NSLocalizedString(@"Reservation", @"Reservation")];
    
    //判断设备的版本
    if (SystemVersion >= 5.0)
    {    //ios5 新特性
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"toolbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:56.0/255.0 green:163.0/255.0 blue:253.0/255.0 alpha:1.0];
    }
    
    //本地化
    topicLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"GroupCall", @"GroupCall"), NSLocalizedString(@"Topic", "Topic")];
    startTimeLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"GroupCall", @"GroupCall"), NSLocalizedString(@"Start Time", "Start Time")];
    remindLabel.text = NSLocalizedString(@"Remind", @"Remind");
    remindLabel.adjustsFontSizeToFitWidth = YES;
    
    membersLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"GroupCall", @"GroupCall"), NSLocalizedString(@"Members", "Members")];;
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(back:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    if(iPhone5)
    {
        self.sendOrderSMS.frame = CGRectMake(sendOrderSMS.frame.origin.x, sendOrderSMS.frame.origin.y+88, sendOrderSMS.frame.size.width, sendOrderSMS.frame.size.height);
    }
    [sendOrderSMS setTitle:NSLocalizedString(@"Send Reservation SMS", @"Send Reservation SMS") forState:UIControlStateNormal];
    
    self.remindSwitch.on = NO;
    
    //显示当前时间
    NSDate *now = [[NSDate alloc] init];
	[remindTimePicker setDate:[now dateByAddingTimeInterval:60*30] animated:NO];
    remindTimePicker.minimumDate = [now dateByAddingTimeInterval:60];
	[now release];
    
    keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.items = [NSArray arrayWithObjects:
                             [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelInput)] autorelease],
                             [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                             [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithInput)] autorelease],
                             nil];
    [keyboardToolbar sizeToFit];
    
    self.remindTimeField.inputView = remindTimePicker;
    self.remindTimeField.inputAccessoryView = keyboardToolbar;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [topicLabel release];
    [startTimeLabel release];
    [remindLabel release];
    [membersLabel release];
    [sendOrderSMS release];
    [orderTableView release];
    [participantsOrder release];
    [remindTimePicker release];
    [remindTimeField release];
    [keyboardToolbar release];
    [groupCallTopic release];
    [conffavorite release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark customized methods
- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)ButtonClick:(id)sender
{
    [self massTexting:groupCallTopic.text andTime:[remindTimePicker date]];
}

- (IBAction) onSwitchChanged: (id) sender
{
    UISwitch *switcher = (UISwitch *)sender;
    if (switcher == remindSwitch)
    {
        BOOL on = switcher.on;
        if (on == YES)
        {
            [self doneWithInput];
        }
        else
        {
            [self ClearGroupCallOrderRemind:conffavorite.uuid];
        }
    }
}

- (void)massTexting:(NSString*)_groupCallTopic andTime:(NSDate *)remindTime
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        NSMutableArray *massTextingPhoneNumbers = [NSMutableArray arrayWithCapacity:10];
        NSMutableString *participantsStr = [NSMutableString stringWithCapacity:10];
        for (ConferenceMember *cm in participantsOrder)
        {
            [massTextingPhoneNumbers addObject:cm.participant.Number];
            [participantsStr appendFormat:@"%@(%@),",cm.participant->Name, cm.participant->Number];
        }
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        //用[NSDate date]可以获取系统当前时间
        NSString *currentDateStr = [dateFormatter stringFromDate:remindTime];
        [dateFormatter release];
        
        NSString *messageText = [NSString stringWithFormat:@"我邀请你参加群呼会议，会议主题：%@，会议时间：%@，参与人员：%@。我正使用的是云通：http://t.cn/zQPDgvP", _groupCallTopic, currentDateStr, participantsStr];
        
        controller.recipients = massTextingPhoneNumbers;
        controller.body = messageText;
        controller.messageComposeDelegate = self;
        
        [self presentModalViewController:controller animated:YES];
        
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

- (IBAction) textFieldDoneEditing:(id)sender
{
    int length = [self convertToInt:groupCallTopic.text];
    if (length > 15)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GroupCall", @"GroupCall")
                                                         message:[NSString stringWithFormat:NSLocalizedString(@"Beyond character limit, please enter again(Chinese is %d,English is %d)", @"Beyond character limit, please enter again(Chinese is %d,English is %d)"), 15, 30]
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    }
    
    [sender resignFirstResponder];
}

/**
 *	@brief	点击弹出工具栏完成按钮事件
 */
-(void)doneWithInput
{
    NSDate *selectedDate = [remindTimePicker date];
    NSDate *now = [NSDate new];
    if ([selectedDate compare:now] == NSOrderedAscending)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message:@"你要穿越到过去吗?请重新选择预约时间吧!"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"I know", @"I know"), nil];
        [alert show];
        [alert release];
         
    }
    else
    {
        [self.remindTimeField resignFirstResponder];
        self.remindSwitch.on = YES;
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        //用[NSDate date]可以获取系统当前时间
        NSString *currentDateStr = [dateFormatter stringFromDate:selectedDate];
        [dateFormatter release];
        
        self.remindTimeField.text = currentDateStr;
        
        NSDate *sendSMSTime = [now dateByAddingTimeInterval:[selectedDate timeIntervalSinceDate:now]];
        
        UILocalNotification *notification = [[[UILocalNotification alloc] init] autorelease];
        if (notification != nil)
        {
            notification.fireDate = sendSMSTime;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.timeZone = [NSTimeZone systemTimeZone];
            notification.alertAction = NSLocalizedString(@"OK", @"OK");
//            notification.applicationIconBadgeNumber = ++[UIApplication sharedApplication].applicationIconBadgeNumber;
            notification.alertBody = @"群呼预约时间到啦,赶紧群呼他们吧!";
//            int IconBadgeNumber = [[NgnEngine sharedInstance].configurationService getIntWithKey:NOTIFICATION_ICON_BADGE];
//            [[NgnEngine sharedInstance].configurationService setIntWithKey:NOTIFICATION_ICON_BADGE andValue:++IconBadgeNumber];
            
            NSMutableDictionary *groupCallRemindDic = [NSMutableDictionary dictionaryWithCapacity:20];
            
            [groupCallRemindDic setObject:kNotifKey_GroupCallRemind forKey:kNotifKey];
            [groupCallRemindDic setObject:conffavorite.uuid forKey:kNotifKey_GroupCallUUID];
            
            notification.userInfo = groupCallRemindDic;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
        NSLog(@"%@\n%@", selectedDate,sendSMSTime);
    }
    [now release];
}

/**
 *	@brief	点击弹出工具栏取消按钮事件
 */
-(void)cancelInput
{
    [self.remindTimeField resignFirstResponder];
}

- (void)ClearGroupCallOrderRemind:(NSString *)_uuid
{
    for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        if([[aNotif.userInfo objectForKey:kNotifKey] isEqualToString:kNotifKey_GroupCallRemind] &&
           [[aNotif.userInfo objectForKey:kNotifKey_GroupCallUUID] isEqualToString:_uuid])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:aNotif];
        }
    }
}

#pragma mark
#pragma mark table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section
{
    return [participantsOrder count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell"];
    UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
    UITableViewCell *cell = [orderTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];
    }
    
    ConferenceMember* cm = [participantsOrder objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", cm.participant.Name, cm.participant.Number];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"System Bold" size:15.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark
#pragma mark table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
            [self.navigationController popViewControllerAnimated:YES];
            //do something
        }
            break;
        default:
            break;
    }
}

@end
