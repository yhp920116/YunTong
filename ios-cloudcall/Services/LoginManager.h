//
//  LoginManager.h
//  CloudCall
//
//  Created by Dan on 14-1-15.
//  Copyright (c) 2014年 CloudTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigurationManager.h"
#import "PersonalInfoManager.h"


typedef NS_ENUM(NSInteger, Login_status){
    User_Unlogin,
    Http_Logining,
    Sip_Logining,
    HttpLogin_Success,
    SipLogin_Success,
    HttpLogin_Failed,
    SipLogin_Failed
};

typedef void (^HttpLoginSuccessBlock)();
typedef void (^SipLoginSuccessBlock)();
typedef void (^HttpLoginFailedBlock)();
typedef void (^SipLoginFailedBlock)();

@interface LoginManager : NSObject
{
    
    BOOL _connectTimeOut;
    BOOL _httpLoginSuccess;
    ConfigurationManager *_cfgMgr;
    PersonalInfoManager *_pInfoMa;
    NSTimer     *_reLoginTimer;

}

@property (nonatomic,copy) NSString *userNum;
@property (nonatomic,copy) NSString *userPwd;
@property (nonatomic,copy) NSString *userPwdMD5;

@property (copy) HttpLoginSuccessBlock httpLoginSuccessBlock;
@property (copy) SipLoginSuccessBlock sipLoginSuccessBlock;
@property (copy) HttpLoginFailedBlock httpLoginFailedBlock;
@property (copy) SipLoginFailedBlock sipLoginFailedBlock;

@property (nonatomic) Login_status loginStatus;


+(LoginManager *)shareInstance;

- (void)httpLoginUserNum:(NSString *)userNum UserPwd:(NSString *)userPwd HttpLoginSuccessBlock:(void (^)())httpSuccessBlock HttpLoginFailedBlock:(void (^)())httpFailedBlock;
- (void)sipLoginSuccessBlock:(void (^)())sipSuccessBlock sipLoginFailedBlock:(void(^)())sipFailedBlock;
- (void)GetConfigFromNet;
- (void)startLoginTheard;

@end
