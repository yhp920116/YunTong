//
//  UrlHeader.h
//  CloudCall
//
//  Created by CloudCall on 13-9-3.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//
#import "RootUrlHeader.h"
#ifndef CloudCall_UrlHeader_h
#define CloudCall_UrlHeader_h


#define kWebAppServerAddr       @"user.callwine.net"
#define kWebTestAppServerAddr   @"test2.cloudcall.cn"
#define kWebAuthServerAddr      @"auth.callwine.net"

#define kWebAppServerPort8080       8080
#define kWebAppServerPort80         80

#define URL_Rate            [NSString stringWithFormat:@"%@/inApp/rate.html", RootUrl]
#define URL_Faq             [NSString stringWithFormat:@"%@/inApp/faq.html", RootUrl]
#define URL_Get_FreeCall    [NSString stringWithFormat:@"%@/inApp/get_freecall.html", RootUrl]
#define URL_Charge          [NSString stringWithFormat:@"%@/inApp/charge.html", RootUrl]
#define URL_Disclaimer      [NSString stringWithFormat:@"%@/inApp/disclaimer.html", RootUrl]
#define kTaobaoShopUrl      @"http://yuntong2013.taobao.com"

#define DianJin_Enable 0
#define testService 0

#define kCallFeedbackUrl [NSString stringWithFormat:@"https://%@:%d/Application/cloudcall/cq.jsp", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

#define kPraiseUrl [NSString stringWithFormat:@"https://%@:%d/Application/cloudcall/praise.jsp", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

#define kDownloadUserInfoUrl [NSString stringWithFormat:@"http://%@:%d/Auth/social/downloaduserinfo.do", testService?kWebTestAppServerAddr:kWebAuthServerAddr, kWebAppServerPort80]

#define kGetUserInfoUrl [NSString stringWithFormat:@"http://%@:%d/Auth/social/userinfo.do", testService?kWebTestAppServerAddr:kWebAuthServerAddr, kWebAppServerPort80]

//游戏规则URL
#define kGameRuleURI [NSString stringWithFormat:@"%@/fun/", RootUrl]

//老虎机结果uri
#define kGetSlotMachineResultURI [NSString stringWithFormat:@"https://%@:%d/Application/tiger/tiger.jsp", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]
//下载广告素材uri
#define kDownloadAdsURI [NSString stringWithFormat:@"https://%@:%d/Application/ad/downloadadlist.jsp", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]
//下载余额、字幕、投注列表uri
#define kGetSlotMachineInitDataURI [NSString stringWithFormat:@"https://%@:%d/Application/tiger/psb.jsp", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//支付宝服务器回调URL
#define kAlipayNotifyURL [NSString stringWithFormat:@"https://%@:%d/Alipay/servlet/RSANotifyReceiver", kBLServerAddr, kBLServerPort]

//签到
#define kSignInUrl [NSString stringWithFormat:@"http://%@:%d/Application/sign.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort80]

//优惠券
//125.65.113.211
#define kCouponsListUrl             [NSString stringWithFormat:@"https://%@:%d/Application/coupons.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]
#define kCollectionCouponsListUrl   [NSString stringWithFormat:@"https://%@:%d/Application/coupons/collection.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]
#define kDeleteCouponsUrl           [NSString stringWithFormat:@"https://%@:%d/Application/coupons/delCollection.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]
#define kUpdateCouponsUrl           [NSString stringWithFormat:@"https://%@:%d/Application/coupons/update.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]
#define kChallengeCouponsUrl        [NSString stringWithFormat:@"https://%@:%d/Application/coupons/challenge.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//广告列表
#define kDownloadListUrl            [NSString stringWithFormat:@"https://%@:%d/Application/ad/downloadadlist.jsp", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//群呼群组
#define kGroupCallGroupUrl          [NSString stringWithFormat:@"https://%@:%d/Application/cloudcall/confgroup.jsp", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//云通小秘书
#define kSecretaryUrl               [NSString stringWithFormat:@"https://%@:%d/Application/cloudcall/sysmsg.jsp", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//版本更新
#define kCheckVersionUpdateUrl               [NSString stringWithFormat:@"https://%@:%d/Application/update/getlatestversion.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//积分墙列表
#define kPointWallUrl              [NSString stringWithFormat:@"https://%@:%d/Application/ad/getadplatformlist.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//群组分享内容
#define kGroupCallShareContentUrl              [NSString stringWithFormat:@"https://%@:%d/Application/social/getsharetext.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//获取推荐人信息
#define kGetreferUrl              [NSString stringWithFormat:@"https://%@:%d/Application/social/getrefer.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//设置推荐人
#define kSetrefereeUrl              [NSString stringWithFormat:@"https://%@:%d/Application/social/setreferee.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//广场页面动态配置
#define kGetSquareAppUrl            [NSString stringWithFormat:@"http://%@:%d/Application/social/squareapp.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort80]

//chong'zhi'lie'biao
#define kLoadRechargeListUrl    [NSString stringWithFormat:@"https://%@:%d/Application/card/getcardlist.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

#define kRechargelUrl  [NSString stringWithFormat:@"https://%@:%d/user/user/recharge/recharge.jsp", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//推荐好友排行榜
#define kRankingListUrl         [NSString stringWithFormat:@"https://%@:%d/Application/social/referranking.jsp", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//广告展示次数统计url
#define kDefaultCloudCallUrl    [NSString stringWithFormat:@"https://%@:%d/Application/Redirect/geturl.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort8080]

//获取广告列表,广告展示点击次数统计
#define kGetAdsURL @"https://ad.callwine.net:8080/ad/getAds.do"
#define kAdStatisticsURL @"https://ad.callwine.net:8080/ad/sendStat.do"

//通讯录
#define kUploadContactsURL      [NSString stringWithFormat:@"http://%@:%d/Application/contact/upload.do", testService?kWebTestAppServerAddr:kWebAuthServerAddr, kWebAppServerPort80]

//IM服务器配置
#define kGetImserverConfigURL   [NSString stringWithFormat:@"http://%@:%d/Application/social/imserver.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort80]

//SIP服务器配置
#define kGetSIPserverConfigURL   [NSString stringWithFormat:@"http://%@:%d/Application/cloudcall/sipServerConfig.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort80]

//获取短信平台信息
#define kGetSmsplatformInfoURL   [NSString stringWithFormat:@"http://%@:%d/Application/sms/smsplatform.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort80]

//短信平台获取手机号码
#define kGetPhoneNumberFromSmsplatformURL   [NSString stringWithFormat:@"http://%@:%d/Application/sms/getphonenum.do", testService?kWebTestAppServerAddr:kWebAppServerAddr, kWebAppServerPort80]

//短信、语音获取验证码
#define kGetAuthCodeURL [NSString stringWithFormat:@"http://%@:%d/Auth/account/getAuthCode.do", testService?kWebTestAppServerAddr:kWebAuthServerAddr, kWebAppServerPort80]

//校验验证码
#define kVerifyAuthCodeURL [NSString stringWithFormat:@"http://%@:%d/Auth/account/verifyAuthCode.do",testService?kWebTestAppServerAddr:kWebAuthServerAddr, kWebAppServerPort80]

//设置密码
#define kSetPasswordURL [NSString stringWithFormat:@"http://%@:%d/Auth/account/setPasswd.do", testService?kWebTestAppServerAddr:kWebAuthServerAddr, kWebAppServerPort80]

//重置密码
#define kResetPasswordURL [NSString stringWithFormat:@"http://%@:%d/Auth/account/resetPasswd.do", testService?kWebTestAppServerAddr:kWebAuthServerAddr, kWebAppServerPort80]

//登录
#define kDoLoginURL [NSString stringWithFormat:@"http://%@:%d/Auth/account/confirmInfo.do", testService?kWebTestAppServerAddr:kWebAuthServerAddr, kWebAppServerPort80]

#endif
