/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import <UIKit/UIKit.h>
#import <iad/iad.h>
#import <immobSDK/immobView.h>
#import "BaiduMobAdView.h"
#import "CTBannerView.h"
#import "BannerViewContainer.h"
#import "UrlHeader.h"
#import "NSString+Code.h"

#import "AudioCallViewController.h"
#import "VideoCallViewController.h"
#import "MessagesViewController.h"
#import "ChatViewController.h"
#import "ContactsViewController.h"

#import "AdResourceManager.h"
#import "ConfigurationManager.h"
#import "IAPRechargeManager.h"
#import "CallFeedbackManager.h"
#import "GroupCallManager.h"
#import "NotificationMessageManager.h"

#import "LogViewController.h"

#import "iOSNgnStack.h"

#import "WXApi.h"
#import "WBApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "XMPP.h"
#import "LoginManager.h"
#import "MBProgressHUD.h"

#define kAppWillEnterForegroundNotification  @"AppWillEnterForeground"

#define kNotifKey									@"key"
#define kNotifKey_IncomingCall						@"icall"
#define kNotifKey_IncomingMsg						@"imsg"
#define kNotifKey_IncomingMsgNum                    @"imsgNum"

#define kNotifKey_SignInRemind						@"signInRemind"
#define kNotifKey_GroupCallRemind                   @"groupCallRemind"
#define kNotifKey_GroupCallUUID                     @"groupCallObject"
#define kNotifIncomingCall_SessionId				@"sid"

#define kUploadContacts                             @"kUploadContacts"
#define kDownloadContacts                           @"kDownloadContacts"
#define kDownloadCCUsers                            @"kDownloadCCUsers"

#define kGetImserverConfig                          @"kGetImserverConfig"

#define CCLog(format, ...) NgnLog(format, ## __VA_ARGS__)
void OutputOn();
void OutputOff();

enum APNS_TYPE {
    APNS_TYPE_NONE,
    APNS_TYPE_INCOMING_CALL,
    ANPS_TYPE_INCOMING_MSG
};

@interface RemoteNotificationDef: NSObject {
    APNS_TYPE type;
    NSString* value;
}

@property(readwrite)  APNS_TYPE type;
@property(nonatomic, retain)  NSString *value;

-(RemoteNotificationDef*) initWithType:(APNS_TYPE) type andValue:(NSString*)value;
@end

enum
{
    kTabBarIndex_Numpad = 0,
    kTabBarIndex_Messages,
    kTabBarIndex_Contacts,
//    kTabBarIndex_GroupCall,
    kTabBarIndex_Discover
};

enum {
    AD_TYPE_IAD    = 0, // Apple iad
    AD_TYPE_91DIANJIN, // 91点金
    AD_TYPE_LIMEI,  //力美
    AD_TYPE_UMENG, // 友盟
    AD_TYPE_CLOUDCALL_HK, // cloudcall 官网
    AD_TYPE_BAIDU,       // 百度广告
    AD_TYPE_DIANRU,         //点入积分墙
};

enum MarketTypeDef {
    CLIENT_FOR_NONE = 0,
    CLIENT_FOR_APP_STORE    = 100, // old is 0, change to 100 since CloudCall 3.2.0 (2012-07-22).
    CLIENT_FOR_YOUTONG      = 101,
    CLIENT_FOR_91_STORE     = 102,
    CLIENT_FOR_HC           = 103,
    CLIENT_FOR_AS           = 104,
	CLIENT_FOR_AS_APP_STORE = 105,
    CLIENT_FOR_DZB          = 106,
	CLIENT_FOR_DY           = 107,
    CLIENT_FOR_CANDOU       = 108,
    CLIENT_FOR_LIQU         = 110,
    CLIENT_FOR_DBANK        = 120,
    CLIENT_FOR_115          = 121,
    CLIENT_FOR_WXGK         = 155,
    CLIENT_FOR_YZ           = 191,
    CLIENT_FOR_MAX
};

static const char* getMarketName(int type) {
    switch (type) {
        case CLIENT_FOR_APP_STORE:    return "App Store";
        case CLIENT_FOR_YOUTONG:      return "yuntong";
        case CLIENT_FOR_91_STORE:     return "91store";
        case CLIENT_FOR_HC:           return "hua chuang shi dai";
        case CLIENT_FOR_AS:           return "ai shang";
		case CLIENT_FOR_AS_APP_STORE: return "AiShang AppStore";
        case CLIENT_FOR_DY:           return "Da Yi";
        case CLIENT_FOR_DZB:          return "Ding Zhi Bao";
        case CLIENT_FOR_CANDOU:       return "candou";
        case CLIENT_FOR_LIQU:         return "liqu";
        case CLIENT_FOR_DBANK:        return "dbank";
        case CLIENT_FOR_115:          return "115";
        case CLIENT_FOR_WXGK:         return "wxgk";
        case CLIENT_FOR_YZ:           return "YZ";
        default:                      return 0;
    }
    return 0;
}

@protocol IMXMPPDelegate <NSObject>
@required

- (void) didReceiveNewMessage:(NSString *) message
                     sendUser:(NSString *) sendUser
                         date:(NSDate *) date
                      msgType:(NSInteger) msgType
                     fileType:(NSInteger) fileType
                      fileUrl:(NSString *) fileUrl
                   orgFileUrl:(NSString *)orgFileUrl
                audioDuration:(NSString *)audioDuration
                     fileName:(NSString *) fileName
                    messageId:(NSString *) messageId
                   localMsgId:(NSString *) localMsgId;
@end

@class ValidationViewController;
@class ShareViewDelegate;

@interface CloudCall2AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, ADBannerViewDelegate, immobViewDelegate, WXApiDelegate, XMPPStreamDelegate, BaiduMobAdViewDelegate, MBProgressHUDDelegate> {

    ShareViewDelegate *_viewDelegate;
@protected
    UIWindow *window;
    UITabBarController *tabBarController;
	ContactsViewController *contactsViewController;
	AudioCallViewController *audioCallController;
	VideoCallViewController *videoCallController;
	MessagesViewController *messagesViewController;
	ChatViewController *chatViewController;
    LogViewController *logViewController;
    ValidationViewController *validationView;
    
    UIViewController<BannerViewContainer>* currentController;
	
	BOOL scheduleRegistration;
	BOOL nativeABChangedWhileInBackground;
	
	BOOL multitaskingSupported;
    
    BOOL phonenumvalidating;
    BOOL starting;
    
    RemoteNotificationDef* launchremns;
    
    //广告
    ADBannerView *iadbanner;
    immobView *lmbanner;
    CTBannerView *ctbanner;
    BaiduMobAdView *bdbanner;
    
    int adType;
    int missedCalls;
    
    BOOL incomingCall;
    BOOL isOpenDianRuWallPoints;
    BOOL isCountBanner;
 @private
    NSDictionary *remoteNotif;
    
    NSString* versionUrl;
    
    unsigned int unreadSysNotify;
    
    unsigned int unreadIM;
    
    NSString* lastMsgCallId;
    
    BOOL checkingVersionUpdate;
    
    BOOL enteringForeground;

    NSMutableArray* rechargeProducts;
    NSString *conferenceUUID;
    
    BOOL        registered; // 注册成功过
    NSTimer     *registerTimer;

    int         regAttempt;
    BOOL        syncReferr;
        
    int         maxexchangepoints;
    int         appstorerelease;
    int         currentrelease;
    BOOL        showAd;
    
    NSMutableArray* incallAdData;
    int currIncallAdIndex;
    
    NSMutableArray* signinAdData;
    int currSigninAdIndex;
    
    NSMutableArray* callFeedBackData;
    int currCallFeedBackIndex;
    
    BOOL useSecondConfServ;
    
    int maxconfmembers;
    
    BOOL setImmobViewDisplay;
    
    BOOL regAfterGetCfg;
    
    IAPRechargeManager* iapMgr;    
    CallFeedbackManager* callFeedbackMgr;    
    GroupCallManager* groupcallMgr;
    NotificationMessageManager* ntymsgMgr;
    
    // IM (XMPP)
    XMPPStream *xmppStream;
    NSString *username;
    NSString *password;
    // 消息提示播放
    SystemSoundID soundID;
    
    NSTimer *reConnectXmppTimer;
    
    LoginManager *loginManager;
}
@property (nonatomic, readonly) ShareViewDelegate *viewDelegate;
@property (nonatomic, retain) NSMutableArray* incallAdData;
@property (nonatomic, retain) NSMutableArray* signinAdData;
@property (nonatomic, retain) NSMutableArray* callFeedBackData;
@property (nonatomic, retain) NSString *conferenceUUID;
@property (nonatomic, assign) int missedCalls;
@property (nonatomic, assign) CTBannerView *ctbanner;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ContactsViewController *contactsViewController;
@property (nonatomic, retain) IBOutlet MessagesViewController *messagesViewController;
@property (nonatomic, retain) IBOutlet LogViewController *logViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) ValidationViewController *validationView;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, readonly) AudioCallViewController *audioCallController;
@property (nonatomic, readonly) VideoCallViewController *videoCallController;
@property (nonatomic, readonly) ChatViewController *chatViewController;
@property (nonatomic, readonly) int adType;
@property (nonatomic, readonly) BOOL registered;
@property (nonatomic, readonly) int maxexchangepoints;
@property (nonatomic, readonly) NSMutableArray* rechargeProducts;

@property (nonatomic, readwrite) BOOL useSecondConfServ;
@property (nonatomic, readwrite) int maxconfmembers;

@property (nonatomic, assign) BOOL isOpenDianRuWallPoints;
@property (nonatomic, assign) BOOL incomingCall;

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, assign) id<IMXMPPDelegate> messageDelegate;
@property (nonatomic, assign) BOOL isCountBanner;

//-(void) selectTabNumpad;
//-(void) selectTabGroupCall;
-(void) selectTabContacts;
-(void) selectTabMessages;
-(void) selectTabSettings;
-(NSString *) getUserName;
-(NSString *) getUserPassword;

+(CloudCall2AppDelegate*) sharedInstance;
-(void)getConfigFileSuccessed:(NSString*)currServ;
-(void)registerAndGetConfig;
+(BOOL) runInBackground;
-(void) displayValidationView;
-(void) PhoneNumValidating:(BOOL)validating;
-(BOOL) PhoneNumValidating;
-(void) uploadContacts2Server:(BOOL)checkDb;
-(void) GetAccountBalance;
-(void) CheckVersionUpdate:(BOOL)autoCheck;
-(void) CheckUserRight;
-(int)getAppStoreRelease;
-(int)getCurrentRelease;

-(void) IAPRecharge:(NgnIAPRecord*)record;

-(void) viewChanged:(UIViewController*)viewController;
-(void) AdClick:(int)awardAmount withType:(int)wallAdType;

-(void) UnreadSysNofifyNum:(unsigned int)num;
-(unsigned int) unreadSysNofifyNum;

-(void) UnreadIMNum:(unsigned int)num;

-(void) SetCheckingVersionUpdate:(BOOL)update;
-(void) ReloadConfigFromFile;
-(BOOL) ShowAllFeatures;
-(BOOL) ShowInAppPurchase;
- (void)ShowNewFeatureRemind;

-(void) ShowCallFeedbackView:(CallFeedbackData*)data;
-(void) SendCallFeedback2Server:(CallFeedbackData*)data;

-(void)AddGroupCallRecords:(NSArray*)records;
-(void)UpdateGroupCallRecords:(NSArray*)records;
-(void)DeleteGroupCallRecords:(NSArray*)records;
-(void)DeleteGroupCallRecord:(NSString*)groupid;
-(void)GetGroupCallRecords;
-(void)GoBackToRootViewFirst;

-(MarketTypeDef) MarkCode;
-(NSString*) MarketTypeName;

-(NSData*)GetIncallImage:(NSString*)filename;

-(NSData*)GetCallFeedBackImage:(NSString*)filename;

-(CCAdsData *)GetCurrIncallAdData;

-(NSString*)GetSigninAdsDirectoryPath;

- (NSString*)GetSlotMachineImgDirectoryPath;

- (NSString*)GetCTBannerAdsDirectoryPath;

- (NSString*)GetAreaOfPhoneNumberDBDirectoryPath;

- (NSString*)GetCouponImgDirectoryPath;

- (NSString*)GetIMCachesDirectoryPath;

- (NSString*)GetDiscoverItemsDirDirectoryPath;

- (CCAdsData *)GetCurrSigninAdData;

- (CCAdsData*)GetCurrCallFeedBackData;

-(void)SetIAPProductIds:(NSMutableArray*)rechargeProducts;

-(void)ValidationSuccessed;

-(void)StartLog;
- (void)createDianJinAd;

- (void)sendRequestToCloudCall;

- (void)setCurrentRelease;

- (void)EnterMessagesView:(NSString *)_friendAccount;

- (void)GoBackToRootViewFirst;

- (void)createAllTable;

- (void)performSelectorAfterUserLogin;

///////////////////////////////////////////////////
/*- (void)getBalance;
- (void)consume:(float)amount;
- (void)getBalanceDidFinish:(NSDictionary *)dict;
- (void)consumeDidFinish:(NSDictionary *)dict;
- (void)appActivatedDidFinish:(NSDictionary *)dict;*/
///////////////////////////////////////////////////


#pragma mark - XMPP

//#define kIMServer_Addr      @"183.61.244.194"

#if IMEncrypt_XMPP_Enable
#define kIMServer_Port      18888
#define kIMServer_Addr      @"im.callwine.net"
#else
#define kIMServer_Port      18888
#define kIMServer_Addr      @"im.callwine.net"       //for test
#endif
#if IMEncrypt_HTTP_Enable
#define kIMServer_Http_Port 8082
#else
#define kIMServer_Http_Port 8082
#endif

//#define kIMServer_Port      18888
//#define kIMServer_Http_Port 8080


// 连接XMPP服务器
- (void) xmppConnect;
- (BOOL) connectWithUSerName:(NSString *) userName passWord:(NSString *) passWord ipAddress:(NSString *) ipAddress  port:(ushort)usport;

// 断开与XMPP服务器的连接
- (void) disConnect;

// 设置XMPPStream
- (void) setUpStream;

// 上线
- (void) goOnline;

// 下线
- (void) goOffline;

- (NSString *)getMessageIdWithTimeAndUUID;

@end



