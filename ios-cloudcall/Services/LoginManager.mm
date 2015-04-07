//
//  LoginManager.m
//  CloudCall
//
//  Created by Dan on 14-1-15.
//  Copyright (c) 2014年 CloudTech. All rights reserved.
//

#import "LoginManager.h"
#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"
#import "ConferenceFavoritesViewController.h"
#import "CommonCrypto/CommonDigest.h"
#import "HttpRequest.h"
#import "NSString+Code.h"

#define CC_CONFIG_FILE_NAME          @"yuntong.cfg"
static MarketTypeDef g_marketType = CLIENT_FOR_YOUTONG;


@implementation LoginManager

- (void)dealloc
{
    [_userNum release];
    [_userPwd release];
    [_userPwdMD5 release];
    [_pInfoMa release];
    [self.httpLoginSuccessBlock release];
    [self.httpLoginFailedBlock release];
    [self.sipLoginSuccessBlock release];
    [self.sipLoginFailedBlock release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {

        _connectTimeOut = NO;
        self.loginStatus = User_Unlogin;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
        
        return self;
    }
    return nil;
}

+(LoginManager *)shareInstance
{
    static LoginManager *_loginManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _loginManager = [[self alloc] init];
    });
    return _loginManager;
}

- (void)handleLoginStatus:(Login_status)status
{
    switch (status) {
        case User_Unlogin:
        {
            self.loginStatus = User_Unlogin;
            break;
        }
        case Http_Logining:
        {
            CCLog(@"Http logining..");
            self.loginStatus = Http_Logining;
            
            //HttpServer Login
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                self.userNum, @"telnumber",
                                                self.userPwdMD5, @"pwd", nil];
                
                CCLog(@"LoginToServer=%@", jsonDic);
                [[HttpRequest instance] sendRequestSyncWithEncrypt:kDoLoginURL andMethod:@"POST" andContent:jsonDic andTimeout:10 andTarget:self andSuccessSelector:@selector(httpRequestSuccess:andUserInfo:) andFailureSelector:@selector(httpRequestFailure:andUserInfo:)];
            

            });
            
            break;
        }
        case Sip_Logining:
        {
            CCLog(@"Sip logining..");
            
            self.loginStatus = Sip_Logining;
            //Only when httpLogin success ,can sipServer login
                //SipServer Login
                if (_connectTimeOut)
                {
                    [self GetConfigFromNet];
                }
                else
                {
                    [self startLoginTheard];
                }
            
            
        }
        case HttpLogin_Success:
        {
            CCLog(@"Http login success..");
            self.loginStatus = HttpLogin_Success;
            
            if (self.httpLoginSuccessBlock) {
                self.httpLoginSuccessBlock();
                self.httpLoginSuccessBlock = NULL;
            }
            
            
            break;
        }
        case SipLogin_Success:
        {
            CCLog(@"Sip login success..");
            self.loginStatus = SipLogin_Success;
        
            if (self.sipLoginSuccessBlock) {
                self.sipLoginSuccessBlock();
                self.sipLoginSuccessBlock = NULL;
            }
            
        }
        case HttpLogin_Failed:
        {
            CCLog(@"Http login failed..");
            self.loginStatus = HttpLogin_Failed;
            
            if (self.httpLoginFailedBlock) {
                self.httpLoginFailedBlock();
                self.httpLoginFailedBlock = NULL;
            }
            
            break;
        }
        case SipLogin_Failed:
        {
            CCLog(@"Sip login failed..");
            self.loginStatus = SipLogin_Failed;
            _connectTimeOut = NO;
            
            if (self.sipLoginFailedBlock) {
                self.sipLoginFailedBlock();
                self.sipLoginFailedBlock = NULL;
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - SipRequest

- (void)GetConfigFromNet
{
    if ([NgnEngine sharedInstance].networkService.reachable == NO) {
        CCLog(@"networkService unreachable!");
        return;
    }
    
    if (!_cfgMgr) {
#if 1
        NSArray* cfgservers = [[NSArray alloc] initWithObjects: kConfigServerAddr1, kConfigServerAddr2, kConfigServerAddr3, nil];
#else
        NSArray* cfgservers = [[NSArray alloc] initWithObjects: @"192.168.0.101", @"s1.cloudcall.hk", @"s2.cloudcall.hk", @"s3.weicall.net", nil];
#endif
        
        _cfgMgr = [[ConfigurationManager alloc] initWithServers:cfgservers andDirectory:[self GetConfigDirectoryPath] andCfgFileName:CC_CONFIG_FILE_NAME];
        [cfgservers release];
    }
    
    [_cfgMgr getConfigFromServer:self successAction:@selector(getConfigFileSuccessed:) failureTarget:self failureAction:@selector(getConfigFileFailed:)];
    
}

-(NSString*)GetConfigDirectoryPath{
#if TARGET_OS_IPHONE
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    return [documentsDir stringByAppendingPathComponent:@"config"];
}


#pragma mark - SipRequest Result Selector
-(void)getConfigFileSuccessed:(NSString*)currServ {
    [[CloudCall2AppDelegate sharedInstance] getConfigFileSuccessed:currServ];
}

-(void)getConfigFileFailed:(NSError*)error {
    return;
}


#pragma mark - LoginMethod

- (void)httpLoginUserNum:(NSString *)userNum UserPwd:(NSString *)userPwd HttpLoginSuccessBlock:(void (^)())httpSuccessBlock HttpLoginFailedBlock:(void (^)())httpFailedBlock
{
    self.httpLoginSuccessBlock = httpSuccessBlock;
    self.httpLoginFailedBlock = httpFailedBlock;
    
    //从coreData获取账号和密码->双重MD5
    if (userNum == nil && userPwd == nil) {
        self.userNum= [[CloudCall2AppDelegate sharedInstance] getUserName];
        
        self.userPwd = [[CloudCall2AppDelegate sharedInstance] getUserPassword];
        
    }
    else
    {
        self.userNum = userNum;
        self.userPwd = userPwd;
    }
    
    NSString *password = [self.userPwd copy];
    self.userPwdMD5 = [password md5];
    self.userPwdMD5 = [self.userPwdMD5 md5];
    [password release];
    
    
    [self handleLoginStatus:Http_Logining];
}

- (void)sipLoginSuccessBlock:(void (^)())sipSuccessBlock sipLoginFailedBlock:(void (^)())sipFailedBlock
{
    self.sipLoginSuccessBlock = sipSuccessBlock;
    self.sipLoginFailedBlock = sipFailedBlock;
    
    [self handleLoginStatus:Sip_Logining];
}

- (void)startLoginTheard
{
    if (self.userNum == nil || self.userPwd == nil || [self.userNum isEqualToString:DEFAULT_IDENTITY_IMPI] || [self.userPwd isEqualToString:DEFAULT_IDENTITY_PASSWORD])
        return;
    
    [self performSelectorInBackground:@selector(loginThread) withObject:nil];
}

- (void)loginThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL ret = [self queryConfigurationAndRegister];
    
    if (NO == ret) {
        [self handleLoginStatus:SipLogin_Failed];
    }
    
    [pool release];
}


#pragma mark - ASIFormDataRequestDelegate

/*
 1.when http request success ,the userInfo will be Null
 2.when http request failure, the userInfo will not be Null
 */
- (void)httpRequestSuccess:(NSData*)responseData andUserInfo:(id)userInfo
{
    if (responseData)
    {
        BOOL succ;
        NSMutableDictionary *root = [responseData mutableObjectFromJSONData];
        CCLog(@"LoginToServer result=%@, %@", root, [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
        NSString *result  = [root objectForKey:@"result"];
        succ = [result isEqualToString:@"success"];
        if (!succ)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                message:[root objectForKey:@"text"]
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                
                [self handleLoginStatus:HttpLogin_Failed];
            });
        }
        else
        {
            //登录成功
            if (_reLoginTimer) {
                [_reLoginTimer invalidate];
                _reLoginTimer = nil;
                return;
            }
            
            //先写入数据
            [self configureUserInfo];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CloudCall2AppDelegate *appDelegate = [CloudCall2AppDelegate sharedInstance];
                /*
                 这段主要是用于处理在登陆后修改密码后自动登录时的情况
                 */
                if (appDelegate.tabBarController != nil) {
                    [appDelegate GoBackToRootViewFirst];
                    appDelegate.tabBarController.selectedIndex = kTabBarIndex_Numpad;
                }
                [appDelegate performSelector:@selector(ValidationSuccessed) withObject:nil afterDelay:0];
                //数据处理
                
                _pInfoMa = [[PersonalInfoManager alloc] init] ;
                [_pInfoMa getPersonalInfoFromServer];
                
                [appDelegate uploadContacts2Server:YES];
                [appDelegate PhoneNumValidating:NO];
                [appDelegate CheckUserRight];
                [appDelegate registerAndGetConfig];
                
                [appDelegate performSelectorAfterUserLogin];    //登陆IM,创建相关文件
                
                //            int acc = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_ACCESS_CONTACTS_LIST];
                //            if (acc == GENERAL_ACCESS_CONTACTS_LIST_ALLOW)
                //            NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
                //            [[NgnEngine sharedInstance].storageService deleteSystemNofiticationIsNotMyNumber:mynum];
                [[NSNotificationCenter defaultCenter] postNotificationName:kConferenceFavTableReload object:nil];
                
                [self handleLoginStatus:HttpLogin_Success];
                
            });

        }
    }
    
 }

- (void)httpRequestFailure:(NSData*)responseData andUserInfo:(id)userInfo
{
    //请求超时
    if ([[userInfo objectForKey:NSLocalizedDescriptionKey] isEqualToString:@"The request timed out"]) {
        
        //定时器，每30秒登录一次
        
        if (![[[CloudCall2AppDelegate sharedInstance] getUserPassword] isEqualToString: DEFAULT_IDENTITY_PASSWORD])
        {
            [self startReLoginTimer];
            
            //先写入数据
            [self configureUserInfo];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CloudCall2AppDelegate *appDelegate = [CloudCall2AppDelegate sharedInstance];
                /*
                 这段主要是用于处理在登陆后修改密码后自动登录时的情况
                 */
                if (appDelegate.tabBarController != nil) {
                    [appDelegate GoBackToRootViewFirst];
                    appDelegate.tabBarController.selectedIndex = kTabBarIndex_Numpad;
                }
                [appDelegate performSelector:@selector(ValidationSuccessed) withObject:nil afterDelay:0];
                //数据处理
                
                _pInfoMa = [[PersonalInfoManager alloc] init] ;
                [_pInfoMa getPersonalInfoFromServer];
                
                [appDelegate uploadContacts2Server:YES];
                [appDelegate PhoneNumValidating:NO];
                [appDelegate CheckUserRight];
                [appDelegate registerAndGetConfig];
                
                [appDelegate performSelectorAfterUserLogin];    //登陆IM,创建相关文件
                
                //            int acc = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_ACCESS_CONTACTS_LIST];
                //            if (acc == GENERAL_ACCESS_CONTACTS_LIST_ALLOW)
                //            NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
                //            [[NgnEngine sharedInstance].storageService deleteSystemNofiticationIsNotMyNumber:mynum];
                [[NSNotificationCenter defaultCenter] postNotificationName:kConferenceFavTableReload object:nil];
                
                [self handleLoginStatus:HttpLogin_Success];
                
            });
        }
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                        message:@"登录失败"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
        [self handleLoginStatus:HttpLogin_Failed];
    }
   
    
}

#pragma markk - ReLoginTimerAndTick

- (void) startReLoginTimer
{
    CCLog(@"HttpReLoginTimer....");
    _reLoginTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                     target:self
                                                   selector:@selector(timerReLoginTick:)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)timerReLoginTick:(NSTimer *)timer
{
    static int counter = 0;
    if (counter >=3)
    {
        if (_reLoginTimer) {
            [_reLoginTimer invalidate];
            _reLoginTimer = nil;
        }
    }
    else
    {
        [self httpLoginUserNum:self.userNum UserPwd:self.userPwd HttpLoginSuccessBlock:self.httpLoginSuccessBlock HttpLoginFailedBlock:self.httpLoginFailedBlock];
        counter++;
    }
    
}

#pragma mark - ConfigureUserInfo

- (void)configureUserInfo
{
    // Save user info while sengding user password to server
    [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:self.userNum forKey:IDENTITY_IMPI];
    [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:self.userPwd forKey:IDENTITY_PASSWORD];
    [[NgnEngine sharedInstance].infoService setInfoValue:ClientDisplayName forKey:IDENTITY_DISPLAY_NAME];
    
    NSMutableString *impu;
    impu = [NSMutableString stringWithString: @"sip:"];
    [impu appendString:self.userNum];
    [impu appendString:@"@"];
    NSString* serverAddr = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_REG_HOST];
    [impu appendString:serverAddr];
    [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:impu forKey:IDENTITY_IMPU];
}

#pragma mark - SipService Login

-(BOOL) queryConfigurationAndRegister{
    if ([NgnEngine sharedInstance].networkService.reachable == NO)
        return NO;
    
	BOOL on3G = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
	BOOL use3G = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
	if (on3G && !use3G)
    {
		return NO;
	}
    else {
        //SipService Register... Sip注册登录主入口
        BOOL ret = [[NgnEngine sharedInstance].sipService registerIdentity];
        return ret;
	}
    
    return NO;
}

#pragma mark - SipService Callback Method

-(void) onRegistrationEvent:(NSNotification*)notification {
	NgnRegistrationEventArgs* eargs = [notification object];
    CCLog(@"LoginManager: Reg notify: %d, %d, '%@', '%@'", eargs.eventType, eargs.sipCode, eargs.sipPhrase ? eargs.sipPhrase : @"", eargs.subServ?eargs.subServ:@"");
	
	switch (eargs.eventType) {
			// provisional responses
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_INPROGRESS:
			break;
			// final responses
		case REGISTRATION_OK:
        {
            if (self.loginStatus == HttpLogin_Success) {
                self.loginStatus = SipLogin_Success;
            }
    
            break;
        }
		case REGISTRATION_NOK: {
            _connectTimeOut = NO;
            
            if (self.loginStatus == HttpLogin_Success) {
                if (eargs.sipCode == tsip_event_code_dialog_terminated)
                {
                    // reigster failed - try to register to the other sip server
                    NSString* strHost    = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_HOST];
                    NSString* strBakHost = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_BACKUP_PCSCF_HOST];
                    NSString* strRegHost = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_REG_HOST];
                    if ([strHost isEqualToString:strRegHost])
                    {
                        [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:strBakHost];
                        [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_REG_HOST andValue:strBakHost];
                        
                        [self startLoginTheard];
                    }
                    else
                    {
                        _connectTimeOut = YES;
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                        message: _connectTimeOut ? NSLocalizedString(@"Connect to server timeout, please check your network or try again later.", @"Connect to server timeout, please check your network or try again later."): NSLocalizedString(@"Login failed, make sure the phone number and password are correct.", @"Login failed, make sure the phone number and password are correct.")
                                                                       delegate: nil
                                                              cancelButtonTitle: nil
                                                              otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                        [alert show];
                        [alert release];
                        [self handleLoginStatus:SipLogin_Failed];
                    }
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                    message: _connectTimeOut ? NSLocalizedString(@"Connect to server timeout, please check your network or try again later.", @"Connect to server timeout, please check your network or try again later."): NSLocalizedString(@"Login failed, make sure the phone number and password are correct.", @"Login failed, make sure the phone number and password are correct.")
                                                                   delegate: nil
                                                          cancelButtonTitle: nil
                                                          otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                    [alert show];
                    [alert release];
                    [self handleLoginStatus:SipLogin_Failed];
                }
            }
            break;
        }
		case UNREGISTRATION_OK:
		case UNREGISTRATION_NOK:
		default:
			break;
	}
}



@end
