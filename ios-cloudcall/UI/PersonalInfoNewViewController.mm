//
//  PersonalInfoNewViewController.m
//  CloudCall
//
//  Created by Sergio on 13-1-29.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import "PersonalInfoNewViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "CloudCall2AppDelegate.h"
#import "RegexKitLite.h"
#import "HttpRequest.h"
#import "JSONKit.h"
#import "MobClick.h"
#import <ShareSDK/ShareSDK.h>
#import <SinaWeiboConnection/SSSinaWeiboStatus.h>
#import "StaticUtils.h"


enum {
    Get_Info_From_Server,
    Set_Info_To_Server,
};

#define kTagCommitSuccess 101

@interface PersonalInfoNewViewController (Commit)

-(void) sendRequest2ServerSucceeded:(NSData *)data;
-(void) sendRequest2ServerFailed:(NSError *)error;
-(void) sendRequest2Server:(NSMutableDictionary*)data;

-(void) setPersonalInfo:(NSMutableDictionary *)personalInfoDictFormServer;
-(void) getPersonalInfoFormLocal;

@end

@implementation PersonalInfoNewViewController (Commit)

//关闭显示框
-(void)dismissHUD:(id)arg
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    self.hud = nil;
}

//加载
- (void)personalInfoLoaded
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.tableView reloadData];
}

//超时
- (void)timeout:(id)arg
{
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:5.0];
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Personal Information", @"Personal Information")
                                                message:NSLocalizedString(@"Connection timed out, please try again later.", @"Connection timed out, please try again later.")
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                      otherButtonTitles: nil];
    [a show];
    [a release];
}

//网络连接失败
-(void)displayNotConnectionUI
{
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:5.0];
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Personal Information", @"Personal Information")
                                                message:NSLocalizedString(@"No network connection", @"No network connection")
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                      otherButtonTitles: nil];
    [a show];
    [a release];
}

/**
 *	@brief	将服务器获取到的个人信息写入本地
 *
 *	@param 	personalInfoDictFormServer 	服务器数据
 */
- (void)setPersonalInfo:(NSMutableDictionary *)personalInfoDictFormServer
{
    if ([personalInfoDictFormServer count] >= 1) {
        
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"telnumber"] forKey:ACCOUNT_LOCALNUM];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"name"] forKey:ACCOUNT_NAME];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"nickname"] forKey:ACCOUNT_NICKNAME];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"sex"] forKey:ACCOUNT_GENDER];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"birthday"] forKey:ACCOUNT_BIRTHDATE];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"qq"] forKey:ACCOUNT_QQ];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"email"] forKey:ACCOUNT_EMAIL];
        [[NgnEngine sharedInstance].infoService setInfoValue:[personalInfoDictFormServer objectForKey:@"sb"] forKey:ACCOUNT_SINAWEIBO];
    }
    else
    {

        [[NgnEngine sharedInstance].infoService setInfoValue:@"" forKey:ACCOUNT_LOCALNUM];
    }
}

/**
 *	@brief	从本地读取个人信息
 *
 *	@param 	personalInfoDictFormServer 	服务器数据
 */
- (void)getPersonalInfoFormLocal
{
    NSString *currentNum = [NSString stringWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
    NSString *oldNum = [[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_LOCALNUM];
    if([currentNum isEqualToString:oldNum])
    {
        [self.personalInfoDict setValue:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_NAME]] forKey:@"name"];
        [self.personalInfoDict setValue:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_NICKNAME]] forKey:@"nickname"];
        [self.personalInfoDict setValue:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_GENDER]] forKey:@"sex"];
        [self.personalInfoDict setValue:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_BIRTHDATE]] forKey:@"birthday"];
        [self.personalInfoDict setValue:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_QQ]] forKey:@"qq"];
        [self.personalInfoDict setValue:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_EMAIL]] forKey:@"email"];
        [self.personalInfoDict setValue:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_SINAWEIBO]] forKey:@"sb"];
    }
}

-(void) sendRequest2ServerSucceeded:(NSData *)data{
    [self personalInfoLoaded];
    
    NSString *recvString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSString *aStr = [recvString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CCLog(@"PersonalInfoNewViewController sendRequest2ServerSucceeded:%@", aStr);
    //[self parseReceiveData:aStr];
    NSRange range = [aStr rangeOfString:@"name"];
    if(reqType == Get_Info_From_Server) {
        if (range.location != NSNotFound) {
            NSString *resultStr = [aStr stringByReplacingOccurrencesOfString:@"\"(null)\"" withString:@"\"\""];
            CCLog(@"PersonalInfoNewViewController resultStr:%@", resultStr);
            self.personalInfoDict = [resultStr mutableObjectFromJSONString];
            [self setPersonalInfo:self.personalInfoDict];
            
            [self.tableView reloadData];
        }
    } else {
        NSRange range = [aStr rangeOfString:@"success"];
        if (range.location != NSNotFound) {
            NSDictionary *dict = [aStr mutableObjectFromJSONString];
            //NSDictionary *data = [dict objectForKey:@"Data"];
            NSString *text = [dict objectForKey:@"text"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Personal Information", @"Personal Information")
                                                            message:text
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil, nil];
            alert.tag = kTagCommitSuccess;
            [alert show];
            [alert release];
            [self.personalInfoDict setValue:self.phoneNum.text forKey:@"telnumber"];
            [self.personalInfoDict setValue:self.trueName forKey:@"name"];
            [self.personalInfoDict setValue:self.nickName forKey:@"nickname"];
            [self.personalInfoDict setValue:self.sex forKey:@"sex"];
            [self.personalInfoDict setValue:self.birthday forKey:@"birthday"];
            [self.personalInfoDict setValue:self.qq forKey:@"qq"];
            [self.personalInfoDict setValue:self.email forKey:@"email"];
            [self.personalInfoDict setValue:self.sinawb forKey:@"sb"];
            [self setPersonalInfo:self.personalInfoDict];
        }
    }
}

-(void) sendRequest2ServerFailed:(NSError *)error{
    //[personalInfoLoaded]
}

-(void) sendRequest2Server:(NSMutableDictionary*)jsonDic{
    NSString* urlString = @"";
    if (reqType == Get_Info_From_Server) {
        urlString = kDownloadUserInfoUrl;
    } else {
        urlString = kGetUserInfoUrl;
    }

    if (jsonDic) {
        int timeout = 10;
        self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = (reqType == Get_Info_From_Server) ? NSLocalizedString(@"Loading...", @"Loading...") :  NSLocalizedString(@"Submitting...", @"Submitting...");
        [self.hud hide:YES afterDelay:timeout];
        
        [[HttpRequest instance] addRequestWithEncrypt:urlString andMethod:@"POST" andContent:jsonDic andTimeout:timeout
                             delegate:self successAction:@selector(sendRequest2ServerSucceeded:)
                             failureAction:@selector(sendRequest2ServerFailed:) userInfo:nil];
       
    }
}

- (void)getPersonalInfoFromServer{
    reqType = Get_Info_From_Server;

    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.phoneNum.text, @"telnumber", nil];
    [self sendRequest2Server:jsonDic];
}

- (void)setPersonalInfoFromServer{
    reqType = Set_Info_To_Server;
    if ([self.sex isEqualToString:NSLocalizedString(@"Male", @"Male")]) {
        self.sex = @"1";
    }
    else if ([self.sex isEqualToString:NSLocalizedString(@"Female", @"Female")]) {
        self.sex = @"0";
    }
    
    if ([self.birthday isEqualToString:@""])
    {
        self.birthday = @"1990-01-01";
    }
    
    if(![NgnStringUtils isNullOrEmpty:self.email])
    {
        BOOL matchEmail = [self.email isMatchedByRegex:@"^\\w+((-\\w+)|(\\.\\w+))*\\@[A-Za-z0-9]+((\\.|-)[A-Za-z0-9]+)*\\.[A-Za-z0-9]+$"];
        if (!matchEmail)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Personal Information", @"Personal Information") message:NSLocalizedString(@"Invalid email", @"Invalid email") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            self.email = @"";
            return;
        }
    }
    
    NSError *error;
    
    //个人信息数据
    //NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:name.text, @"name",nickName, @"nickName",sex, @"sex",birthday, @"birthday",qq, @"qq",email, @"email",sinawb, @"sinawb",nil];
    //        NSData* jsonBody = nil;
    //        if([NSJSONSerialization isValidJSONObject:body])
    //        {
    //            jsonBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
    //            NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
    //            CCLog(@"btnSubmitPersonalInfo-->%@",json);
    //        }
    self.trueName = self.name.text;
    //        NSMutableString *sbBody =[NSMutableString stringWithCapacity:128];
    //        [sbBody appendFormat:@"{\"telnumber\":\"%@\",\"name\":\"%@\",\"nickname\":\"%@\",\"sex\":\"%@\",\"birthday\":\"%@\",\"email\":\"%@\",\"qq\":\"%@\",\"sb\":\"%@\",\"id\":\"%@\",\"gender\":\"%@\",\"location\":\"%@\",\"profiled_url\":\"%@\",\"verified\":\"%d\",\"weibojsondata\":\"[%@]\"}", self.phoneNum.text, self.trueName, self.nickName, self.sex,self.birthday, self.email, self.qq, self.sinawb, self.sina_Id, self.sina_gender, self.sina_location, self.sina_profileUrl, sina_verified, self.sina_weiBoJsonData];
    
    NSMutableDictionary *userInfoBody = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  self.phoneNum.text,    @"telnumber",
                                  self.trueName,         @"name",
                                  self.nickName,         @"nickname",
                                  self.sex,              @"sex",
                                  self.birthday,         @"birthday",
                                  self.email,            @"email",
                                  self.qq,               @"qq",
                                  self.sinawb,           @"sb",
                                  self.sina_Id,          @"id",
                                  self.sina_gender,      @"gender",
                                  self.sina_location,    @"location",
                                  self.sina_profileUrl,  @"profiled_url",
                                  sina_verified,         @"verified",
                                  self.sina_weiBoJsonData,@"weibojsondata", nil];
    
    
    NSLog(@"UserInfoBody = %@",userInfoBody);
    [self sendRequest2Server:userInfoBody];
}

@end


@interface PersonalInfoNewViewController (KeyboardNotifications)
-(void) keyboardWillHide:(NSNotification *)note;
-(void) keyboardWillShow:(NSNotification *)note;
-(void) keyboardNotificationWithNote:(NSNotification *)note willShow: (BOOL) showing;
@end

@implementation PersonalInfoNewViewController (KeyboardNotifications)

-(void) keyboardWillHide:(NSNotification *)note{
	[self keyboardNotificationWithNote:note willShow:NO];
}

-(void) keyboardWillShow:(NSNotification *)note{
	[self keyboardNotificationWithNote:note willShow:YES];
}

-(void) keyboardNotificationWithNote:(NSNotification *)note willShow: (BOOL)showing{
    if (showing) {
        CGRect keyboardBounds;

        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];

        CGRect tempFrame;
        CGRect frame = self.tableView.frame;
        //        tempFrame.origin = CGPointMake(frame.origin.x, 460 - frame.size.height - keyboardBounds.size.height);
        //在中英切换时,也会产生keyboardWillShow消息,为了防止tableview被再次上移,所以把高度写死了

        tempFrame.origin = frame.origin;
        CGFloat height;
        height = 177.0f;
        
        if (iPhone5)
            height = height+88.0f;
        if (SystemVersion >= 7)
            height += 20.0f;
        
        tempFrame.size = CGSizeMake(frame.size.width, height);

        [UIView beginAnimations:@"Curl"context:nil];//动画开始
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:self];
        [self.tableView setFrame:tempFrame];
        [UIView commitAnimations];
        if (editingFeildIndex >= 11)
        {
            [self performSelector:@selector(scrollTableViewToTop) withObject:nil afterDelay:0];
        }
    } else {
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        CGRect rect = CGRectMake(0.0f, self.tableView.frame.origin.y, self.tableView.frame.size.width, 416.0f);
        if (iPhone5) {
            rect = CGRectMake(0.0f, self.tableView.frame.origin.y, self.tableView.frame.size.width, 510.0f);
        }
        self.tableView.frame = rect;
        [UIView commitAnimations];
    }
}
@end

@implementation PersonalInfoNewViewController
@synthesize tipView;
@synthesize tipText;
@synthesize btnCloseTip;
@synthesize tableView;
@synthesize headerCell;
@synthesize rHeaderView;
@synthesize photo;
@synthesize name;
@synthesize phoneNum;
@synthesize vipLevel;
@synthesize personalInfoPlaceholderArray;
@synthesize personalInfoArray;
@synthesize personalInfoDict;
@synthesize trueName;
@synthesize nickName;
@synthesize sex;
@synthesize birthday;
@synthesize email;
@synthesize qq;
@synthesize sinawb;
@synthesize currentTextFeild;
@synthesize pickerGender;
@synthesize pickerBirthdate;
@synthesize buttonAd;

@synthesize sina_Id;
@synthesize sina_gender;
@synthesize sina_location;
@synthesize sina_verified;
@synthesize sina_profileUrl;
@synthesize sina_weiBoJsonData;

@synthesize hud = _hud;

#pragma mark - ViewController Lifecycle

- (void)dealloc
{
    [keyboardToolbar release];
    if (self.tipView) {
        [tipView release];
    }
    if (tipText) {
        [tipText release];
    }
    [btnCloseTip release];
    [tableView release];
    [headerCell release];
    [rHeaderView release];
    [self->photoImage release];
    [photo release];
    [name release];
    [phoneNum release];
    [vipLevel release];
    [personalInfoPlaceholderArray release];
    [personalInfoArray release];
    [currentTextFeild release];
    [pickerGender release];
    [pickerBirthdate release];
    [buttonAd release];
    
    [sina_Id release];
    [sina_gender release];
    [sina_location release];
    [sina_profileUrl release];
    [sina_weiBoJsonData release];
    
    self.hud = nil;
    [_hud release];
    _hud = nil;
    
    [super dealloc];
}

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
    self.personalInfoDict = [NSMutableDictionary dictionaryWithCapacity:100];

    self.title = NSLocalizedString(@"Personal Information", @"Personal Information");

    //返回按钮
    self->barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [self->barButtonItemBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonItemBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self->barButtonItemBack] autorelease];
    
    //提交按钮
    self->barButtonItemSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonItemSubmit.frame = CGRectMake(273, 0, 44, 44);
    
    [self->barButtonItemSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self->barButtonItemSubmit setBackgroundImage:[UIImage imageNamed:@"submit_up.PNG"] forState:UIControlStateNormal];
    [self->barButtonItemSubmit setBackgroundImage:[UIImage imageNamed:@"submit_down.PNG"] forState:UIControlStateHighlighted];
    self->barButtonItemSubmit.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [self->barButtonItemSubmit addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self->barButtonItemSubmit] autorelease];
    
    //设置表格第一栏圆角
//    rHeaderView.layer.cornerRadius = 8;
    
    //图片框圆角处理
//    UIImageView *imgview = (UIImageView *)self.photo;
//    imgview.layer.cornerRadius = 8;
//    self.name.delegate = self;
//    self.name.tag = 1;
    
    //设置姓名提示信息
    [self.name setPlaceholder:NSLocalizedString(@"Your name", @"Your name")];
    [self.name addTarget:self action:@selector(tableTextFieldWithText:) forControlEvents:UIControlEventEditingChanged];
    
    //设置联系电话 从本地获取IMPI 用于从服务器获取个人数据
    NSString *num = [NSString stringWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
    if ([num isEqualToString:DEFAULT_IDENTITY_IMPI])
        num = @"";
    [self.phoneNum setText:[NSString stringWithFormat:@"%@",num]];
    
    
    NSString *oldnum = [[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_LOCALNUM];
    if([oldnum isEqualToString:num])
        
    if ([oldnum isEqualToString:num]) {
        //获取头像图片
        NgnContact* Mycontact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_LOCALNUM]];
        
        if (Mycontact && Mycontact.picture != nil) {
            // Fetch image from NgnContact
            self.photo.image = [StaticUtils createRoundedRectImage:[UIImage imageWithData:Mycontact.picture] size:CGSizeMake(80, 80)];
        }
        else
        {
            //Fetch image from CoreData
            self.photo.image = [UIImage imageWithData:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_THUMBNAIL]];
        }
        
    }
    
    //设置提示栏
    BOOL tipSwitch = [[NgnEngine sharedInstance].configurationService getBoolWithKey:ACCOUNT_CLOSETIP];
    if (tipSwitch) {
        [self.tipView removeFromSuperview];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,self.tableView.frame.origin.y - 30 , self.tableView.frame.size.width, self.tableView.frame.size.height + 30)];
    }
    
    //设置VIP等级标签
    int userLevel = 0;
    userLevel = [[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_LEVEL] integerValue];
    if (0 == userLevel) {
        [self.vipLevel setHidden:YES];
    } else {
        [self.vipLevel setHidden:NO];
        [self.vipLevel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"vip%d_@2x.png", userLevel]]];
    }
    
    //设置提示信息
    self.tipText.text = NSLocalizedString(@"personal info tips", @"personal info tips");
    
    keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.items = [NSArray arrayWithObjects:
                             [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelInput)] autorelease],
                             [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                             [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithInput)] autorelease],
                             nil];
    [keyboardToolbar sizeToFit];
    
    //获取本地个人信息
    [self getPersonalInfoFormLocal];
    
    genderData = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Male", @"Male"), NSLocalizedString(@"Female", @"Female"), nil];
    
    self.personalInfoPlaceholderArray = [NSArray arrayWithObjects:NSLocalizedString(@"Your nickname", @"Your nickname"),NSLocalizedString(@"Your gender", @"Your gender"),NSLocalizedString(@"Your Birthday", @"Your Birthday"),NSLocalizedString(@"Your QQ", @"Your QQ"),NSLocalizedString(@"Recive preferential info", @"Recive preferential info"),NSLocalizedString(@"Your SinaWeibo", @"Your SinaWeibo"),nil];
    
    self.personalInfoArray = [NSArray arrayWithObjects:NSLocalizedString(@"Nickname", @"Nickname") ,NSLocalizedString(@"Gender", @"Gender"),NSLocalizedString(@"Birthdate", @"Birthdate"),@"QQ",@"E-mail",NSLocalizedString(@"SinaWeibo", @"SinaWeibo"),nil];
    
}

- (void)viewDidUnload
{
    self.trueName = nil;
    self.nickName = nil;
    self.sex = nil;
    self.birthday = nil;
    self.qq = nil;
    self.email = nil;
    self.sinawb = nil;
    self.personalInfoPlaceholderArray = nil;
    self.personalInfoArray = nil;
    self.personalInfoDict = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
    [MobClick beginLogPageView:@"PersonalInfo"];
    
    [self.navigationController setNavigationBarHidden: NO];
    //键盘响应事件
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    [MobClick endLogPageView:@"PersonalInfo"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //新功能提醒消失
    if ([[[NgnEngine sharedInstance].configurationService getStringWithKey:SHOW_NEW_FOR_PERSONALINFO] length] != 0)
    {
        [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FOR_PERSONALINFO andValue:nil];
        [[CloudCall2AppDelegate sharedInstance] ShowNewFeatureRemind];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewReloadData" object:nil];
    }

    if ([NgnEngine sharedInstance].networkService.reachable)
    {
        //从服务器获取个人信息的信息项和提示项
        [self getPersonalInfoFromServer];
    }
    else
    {
        [self displayNotConnectionUI];
    }
    

    NSString *currentNum = [NSString stringWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
    NSString *oldNum = [[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_LOCALNUM];
    if([currentNum isEqualToString:oldNum])
    {
        self.name.text = [NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_NAME]];
    }
    else
    {
        self.email = @"";
    }
    //设置性别和生日的选取器
    if (iPhone5) {
        self.pickerGender.frame = CGRectMake(0, 520, 320, 216);
        self.pickerBirthdate.frame = CGRectMake(0, 520, 320, 216);
    }
    else
    {
        self.pickerGender.frame = CGRectMake(0, 480, 320, 216);
        self.pickerBirthdate.frame = CGRectMake(0, 480, 320, 216);
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *initDate = [dateFormatter dateFromString:@"1990-01-01 00:00:00"];
    self.pickerBirthdate.date = initDate;
    [dateFormatter release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark Private Methods
/**
 *	@brief	点击背景隐藏键盘
 */
- (IBAction)touchBGEndingEditing:(id)sender
{
    [self.view endEditing:YES];
}
- (IBAction)setCustomPhoto:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照上传",@"手机相册上传", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
    
}

- (void)tableTextFieldWithText:(UITextField *)textField
{
    switch (textField.tag)
    {
        case 1:
            if ([textField.text length] > 30) {//Too long to input
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Personal Information", @"Personal Information")
                                                                message:NSLocalizedString(@"Too long to input", @"Too long to input")
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                textField.text = [textField.text substringToIndex:30];
                return;
            }
            self.trueName = textField.text;
            [self.personalInfoDict setValue:self.trueName forKey:@"name"];
            [[NgnEngine sharedInstance].infoService setInfoValue:self.trueName forKey:ACCOUNT_NAME];
            break;
        case 11:
            if ([textField.text length] > 30) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Personal Information", @"Personal Information")
                                                                message:NSLocalizedString(@"Too long to input", @"Too long to input")
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                textField.text = [textField.text substringToIndex:30];
                return;
            }
            self.nickName = textField.text;
            [self.personalInfoDict setValue:self.nickName forKey:@"nickname"];
            [[NgnEngine sharedInstance].infoService setInfoValue:self.nickName forKey:ACCOUNT_NICKNAME];
            break;
        case 14:
            if ([textField.text length] > 30) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Personal Information", @"Personal Information")
                                                                message:NSLocalizedString(@"Too long to input", @"Too long to input")
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                textField.text = [textField.text substringToIndex:50];
                return;
            }
            self.qq = textField.text;
            [self.personalInfoDict setValue:self.qq forKey:@"qq"];
            [[NgnEngine sharedInstance].infoService setInfoValue:self.qq forKey:ACCOUNT_QQ];
            break;
        case 15:
            self.email = textField.text;
            [self.personalInfoDict setValue:self.email forKey:@"email"];
            [[NgnEngine sharedInstance].infoService setInfoValue:self.email forKey:ACCOUNT_EMAIL];
            break;
        default:
            break;
    }
}

/**
 *	@brief	工具栏按钮点击事件
 */
- (IBAction)onButtonToolBarItemClick: (id)sender
{
    if (sender == barButtonItemBack)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender == barButtonItemSubmit)
    {        
        [self setPersonalInfoFromServer];
    }
}


/**
 *	@brief	点击弹出工具栏取消按钮事件
 */
-(void)cancelInput
{
    [self.currentTextFeild resignFirstResponder];
    if (self.currentTextFeild.tag == 12 || self.currentTextFeild.tag == 13 || self.currentTextFeild.tag == 14) {
        ; // do nothing
    } else {
        if (oldContent)
        {
            self.currentTextFeild.text = oldContent;
        }
    }
}

/**
 *	@brief	点击弹出工具栏完成按钮事件
 */
-(void)doneWithInput
{
    if (self.currentTextFeild.tag == 12) {
        NSInteger row = [pickerGender selectedRowInComponent:0];
        self.currentTextFeild.text = [genderData objectAtIndex:row];
        self.sex = self.currentTextFeild.text;
        [self.personalInfoDict setValue:self.sex forKey:@"sex"];
        [[NgnEngine sharedInstance].infoService setInfoValue:self.sex forKey:ACCOUNT_GENDER];
    }
    else if (self.currentTextFeild.tag == 13) {
        NSDate *nowDate = [NSDate date];
        if ([nowDate isEqualToDate:[nowDate earlierDate:pickerBirthdate.date]] || [nowDate isEqualToDate:pickerBirthdate.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Personal Information", @"Personal Information")
                                                            message:NSLocalizedString(@"Invalid date", @"Invalid date")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            return;
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        self.currentTextFeild.text = [NSString stringWithString:[formatter stringFromDate:pickerBirthdate.date]];
        self.birthday = self.currentTextFeild.text;
        [self.personalInfoDict setValue:self.birthday forKey:@"birthday"];
        [[NgnEngine sharedInstance].infoService setInfoValue:self.birthday forKey:ACCOUNT_BIRTHDATE];
        [formatter release];
    }
    
    [self.currentTextFeild resignFirstResponder];
}

- (IBAction)closeTip:(id)sender
{
    [self.tipView removeFromSuperview];
    [[NgnEngine sharedInstance].configurationService setBoolWithKey:ACCOUNT_CLOSETIP andValue:YES];

    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,self.tableView.frame.origin.y - 30 , self.tableView.frame.size.width, self.tableView.frame.size.height + 30)];
}

#pragma mark - TableView Datasource
- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 68;
    else
        return 44;
}

- (NSString *)tableView:(UITableView *)tableView_ titleForHeaderInSection:(NSInteger)section
{
    //return @"基本资料";
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView_
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        default:
            return 6;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            NSString *currentNum = [NSString stringWithString:[[CloudCall2AppDelegate sharedInstance] getUserName]];
            NSString *oldNum = [[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_LOCALNUM];
            if([currentNum isEqualToString:oldNum])
            {
                self.name.text = [NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_NAME]];
            }
            return headerCell;
            break;
        }
        case 1:
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"cellForPersonalInfo%d", indexPath.row];
            UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];
                UITextField *detailField = [[[UITextField alloc] initWithFrame:CGRectMake(100, 5, 200, 36)] autorelease];
                [detailField setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
                [detailField setPlaceholder:[personalInfoPlaceholderArray objectAtIndex:indexPath.row]];
                //[detailField setText:[]];
                detailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                detailField.delegate = self;
                detailField.tag = indexPath.row+11;
                detailField.returnKeyType = UIReturnKeyDone;
                switch (indexPath.row) {
                    case 1:
                    {
                        detailField.inputView = self.pickerGender;
                        detailField.inputAccessoryView = keyboardToolbar;
                        break;
                    }
                    case 2:
                    {
                        detailField.inputView = self.pickerBirthdate;
                        detailField.inputAccessoryView = keyboardToolbar;
                        break;
                    }
                    case 3:
                    {
                        detailField.keyboardType = UIKeyboardTypeNumberPad;
                        detailField.inputAccessoryView = keyboardToolbar;
                        break;
                    }
                    case 4:
                    {
                        detailField.keyboardType = UIKeyboardTypeEmailAddress;
                        break;
                    }
                    case 5:
                    {
//                        detailField.keyboardType = UIKeyboardTypeEmailAddress;
                        detailField.enabled = NO;
                        break;
                    }
                    default:
                        break;
                }
                //此方法为关键方法
                [detailField addTarget:self action:@selector(tableTextFieldWithText:) forControlEvents:UIControlEventEditingChanged];
                [detailField addTarget:self action:@selector(touchBGEndingEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
                [detailField setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
                [cell addSubview:detailField];
            }
            UITextField *textField = (UITextField *)[cell viewWithTag:indexPath.row+11];
            switch (textField.tag)
            {
                case 11:
                    self.nickName = [[self.personalInfoDict objectForKey:@"nickname"] isEqualToString:@"(null)"]? @"" : [self.personalInfoDict objectForKey:@"nickname"];
                    textField.text = [self.nickName length]?self.nickName:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_NICKNAME]];
                    break;
                case 12:
                    self.sex = [[self.personalInfoDict objectForKey:@"sex"] isEqualToString:@"0"] ? [self.personalInfoDict objectForKey:@"sex"] :[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_GENDER];
                    [self.sex isEqualToString:@""] ? self.sex = NSLocalizedString(@"Male", @"Male") : ([self.sex isEqualToString:@"0"] ? self.sex = NSLocalizedString(@"Female", @"Female") : self.sex = NSLocalizedString(@"Male", @"Male"));
                    textField.text = [self.sex length]?self.sex:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_GENDER]];
                    break;
                case 13:
                    self.birthday= [[self.personalInfoDict objectForKey:@"birthday"] isEqualToString:@"(null)"]? @"" : [self.personalInfoDict objectForKey:@"birthday"];
                    if ([self.personalInfoDict count] < 1) {
                        self.birthday = @"1990-01-01";
                    }
                    textField.text = [self.birthday length]?self.birthday:@"1990-01-01";
                    break;
                case 14:
                    self.qq = [[self.personalInfoDict objectForKey:@"qq"] isEqualToString:@"(null)"]? @"" : [self.personalInfoDict objectForKey:@"qq"];
                    textField.text = [self.qq length]?self.qq:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_QQ]];
                    break;
                case 15:
                    self.email = [[self.personalInfoDict objectForKey:@"email"] isEqualToString:@"(null)"]? @"" : [self.personalInfoDict objectForKey:@"email"];
                    textField.text = [self.email length]?self.email:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_EMAIL]];
                    break;
                case 16:
                    self.sinawb = [[self.personalInfoDict objectForKey:@"sb"] isEqualToString:@"(null)"]? @"" : [self.personalInfoDict objectForKey:@"sb"];
                    textField.text = [self.sinawb length]?self.sinawb:[NSString stringWithString:[[NgnEngine sharedInstance].infoService getInfoValueForkey:ACCOUNT_SINAWEIBO]];
                    break;
                default:
                    break;
            }
            
            cell.textLabel.text = [personalInfoArray objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
            cell.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];
            return cell;
        }
            break;
        default:
            return nil;
    }
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    switch (indexPath.section)
    {
        case 0:
            break;
        case 1:
        {
            switch (indexPath.row)
            {
                case 5:
                {
                    CloudCall2AppDelegate *_appDelegate = [CloudCall2AppDelegate sharedInstance];
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
                    
                    [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo
                                      authOptions:authOptions
                                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
                                               if (result)
                                               {
                                                   //CCLog(@"userInfo=%@",[userInfo sourceData]);
                                                   NSDictionary *SinaUserInfo = [userInfo sourceData];
                                                   self.sinawb = [SinaUserInfo objectForKey:@"name"];
                                                   [self.personalInfoDict setValue:self.sinawb forKey:@"sb"];
                                                   [[NgnEngine sharedInstance].infoService setInfoValue:self.sinawb forKey:ACCOUNT_SINAWEIBO];
                                                   [self.tableView reloadData];
                                                   
                                                   self.sina_Id = [NSString stringWithFormat:@"%@",[SinaUserInfo objectForKey:@"id"]];
                                                   self.sina_gender = [SinaUserInfo objectForKey:@"gender"];
                                                   self.sina_location = [SinaUserInfo objectForKey:@"location"];
                                                   self.sina_profileUrl = [SinaUserInfo objectForKey:@"profile_url"];
                                                   self.sina_verified = [NSString stringWithFormat:@"%d",[[SinaUserInfo objectForKey:@"verified"] intValue]];
                                                   //ShareSdk已经把这两个key封装成对象,这里需要变成字符串,visible置空
//                                                   NSDictionary * tempDic = [[SinaUserInfo valueForKey:@"status"] sourceData];
//                                                   [tempDic setValue:@"" forKey:@"visible"];
//                                                   [SinaUserInfo setValue:tempDic forKey:@"status"];
                                                   self.sina_weiBoJsonData = SinaUserInfo;
                                               }
                                               else
                                               {
                                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                                       message:error.errorDescription
                                                                                                      delegate:nil
                                                                                             cancelButtonTitle:@"知道了"
                                                                                             otherButtonTitles: nil];
                                                   [alertView show];
                                                   [alertView release];
                                               }
                                           }];

                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Textfield Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextFeild = textField;
    
    if (oldContent) {
        [oldContent release];
        oldContent = nil;
    }
    if ([textField.text length])
        oldContent = [[NSString alloc] initWithString:textField.text];
    
    if (textField.tag < 10)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        editingFeildIndex = 0;
    }
    else
    {
        editingFeildIndex = textField.tag;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (oldContent) {
        [oldContent release];
        oldContent = nil;
    }
    if(textField.tag == 15 && ![textField.text isEqualToString:@""])
    {
        BOOL matchEmail = [textField.text isMatchedByRegex:@"^\\w+((-\\w+)|(\\.\\w+))*\\@[A-Za-z0-9]+((\\.|-)[A-Za-z0-9]+)*\\.[A-Za-z0-9]+$"];
        if (!matchEmail)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Personal Information", @"Personal Information") message:NSLocalizedString(@"Invalid email", @"Invalid email") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            self.email = @"";
            textField.text = @"";
            return;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)scrollTableViewToTop
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:editingFeildIndex-11 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) //拍照上传
    {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"手机拍照功能不可用"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [self presentViewController:picker animated:YES completion:NULL];
        [picker release];
        
    }
    else if (buttonIndex == 1) //相册上传
    {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [self presentViewController:picker animated:YES completion:NULL];
        [picker release];
        
    }
    else if (buttonIndex == 2) //取消
    {
        
    }
}

#pragma mark - ImagePickControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = nil;
    
    if (picker.allowsEditing)
    {
        img = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    else
    {
        img = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    img = [StaticUtils createRoundedRectImage:img size:CGSizeMake(80, 80)];
    photo.image = img;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        NSData *imgData = UIImagePNGRepresentation(img);
        [[NgnEngine sharedInstance].infoService setInfoValue:imgData forKey:ACCOUNT_THUMBNAIL];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - PickView Delegate
// UIPickerView
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [genderData count];
}


//两者2存1,viewForRow 高于 titleForRow
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *retval = (id)view;
    if(!retval)
    {
        retval = [[[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)] autorelease];
    }
    retval.font = [UIFont boldSystemFontOfSize:22.0f];
    retval.backgroundColor = [UIColor clearColor];
    retval.textAlignment = UITextAlignmentCenter;
    retval.text = [genderData objectAtIndex:row];
    return retval;
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [genderData objectAtIndex:row];
}

- (void)PickerGenderViewAnimation:(UIView*)view willHidden:(BOOL)hidden {
    [UIView animateWithDuration:0.3 animations:^{
        if (hidden) {
            view.frame = CGRectMake(0, 480, 320, 216);
        } else {
            [view setHidden:hidden];
            view.frame = CGRectMake(0, 188, 320, 216);
        }
    } completion:^(BOOL finished) {
        [view setHidden:hidden];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case kTagCommitSuccess: {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

@end
