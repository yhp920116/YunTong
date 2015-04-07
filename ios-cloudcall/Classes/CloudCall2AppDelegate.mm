/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@cloudcall.hk
 *       
 * This file is part of SkyBroad CloudCall Project
 *
 */
 
#import "CloudCall2AppDelegate.h"
#import "CloudCall2Constants.h"
#import "ValidationViewController.h"
#import "MHImageCache.h"

#import "MediaContent.h"
#import "MediaSessionMgr.h"

#import "MobClick.h"
#import "JSONKit.h"

#import <ShareSDK/ShareSDK.h>

#import "CCGTMBase64.h"
#import "JSONKit.h"

#import "CallFeedbackViewController.h"
#import "GuideViewController.h"

#import "NumpadViewController.h"
#import "ContactsViewController.h"
#import "ConferenceFavoritesViewController.h"
#import "MoreViewController.h"

#import "DianRuAdWall.h"
#import "ShareViewDelegate.h"

#import "AlixPay.h"
#import "AlixPayResult.h"
#import "RSADataVerifier.h"

#import "IMWebInterface.h"
#import "RecorderManager.h"
#import "IMDownLoadAudioFromServerModel.h"
#import "SqliteHelper.h"

#import "NSString+Code.h"

#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#import "CloudCallJSONSerialization.h"
#import "StaticUtils.h"
#import "CCSqliteHelper.h"

void OutputOn() {
    NgnOutputOn();
}

void OutputOff() {
    NgnOutputOff();
}

/* 为了区分我们的软件在不同市场的下载量，现约定市场代码如下：
 * 苹果：
 * 市场              代码
 * 官方APP STORE     100     e.g. 2.0.100 - old is 0, change to 100 since CloudCall 3.2.0 (2012-07-22)
 * CloudCall官网     101     e.g. 2.0.101
 * 威锋              102     e.g. 2.0.102
 * 91               103     e.g. 2.0.103
 */
static MarketTypeDef g_marketType = CLIENT_FOR_YOUTONG;


NSString* GetCrashReportPath(void)
{
#if TARGET_OS_IPHONE
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    
    return [documentsDir stringByAppendingPathComponent:@"crashReport"];
}

void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
//    NSString *urlStr = [NSString stringWithFormat:@"mailto:crashreport@cloudcall.hk?subject=bug报告:%@&body=感谢您的配合!<br><br><br>"
//                        "错误详情:<br>%@<br>--------------------------<br>%@<br>---------------------<br>%@",
//                        name,name,reason,[arr componentsJoinedByString:@"<br>"]];
//    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [[UIApplication sharedApplication] openURL:url];
    NSString *crashReport = [NSString stringWithFormat:@"Name:%@\n\n  reason:%@\n\n   detail:%@\n\n", name, reason, arr];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *servTime = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    NSString *crashPath = GetCrashReportPath();
    
    NSString *path = [crashPath stringByAppendingString:[NSString stringWithFormat:@"/%@闪退报告.txt", servTime]];
    
    NSError *error = nil;
    [crashReport writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

#undef TAG
#define kTAG @"CloudCall2AppDelegate///: "
#define TAG kTAG

#define kTagAlertSignInRemind    1000
#define kTagAlertGroupCallRemind 1001
#define kTagAlertMessagesRemind  1002

#define kNewMessageAlertText						NSLocalizedString(@"You have a new message", @"You have a new message")

#define kAlertMsgButtonOkText						NSLocalizedString(@"OK", @"OK")
#define kAlertMsgButtonCancelText				    NSLocalizedString(@"Cancel", @"Cancel")

#define kIncomingCallAlertText				        NSLocalizedString(@"Call from\n%@", @"Call from\n%@")
#define kIncomingVideoCallAlertText				    NSLocalizedString(@"Video call from\n%@", @"Video call from\n%@")

#define kOnNotifyMsgResponseStatusFinished          @"kOnNotifyMsgResponseStatusFinished"

#define kNotificationUpdateAdsInfo                  @"kNotificationUpdateAdsInfo"

#define kNotificationUploadContact                  @"kNotificationUploadContact"

/////////////////////////////////////////////////////////////////////////
#define kTagActionAlertUpdateVersion 1

#define CC_CONFIG_FILE_NAME          @"yuntong.cfg"
#define CC_INCALL_ADS_INFO_FILE_NAME @"ccadsinfo.plist"
#define CC_SIGNIN_ADS_FILE_NAME      @"ccsigninadsnew.plist"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static int g_recharge_attmpt_seconds = 120;

@implementation RemoteNotificationDef

@synthesize type;
@synthesize value;

-(RemoteNotificationDef*) initWithType:(APNS_TYPE)_type andValue:(NSString *)_value {
    if ((self = [super init])) {
        self->type  = _type;
        self->value = [_value retain];
	}
	return self;
}

-(void) dealloc {
    [value release];
    
    [super dealloc];
}

@end


// UIImagePickerController
@implementation UIImagePickerController (Rotation_IOS6)

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end

//
// private functions
//
@interface CloudCall2AppDelegate(Private)
-(void) networkAlert:(NSString*)message;
-(void) newMessageAlert:(NSString*)message;
-(void) keepRegisterCallback;
-(BOOL) parseConfiguration:(NSString *)strCfg;


// Added for sync contacts from server.
-(void) processContactsGotFromServer:(NSMutableArray *)friendArray;

-(UIViewController<BannerViewContainer> *) toBannerViewContainer:(UIViewController*) viewController;


-(NSString*)LoadConfigFile;
//-(void)SaveConfigFile:(NSString*)strcfg;

-(void)ShowAdBanner:(UIViewController<BannerViewContainer>*) bannerView;
@end

@implementation CloudCall2AppDelegate(Private)

-(BOOL)writeData2File:(NSData*)data toFileAtPath:(NSString*)aPath{
    if (!data || !aPath || ![aPath length])
        return NO;
    
    @try {
        if ((data == nil) || ([data length] <= 0))
            return NO;
        
        [data writeToFile:aPath atomically:YES];
        
        return YES;
    } @catch (NSException *e) {
        CCLog(@"create thumbnail exception.");
    }
    
    return NO;
}

-(void)keepRegisterCallback {    
	CCLog(@"cc2app keepRegisterCallback");
    /*[self queryConfigurationAndRegister]; GARY DISABLE 20120311*/
}

-(void) networkAlert:(NSString*)message{
	if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
														message:message
													   delegate:nil
											  cancelButtonTitle:kAlertMsgButtonOkText
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

-(void) newMessageAlert:(NSString*)message{
	if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
														message:message
													   delegate:self
											  cancelButtonTitle:kAlertMsgButtonCancelText
											  otherButtonTitles:kAlertMsgButtonOkText, nil];
		[alert show];
		[alert release];
	}
}

////////////////////////////////////////

-(void)getIncallAdImageFromNet{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *documentsDirectory = [self GetIncallAdsDirectoryPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *fileList;
    NSError *error = nil;
    NSString* fileName = @"";
    // fileList便是包含有该文件夹下所有文件的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
//    [fileManager release]; 这里已经加了自动释放池应该,这个是静态方法创建的对象,应该不需要手动释放
    
    NSString* adspath = [self GetIncallAdsDirectoryPath];
    NSMutableArray* images = incallAdData;
    if (!images || [images count] == 0) {
        [pool release];
        return;
    }
    
    // remove local file if the filename is not found in incallAdData.
    for (NSString* f in fileList) {
        BOOL found = NO;
        for (NSArray* a in images) {
            NSString* imgfile = [a objectAtIndex:0];
            if (NSOrderedSame == [f caseInsensitiveCompare:imgfile]) {
                //CCLog(@"%@ already in local dir", imgfile);
                found = YES;
                break;
            }
        }
        
        if (!found && ![f isEqualToString:CC_INCALL_ADS_INFO_FILE_NAME]) {
            NSString* imgpath = [adspath stringByAppendingPathComponent:f];
            [fileManager removeItemAtPath:imgpath error:nil];
        }
    }
    
    CCLog(@"images count %d", [images count]);
    
    int i = 0;
    while (i < [images count]) {
        NSArray* a = [images objectAtIndex:i];
        NSString* s = [a objectAtIndex:0];
        //CCLog(@" --------- imgfile '%@', %@", s, [a objectAtIndex:1]);
        
        BOOL found = NO;
        for (NSString* f in fileList) {
            if (NSOrderedSame == [f caseInsensitiveCompare:s]) {
                //CCLog(@"%@ already in local dir", f);
                found = YES;
                break;
            }
        }
        if (!found) {
            NSString* strURL = [NSString stringWithFormat:@"https://%@:8080/CloudCall/config/%@", g_currserv, s];
            NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:strURL]];
            if (imageData) {
                NSString* imgpath = [adspath stringByAppendingPathComponent:s];
                [self writeData2File:imageData toFileAtPath:imgpath];
            } else {
                CCLog(@"Get image failed %@", s);
                
                [images removeObject:a];
                
                continue;
            }
            
            [imageData release];
        }
        
        i++;
    }
    
    [pool release];
}

-(void) StartUpdateAdImageFromNetThread {
    [self performSelectorInBackground:@selector(getIncallAdImageFromNet) withObject:nil];
}

////////////////

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

-(NSString*)LoadConfigFile{
    NSString *path = [self GetConfigDirectoryPath];
    NSString *filename = [path stringByAppendingPathComponent:CC_CONFIG_FILE_NAME];
    return [ConfigurationManager LoadFromFile:filename];
}

/*      这个没有在其它地方用到,应该可以删除
-(void)SaveConfigFile:(NSString*)strcfg {
    if (strcfg == nil)
        return;
    
   // CCLog(@"SaveConfigFile:\n%@\n", strcfg);

    NSString *path = [self GetConfigDirectoryPath];
    NSString *filename = [path stringByAppendingPathComponent:CC_CONFIG_FILE_NAME];
    
    [ConfigurationManager SaveToFile:filename andData:strcfg];
}*/

-(NSString*)GetIncallAdsDirectoryPath{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    return [dir stringByAppendingPathComponent:@"Ads"];
}

-(NSString*)GetCallFeedBackDirectoryPath{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    return [dir stringByAppendingPathComponent:@"CallFeedBack"];
}

-(void)LoadIncallAdsData {
    [incallAdData removeAllObjects];
    
    AdResourceManager *manager = [[AdResourceManager alloc] init];
    [manager dbLoadAdsData:incallAdData andMyIndex:ADSMyindexScreen];
    [manager release];
}

-(void)LoadAdsData {
    [self LoadIncallAdsData];
}

////////////////////////////////////////

NSString*  g_currserv = nil;

-(BOOL) parseConfiguration:(NSString *)strCfg {
    if (strCfg == nil || strCfg.length == 0)
        return NO;
    
    unsigned int i = 0;
    
    //从字符串分割到数组－ componentsSeparatedByString:
    //CCLog(@"parseConfiguration:\n%@\n", strCfg);
#if 1
//    NSString* strtmp = [strCfg stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
//    strtmp = [strtmp stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    NSDictionary *dicJson = [strCfg mutableObjectFromJSONString];
#else // for debug
    NSString* strtmp = [[[NSString alloc] initWithFormat:@"{\"config\":{\"app store release\":\"200\",\"backup server\":\"s1.callwine.net\",\"backup server port\":\"9200\",\"cbkcall enable\":\"1\",\"codec\":\"speex8k,g729,g711a,g711u\",\"innetcall enable\":\"0\",\"landcall enable\":\"1\",\"phonecall enable\":\"0\",\"productid\":\"YoubaitongASYunTongiosrate1\",\"registration period\":\"1800\",\"server\":\"s1.callwine.net\",\"server port\":\"9200\",\"stun enable\":\"0\",\"stun port\":\"3478\",\"stun sever\":\"numb.viagenie.ca\"},\"result\":\"success\",\"text\":\"\"}"] autorelease];
    
    NSDictionary *dicJson = [strCfg mutableObjectFromJSONString];
#endif
    
    NSDictionary *config = [dicJson objectForKey:@"config"];
    
    CCLog(@"config:%@",config);
    if (config)
    {
        //server
        NSString *server = [config objectForKey:@"server"];
        [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_HOST andValue:server];
        [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:server];
        [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_REG_HOST andValue:server];
        
        NSString *impi = [self getUserName];
        NSMutableString *impu = [NSMutableString stringWithString: @"sip:"];
        [impu appendString:impi];
        [impu appendString:@"@"];
        [impu appendString:server];
        [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:impu forKey:IDENTITY_IMPU];
        
        //server port
        NSString *serverPort = [config objectForKey:@"server port"];
        [[NgnEngine sharedInstance].configurationService setIntWithKey:NETWORK_PCSCF_PORT andValue:[serverPort intValue]];
        [[NgnEngine sharedInstance].configurationService setIntWithKey:NETWORK_PCSCF_REG_PORT andValue:[serverPort intValue]];
        
        //backup server
        NSString *backupServer = [config objectForKey:@"backup server"];
        [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_BACKUP_PCSCF_HOST andValue:backupServer];
        
        if ([g_currserv isEqualToString:backupServer]) {
            [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:backupServer];
            [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_REG_HOST andValue:backupServer];
            
            NSString *impi = [self getUserName];
            NSMutableString *impu = [NSMutableString stringWithString: @"sip:"];
            [impu appendString:impi];
            [impu appendString:@"@"];
            [impu appendString:backupServer];
            [[NgnEngine sharedInstance].infoService setInfoValueWithEncrypt:impu forKey:IDENTITY_IMPU];
        }
        
        //backup server port
        NSString *backupServerPort = [config objectForKey:@"backup server port"];
        [[NgnEngine sharedInstance].configurationService setIntWithKey:NETWORK_BACKUP_PCSCF_PORT andValue:[backupServerPort intValue]];
        
        //registration period
        NSString *registrationPeriod = [config objectForKey:@"registration period"];
        [[NgnEngine sharedInstance].configurationService setIntWithKey:NETWORK_REGISTRATION_TIMEOUT andValue:[registrationPeriod intValue]];
        
        
        //app store release
        NSString *appStoreRelease = [config objectForKey:@"app store release"];
        appstorerelease = [appStoreRelease intValue];
        
        if (g_marketType == CLIENT_FOR_AS_APP_STORE) {
            showAd = currentrelease <= appstorerelease;
            if (showAd && self->bdbanner) {
                [self ShowAdBanner:currentController];
            }
        }
        
        //cbkcall enable
        NSString *cbkcallEnable = [config objectForKey:@"cbkcall enable"];
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_CALLBACK_ENABLE andValue:[cbkcallEnable intValue]?YES:NO];
        
        //codec
        NSString *codec = [config objectForKey:@"codec"];
        NSArray *strcodes = [codec componentsSeparatedByString:@","];
        CCLog(@"codes:\n%@", strcodes);
        int prio = 0;
        for (NSString* str in strcodes) {
            CCLog(@"code:%@", str);
            if (NSOrderedSame == [str caseInsensitiveCompare:@"speex8k"]) {
                SipStack::setCodecPriority(tdav_codec_id_speex_nb, prio++);
            } else if (NSOrderedSame == [str caseInsensitiveCompare:@"g729"]) {
                SipStack::setCodecPriority(tdav_codec_id_g729ab, prio++);
            } else if (NSOrderedSame == [str caseInsensitiveCompare:@"g711a"]) {
                SipStack::setCodecPriority(tdav_codec_id_pcma, prio++);
            } else if (NSOrderedSame == [str caseInsensitiveCompare:@"g711u"]) {
                SipStack::setCodecPriority(tdav_codec_id_pcmu, prio++);
            }
            /*else if (NSOrderedSame == [str caseInsensitiveCompare:@"amr_nb_oa"]) {
             SipStack::setCodecPriority(tdav_codec_id_amr_nb_oa, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"amr_nb_be"]) {
             SipStack::setCodecPriority(tdav_codec_id_amr_nb_be, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"amr_wb_oa"]) {
             SipStack::setCodecPriority(tdav_codec_id_amr_wb_oa, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"amr_wb_be"]) {
             SipStack::setCodecPriority(tdav_codec_id_amr_wb_be, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"gsm"]) {
             SipStack::setCodecPriority(tdav_codec_id_gsm, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"ilbc"]) {
             SipStack::setCodecPriority(tdav_codec_id_ilbc, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"speex16k"]) {
             SipStack::setCodecPriority(tdav_codec_id_speex_wb, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"speex32k"]) {
             SipStack::setCodecPriority(tdav_codec_id_speex_uwb, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"bv16"]) {
             SipStack::setCodecPriority(tdav_codec_id_bv16, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"bv32"]) {
             SipStack::setCodecPriority(tdav_codec_id_bv32, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"evrc"]) {
             SipStack::setCodecPriority(tdav_codec_id_evrc, prio++);
             } else if (NSOrderedSame == [str caseInsensitiveCompare:@"g722"]) {
             SipStack::setCodecPriority(tdav_codec_id_g722, prio++);
             }*/
        }
        
        //innetcall enable
        NSString *innetCallEnable = [config objectForKey:@"innetcall enable"];
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_INNET_CALL_ENABLE andValue:[innetCallEnable intValue]?YES:NO];
        
        //landcall enable
        NSString *landCallEnable = [config objectForKey:@"landcall enable"];
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_LANDS_CALL_ENABLE andValue:[landCallEnable intValue]?YES:NO];
        
        //phonecall enable
        NSString *phoneCallEnable = [config objectForKey:@"phonecall enable"];
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_PHONE_CALL_ENABLE andValue:[phoneCallEnable intValue]?YES:NO];
        
        //productid
        NSString *productid = [config objectForKey:@"productid"];
        if (rechargeProducts) {
            [rechargeProducts release];
            rechargeProducts = nil;
        }
        if (productid) {
            rechargeProducts = [[NSMutableArray alloc] init];
            NSArray *strids = [productid componentsSeparatedByString:@","];
            CCLog(@"productids:\n%@", strids ? strids : @"");
            for (NSString* id in strids) {
                CCLog(@"productid:%@", id);
                [rechargeProducts addObject:id];
            }
            if (iapMgr)
                iapMgr.products = rechargeProducts;
        }
        
        //stun enable
        NSString *stunEnable = [config objectForKey:@"stun enable"];
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:NATT_USE_STUN andValue:[stunEnable intValue]?YES:NO];
        
        //stun port
        NSString *stunPort = [config objectForKey:@"stun port"];
        [[NgnEngine sharedInstance].configurationService setIntWithKey:NATT_STUN_PORT andValue:[stunPort intValue]];
        
        //stun sever
        NSString *stunSever = [config objectForKey:@"stun sever"];
        [[NgnEngine sharedInstance].configurationService setStringWithKey:NATT_STUN_SERVER andValue:stunSever];
        
        //max exchange points
        NSString *maxExchangePoints = [config objectForKey:@"max exchange points"];
        maxexchangepoints = [maxExchangePoints intValue];
    }
    return YES;
}

-(void) processContactsGotFromServer:(NSMutableArray *)friendArray
{
    NSString *myNumber = [self getUserName];
    
    for (NSString *friendNumber in friendArray)
    {
        //非纯数字的号码
        if (!IsPureNumber(friendNumber)) continue;
        
        [[NgnEngine sharedInstance].contactService dbAddWeiCallUserContact:myNumber PhoneNum:friendNumber];
    }
    
//    NSString* strPos = msgContent;
//    NSString* tmpStr = nil;
//    CCLog(@"processContactsGotFromServer: Content=%@", strPos);
//
//    NSString* startTag    = @"Number!";
//    NSString* myNumTag    = @"User:";
//    NSString* contactsTag = @"WeiCall!";
//
//    tmpStr = [strPos substringToIndex:[startTag length]];
//    if (!tmpStr && NSOrderedSame != [tmpStr caseInsensitiveCompare:startTag]) {
//        CCLog(@"processContactsGotFromServer: can't get %@ header\n", startTag);
//        return;
//    }
//
//    strPos = [strPos substringFromIndex:[startTag length]]; // Piont to @"User:......"
//    if (!strPos) {
//        CCLog(@"processContactsGotFromServer: move to %@ failed\n", myNumTag);
//        return;
//    }
//    tmpStr = [strPos substringToIndex:[myNumTag length]];
//    if (!tmpStr && NSOrderedSame != [tmpStr caseInsensitiveCompare:myNumTag]) {
//        CCLog(@"processContactsGotFromServer: can't get %@ header\n", myNumTag);
//        return;
//    }
//
//    strPos = [strPos substringFromIndex:[myNumTag length]]; // Piont to my number
//    if (!strPos) {
//        CCLog(@"processContactsGotFromServer: move to my number\n");
//        return;
//    }
//    NSRange range = [strPos rangeOfString:@";"];
//    tmpStr = [strPos substringToIndex:range.location];
//    if (!tmpStr) {
//        CCLog(@"processContactsGotFromServer: can't get my number\n");
//        return;
//    }
//    NSString *myNum = tmpStr;
//    CCLog(@"myNum:%@", myNum);
//    NSString *originalPhoneNum = [self getUserName];
//    if (NSOrderedSame != [originalPhoneNum caseInsensitiveCompare:myNum]) {
//        CCLog(@"processContactsGotFromServer: my Number %@ != %@ (got)", originalPhoneNum, myNum);
//        return;
//    }
//
//    strPos = [strPos substringFromIndex:[myNum length] + 1]; // Piont to @"WeiCall!......"
//    if (!strPos) {
//        CCLog(@"processContactsGotFromServer: move to %@ failed\n", contactsTag);
//        return;
//    }
//    tmpStr = [strPos substringToIndex:[contactsTag length]];
//    if (!tmpStr && NSOrderedSame != [tmpStr caseInsensitiveCompare:contactsTag]) {
//        CCLog(@"processContactsGotFromServer: can't get %@ header\n", contactsTag);
//        return;
//    }
//
//    strPos = [strPos substringFromIndex:[contactsTag length]]; // Piont to frist contact number
//    if (!strPos) {
//        CCLog(@"processContactsGotFromServer:: move to frist contact number\n");
//        return;
//    }
//    unsigned long index = 0;
//    while (strPos && [strPos length]) {
//        NSRange range = [strPos rangeOfString:@";"];
//        tmpStr = [strPos substringToIndex:range.location];
//        if (!tmpStr) {
//            CCLog(@"processContactsGotFromServer: can't get contact number\n");
//            return;
//        }
//        NSString *contactNum = tmpStr;
//
//        index++;
//        CCLog(@"contactNum:%@ [index %ld]", contactNum, index);
//        
//        [[NgnEngine sharedInstance].contactService dbAddWeiCallUserContact:myNum PhoneNum:contactNum]; 
//        
//        strPos = [strPos substringFromIndex:[contactNum length] + 1]; // Piont to next contact number
//    }
//    
//    return;
}

-(RemoteNotificationDef*)parseremotenotification:(NSDictionary*)note {
    if (!note) {        
        return NULL;
    }

#if 0
    NSString *msg = [NSString stringWithFormat:@"%@", note];
    //CCLog(@"ReceiveRemoteNotification:\n%@", msg);
    
    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"getcidfromremnote"                        
                                                  message:msg delegate:nil                        
                                        cancelButtonTitle:@"OK" otherButtonTitles:nil];    
    [alert show];
    [alert release];
#endif

    RemoteNotificationDef* prnd = [[[RemoteNotificationDef alloc] init] autorelease];
    NSString* value = nil;
    for (id key in note) {
        NSString* strKey = key;
        value = [note objectForKey:key];
        CCLog(@"key:'%@', value:'%@'\n", strKey, value);        
        if (NSOrderedSame == [strKey caseInsensitiveCompare:@"type"]) {            
            if (NSOrderedSame == [value caseInsensitiveCompare:@"1"])
                prnd.type = APNS_TYPE_INCOMING_CALL;
            else if (NSOrderedSame == [value caseInsensitiveCompare:@"2"])
                prnd.type = ANPS_TYPE_INCOMING_MSG;
        } else if (NSOrderedSame == [strKey caseInsensitiveCompare:@"cid"]) {
            prnd.type = APNS_TYPE_INCOMING_CALL;
            prnd.value = value;
        }
    }
    return prnd;
}

-(BOOL) sendAnswerCallMsg:(NSString*)pcid {
    BOOL ret = NO;    
    if (!pcid)
        return ret;
        
    // send Content-Type：text/answercall
    //      content:cid=xxxx
    NSString* txtMsgType = @"text/answercall";
    NSString* strContent = [@"cid=" stringByAppendingString:pcid];
    NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack] 
                                                                                  andToUri:txtMsgType];
    if (!session)
        return ret;
    
    ret = [session sendTextMessage:strContent contentType:txtMsgType];

#if 0
    NSString* strOut = [[NSString alloc] initWithFormat:@"Send '%@', '%@' %@", txtMsgType, strContent, ret?@"succ":@"fail"];        
    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"send" message:strOut delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];    
    [alert show];    
    alert=nil;
        
    [strOut release];
#endif
    
    return ret;
}

-(UIViewController<BannerViewContainer> *) toBannerViewContainer:(UIViewController*) viewController {
    if ([viewController conformsToProtocol:@protocol(BannerViewContainer)])
        return (UIViewController<BannerViewContainer> *)viewController;
    return nil;
}

-(void)ShowAdBanner:(UIViewController<BannerViewContainer>*) bannerView {
    if (bannerView) {
        NSObject* adBanner = nil;
        if (adType == AD_TYPE_IAD) {
            if (iadbanner.bannerLoaded) {
                adBanner = iadbanner;
            }
        } /*else if (adType == AD_TYPE_91DIANJIN) {
            adBanner = djbanner;
        } */else if (adType == AD_TYPE_LIMEI) {
            adBanner = lmbanner;
        } else if (adType == AD_TYPE_CLOUDCALL_HK) {
            adBanner = ctbanner;
        } else if (adType == AD_TYPE_BAIDU || adType == AD_TYPE_91DIANJIN){
            adBanner = bdbanner;
            
//            if (currentController)
//                [currentController hideBannerView:adBanner adtype:adType animated:NO];
//            if (bannerView && showAd) 
//                [bannerView showBannerView:adBanner adtype:adType animated:NO];
        }
        
        if (adBanner) {
            if (currentController && [currentController respondsToSelector:@selector(hideBannerView:adtype:animated:)])
                [currentController hideBannerView:adBanner adtype:adType animated:NO];
            if (bannerView && showAd) {
                [bannerView showBannerView:adBanner adtype:adType animated:NO];                
                
                if (adType == AD_TYPE_LIMEI && setImmobViewDisplay == NO) {
                    [lmbanner immobViewDisplay];
                    
                    setImmobViewDisplay = YES;
                }
            }
        }
        
        currentController = bannerView;
    }
}

@end


//
//	sip callback events implementation
//
@interface CloudCall2AppDelegate(Sip_And_Network_Callbacks)
-(void) onNetworkEvent:(NSNotification*)notification;
-(void) onNativeContactEvent:(NSNotification*)notification;
-(void) onStackEvent:(NSNotification*)notification;
-(void) onRegistrationEvent:(NSNotification*)notification;
-(void) onMessagingEvent:(NSNotification*)notification;
-(void) onInviteEvent:(NSNotification*)notification;
-(void) onNotifyMsgResponseStatus:(NSNotification*)notification;
@end

@implementation CloudCall2AppDelegate(Sip_And_Network_Callbacks)

//== Network events == //
-(void) onNetworkEvent:(NSNotification*)notification {
	NgnNetworkEventArgs *eargs = [notification object];
	
	switch (eargs.eventType) {
		case NETWORK_EVENT_STATE_CHANGED:
		default: {
			NgnNSLog(TAG,@"NetworkEvent reachable=%@ networkType=%i", 
					 [NgnEngine sharedInstance].networkService.reachable ? @"YES" : @"NO", [NgnEngine sharedInstance].networkService.networkType);
			
			if ([NgnEngine sharedInstance].networkService.reachable) {
				BOOL onMobileNework = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
				
				if (onMobileNework) { // 3G, 4G, EDGE ...
					MediaSessionMgr::defaultsSetBandwidthLevel(tmedia_bl_medium); // QCIF, SQCIF
				} else {// WiFi
					MediaSessionMgr::defaultsSetBandwidthLevel(tmedia_bl_unrestricted);// SQCIF, QCIF, CIF ...
				}
				
				// unregister the application and schedule another registration
				BOOL on3G = onMobileNework; // Downgraded to 3G even if it could be 4G or EDGE
				BOOL use3G = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
				if (on3G && !use3G) {
					[self networkAlert:NSLocalizedString(@"Only 3G network is available. Please allow YunTong to use 3G network.", @"Only 3G network is available. Please allow YunTong to use 3G network.")];
					[[NgnEngine sharedInstance].sipService stopStackSynchronously];
				} else { // "on3G and use3G" or on WiFi
					// stop stack => clean up all dialogs
					[[NgnEngine sharedInstance].sipService stopStackSynchronously];
                    [loginManager startLoginTheard];
				}
			} else {
                //network unreachable
                [[NgnEngine sharedInstance].sipService stopStackSynchronously];
            }
			
			break;
		}
	}
}

//== Native Contact events == //
-(void) onNativeContactEvent:(NSNotification*)notification {
	NgnContactEventArgs *eargs = [notification object];
	
	switch (eargs.eventType) {
		case CONTACT_RESET_ALL:
		default:
		{
			if([UIApplication sharedApplication].applicationState != UIApplicationStateActive){
				self->nativeABChangedWhileInBackground = YES;
			}
			// otherwise addAll will be called when the client registers
			break;
		}
	}
}

-(void) onStackEvent:(NSNotification*)notification {
	NgnStackEventArgs * eargs = [notification object];
	switch (eargs.eventType) {
		case STACK_STATE_STARTING:
		{
			// this is the only place where we can be sure that the audio system is up
            //[[NgnEngine sharedInstance].soundService setSpeakerEnabled:YES];
			
			break;
		}
		default:
			break;
	}
}

//== REGISTER events == //
-(void) onRegistrationEvent:(NSNotification*)notification {
    NgnRegistrationEventArgs* eargs = [notification object];
	CCLog(@"AppDelegate: Reg notify: %d, %d, %d, %@, %@", regAttempt, eargs.eventType, eargs.sipCode, eargs.sipPhrase ? eargs.sipPhrase : @"", eargs.subServ ? eargs.subServ : @"");

	// gets the new registration state
	ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];	
    
    //ensure register timer is running
    /*if (!registerTimer){
        //gary keep registeing for every 300 seconds, because the SetExpires seems not always working
        registerTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0]
                                                 interval:300
                                                   target:self
                                                 selector:@selector(keepRegisterCallback)
                                                 userInfo:nil
                                                  repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:registerTimer forMode:NSRunLoopCommonModes];
        
    }*/
    CCLog(@"onRegistrationEvent: %d", registrationState);
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			/*if (scheduleRegistration) {
				scheduleRegistration = NO;
				[[NgnEngine sharedInstance].sipService registerIdentity];
			}*/
            
            if (eargs.sipCode == 301) {
                regAttempt = 0;
                
                if (eargs.subServ) {
                    URI uri;
                    uri.parse([eargs.subServ UTF8String]);                    
                    NSString* strHost = [NSString stringWithCString:uri.host encoding:NSASCIIStringEncoding];
                    [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:strHost];
                    [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_REG_HOST andValue:strHost];
                    
                    [[NgnEngine sharedInstance].sipService stopStackSynchronously];
                    [loginManager startLoginTheard];
                }
            } else if (eargs.sipCode == tsip_event_code_dialog_terminated) {
                // reigster failed - try to register to the other sip server
                if (phonenumvalidating == NO && regAttempt < 3) {
                    NSString* strHost    = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_HOST];
                    NSString* strBakHost = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_BACKUP_PCSCF_HOST];
                    NSString* strRegHost = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_REG_HOST];
                    if ([strHost isEqualToString:strRegHost]) {                    
                        [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:strBakHost];
                        [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_REG_HOST andValue:strBakHost];
                    } else if ([strBakHost isEqualToString:strRegHost]) {
                        [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:strHost];
                        [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_REG_HOST andValue:strHost];
                    }
                    
                    [[NgnEngine sharedInstance].sipService stopStackSynchronously];
                    [loginManager startLoginTheard];
                    
                    regAttempt++;
                }
            }
			break;
			
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
            break;
		case CONN_STATE_CONNECTED: {
            regAttempt = 0;
            registered = YES;
            if (launchremns) {
                if (launchremns.type == APNS_TYPE_INCOMING_CALL && launchremns.value) {
                    [self sendAnswerCallMsg:launchremns.value];
                }
                [launchremns release];
                launchremns = 0;
            }
            
            if (starting) {
                starting = NO;
                
                //int syncc = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_ACCESS_CONTACTS_LIST];
                //if (syncc == GENERAL_ACCESS_CONTACTS_LIST_ALLOW)
                //    [self uploadContacts2Server:NO];
                
                [self CheckUserRight];
                
            }
            break;
        }
		default:
			break;
	}
}

//== PagerMode IM (MESSAGE) events == //
-(void) onMessagingEvent:(NSNotification*)notification {
	NgnMessagingEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case MESSAGING_EVENT_CONNECTING:
		case MESSAGING_EVENT_CONNECTED:
		case MESSAGING_EVENT_TERMINATING:
		case MESSAGING_EVENT_TERMINATED:
		case MESSAGING_EVENT_FAILURE:
		case MESSAGING_EVENT_SUCCESS:
		case MESSAGING_EVENT_OUTGOING:
		default:
		{
			break;
		}
			
		case MESSAGING_EVENT_INCOMING:
		{
            CCLog(@"Incoming message: content:\n%s",  eargs.payload?[eargs.payload bytes]:"<NULL>");
			if(eargs.payload){
				// The payload is a NSData object which means that it could contain binary data
				// here I consider that it's utf8 text message
				NSString* contentType = [eargs getExtraWithKey: kExtraMessagingEventArgsContentType];
				//NSString* from = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUri];
				NSString* userName = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUserName];
				//content-transfer-encoding: base64\r\n
				//NSString* content = [NSString stringWithUTF8String: (const char*)[eargs.payload bytes]];
				
				// default content: e.g. plain/text
				NSData *content = eargs.payload;
				CCLog(@"Incoming message: from:%@\n with ctype:%@\n and content:\n%s", userName, contentType, [content bytes]);
                
                BOOL txtMsg = YES;
                if (contentType) {
                    if ([[contentType lowercaseString] hasPrefix:@"text/authfail"]) { // incorrect password
                        txtMsg = NO;
                        NSString *passwd = [self getUserPassword];
                        if (![passwd isEqualToString:DEFAULT_IDENTITY_PASSWORD]) {
                            if (phonenumvalidating == NO) {
//                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
//                                                                            message: NSLocalizedString(@"Invalid password!\nYou need to get the password again.", @"Invalid password!\nYou need to get the password again.")
//                                                                           delegate: nil
//                                                                  cancelButtonTitle: nil
//                                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
//                                [alert show];
//                                [alert release];
                        
                                //就算sip登录失败，也不会返回
//                                [self displayValidationView];
                            }
                            
                            break;
                        }
                    } /*else if ([[contentType lowercaseString] hasPrefix:@"text/contacts"]) {
                        NSString *aString = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
                        [self processContactsGotFromServer:aString];
                        [aString release];
                        
                        break;
                    }*/ else if ([[contentType lowercaseString] hasPrefix:@"text/config"]) {
                        NSString *strContent = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
                        CCLog(@"strContent: %@", strContent);
                        
                        NSString* startTag = @"LANDCALL=";
                        NSString* strPos = strContent;
                        NSString* tmpStr = [strPos substringToIndex:[startTag length]];
                        if (!tmpStr && NSOrderedSame != [tmpStr caseInsensitiveCompare:startTag]) {
                            CCLog(@"text/config: can't get %@ header\n", startTag);
                            [strContent release];
                            break;
                        }
                        
                        strPos = [strPos substringFromIndex:[startTag length]];
                        if (!strPos) {
                            CCLog(@"text/config: move to version number failed\n");
                            [strContent release];
                            break;
                        }
                        CCLog(@"strPos %@", strPos);
                        
                        BOOL enabled = NO;
                        if (NSOrderedSame == [strPos caseInsensitiveCompare:@"1"]) { // Enabled
                            enabled = YES;
                        }
                        
                        [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_LANDS_CALL_ENABLE andValue:enabled];
                                                
                        [strContent release];
                        
                        break;
                    } else if ([[contentType lowercaseString] hasPrefix:@"text/register"]) {                        
                        NSString *strContent = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
                        CCLog(@"strContent: %@", strContent);
                        
                        /*
                         Content-Type:text/register
                         rechargemoney:          //本次赠送点数
                         remainmoney:            //用户余额
                         errorcode:0             //0 – 成功；无错误代码
                         */                        
                        int recharge = 0;
                        int balance = 0;
                        int errorcode = 0;
                        
                        NSString* strTmp = [strContent stringByReplacingOccurrencesOfString:@"\r" withString:@""];                        
                        NSArray *array = [strTmp componentsSeparatedByString:@"\n"];
                        CCLog(@"array:%@",array);
                        for (NSString* str in array) {
                            CCLog(@"item:%@", str);
                            NSString* item = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            if (!item || [item length] == 0) 
                                continue;
                            NSArray *as = [item componentsSeparatedByString:@":"];
                            if (as && as.count == 2) {
                                NSString* strparameter = [as objectAtIndex:0];
                                NSString* strvalue     = [as objectAtIndex:1];
                                strparameter = [strparameter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                strvalue     = [strvalue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                
                                CCLog(@"p=%@, v=%@\n", strparameter, strvalue);
                                if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"rechargemoney"]) {
                                    recharge = [strvalue intValue];
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"remainmoney"]) {
                                    balance = [strvalue intValue];
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"errorcode"]) {
                                    errorcode = [strvalue intValue];
                                }
                            }
                        }
                        
                        NSString* strbalance = nil;                        
                        if (errorcode == 0) { // succ
                            strbalance = [[NSString alloc] initWithFormat:NSLocalizedString(@"Welcome to YunTong! Got %d YunTong points for the first time login, your balance is %d YunTong points", @"Welcome to YunTong! Got %d YunTong points for the first time login, your balance is %d YunTong points"), recharge, balance];
                        }
                        UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"YunTong", @"YunTong")
                                                                    message: strbalance
                                                                   delegate: self
                                                          cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                        [a show];
                        [a release];                        
                        [strbalance release];
                        
                        [strContent release];
                        
                        break;
                    }
//                    else if ([[contentType lowercaseString] hasPrefix:@"text/getreferee"]) {
//                        if (lastMsgCallId && [lastMsgCallId isEqualToString: eargs.callId]) {
//                            CCLog(@"Incoming message: Error -- the same call-id as the last received %@", eargs.callId);
//                            break;
//                        }
//                        if (lastMsgCallId) {
//                            [lastMsgCallId release];
//                            lastMsgCallId = nil;
//                        }
//                        lastMsgCallId = [eargs.callId retain];
//                        
//                        NSString *strContent = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
//                        CCLog(@"strContent: %@", strContent);
//                        
//                        /*
//                         friend:00000
//                         errorcode:1
//                         */
//                        NSString* referee = nil;
//                        int errorcode = 0;
//                        
//                        NSString* strTmp = [strContent stringByReplacingOccurrencesOfString:@"\r" withString:@""];                        
//                        NSArray *array = [strTmp componentsSeparatedByString:@"\n"];
//                        CCLog(@"array:%@",array);
//                        for (NSString* str in array) {
//                            CCLog(@"item:%@", str);
//                            NSString* item = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//                            if (!item || [item length] == 0) 
//                                continue;
//                            NSArray *as = [item componentsSeparatedByString:@":"];
//                            if (as && as.count == 2) {
//                                NSString* strparameter = [as objectAtIndex:0];
//                                NSString* strvalue     = [as objectAtIndex:1];
//                                strparameter = [strparameter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                                strvalue     = [strvalue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                                
//                                CCLog(@"p=%@, v=%@\n", strparameter, strvalue);
//                                if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"friend"]) {
//                                    referee = strvalue;
//                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"errorcode"]) {
//                                    errorcode = [strvalue intValue];
//                                }
//                            }
//                        }
//                        
//                        if (0 == errorcode && referee && [referee length]) {
//                            // "00000" : no set referee
//                            if ([referee isEqualToString:@"00000"] == NO) {
//                                // set referee
////                                [[NgnEngine sharedInstance].configurationService setStringWithKey:ACCOUNT_REFEREE andValue:referee];
//                            }
//                        }                        
//                        else
//                        {
//                            haveSetReferee = NO;
//                        }
//                        [strContent release];
//                        
//                        break;
//                    }
//                        else if ([[contentType lowercaseString] hasPrefix:@"text/versionupdate"]) {
//                        BOOL checking = checkingVersionUpdate;
//                        checkingVersionUpdate = NO;
//                        
//                        if (lastMsgCallId && [lastMsgCallId isEqualToString: eargs.callId]) {
//                            CCLog(@"Incoming message: Error -- the same call-id as the last received %@", eargs.callId);
//                            break;
//                        }
//                        if (lastMsgCallId) {
//                            [lastMsgCallId release];
//                            lastMsgCallId = nil;
//                        }
//                        lastMsgCallId = [eargs.callId retain];
//                        
//                        NSString *strContent = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
//                        CCLog(@"strContent: %@", strContent);
//                        
//                        NSString* version = nil;
//                        int filesize = 0;
//                        NSString* md5 = nil;
//                        NSString* versionnotes = nil;
//                        NSString* url = nil;
//                        
//                        NSString* strTmp = [strContent stringByReplacingOccurrencesOfString:@"\r" withString:@""];                        
//                        NSArray *array = [strTmp componentsSeparatedByString:@"\n"];
//                        //CCLog(@"array:%@",array);                        
//                        for (NSString* str in array) {                            
//                            NSString* item = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//                            //CCLog(@"item:%@", item);
//                            if (!item || 0 == [item length])
//                                continue;
//                            
//                            NSRange range = [item rangeOfString:@":"];
//                            NSString* strparameter = [item substringToIndex:range.location];
//                            if (!strparameter) {
//                                continue;
//                            }
//                            CCLog(@"strparameter: '%@', %d", strparameter, range.location);
//                            
//                            if (range.location + 1 >= [item length])
//                                continue;
//                            NSString* strvalue = [item substringFromIndex:(range.location + 1)];
//                            if (!strvalue) {
//                                continue;
//                            }                  
//                            CCLog(@"strvalue: '%@'", strvalue);
//                            
//                            CCLog(@"p=%@, v=%@\n", strparameter, strvalue);
//                            if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"version"]) {
//                                version = strvalue;
//                            } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"filesize"]) {
//                                filesize = [strvalue intValue];
//                            } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"md5"]) {
//                                md5 = strvalue;
//                            } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"url"]) {
//                                url = strvalue;
//                            } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"notes"]) {
//                                versionnotes = strvalue;
//                            }
//                        }
//                        CCLog(@"filesize=%@,md5=%@",filesize,md5);
//                        if (!version || [version length] == 0)
//                        {
//                            [strContent release];
//                            break;
//                        }
//                        
//                        NSString* strPrompt = nil;
//                        BOOL cancelButton = NO;
//                        NSString* currVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
//                        
//                        BOOL showAlertView = YES;
//                        BOOL update = NO;
//                        if (version && (NSOrderedSame == [version caseInsensitiveCompare:currVer] || NSOrderedAscending == [version caseInsensitiveCompare:currVer])) {
//                            showAlertView = checking;                            
//                            strPrompt = [NSString stringWithFormat:NSLocalizedString(@"You are using the latest version!", @"You are using the latest version!"), version];
//                        } else {
//                            NSString* strNotes = @"";
//                            if (versionnotes && [versionnotes length])
//                                strNotes = [versionnotes stringByReplacingOccurrencesOfString:@"&&" withString:@"\n"];
//                            strPrompt = [NSString stringWithFormat:NSLocalizedString(@"YunTong %@ is available now.\nRelease Notes:\n%@", @"YunTong %@ is available now.\nRelease Notes:\n%@"), version, strNotes];
//                            update = YES;
//                            
//                            if (versionUrl) {
//                                [versionUrl release];
//                                versionUrl = nil;
//                            }
//                            if (url && [url length])
//                                versionUrl = [[NSString alloc] initWithString:url];
//                        }
//                        if (showAlertView) {
//                            UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Check Update", @"Check Update")
//                                                                    message: strPrompt
//                                                                   delegate: self
//                                                          cancelButtonTitle:update?NSLocalizedString(@"Cancel", @"Cancel"):nil otherButtonTitles: update?NSLocalizedString(@"Update", @"Update"):NSLocalizedString(@"OK", @"OK"), nil];
//                            if (update) a.tag = kTagActionAlertUpdateVersion;
//                            [a show];
//                            [a release];
//                        }
//                        
//                        [strContent release];
//                        
//                        break;
//                    }
                        else if ([[contentType lowercaseString] hasPrefix:@"text/notify"]) {
                        NSString *strContent = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
                        CCLog(@"strContent: %@", strContent);
                        
                        if (strContent && strContent.length) {                            
                            NSString* strNotify = [strContent stringByReplacingOccurrencesOfString:@"&&" withString:@"\n"];
                            
                            if (strNotify && strNotify.length) {
                                NSString *mynum = [self getUserName];                                
                                NgnSystemNotification* sysnotify = [[NgnSystemNotification alloc] initWithContent:strNotify andMyNumber:mynum andReceiveTime:[[NSDate date] timeIntervalSince1970] andRead:NO];
                                [[NgnEngine sharedInstance].storageService addSystemNofitication:sysnotify];
                                [sysnotify release];
                            
                                unreadSysNotify++;
                                [self UnreadSysNofifyNum:unreadSysNotify];
                            }
                        }
                        
                        [strContent release];
                        
                        break;
                    } else if ([[contentType lowercaseString] hasPrefix:@"text/userright"]) {
                        if (lastMsgCallId && [lastMsgCallId isEqualToString: eargs.callId]) {
                            CCLog(@"Incoming message: Error -- the same call-id as the last received %@", eargs.callId);
                            break;
                        }
                        if (lastMsgCallId) {
                            [lastMsgCallId release];
                            lastMsgCallId = nil;
                        }
                        lastMsgCallId = [eargs.callId retain];
                        
                        NSString *strContent = [[NSString alloc] initWithData:eargs.payload encoding:NSUTF8StringEncoding];
                        CCLog(@"strContent: %@", strContent);
                        
                        int userLevel = 0;
                        BOOL conferenceEnable = NO;
                        
                        /*
                         服务器->客户端消息格式：
                         Content-Type:text/userright
                         userlevel:整数        //用户等级，数值越大等级越高；默认为0，大于0则显示VIP用户标识
                         conference:enable/disable  //会议权限
                         confmember:会议成员数量  //根据用户等级依次增加,取值 0,5,7,10
                         */
                        NSString* strTmp = [strContent stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                        NSArray *array = [strTmp componentsSeparatedByString:@"\n"];
                        CCLog(@"array:%@",array);
                        for (NSString* str in array) {
                            CCLog(@"item:%@", str);
                            NSString* item = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            if (!item || [item length] == 0)
                                continue;
                            NSArray *as = [item componentsSeparatedByString:@":"];
                            if (as && as.count == 2) {
                                NSString* strparameter = [as objectAtIndex:0];
                                NSString* strvalue     = [as objectAtIndex:1];
                                
                                strparameter = [strparameter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                strvalue     = [strvalue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                
                                CCLog(@"p=%@, v=%@\n", strparameter, strvalue);
                                if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"userlevel"]) {
                                    userLevel = [strvalue intValue];
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"conference"]) {
                                    if (NSOrderedSame == [strvalue caseInsensitiveCompare:@"enable"]) {
                                        conferenceEnable = YES;
                                    }
                                } else if (NSOrderedSame == [strparameter caseInsensitiveCompare:@"confmember"]) {
                                    maxconfmembers = [strvalue intValue];
                                }
                            }
                        }
                        
                        /*if (0 == userLevel) {
                            [imageVIP setHidden:YES];
                        } else {
                            [imageVIP setHidden:NO];
                            [imageVIP setImage:[UIImage imageNamed:[NSString stringWithFormat:@"vip%d.png", userLevel]]];
                        }*/
//                        [[NgnEngine sharedInstance].configurationService setIntWithKey:ACCOUNT_LEVEL andValue:userLevel];
                        [[NgnEngine sharedInstance].infoService setInfoValue:[NSNumber numberWithInt:userLevel] forKey:[ACCOUNT_LEVEL lowercaseString]];
                        
                        [strContent release];
                        //通知刷新群组页面的标题栏
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTitleText" object:nil];
                         
                        break;
                    } else if ([[contentType lowercaseString] hasPrefix:@"message/cpim"]) { // message/cpim content
                        MediaContent *_content = MediaContent::parse([eargs.payload bytes], [eargs.payload length], [NgnStringUtils toCString:@"message/cpim"]);
                        if(_content){
                            unsigned _clen = dynamic_cast<MediaContentCPIM*>(_content)->getPayloadLength();
                            const void* _cptr = dynamic_cast<MediaContentCPIM*>(_content)->getPayloadPtr();
                            if(_clen && _cptr){
                                const char* _contentTransferEncoding = dynamic_cast<MediaContentCPIM*>(_content)->getHeaderValue("content-transfer-encoding");
                                    
                                if(tsk_striequals(_contentTransferEncoding, "base64")){
                                    char *_ascii = tsk_null;
                                    int ret = tsk_base64_decode((const uint8_t*)_cptr, _clen, &_ascii);
                                    if((ret > 0) && _ascii){
                                        content = [NSData dataWithBytes:_ascii length:ret];
                                    }
                                    else {
                                        TSK_DEBUG_ERROR("tsk_base64_decode() failed with error code equal to %d", ret);
                                    }
                                        
                                    TSK_FREE(_ascii);
                                }
                                else {
                                    content = [NSData dataWithBytes:_cptr length:_clen];
                                }
                            }
                            delete _content;
                        }
                    }
                }
                
                if (txtMsg) {
#if 0 // Do NOT support message anymore
                    NgnHistorySMSEvent *smsEvent = [NgnHistoryEvent createSMSEventWithStatus:HistoryEventStatus_Incoming
                                                                            andRemoteParty:userName
                                                                                andContent:content];
                    [[NgnEngine sharedInstance].historyService addEvent:smsEvent];
				
                    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                        UILocalNotification* localNotif = [[[UILocalNotification alloc] init] autorelease];
                        NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:userName];
                        NSString* contentAsString = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
                        localNotif.alertBody = [NSString stringWithFormat:@"%@: %@", contact.displayName, contentAsString];
                        [contentAsString release];
                        localNotif.soundName = @"myring.caf"; 
                        localNotif.applicationIconBadgeNumber = ++[UIApplication sharedApplication].applicationIconBadgeNumber;
                        localNotif.repeatInterval = 0;
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  kNotifKey_IncomingMsg, kNotifKey,
                                                  nil];
                        localNotif.userInfo = userInfo;
                        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
                    }
#endif
                }
			}
			break;
		}
	}
}


//== INVITE (audio/video, file transfer, chat, ...) events == //
-(void) onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INCOMING:
		{
            incomingCall = YES;
			NgnAVSession* incomingSession = [[NgnAVSession getSessionWithId: eargs.sessionId] retain];
			if (incomingSession && [UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
				UILocalNotification* localNotif = [[[UILocalNotification alloc] init] autorelease];
				if (localNotif){
					bool _isVideoCall = isVideoType(incomingSession.mediaType);
					NSString *remoteParty = incomingSession.historyEvent ? incomingSession.historyEvent.remotePartyDisplayName : [incomingSession getRemotePartyUri];
					
					NSString *stringAlert = [NSString stringWithFormat:kIncomingCallAlertText, remoteParty];
#ifdef CLIENT_SUPPORT_VIDEO
					if (_isVideoCall)
						stringAlert = [NSString stringWithFormat:kIncomingVideoCallAlertText, remoteParty];
#endif
					
					localNotif.alertBody = stringAlert;
					localNotif.soundName = @"myring.wav";//UILocalNotificationDefaultSoundName;
					localNotif.applicationIconBadgeNumber = ++[UIApplication sharedApplication].applicationIconBadgeNumber;
                    ++missedCalls;
                    
					localNotif.repeatInterval = 0;
					NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
											  kNotifKey_IncomingCall, kNotifKey,
											  [NSNumber numberWithLong:incomingSession.id], kNotifIncomingCall_SessionId,
											  nil];
					localNotif.userInfo = userInfo;
					[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
				}
			}
			else if(incomingSession){
				[CallViewController receiveIncomingCall:incomingSession];
			}
			
			[NgnAVSession releaseSession:&incomingSession];
			break;
		}
			
		case INVITE_EVENT_MEDIA_UPDATED:
		{
			NgnAVSession* session = [[NgnAVSession getSessionWithId:eargs.sessionId] retain];
			if(session){
				// Dismiss previous and display(present) the new one
				// animation must be NO because we are calling dismiss then present
				[self.tabBarController dismissModalViewControllerAnimated:NO];
				[CallViewController displayCall:session];
			}
			[NgnAVSession releaseSession:&session];
			break;
		}
			
		case INVITE_EVENT_TERMINATED:
		{
			if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
				// call terminated while in background
				// if the application goes to background while in call then the keepAwake mechanism was not started
				if([NgnEngine sharedInstance].sipService.registered && ![NgnAVSession hasActiveSession]){
					[[NgnEngine sharedInstance] startKeepAwake];
				}
			}
			break;
		}
		
		default:
		{
			break;
		}
	}
}

-(void) onNotifyMsgResponseStatus:(NSNotification*)notification {
    NotifyMsgResponseStatusNotificationArgs* nmrsna = [notification object];
    for (NgnSystemNotification* sysnotify in nmrsna.records) {
        [[NgnEngine sharedInstance].storageService addSystemNofitication:sysnotify];
    }
    
    if ([nmrsna.records count]) {
        NSString *myNum = [self getUserName];
        if (myNum && [myNum length]) {
            unsigned int unreadnum = [[NgnEngine sharedInstance].storageService getUnreadSystemNotificationNum:myNum];
            if (unreadnum) {
                [self UnreadSysNofifyNum:unreadnum];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnNotifyMsgResponseStatusFinished object:nil];
}

@end

@interface CloudCall2AppDelegate(CheckVersionUpdate)
- (void)sendCheckVersionUpdateRequest:(BOOL)autoCheck;
- (void)sendCheckVersionUpdateRespone:(NSData *)data andUserInfo:(NSDictionary *)userInfo;
- (void)sendCheckVersionUpdateResponeError:(NSData *)data andUserInfo:(NSDictionary *)userInfo;
- (BOOL)checkVersionNeedToUpdateByServV:(NSString *)servVersion compareCurrV:(NSString *)currVersion;

@end

@implementation CloudCall2AppDelegate(CheckVersionUpdate)
- (void)sendCheckVersionUpdateRequest:(BOOL)autoCheck
{
    NSString *strJson = @"{}";
    NSData *jsonData = [strJson JSONData];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [userInfo setValue:autoCheck?@"1":@"0" forKey:@"autoCheck"];
    
    [[HttpRequest instance] addRequest:kCheckVersionUpdateUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:8
                         successTarget:self successAction:@selector(sendCheckVersionUpdateRespone:andUserInfo:)
                         failureTarget:self failureAction:@selector(sendCheckVersionUpdateResponeError:andUserInfo:) userInfo:userInfo];
}

- (void)sendCheckVersionUpdateRespone:(NSData *)data andUserInfo:(NSDictionary *)userInfo
{
    NSString *autoCheck = [userInfo objectForKey:@"autoCheck"];
    
    NSString *recvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *aStr = [recvString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    CCLog(@"sendCheckVersionUpdateRespone:%@",aStr);
    NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithDictionary:[aStr mutableObjectFromJSONString]];
    
    NSString *result = [root objectForKey:@"result"];
    
    if ([result isEqualToString:@"success"])
    {
        NSString *version = [root objectForKey:@"version"];
        NSString *text = [root objectForKey:@"notes"];
        NSString *url = [root objectForKey:@"url"];
        
        NSString* strPrompt = nil;
        BOOL cancelButton = NO;
        NSString* currVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        BOOL showAlertView = YES;
        BOOL update = NO;
        if (version && [self checkVersionNeedToUpdateByServV:version compareCurrV:currVer])
        {
            strPrompt = [NSString stringWithFormat:NSLocalizedString(@"YunTong %@ is available now.\nRelease Notes:\n%@", @"YunTong %@ is available now.\nRelease Notes:\n%@"), version, text];
            update = YES;
            
            if (versionUrl) {
                [versionUrl release];
                versionUrl = nil;
            }
            if (url && [url length])
                versionUrl = [[NSString alloc] initWithString:url];
        }
        else
        {
            //如果自动更新不需要提醒用户,手动更新才需要告知
            if ([autoCheck isEqualToString:@"1"])
                showAlertView = NO;
            strPrompt = [NSString stringWithFormat:NSLocalizedString(@"You are using the latest version!", @"You are using the latest version!"), version];
        }
        if (showAlertView) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCheckVersionUpdateNotification object:nil];
            UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Check Update", @"Check Update")
                                                        message: strPrompt
                                                       delegate: self
                                              cancelButtonTitle:update?NSLocalizedString(@"Cancel", @"Cancel"):nil otherButtonTitles: update?NSLocalizedString(@"Update", @"Update"):NSLocalizedString(@"OK", @"OK"), nil];
            if (update) a.tag = kTagActionAlertUpdateVersion;
            [a show];
            [a release];
        }
        
        //当前时间
        NSDate *nowDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSString *strNowDate = [dateFormatter stringFromDate:nowDate];
        [dateFormatter release];
        
        //本地设置更新时间
        [[NgnEngine sharedInstance].configurationService setStringWithKey:GENERAL_LASTCHECKVERSIONDATE andValue:strNowDate];
    }
    else
    {
        if ([autoCheck isEqualToString:@"0"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCheckVersionUpdateNotification object:nil];
            UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Check Update", @"Check Update")
                                                        message: NSLocalizedString(@"Check update failed, please try again later!", @"Check update failed, please try again later!")
                                                       delegate: self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
            [a show];
            [a release];
        }
    }
    
    [recvString release];
    [root release];
}

- (void)sendCheckVersionUpdateResponeError:(NSError *)error andUserInfo:(NSDictionary *)userInfo
{
    NSString *autoCheck = [userInfo objectForKey:@"autoCheck"];
    
    if ([autoCheck isEqualToString:@"0"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCheckVersionUpdateNotification object:nil];
        UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Check Update", @"Check Update")
                                                    message: NSLocalizedString(@"Check update failed, please try again later!", @"Check update failed, please try again later!")
                                                   delegate: self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
        [a show];
        [a release];
    }
}

- (BOOL)checkVersionNeedToUpdateByServV:(NSString *)servVersion compareCurrV:(NSString *)currVersion
{
    if (!servVersion || !currVersion || [servVersion isEqualToString:currVersion]) return NO;
    
    NSArray *servArray = [servVersion componentsSeparatedByString:@"."];
    NSArray *currArray = [currVersion componentsSeparatedByString:@"."];
    
    if ([servArray count] != 3 || [currArray count] != 3) return NO;
    
    //首位
    NSString *firstServV = [servArray objectAtIndex:0];
    NSString *firstCurrV = [currArray objectAtIndex:0];
    
    if ([firstServV intValue] > [firstCurrV intValue])
        return YES;
    else if([firstServV intValue] < [firstCurrV intValue])
        return NO;
    else
    {
        //次位
        NSString *secondServV = [servArray objectAtIndex:1];
        NSString *secondCurrV = [currArray objectAtIndex:1];
        
        if ([secondServV intValue] > [secondCurrV intValue])
            return YES;
        else if([secondServV intValue] < [secondCurrV intValue])
            return NO;
        else
        {
            //末位
            NSString *thirdServV = [servArray objectAtIndex:2];
            NSString *thirdCurrV = [currArray objectAtIndex:2];
            
            if ([thirdServV intValue] > [thirdCurrV intValue])
                return YES;
            else
                return NO;
        }
    }
}

@end

@interface CloudCall2AppDelegate(CloudCallRequest)
- (void)sendDefaultCloudCallRequest:(NSString *)url;
- (void)sendDefaultCloudCallResponse:(NSData *)data userInfo:(NSMutableDictionary *)userInfo;
- (void)sendDefaultCloudCallError:(NSData *)data userInfo:(NSMutableDictionary *)userInfo;
@end

@implementation CloudCall2AppDelegate(CloudCallRequest)
- (void)sendDefaultCloudCallRequest:(NSString *)url
{
    NSData *jsonData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    if (![url isEqualToString:kDefaultCloudCallUrl])
        [userInfo setValue:@"redirect" forKey:@"reqType"];
    else
        [userInfo setValue:@"sendAdsResponse" forKey:@"reqType"];
    
    [[HttpRequest instance] addRequest:url andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:15
                         successTarget:self successAction:@selector(sendDefaultCloudCallResponse:userInfo:)
                         failureTarget:self failureAction:@selector(sendDefaultCloudCallError:userInfo:) userInfo:userInfo];
}

- (void)sendDefaultCloudCallResponse:(NSData *)data userInfo:(NSMutableDictionary *)userInfo
{
    NSString *reqType = [userInfo objectForKey:@"reqType"];
    if ([reqType isEqualToString:@"redirect"]) return;
    
    NSMutableDictionary *root = (NSMutableDictionary *)[CloudCallJSONSerialization JsonDataToObject:data];
    CCLog(@"2sendAdsResponse data:%@",root);
    
    NSString *result = [root objectForKey:@"result"];
    if ([result isEqualToString:@"success"])
    {
        NSString *redirectUrl = [root objectForKey:@"url"];
        [self sendDefaultCloudCallRequest:redirectUrl];
    }
}

- (void)sendDefaultCloudCallError:(NSError *)error userInfo:(NSMutableDictionary *)userInfo{}

@end

@interface CloudCall2AppDelegate(HttpRequest)
- (void)sendHttpRequest:(NSString *)url andData:(NSData *)jsonData andUserInfo:(NSMutableDictionary *)userInfo;
- (void)receiveHttpResponse:(NSData *)data andUserInfo:(NSMutableDictionary *)userInfo;
- (void)requestHttpError:(NSData *)data andUserInfo:(NSMutableDictionary *)userInfo;
@end

@implementation CloudCall2AppDelegate(HttpRequest)
- (void)sendHttpRequest:(NSString *)url andData:(NSData *)jsonData andUserInfo:(NSMutableDictionary *)userInfo
{
    [[HttpRequest instance] addRequest:url andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:15
                         successTarget:self successAction:@selector(receiveHttpResponse:andUserInfo:)
                         failureTarget:self failureAction:@selector(requestHttpError:andUserInfo:) userInfo:userInfo];
}

- (void)receiveHttpResponse:(NSData *)data andUserInfo:(NSMutableDictionary *)userInfo
{
    NSString *reqType = [userInfo objectForKey:@"reqType"];
    
    NSMutableDictionary *root = (NSMutableDictionary *)[CloudCallJSONSerialization JsonDataToObject:data];
    CCLog(@"receiveHttpResponse reqType: %@ andData:%@", reqType, root);
    
    if ([reqType isEqualToString:kUploadContacts])
    {
        NSMutableArray *friendArray = [root objectForKey:@"friend_list"];
        
        if (friendArray && [friendArray count] > 0)
            [self processContactsGotFromServer:friendArray];
    }
    else if([reqType isEqualToString:kGetImserverConfig])       //获取IM服务器配置
    {
        NSString *result = [root objectForKey:@"result"];
        
        if ([result isEqualToString:@"success"])
        {
            NSArray *serverArray = [root objectForKey:@"server"];
            
            if ([serverArray count])
            {
                NSMutableArray *imServerArray = [NSMutableArray arrayWithCapacity:3];
                BOOL first = YES;  //将首个IM服务器地址设置为默认地址 , 服务器集群完成后可考虑随机设置为默认地址
                for (NSDictionary *aServer in serverArray)
                {
                    NSString *ser_addr = [aServer objectForKey:@"address"];
                    int ser_port_http = [[aServer objectForKey:@"http_port"] integerValue];
                    int ser_port = [[aServer objectForKey:@"xmpp_port"] integerValue];
                    int enable = [[aServer objectForKey:@"enable"] integerValue];
                    
                    if (enable && first && ![NgnStringUtils isNullOrEmpty:ser_addr] && ser_port_http && ser_port)
                    {
                        [[NgnEngine sharedInstance].configurationService setStringWithKey:GENERAL_IMSERVER_ADDR andValue:ser_addr];
                        [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_IMSERVER_PORT_HTTP andValue:ser_port_http];
                        [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_IMSERVER_PORT andValue:ser_port];
                    }
                    
                    IMServerConfigInfo *aServerInfo = [[IMServerConfigInfo alloc] initWithAddress:ser_addr andXmppPort:ser_port andHttpPort:ser_port_http andEnable:enable];
                    [imServerArray addObject:aServerInfo];
                    [aServerInfo release];
                    first = NO;
                }
                
                //删除旧数据 , 写入新数据
                CCSqliteHelper *ccSqliteHelper = [[CCSqliteHelper alloc] init];
                [ccSqliteHelper deleteAllRecordFromIMServerConfigInfo];
                [ccSqliteHelper addIMServerInfo:imServerArray];
                [ccSqliteHelper release];
            }
            
        }
        
    }
    else if([reqType isEqualToString:@"3"])
    {
        
    }
}

- (void)requestHttpError:(NSError *)error andUserInfo:(NSMutableDictionary *)userInfo
{
    
}

@end

//
//	Default implementation
//
@implementation CloudCall2AppDelegate

@synthesize conferenceUUID;
@synthesize viewDelegate = _viewDelegate;
@synthesize incallAdData;
@synthesize signinAdData;
@synthesize callFeedBackData;
@synthesize missedCalls;
@synthesize window;
@synthesize tabBarController;
@synthesize contactsViewController;
@synthesize messagesViewController;
@synthesize logViewController;
@synthesize validationView;

@synthesize useSecondConfServ;
@synthesize maxconfmembers;

@synthesize ctbanner;

@synthesize incomingCall;
@synthesize isOpenDianRuWallPoints;

@synthesize xmppStream;
@synthesize messageDelegate;
@synthesize isCountBanner;
@synthesize username;
@synthesize password;

static UIBackgroundTaskIdentifier sBackgroundTask = UIBackgroundTaskInvalid;
static dispatch_block_t sExpirationHandler = nil;

#pragma mark -
#pragma mark Application lifecycle
- (id)init
{
    if(self = [super init])
    {
//        _scene = WXSceneSession;
        _viewDelegate = [[ShareViewDelegate alloc] init];
    }
    return self;
}

- (void) displayValidationView {
//    if (self.tabBarController == nil)
//        return;
    //注销时的方法，这里注意要让self.validationView = validationView，因为登录时要判断self.validationview是否存在
    
    if (self.tabBarController) {
        [self.tabBarController removeFromParentViewController];
        [self.tabBarController.view removeFromSuperview];
        self.tabBarController = nil;
        CCLog(@"tabBarController remove from superview ..");
    }
    
    currentController = nil;
    
    if (!self.validationView) {
        self.validationView = [[ValidationViewController alloc] initWithNibName:@"ValidationView" bundle:nil];

    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.validationView];
    self.validationView.isLogOut = YES;
    if (self.validationView)
    {
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
    }
    else
    {
        CCLog(@"displayValidationView: Create ValidationViewController Failed!!\n");
    }
    [nav release];
    CCLog(@"displayValidationView");
}

-(void) PhoneNumValidating:(BOOL)validating{
    phonenumvalidating = validating;
    if (phonenumvalidating)
        syncReferr = NO;
}

-(BOOL) PhoneNumValidating{
    return phonenumvalidating;
}

/////////////////////////////////////////////////////////

- (NSString*)GetLogDirectoryPath{
#if TARGET_OS_IPHONE
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    
    return [documentsDir stringByAppendingPathComponent:@"log"];
}

- (void)redirectNSLogToDocumentFolder:(NSString*)logDir{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss Z"];
    NSString *locationString = [formatter stringFromDate: [NSDate date]];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.log", locationString];
    NSString *logFilePath = [logDir stringByAppendingPathComponent:fileName];
    
    [formatter release];
        
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

-(void)SetIAPProductIds:(NSMutableArray*)_rechargeProducts {
    if (rechargeProducts)
        [rechargeProducts release];
    rechargeProducts = [_rechargeProducts retain];
    if (iapMgr)
        iapMgr.products = rechargeProducts;
}

-(void)ValidationSuccessed {
    if (iapMgr) {
        NSString *myNum = [self getUserName];
        [iapMgr updateAfterValidation:myNum];
    }
    //登录时
    if (self.validationView != nil)
    {
        [validationView.view removeFromSuperview];
        [validationView release];
        self.validationView = nil;
        [self enterTabbarViewController];
        return;
    }
    //自动登录时
    if (self.tabBarController == nil) {
        [self enterTabbarViewController];
    }
    
}

- (void)enterTabbarViewController
{
    NSMutableArray *items = [[[NSMutableArray alloc] init] autorelease];
    
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:[[[NumpadViewController alloc] initWithNibName:@"NumpadView" bundle:nil] autorelease]];
    [items addObject:nav1];
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:[[[MessagesViewController alloc] initWithNibName:@"MessagesView" bundle:nil] autorelease]];
    [items addObject:nav2];
    
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:[[[ContactsViewController alloc] initWithNibName:@"ContactsView" bundle:nil] autorelease]];
    [items addObject:nav3];

//    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:[[[ConferenceFavoritesViewController alloc] initWithNibName:@"ConferenceFavoritesView" bundle:nil] autorelease]];
//    [items addObject:nav4];
    
    UINavigationController *nav5 = [[UINavigationController alloc] initWithRootViewController:[[[MoreViewController alloc] initWithNibName:@"MoreViewController" bundle:nil] autorelease]];
    [items addObject:nav5];
    
    // items是数组，每个成员都是UIViewController
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    tabBarController.delegate = self;
    [tabBarController setTitle:@"TabBarController"];
    [tabBarController setViewControllers:items];
    
    [nav1 release];
    [nav2 release];
    [nav3 release];
//    [nav4 release];
    [nav5 release];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    ///////////////////////////////////////
    CGRect frame = CGRectMake(0, 0, 320, 50);
    UIView *viewa = [[UIView alloc] initWithFrame:frame];
    UIImage *tabBarBackgroundImage = [UIImage imageNamed:@"tabbar_bg.png"];
    UIColor *color = [[UIColor alloc] initWithPatternImage:tabBarBackgroundImage];
    
    [viewa setBackgroundColor:color];
    if (SystemVersion < 5)  {
        [[tabBarController tabBar] insertSubview:viewa atIndex:0];
    }else{
        [[tabBarController tabBar] insertSubview:viewa atIndex:1];
        tabBarController.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"glow.png"];
    }
    [color release];
    [viewa release];
    ///////////////////////////////////////
}

-(void)StartLog;
{
    //[self redirectNSLogToDocumentFolder:[self GetLogDirectoryPath]];
    if (!logViewController)
        logViewController = [LogViewController alloc];
    
    [logViewController startLog];
}

- (void)EnterSignInView
{
    //页面跳转
    self.tabBarController.selectedIndex = kTabBarIndex_Discover;
    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:kTabBarIndex_Discover];
    MoreViewController *moreView = [[nav viewControllers] objectAtIndex:0];
    if (moreView)
    {
        [moreView SignInRemindCallBack];
    }
}

- (void)EnterMessagesView:(NSString *)_friendAccount
{
    //页面跳转
    self.tabBarController.selectedIndex = kTabBarIndex_Messages;
    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:kTabBarIndex_Messages];
    MessagesViewController *view = [[nav viewControllers] objectAtIndex:0];
    if (view)
    {
        if (_friendAccount && [_friendAccount length])
            [view EnterIMChatView:_friendAccount];
    }
}

/*- (void)EnterGroupCallView
{
    //页面跳转
    self.tabBarController.selectedIndex = kTabBarIndex_GroupCall;
    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:kTabBarIndex_GroupCall];
    ConferenceFavoritesViewController *conferenceView = [[nav viewControllers] objectAtIndex:0];
    if (conferenceView)
    {
        [conferenceView enterGroupDetailedView:conferenceUUID];
    }
}*/

- (void)GoBackToRootViewFirst
{
    //如果在子页面先返回到顶层
    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:tabBarController.selectedIndex];
    MoreViewController *View = [[nav viewControllers] objectAtIndex:0];
    [View.navigationController popToRootViewControllerAnimated:NO];
}

- (void)resetNotificationIconBadge
{
    NSString *mynum = username;
    
    //用户未登陆,不需要更新
    if ([mynum isEqualToString:DEFAULT_IDENTITY_IMPI])
        return;
    
    //更新未读消息数
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    int unreadAllnum = [helper selectAllUnReadCountByReceiver:mynum];
    [helper closeDatabase];
    [helper release];
        
    //更新小秘书未读消息
    unsigned int unreadSysNotifiNum = [[NgnEngine sharedInstance].storageService getUnreadSystemNotificationNum:mynum];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = (unreadAllnum+unreadSysNotifiNum+self.missedCalls);
   
}

-(NSString *) getUserName
{
    if ([self.username isEqualToString:DEFAULT_IDENTITY_IMPI] || [self.username length] == 0)
    {
        NSString *mynum = [[NgnEngine sharedInstance].infoService getInfoValueForkeyWithDecrypt:IDENTITY_IMPI];
        if (!mynum || [mynum length]==0)
            self.username = DEFAULT_IDENTITY_IMPI;
        else
            self.username = mynum;
    }
    return username;
}

-(NSString *) getUserPassword
{
    if ([self.password isEqualToString:DEFAULT_IDENTITY_PASSWORD] || [self.password length] == 0)
    {
        NSString *myPassword = [[NgnEngine sharedInstance].infoService getInfoValueForkeyWithDecrypt:IDENTITY_PASSWORD];
        if (!myPassword || [myPassword length] == 0)
            self.password = DEFAULT_IDENTITY_PASSWORD;
        else
            self.password = myPassword;
    }
    return password;
}

- (void)createDianJinAd
{
#if DianJin_Enable
    if (djbanner != nil)
        return;
    
    // Override point for customization after application launch.
    [[DianJinOfferPlatform defaultPlatform] setAppId:DianJin_ID andSetAppKey:DianJin_key];
    
    djbanner = [[DianJinOfferBanner alloc] initWithOfferBanner:CGPointMake(0, 0) style:kDJBannerStyle320_50];
    DianJinBannerSubViewProperty *colorProperty = [[DianJinBannerSubViewProperty alloc] init];
    colorProperty.viewNormalBackgroundColor = [UIColor colorWithRed:3.0/255.0 green:165.0/255.0 blue:230.0/255.0 alpha:1.0];		//正常时banner视图背景颜色
    colorProperty.appRewardLabelTextColor = [UIColor whiteColor];		//奖励描述字体颜色
    [djbanner setupSubViewProperty:colorProperty];
    [colorProperty release];
    
    //如果想让 banner 视图自适应需添加下面代码 banner.isAutoRotate = YES;
    djbanner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    DianJinTransitionParam *transitionParam = [[DianJinTransitionParam alloc] init];
    transitionParam.animationType = kDJTransitionPageCurl;
    transitionParam.animationSubType = kDJTransitionFromBottom;
    transitionParam.duration = 1.0;
    [djbanner setupTransition:transitionParam];
    [transitionParam release];
    
    NSTimeInterval ti = 8;
    [djbanner startWithTimeInterval:ti delegate:self];
    #endif
}

- (void)initializePlat
{
    [ShareSDK convertUrlEnabled:NO];
    /**
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectSinaWeiboWithAppKey:kSinaAppKey
                               appSecret:kSinaAppSecret
                             redirectUri:kAppRedirectURI];
    /**
     连接腾讯微博开放平台应用以使用相关功能，此应用需要引用TencentWeiboConnection.framework
     http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
     **/
    [ShareSDK connectTencentWeiboWithAppKey:kTencentWeiboAppKey
                                  appSecret:kTencentWeiboAppSecret
                                redirectUri:kAppRedirectURI
                                   wbApiCls:[WBApi class]];
    /**
     连接QQ空间应用以使用相关功能，此应用需要引用QZoneConnection.framework
     http://connect.qq.com/intro/login/上申请加入QQ登录，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入TencentOpenAPI.framework,并引入QQApiInterface.h和TencentOAuth.h，将QQApiInterface和TencentOAuth的类型传入接口
     **/
    [ShareSDK connectQZoneWithAppKey:kQZoneAppKey
                           appSecret:kQZoneAppSecret
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    /**
     连接豆瓣应用以使用相关功能，此应用需要引用DouBanConnection.framework
     http://developers.douban.com上注册豆瓣社区应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectDoubanWithAppKey:kDouBanAppKey
                            appSecret:kDouBanAppSecret
                          redirectUri:kAppRedirectURI];
    
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
     http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectQQWithAppId:kQQAppId qqApiCls:[QQApi class]];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:kWeChatAppId wechatCls:[WXApi class]];
    
}

// user for loginManger to callback
- (void)registerAndGetConfig
{
    if ([NgnEngine sharedInstance].networkService.reachable) {
#if TARGET_IPHONE_SIMULATOR
        // do nothing
#else
        // Register for APNs service
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
#endif
        
        regAfterGetCfg = YES;
        
        [loginManager GetConfigFromNet];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    starting = YES;
    syncReferr = YES;
    isCountBanner = YES;
    maxexchangepoints = 2000;
    appstorerelease = 202;
    self.username = [NSString string];
    self.password = [NSString string];
    //开启加密设置
    [StaticUtils encryptSetup];
    
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);

#if DEBUG
    [DDLog addLogger:[DDASLLogger sharedInstance]];    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
    
    /**
     注册SDK应用，此应用请到http://www.sharesdk.cn中进行注册申请。
     此方法必须在启动时调用，否则会限制SDK的使用。
     **/
    [ShareSDK registerApp:ShareSDK_key];
    [ShareSDK convertUrlEnabled:YES];
    [self initializePlat];
    
//    _interfaceOrientationMask = SSInterfaceOrientationMaskAll;
        
    //监听用户信息变更
    [ShareSDK addNotificationWithName:SSN_USER_INFO_UPDATE
                               target:self
                               action:@selector(userInfoUpdateHandler:)];
    
    //创建各类文件夹
    [self createDirectoryNecessary];
    
    //广告资源数据库
    AdResourceManager *adResourceManager = [[AdResourceManager alloc] init];
    [adResourceManager checkAdsDatabaseAndCreateTable];
    
    //从服务器请求广告
    NSNumber *longtitude = [NSNumber numberWithDouble:0.0f];
    NSNumber *latitude = [NSNumber numberWithDouble:0.0f];
    NSString *mobile = [self getUserName];
    
    if ([NgnStringUtils isNullOrEmpty:mobile]) mobile = @"";
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:mobile, @"mobile", longtitude, @"longtitude", latitude, @"latitude", nil];
    NSData *jsonData = [jsonDict JSONData];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setValue:@"getAds" forKey:@"reqType"];
    [adResourceManager sendAdsRequest:jsonData andUserInfo:userInfo];
    [adResourceManager release];

    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    CCLog(@"resourcePath=%@", resourcePath);
    NSString* fileName = [NSString stringWithFormat:@"%@/sourceid.dat", resourcePath];
    NSString* fileData = [NSString stringWithContentsOfFile: fileName usedEncoding: nil error: nil];
    CCLog(@"fileData=%@", fileData);
    MarketTypeDef n = (MarketTypeDef)[fileData intValue];
    if (n > CLIENT_FOR_NONE && n < CLIENT_FOR_MAX)
    {
        g_marketType = n;
    }
#ifdef DEBUG
    CCLog(@"marketType=%d\n", g_marketType);
#else
    if (g_marketType == CLIENT_FOR_AS_APP_STORE)
    {
        [MobClick startWithAppkey:UMENG_APP_KEY];
    }
    else
    {
        const char* s = getMarketName(g_marketType);        
        if (s == nil)
        {
            UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:nil message:@"Invalid m name, the app will quit!" delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertview show];
            [alertview release];
            return NO;
        }
        
        NSString* marketname = [NSString stringWithUTF8String:s];
        [MobClick startWithAppkey:UMENG_APP_KEY reportPolicy:REALTIME channelId:marketname];
    }
#endif
    //[MobClick updateOnlineConfig];
    
    showAd = YES;
    adType = AD_TYPE_BAIDU;
    if (g_marketType == CLIENT_FOR_AS_APP_STORE) {
        showAd = NO;
        //adType = AD_TYPE_IAD; // iAd has not post ad. in China yet.
    }
    /*else if (g_marketType == CLIENT_FOR_91_STORE) {
        adType = AD_TYPE_91DIANJIN;
    }*/
    CCLog(@"adType %d", adType);
    
    // The ADBannerView will fix up the given size, we just want to ensure it is created at a location off the bottom of the screen.
    // This ensures that the first animation doesn't come in from the top of the screen.
    if (adType == AD_TYPE_IAD) {
        iadbanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        iadbanner.delegate = self;
    } else if (adType == AD_TYPE_91DIANJIN) {
//        [self createDianJinAd];   //91点金
    } else if (adType == AD_TYPE_UMENG) {
        ;// add in each view
    } else if (adType == AD_TYPE_LIMEI) {
        lmbanner = [[immobView alloc] initWithAdUnitID:immobBannerKey];        
        lmbanner.delegate = self;
        lmbanner.frame = CGRectMake(0, 0, 320, 50);
        [lmbanner immobViewRequest];
    } else if (adType == AD_TYPE_BAIDU) {
        
        //使用嵌入广告的方法实例。
        bdbanner = [[BaiduMobAdView alloc] init];
        //sharedAdView.AdUnitTag = @"myAdPlaceId1";
        //此处为广告位id，可以不进行设置，如需设置，在百度移动联盟上设置广告位id，然后将得到的id填写到此处。
        bdbanner.AdType = BaiduMobAdViewTypeBanner;
        bdbanner.delegate = self;
        if (SystemVersion >= 7)
            bdbanner.frame=CGRectMake(0, 20 , 320, 50);
        else
            bdbanner.frame=CGRectMake(0, 0 , 320, 50);
        [bdbanner start];
        
    }
    ctbanner = [[CTBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    currentrelease = 320;
    NSString* strver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if (strver && [strver length])
    {
        NSMutableString *strippedString = [NSMutableString stringWithCapacity:strver.length];
        NSScanner *scanner = [NSScanner scannerWithString:strver];
        NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        while ([scanner isAtEnd] == NO)
        {
            NSString *buffer;
            if ([scanner scanCharactersFromSet:numbers intoString:&buffer])
            {
                [strippedString appendString:buffer];
            }
            else
            {
                [scanner setScanLocation:([scanner scanLocation] + 1)];
            }
        }
        CCLog(@"strippedString=%@", strippedString);
        currentrelease = [strippedString intValue];
    }
    
	// add observers
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkEvent:) name:kNgnNetworkEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNativeContactEvent:) name:kNgnContactEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStackEvent:) name:kNgnStackEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyMsgResponseStatus:) name:kNotifyMsgResponseStatusNotification object:nil];
    //监听广告信息更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAdsData) name:kNotificationUpdateAdsInfo object:nil];
    
    //监听本地通讯录是否修改,修改了上传通讯录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUploadContact) name:kNotificationUploadContact object:nil];
    
    // start the engine
    if (NO == [[NgnEngine sharedInstance] start]) {
        return YES;
    }

    //[[NSUserDefaults standardUserDefaults] setInteger:g_marketType forKey:GENERAL_MAKET_TYPE];
    [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_MAKET_TYPE andValue:g_marketType];
    
    //////////////////////////////////////////////////////////    
    
    // Must do LoadConfigFile after [NgnEngine sharedInstance] start] and IAPRechargeManager initiate
    // read data from yuntong.cfg file under config folder
    NSString* strcfg = [self LoadConfigFile];
    [self parseConfiguration:strcfg];
    
//    if (ctbanner) {
//        [ctbanner bannerViewStart];
//    }
    self.incallAdData = [NSMutableArray arrayWithCapacity:10];
    self.signinAdData = [NSMutableArray arrayWithCapacity:10];
    self.callFeedBackData = [NSMutableArray arrayWithCapacity:10];
    [self reloadAdsData];
    
//    NSString* strRef = [[NgnEngine sharedInstance].configurationService getStringWithKey:ACCOUNT_REFEREE];
//    haveSetReferee = strRef && [strRef length];
    
    //[self selectTabNumpad];
#if 0 // for debug
    {
        NSString *myNum = [self getUserName];
        NSString* content = [NSString stringWithFormat:@"Vincent Test System Nofification %@", [[NgnDateTimeUtils chatDate] stringFromDate: [NSDate dateWithTimeIntervalSince1970: [[NSDate date] timeIntervalSince1970]]]];
        NgnSystemNotification* sysnotify = [[NgnSystemNotification alloc] initWithContent:content andMyNumber:myNum andReceiveTime:[[NSDate date] timeIntervalSince1970] andRead:NO];
        [[NgnEngine sharedInstance].storageService addSystemNofitication:sysnotify];
        [sysnotify release];
    }
#endif

    // Set media parameters if you want
	MediaSessionMgr::defaultsSetAudioGain(0, 0);
	// Set some codec priorities
	int prio = 0;
	SipStack::setCodecPriority(tdav_codec_id_speex_nb, prio++);
	SipStack::setCodecPriority(tdav_codec_id_g729ab, prio++);
	SipStack::setCodecPriority(tdav_codec_id_pcmu, prio++);
	SipStack::setCodecPriority(tdav_codec_id_pcma, prio++);
    
	//SipStack::setCodecPriority(tdav_codec_id_h264_bp30, prio++);
	//SipStack::setCodecPriority(tdav_codec_id_h264_bp20, prio++);
	//SipStack::setCodecPriority(tdav_codec_id_vp8, prio++);
	//...etc etc etc
    
    //code by Sergio
    //start
    //判断是否第一次运行，用于用户设置
    if (![[NgnEngine sharedInstance].configurationService getBoolWithKey:DEFAULT_ACCOUNT_EVERLAUNCHED]) {
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:DEFAULT_ACCOUNT_EVERLAUNCHED andValue:YES];
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:DEFAULT_ACCOUNT_FIRSTLAUNCH andValue:YES];
    }
    else{
        [[NgnEngine sharedInstance].configurationService setBoolWithKey:DEFAULT_ACCOUNT_FIRSTLAUNCH andValue:NO];
    }
    //end
    
	NSString *impi = [self getUserName];
    NSString *passwd = [self getUserPassword];
    
    //NavigationBar appearance
    if (SystemVersion >= 5.0) {
        //设置title颜色,字体,阴影等
        UIColor *cc = [UIColor colorWithRed:130.0f/255.0f green:140.0f/255.0f blue:150.0f/255.0f alpha:1.0];
        UIFont *font = [UIFont systemFontOfSize:17];
        NSValue *value = [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)];
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
                               cc, UITextAttributeTextColor,
                               font, UITextAttributeFont,
                               value, UITextAttributeTextShadowOffset, nil];
        [[UINavigationBar appearance] setTitleTextAttributes:dict];
        
        if (SystemVersion >= 7)
        {
            [[UINavigationBar appearance] setTintColor:[UIColor grayColor]];
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"toolbar_bg_ios7.png"] forBarMetrics:UIBarMetricsDefault];
        }
        else
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"toolbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:56.0/255.0 green:163.0/255.0 blue:253.0/255.0 alpha:1.0]];
    }
    
    loginManager = [LoginManager shareInstance];
    
    self.validationView = [[ValidationViewController alloc] initWithNibName:@"ValidationView" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.validationView];
    self.window.rootViewController =nav;
    [nav release];
    [self.window makeKeyAndVisible];
    

    if ([impi isEqualToString:DEFAULT_IDENTITY_IMPI] || ![passwd length] || [passwd isEqualToString:DEFAULT_IDENTITY_PASSWORD]
        || [passwd isEqualToString:@"00000"] || [passwd isEqualToString:@"995995"]) {
        if (remoteNotif) {
            [remoteNotif release];
            remoteNotif = nil;
        }
        
    }
    else
    {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.validationView.view];
        [self.validationView.view addSubview:hud];
        hud.labelText = @"自动登录中..";
        [hud show:YES];
        hud.delegate = self;
        [loginManager httpLoginUserNum:impi UserPwd:passwd HttpLoginSuccessBlock:^{
            
            [hud hide:YES];
            //获取存储的手机号和密码，进入登陆后页面
            [[NgnEngine sharedInstance].contactService start];
            
            //比较通讯录查看是否需要上传通讯录
            [self checkContactForUpload];
            
            //更新未读消息数
            SqliteHelper *helper = [[SqliteHelper alloc] init];
            [helper createDatabase];
            int unreadAllnum = [helper selectAllUnReadCountByReceiver:[self getUserName]];
            [helper closeDatabase];
            [helper release];
            
            [[CloudCall2AppDelegate sharedInstance] UnreadIMNum:unreadAllnum];
            
            //更新小秘书未读消息
            unsigned int unreadSysNotifiNum = [[NgnEngine sharedInstance].storageService getUnreadSystemNotificationNum:[self getUserName]];
            if (unreadSysNotifiNum) {
                [self UnreadSysNofifyNum:unreadSysNotifiNum];
            }
            //[self resetNotificationIconBadge];
            
        } HttpLoginFailedBlock:^{
            [hud hide:YES];
            //do anything else here
        }];
        
    }
    //[self ShowNewFeatureRemind];云通不显示向导页面
    if (g_marketType == CLIENT_FOR_AS_APP_STORE) {
        if (!iapMgr) {
            iapMgr = [[IAPRechargeManager alloc] init];
            [iapMgr start:impi];
        }
    }
    
    remoteNotif = [[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] retain];
    
    
    // enable the speaker: for errors, ringtone, numpad, ...
	// shoud be done after the SipStack is initialized (thanks to tdav_init() which will initialize the audio system)
    //[[NgnEngine sharedInstance].soundService setSpeakerEnabled:YES];
    
    multitaskingSupported = [[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)] && [[UIDevice currentDevice] isMultitaskingSupported];
	sBackgroundTask = UIBackgroundTaskInvalid;
	sExpirationHandler = ^{
		CCLog(@"Background task completed");
		// keep awake
		if([[NgnEngine sharedInstance].sipService isRegistered]){            
			[[NgnEngine sharedInstance] startKeepAwake];            
		}
		[[UIApplication sharedApplication] endBackgroundTask:sBackgroundTask];
		sBackgroundTask = UIBackgroundTaskInvalid;
    };
	
	if (multitaskingSupported) {
		NgnNSLog(TAG, @"Multitasking IS supported");
	}
    
    if (!callFeedbackMgr) {
        callFeedbackMgr = [[CallFeedbackManager alloc] init];
        [callFeedbackMgr start:impi];
    }
    
    if (!groupcallMgr) {
        groupcallMgr = [[GroupCallManager alloc] init];
    }
    
    if (!ntymsgMgr) {
        ntymsgMgr = [[NotificationMessageManager alloc] init];
        [ntymsgMgr Start];
    }
    
    //检查更新
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *strNowDate = [dateFormatter stringFromDate:nowDate];
    
    NSString *lastCheckVersionDate = [[NgnEngine sharedInstance].configurationService getStringWithKey:GENERAL_LASTCHECKVERSIONDATE];
    
    if (lastCheckVersionDate == nil)
    {
        NSDate *yesterday = [NSDate dateWithTimeInterval:- 24 * 60 * 60 sinceDate:nowDate];
        lastCheckVersionDate = [dateFormatter stringFromDate:yesterday];
        
        [[NgnEngine sharedInstance].configurationService setStringWithKey:GENERAL_LASTCHECKVERSIONDATE andValue:lastCheckVersionDate];
    }
    [dateFormatter release];
    
    //日期不一样就更新
    if (NSOrderedSame != [lastCheckVersionDate compare:strNowDate])
        [self CheckVersionUpdate:YES];    
    
    /////////////////////////////////////    
    //NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"msg" withExtension:@"aif"];
    //AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"receive-msg" withExtension:@"caf"];
    AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
    /////////////////////////////////////

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (isOpenDianRuWallPoints == YES)
        [DianRuAdWall dianruOnPause];
	// application.idleTimerDisabled = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
	if([CloudCall2AppDelegate sharedInstance]->multitaskingSupported){
		ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
		if(registrationState == CONN_STATE_CONNECTING || registrationState == CONN_STATE_CONNECTED){
			CCLog(@"applicationDidEnterBackground (Registered or Registering)");
			//if(registrationState == CONN_STATE_CONNECTING){
			// request for 10min to complete the work (registration, computation ...)
			sBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:sExpirationHandler];
			//}
			if(registrationState == CONN_STATE_CONNECTED){
				if(![NgnAVSession hasActiveSession]){
					[[NgnEngine sharedInstance] startKeepAwake];
				}
			}
			
			//[application setKeepAliveTimeout:600 handler: ^{
			//	CCLog(@"applicationDidEnterBackground:: setKeepAliveTimeout:handler^");
			//}];
		}
	}
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED */
    
    isCountBanner = NO;
    //发送广告统计数据以及请求广告资源列表
    AdResourceManager *adResourceManager = [[AdResourceManager alloc] init];
    [adResourceManager submitADStatisticsData];

    //从服务器请求广告
    NSNumber *longtitude = [NSNumber numberWithDouble:0.0f];
    NSNumber *latitude = [NSNumber numberWithDouble:0.0f];
    NSString *mobile = [self getUserName];
    if ([NgnStringUtils isNullOrEmpty:mobile]) mobile = @"";
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:mobile, @"mobile", longtitude, @"longtitude", latitude, @"latitude", nil];
    NSData *jsonData = [jsonDict JSONData];

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setValue:@"getAds" forKey:@"reqType"];
    [adResourceManager sendAdsRequest:jsonData andUserInfo:userInfo];
    [adResourceManager release];
    //切换后台停止xmpp重连定时器
    if (reConnectXmppTimer)
    {
        [reConnectXmppTimer invalidate];
        reConnectXmppTimer = nil;
    }
    [self resetNotificationIconBadge];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// application.idleTimerDisabled = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppWillEnterForegroundNotification object:nil];
    
    ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
	NgnNSLog(TAG, @"applicationWillEnterForeground and RegistrationState=%d", registrationState);
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
	// terminate background task
	if(sBackgroundTask != UIBackgroundTaskInvalid){
		[[UIApplication sharedApplication] endBackgroundTask:sBackgroundTask]; // Using shared instance will crash the application
		sBackgroundTask = UIBackgroundTaskInvalid;
	}
	// stop keepAwake
	[[NgnEngine sharedInstance] stopKeepAwake];
	
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED */
	
	//if(registrationState != CONN_STATE_CONNECTED && phonenumvalidating == NO){
    if (phonenumvalidating == NO) {
        enteringForeground = YES;
        
        regAfterGetCfg = YES;
//        [self GetConfigFromNet:self successAction:@selector(getConfigFileSuccessed:) failureTarget:self failureAction:@selector(getConfigFileFailed:)];
        [loginManager GetConfigFromNet];
	}
	
	// check native contacts changed while app was runnig on background
	if(self->nativeABChangedWhileInBackground){
		// trigger refresh
		self->nativeABChangedWhileInBackground = NO;
        
        if ([self.tabBarController selectedIndex] == kTabBarIndex_Contacts)
            [contactsViewController refreshDataAndReload];
	}

    isCountBanner = YES;
    //发送广告统计数据以及请求广告资源列表
    AdResourceManager *adResourceManager = [[AdResourceManager alloc] init];
    [adResourceManager submitADStatisticsData];
    [adResourceManager release];

//    [self reloadAdsData];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
	NSString *notifKey = [notification.userInfo objectForKey:kNotifKey];
	if([notifKey isEqualToString:kNotifKey_IncomingCall])
    {
		NSNumber* sessionId = [notification.userInfo objectForKey:kNotifIncomingCall_SessionId];
		NgnAVSession* session = [[NgnAVSession getSessionWithId:[sessionId longValue]] retain];
		
		if(session){
			[CallViewController receiveIncomingCall:session];
			[session release];
		}
	}
    else if ([notifKey isEqualToString:kNotifKey_SignInRemind])
    {
        UIApplicationState state = application.applicationState;
        if (state == UIApplicationStateActive)
        {
            CCLog(@"前台收到通知");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertAction
                                                            message:notification.alertBody
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            alert.tag = kTagAlertSignInRemind;
            [alert show];
            [alert release];
        }
        else
        {
            [self GoBackToRootViewFirst];
            [self EnterSignInView];
        }
    }
    else if ([notifKey isEqualToString:kNotifKey_GroupCallRemind])
    {
        self.conferenceUUID = [notification.userInfo objectForKey:kNotifKey_GroupCallUUID];
        UIApplicationState state = application.applicationState;
        if (state == UIApplicationStateActive)
        {
            CCLog(@"前台收到通知");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertAction
                                                            message:notification.alertBody
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            alert.tag = kTagAlertGroupCallRemind;
            [alert show];
            [alert release];
        }
        else
        {
            [self GoBackToRootViewFirst];
//            [self EnterGroupCallView];
        }
    }
    else if ([notifKey isEqualToString:kNotifKey_IncomingMsg])
    {
        NSString *imsgNum = [notification.userInfo objectForKey:kNotifKey_IncomingMsgNum];
        
        //在前台不会收到这个消息
        UIApplicationState state = application.applicationState;
        if (state == UIApplicationStateActive)
        {
            CCLog(@"前台收到IM通知");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertAction
                                                            message:notification.alertBody
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            alert.tag = kTagAlertMessagesRemind;
            [alert show];
            [alert release];
        }
        else
        {
            [self GoBackToRootViewFirst];
            [self EnterMessagesView:imsgNum];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (isOpenDianRuWallPoints)
        [DianRuAdWall dianruOnResume];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
	NgnNSLog(TAG, @"applicationWillTerminate");
	
    if(registerTimer){
		[registerTimer invalidate];
		[registerTimer release];
		registerTimer = nil;
	}

    [[NgnEngine sharedInstance] stop];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url scheme] isEqualToString:@"Alipay2088901012551910"]) {
        [self parseURL:url application:application];
        return YES;
    }
    else
        return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:@"Alipay2088901012551910"])
    {
        [self parseURL:url application:application];
        return YES;
    }
    else
    {
        return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
    }
}

- (void)userInfoUpdateHandler:(NSNotification *)notif
{
    NSMutableArray *authList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()]];
    if (authList == nil)
    {
        authList = [NSMutableArray array];
    }
    
    NSString *platName = nil;
    NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
    switch (plat)
    {
        case ShareTypeSinaWeibo:
            platName = @"新浪微博";
            break;
        case ShareType163Weibo:
            platName = @"网易微博";
            break;
        case ShareTypeDouBan:
            platName = @"豆瓣";
            break;
        case ShareTypeFacebook:
            platName = @"Facebook";
            break;
        case ShareTypeKaixin:
            platName = @"开心网";
            break;
        case ShareTypeQQSpace:
            platName = @"QQ空间";
            break;
        case ShareTypeRenren:
            platName = @"人人网";
            break;
        case ShareTypeSohuWeibo:
            platName = @"搜狐微博";
            break;
        case ShareTypeTencentWeibo:
            platName = @"腾讯微博";
            break;
        case ShareTypeTwitter:
            platName = @"Twitter";
            break;
        case ShareTypeInstapaper:
            platName = @"Instapaper";
            break;
        case ShareTypeYouDaoNote:
            platName = @"有道云笔记";
            break;
        default:
            platName = @"未知";
    }
    id<ISSPlatformUser> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
    
    BOOL hasExists = NO;
    for (int i = 0; i < [authList count]; i++)
    {
        NSMutableDictionary *item = [authList objectAtIndex:i];
        ShareType type = (ShareType)[[item objectForKey:@"type"] integerValue];
        if (type == plat)
        {
            [item setObject:[userInfo nickname] forKey:@"username"];
            hasExists = YES;
            break;
        }
    }
    
    if (!hasExists)
    {
        NSDictionary *newItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 platName,
                                 @"title",
                                 [NSNumber numberWithInteger:plat],
                                 @"type",
                                 [userInfo nickname],
                                 @"username",
                                 nil];
        [authList addObject:newItem];
    }
    
    [authList writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];
}

#pragma mark UITabBarControllerDelegate methods

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    UIViewController* view = viewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nc = (UINavigationController*)viewController;
        view = [nc topViewController];
    }
    UIViewController<BannerViewContainer>* bannerView = [self toBannerViewContainer:view];
    [self ShowAdBanner:bannerView];     

 }
 

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 }
 */

/*---------APNs service callback---------*/
// 注册Device token
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NgnEngine sharedInstance].configurationService setStringWithKey:SECURITY_DEVICE_TOKEN andValue:[NSString
                                                     stringWithFormat:@"%@",deviceToken]];
    CCLog(@"RegisterForRemoteNotificationsWithDeviceToken: DeviceToken=%@", deviceToken);
}

// 注册APNs错误
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    CCLog(@"FailToRegisterForRemoteNotificationsWithError: %@", err);
}

// 接收推送通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {    
    NSString *msg = [NSString stringWithFormat:@"%@", userInfo];
    CCLog(@"ReceiveRemoteNotification:\n%@", msg);

#if 0
    UIAlertView* alert2=[[UIAlertView alloc]initWithTitle:@"didReceiveRemoteNotification"                        
                                                  message:msg delegate:nil                        
                                        cancelButtonTitle:@"OK" otherButtonTitles:nil];    
    [alert2 show];    
    alert2=nil;
#endif
    
    /*ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
     if (registrationState == CONN_STATE_CONNECTED) {
     CCLog(@"ReceiveRemoteNotification: Current register status is connected, do NOT need to send msg to server");
     return;
     }*/
    /*CCLog(@"ReceiveRemoteNotification: %d", [UIApplication sharedApplication].applicationState);
     if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
     CCLog(@"ReceiveRemoteNotification: Running in foreground, do NOT need to send msg to server");
     return;
     }*/

    RemoteNotificationDef* rnd = [self parseremotenotification:userInfo];
    if (rnd) {
        if (rnd.type == APNS_TYPE_INCOMING_CALL) {
            [self sendAnswerCallMsg:rnd.value];
        }
    }
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    //[[NgnEngine sharedInstance].contactService unload];   /*gary remove for losing contact and history*/
	//[[NgnEngine sharedInstance].historyService clear];
	[[NgnEngine sharedInstance].storageService clearFavorites];
    [[MHImageCache sharedInstance] flushMemory];
}

-(AudioCallViewController *)audioCallController{
	if(!self->audioCallController){
		self->audioCallController = [[AudioCallViewController alloc] initWithNibName: @"AudioCallView" bundle:nil];;
	}
	return self->audioCallController;
}

-(VideoCallViewController *)videoCallController{
	if(!self->videoCallController){
		self->videoCallController = [[VideoCallViewController alloc] initWithNibName: @"VideoCallView" bundle:nil];;
	}
	return self->videoCallController;
}

-(ChatViewController *)chatViewController{
	if(!self->chatViewController){
		self->chatViewController = [[ChatViewController alloc] initWithNibName: @"ChatView" bundle:nil];
	}
	return self->chatViewController;
}

-(int)adType{
	return self->adType;
}

- (int)getAppStoreRelease
{
    return self->appstorerelease;
}

- (int)getCurrentRelease
{
    return self->currentrelease;
}

-(BOOL)registered {
    return self->registered;
}

-(int) maxexchangepoints
{
    return self->maxexchangepoints;
}

-(NSMutableArray*)rechargeProducts
{
    return self->rechargeProducts;
}

-(void) selectTabNumpad{
    if (self.tabBarController == nil) {
        return;
    }
    
	self.tabBarController.selectedIndex = kTabBarIndex_Numpad;
    
    if ((adType == AD_TYPE_91DIANJIN) || (adType == AD_TYPE_LIMEI)) {
        UIViewController* view = tabBarController.selectedViewController;
        if ([view isKindOfClass:[UINavigationController class]]) {
            UINavigationController* nc = (UINavigationController*)view;
            view = [nc topViewController];
        }
        UIViewController<BannerViewContainer>* bannerView = [self toBannerViewContainer:view];
        [self ShowAdBanner:bannerView];
    }
}

/*-(void) selectTabGroupCall{
    if (self.tabBarController == nil) {
        return;
    }
    
	self.tabBarController.selectedIndex = kTabBarIndex_GroupCall;
    
    if ((adType == AD_TYPE_91DIANJIN) || (adType == AD_TYPE_LIMEI)) {
        UIViewController* view = tabBarController.selectedViewController;
        if ([view isKindOfClass:[UINavigationController class]]) {
            UINavigationController* nc = (UINavigationController*)view;
            view = [nc topViewController];
        }
        UIViewController<BannerViewContainer>* bannerView = [self toBannerViewContainer:view];
        [self ShowAdBanner:bannerView];
    }
}*/

-(void) selectTabContacts{
    if (self.tabBarController)
        self.tabBarController.selectedIndex = kTabBarIndex_Contacts;
}

-(void) selectTabMessages{
    if (self.tabBarController)
        self.tabBarController.selectedIndex = kTabBarIndex_Messages;
}

-(void) selectTabSettings{
    //if (self.tabBarController)
//	self.tabBarController.selectedIndex = kTabBarIndex_Settings;
}

-(void) uploadContacts2Server:(BOOL)checkDb
{
    NSString *user_number = [self getUserName];
    
    //当切换用户的时候删除非自己的好友,其实意义不大,使用的通讯录还是本地的通讯录啊
    if (checkDb && user_number)
        [[NgnEngine sharedInstance].contactService dbDeleteContactsNotMine:user_number];
    
    NgnContactMutableArray *_contacts = (NgnContactMutableArray*)[[NgnEngine sharedInstance].contactService contacts];
    NSMutableString *allContactMsg = [NSMutableString stringWithCapacity:50];       //用于生成md5值
    
    //组织contact_list数据
    NSMutableArray *contact_list = [NSMutableArray arrayWithCapacity:20];
    for (NgnContact* contact in _contacts) {
        if (!contact) continue;
        
        [allContactMsg appendString:contact.displayName];
        
        //名称
        NSString *name = @"No Name";
        if (contact.displayName) {
            name = [contact.displayName stringByReplacingOccurrencesOfString:@"!" withString:@""];
            name = [name stringByReplacingOccurrencesOfString:@":" withString:@""];
            name = [name stringByReplacingOccurrencesOfString:@";" withString:@""];
        }
        
        //号码
        for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers)
        {
			if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number)
            {
                NSString *number = [phoneNumber.number phoneNumFormat];
                
                //非数字号码,有可能是用户随便填写的,通过判断是否数字来决定,比如含有字母
                if (!IsPureNumber(number)) continue;
                
                NSDictionary *aCell = [[NSDictionary alloc] initWithObjectsAndKeys:name, @"name", number, @"number", nil];
                [contact_list addObject:aCell];
                [aCell release];
                
                [allContactMsg appendString:number];
			}
		}
    }
    
    NSString *md5String = [allContactMsg md5];
    CCLog(@"md5String : %@",md5String);
    [[NgnEngine sharedInstance].configurationService setStringWithKey:GENERAL_CONTACT_MD5_STRING andValue:md5String ];
    
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:user_number, @"user_number", contact_list, @"contact_list", nil];
    
//    CCLog(@"jsonString : %@",jsonDict);
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
    [userInfo setValue:kUploadContacts forKey:@"reqType"];
    
    //提交上传通讯录请求
    [[HttpRequest instance] addRequestWithEncrypt:kUploadContactsURL andMethod:@"POST" andContent:jsonDict andTimeout:15
                         delegate:self successAction:@selector(receiveHttpResponse:andUserInfo:) failureAction:@selector(requestHttpError:andUserInfo:) userInfo:userInfo];
    
//    const int maxPacketLen = 300;// One packet max length supportted by server is 300.
//    NSString* cType = @"text/contacts";
//    NSString* remoteParty = @"cc-server";
//    NSString* remotePartyUri = [NgnUriUtils makeValidSipUri: remoteParty];
//    
//    NgnMessagingSession* session = nil;
//    
//    /* Client -> Server
//     * Contacts Format:
//     *   Number!User:13500000001;Contacts!李四:13500000002;王五:13500000003;王五:13500000004;李六:13500000006;
//     */
//    NSString *myNum = [self getUserName];
//    if (checkDb && myNum) {
//        [[NgnEngine sharedInstance].contactService dbDeleteContactsNotMine:myNum];
//    }
//    
//    NSString* textContent = nil;
//    NgnContactMutableArray* contacts_ = (NgnContactMutableArray*)[[[NgnEngine sharedInstance].contactService contacts] retain];    
//    int sentTime = 0;
//    CCLog(@"uploadContacts2Server count=%d", [contacts_ count]);
//    for (NgnContact* contact in contacts_) {
//        if (!contact) {
//            continue;
//        }
//        
//        //CCLog(@"uploadContacts2Server name=%@", contact.displayName);
//        // Name must not include ‘!’,’:’ or ’;’.
//        NSString* tmpDisplayName = @"No Name";
//        if (contact.displayName) {
//            tmpDisplayName = [contact.displayName stringByReplacingOccurrencesOfString:@"!" withString:@""];
//            tmpDisplayName = [tmpDisplayName stringByReplacingOccurrencesOfString:@":" withString:@""];
//            tmpDisplayName = [tmpDisplayName stringByReplacingOccurrencesOfString:@";" withString:@""];
//        }
//        
//        for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers) {
//			if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number) {
//                NSString* tmpPhoneNum = [phoneNumber.number stringByReplacingOccurrencesOfString:@" " withString:@""];
//                tmpPhoneNum = [tmpPhoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
//                tmpPhoneNum = [tmpPhoneNum stringByReplacingOccurrencesOfString:@"(" withString:@""];
//                tmpPhoneNum = [tmpPhoneNum stringByReplacingOccurrencesOfString:@")" withString:@""];
//                tmpPhoneNum = [tmpPhoneNum stringByReplacingOccurrencesOfString:@"+86" withString:@""];
//                
//                if (!IsPureNumber(tmpPhoneNum)) {
//#if 0               // for debug
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:tmpDisplayName
//                                                                    message:tmpPhoneNum
//                                                                   delegate:nil
//                                                          cancelButtonTitle:kAlertMsgButtonOkText
//                                                          otherButtonTitles: nil];
//                    [alert show];
//                    [alert release];
//#endif              
//                    
//                    continue;                    
//                }
//                
//                if (!textContent) {
//                    textContent = [[[NSString alloc] initWithFormat:@"Number!User:%@;Contacts!%@:%@;", myNum, tmpDisplayName,tmpPhoneNum] autorelease];
//                } else {
//                    if (textContent && [textContent length] + [tmpPhoneNum length] >= maxPacketLen) {
//                        [textContent stringByAppendingString:@"\0"];
//                        session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack]
//                                                                             andToUri: remotePartyUri];
//                        BOOL ret = [session sendTextMessage:textContent contentType:cType];
//                        //CCLog(@"uploadContacts2Server %d\n=%@", ret, textContent);
//
//                        sentTime++;
//                        
//                        // A new ones.
//                        textContent = [[[NSString alloc] initWithFormat:@"Number!User:%@;Contacts!%@:%@;", myNum, tmpDisplayName, tmpPhoneNum] autorelease];
//                    } else {                        
//                        NSString* strTmp = [textContent stringByAppendingFormat:@"%@:%@;", tmpDisplayName, tmpPhoneNum];
//                        textContent = strTmp;
//                    }
//                }
//			}
//		}
//    }
//    
//    if (textContent && [textContent length]) {
//        [textContent stringByAppendingString:@"\0"];
//        session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack] andToUri: remotePartyUri];
//        BOOL ret = [session sendTextMessage:textContent contentType:cType];
//        //CCLog(@"uploadContacts2Server %d\n=%@", ret, textContent);
//        sentTime++;
//    }
//    
//    CCLog(@"uploadContacts2Server sentTime=%d", sentTime);
// 
//    [contacts_ release];
}

-(void) GetAccountBalance {
    NSString* remoteParty = @"cc-server";
    NSString* remotePartyUri = [NgnUriUtils makeValidSipUri: remoteParty];
    
    NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack] andToUri: remotePartyUri];        
    BOOL ret = [session sendTextMessage:@"" contentType:@"text/balance"];
    CCLog(@"GetAccountBalance %d", ret);
}

/*-(void) GetAccountReferee {
    NSString* remoteParty = @"cc-server";
    NSString* remotePartyUri = [NgnUriUtils makeValidSipUri: remoteParty];
        
    NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack] andToUri: remotePartyUri];        
    BOOL ret = [session sendTextMessage:@"" contentType:@"text/getreferee"];
    CCLog(@"GetAccountReferee %d", ret);
}
    
-(void) SetAccountReferee:(NSString*)num {
    NSString* remoteParty = @"cc-server";
    NSString* remotePartyUri = [NgnUriUtils makeValidSipUri: remoteParty];
        
    NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack] andToUri: remotePartyUri];
    NSString* textContent = [[[NSString alloc] initWithFormat:@"friend:%@\r\n", num] autorelease];
    BOOL ret = [session sendTextMessage:textContent contentType:@"text/setreferee"];
    CCLog(@"SetAccountReferee %d", ret);
}*/

-(void) CheckVersionUpdate:(BOOL)autoCheck{
//    NSString* remoteParty = @"cc-server";
//    NSString* remotePartyUri = [NgnUriUtils makeValidSipUri: remoteParty];    
//    NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack] andToUri: remotePartyUri];
//    BOOL ret = [session sendTextMessage:@"" contentType:@"text/versionupdate"];
//    CCLog(@"CheckVersionUpdate %d, %ld", ret, session.id);
//    checkingVersionUpdate = ret;
    [self sendCheckVersionUpdateRequest:autoCheck];
}

-(void) CheckUserRight {
    NSString* remoteParty = @"cc-server";
    NSString* remotePartyUri = [NgnUriUtils makeValidSipUri: remoteParty];
    NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack] andToUri: remotePartyUri];
    BOOL ret = [session sendTextMessage:@"" contentType:@"text/userright"];
    CCLog(@"CheckUserRight %d, %ld", ret, session.id);
}

-(void) SetCheckingVersionUpdate:(BOOL)update {
    checkingVersionUpdate = update;
}

-(NSMutableArray*) GetRechargeProductIds {
    return rechargeProducts;
}

-(void) IAPRecharge:(NgnIAPRecord*)record {
    if (iapMgr)
        [iapMgr recharge:record];
}

-(NSString*)GetSigninAdsDirectoryPath{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    return [dir stringByAppendingPathComponent:@"SigninAds"];
}

/**
 *	@brief	获取老虎机相关文件夹路径
 *
 *	@return	返回路径
 */
- (NSString*)GetSlotMachineImgDirectoryPath
{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    return [dir stringByAppendingPathComponent:@"SlotMachine"];
}

- (NSString*)GetCTBannerAdsDirectoryPath
{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    return [dir stringByAppendingPathComponent:@"CTBannerAds"];
}

/**
 *	@brief	获取广场按钮相关文件夹路径
 *
 *	@return	返回路径
 */
- (NSString*)GetDiscoverItemsDirDirectoryPath
{
    NSArray *CachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *CachessDir = [CachesPaths objectAtIndex:0];
    return [CachessDir stringByAppendingPathComponent:@"DiscoverItems"];
}

/**
 *	@brief	获取号码归属地数据库文件路径
 *
 *	@return	返回路径
 */
- (NSString*)GetAreaOfPhoneNumberDBDirectoryPath
{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    return [dir stringByAppendingPathComponent:kAreaOfPhoneNumberDB];
}

/**
 *	@brief	获取优惠券图片文件夹路径
 *
 *	@return	返回路径
 */
- (NSString*)GetCouponImgDirectoryPath
{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    return [dir stringByAppendingPathComponent:@"Coupon"];
}

/**
 *	@brief	获取IM缓存文件夹路径
 *
 *	@return	返回路径
 */
- (NSString*)GetIMCachesDirectoryPath
{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
#elif TARGET_OS_MAC
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"CC"];
#endif
    return [dir stringByAppendingPathComponent:@"IMCaches"];
}

-(void) AdClick:(int)awardAmount withType:(int)wallAdType
{
    NSString* remoteParty = @"cc-server";
    NSString* remotePartyUri = [NgnUriUtils makeValidSipUri: remoteParty];
    
    NSString* textContent = nil;
    NSString* advertiser = @"";
    switch (wallAdType) {
        case AD_TYPE_IAD:
            advertiser = @"apple";
            break;
        case AD_TYPE_91DIANJIN:
            advertiser = @"dianjin"; // old is @"91";
            break;
        case AD_TYPE_CLOUDCALL_HK:
            advertiser = @"cloudcall";
            break;
        case AD_TYPE_DIANRU:
            advertiser = @"dianru";
            break;
        case AD_TYPE_LIMEI:
            advertiser = @"immob";      //力美
            break;
    }
    textContent = [[[NSString alloc] initWithFormat:@"advertiser:%@\r\nadmtype:%d\r\n", advertiser, awardAmount] autorelease];
    NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack]
                                                                              andToUri: remotePartyUri];        
    BOOL ret = [session sendTextMessage:textContent contentType:@"text/adclick"];
    CCLog(@"AdClick %d", ret);
}

-(void) viewChanged:(UIViewController*)viewController {
    UIViewController<BannerViewContainer>* bannerView = [self toBannerViewContainer:viewController];
    [self ShowAdBanner:bannerView];
}

+(CloudCall2AppDelegate*) sharedInstance{
	return ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
}

+(BOOL) runInBackground {
    return sBackgroundTask != UIBackgroundTaskInvalid;
}

- (void)dealloc {
    [conferenceUUID release];
    [_viewDelegate release];
    [tabBarController release];
	[contactsViewController release];
	[audioCallController release];
	[videoCallController release];
	[messagesViewController release];
	[chatViewController release];
    [logViewController release];
    if (self.validationView != nil)
    {
        [validationView release];
        self.validationView = nil;
    }
    
    if (launchremns)
        [launchremns release];
    
    [iadbanner release];
    [lmbanner release];
    [bdbanner release];
    
    if (versionUrl) {
        [versionUrl release];
        versionUrl = nil;
    }
    
    if (lastMsgCallId) {
        [lastMsgCallId release];
    }
    
    if (rechargeProducts) {
        [rechargeProducts release];
    }
    
    if (incallAdData) {
        [incallAdData release];
    }
    
    if (signinAdData) {
        [signinAdData release];
    }
    
    if (callFeedBackData) {
        [callFeedBackData release];
    }
    
    if (ctbanner) {
        [ctbanner release];
    }
        
    if (groupcallMgr) {
        [groupcallMgr release];
        groupcallMgr = nil;
    }
    
    if (ntymsgMgr) {
        [ntymsgMgr release];
        ntymsgMgr = nil;
    }
    [username release];
    [password release];
    
    [window release];
    [super dealloc];
}

- (void)showGuideViewController
{
    GuideViewController *teachViewCtrlr = [[GuideViewController alloc] initWithNibName:@"GuideViewController" bundle:nil];
    [self.window.rootViewController presentModalViewController:teachViewCtrlr animated:NO];
    [teachViewCtrlr release];
}

- (void)ShowNewFeatureRemind
{
    int num = 0;
    //判断是否需要显示向导页面
    NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if (![versionString isEqualToString:[[NgnEngine sharedInstance].configurationService getStringWithKey:SHOW_NEW_FUNCTION_REMIND]])
    {
        [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FUNCTION_REMIND andValue:versionString];
        [self showGuideViewController];     //版本不同时显示向导页面
        
	/*
        [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FOR_SHAKE_TO_SIGNIN andValue:@"ShakeToSignInView"];
        
        [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FOR_PERSONALINFO andValue:@"PersonalInfoNewView"];
        
        [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FOR_SLOTMACHINE andValue:@"SlotMachineViewController"];
      
    [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FOR_GROUP andValue:@"GroupView"];
    [[NgnEngine sharedInstance].configurationService setStringWithKey:SHOW_NEW_FOR_GROUPCALL andValue:@"GroupCallView"];
    */
    }

    /*
    if ([self ShowAllFeatures] == NO)
    {
    	return;
    }
	
    if ([[[NgnEngine sharedInstance].configurationService getStringWithKey:SHOW_NEW_FOR_SHAKE_TO_SIGNIN] length] != 0)
    {
        num++;
    }
    
    if ([[[NgnEngine sharedInstance].configurationService getStringWithKey:SHOW_NEW_FOR_PERSONALINFO] length] != 0)
    {
        num++;
    }
    
    if ([[[NgnEngine sharedInstance].configurationService getStringWithKey:SHOW_NEW_FOR_SLOTMACHINE] length] != 0)
    {
        num++;
    }
    
    if (self.tabBarController)
    {
        UITabBarItem *tbi = (UITabBarItem*)[[[self.tabBarController tabBar] items] objectAtIndex:kTabBarIndex_Discover];
        if (tbi)
            [tbi setBadgeValue:num?[NSString stringWithFormat:@"%d", num]:nil];
    }
    */
}

-(void) UnreadSysNofifyNum:(unsigned int)num {
    unreadSysNotify = num;
    NSString* strBadgeValue = [NSString stringWithFormat:@"%d", unreadSysNotify];
    if (self.tabBarController)
    {
        UITabBarItem *tbi = (UITabBarItem*)[[[self.tabBarController tabBar] items] objectAtIndex:kTabBarIndex_Contacts];
        if (tbi)
            [tbi setBadgeValue:num?strBadgeValue:nil];
    }
}

-(unsigned int) unreadSysNofifyNum {
    return unreadSysNotify;
}

-(void) UnreadIMNum:(unsigned int)num {
    unreadIM = num;
    NSString* strBadgeValue = [NSString stringWithFormat:@"%d", unreadIM];
    if (self.tabBarController)
    {
        UITabBarItem *tbi = (UITabBarItem*)[[[self.tabBarController tabBar] items] objectAtIndex:kTabBarIndex_Messages];
        if (tbi)
            [tbi setBadgeValue:num?strBadgeValue:nil];
    }
}

-(void)ReloadConfigFromFile {
    NSString* strCfg = [self LoadConfigFile];
    [self parseConfiguration:strCfg];
}


-(BOOL) ShowAllFeatures
{
    if (g_marketType == CLIENT_FOR_AS_APP_STORE)
    {
        if (currentrelease > appstorerelease)
            return NO;
    }
    return YES;
}

- (void)setCurrentRelease
{
    currentrelease = 100;
}

-(BOOL) ShowInAppPurchase
{
    return (g_marketType == CLIENT_FOR_AS_APP_STORE);
}

-(MarketTypeDef) MarkCode
{
    return g_marketType;
}

-(NSString*) MarketTypeName
{
    const char* s = getMarketName(g_marketType);
    return s ? [NSString stringWithUTF8String:s] : @"Unknown";
}

-(NSData*)GetIncallImage:(NSString*)filename {
    NSString* imgpath = [[self GetIncallAdsDirectoryPath] stringByAppendingPathComponent:filename];
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:imgpath];
    return [imageData autorelease];
}

-(NSData*)GetCallFeedBackImage:(NSString*)filename {
    NSString* imgpath = [[self GetCallFeedBackDirectoryPath] stringByAppendingPathComponent:filename];
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:imgpath];
    return [imageData autorelease];
}

- (CCAdsData *)GetCurrIncallAdData
{
    if (currIncallAdIndex >= [incallAdData count])
        currIncallAdIndex = 0;
    
    if (incallAdData && [incallAdData count] != 0) {
        CCAdsData *adsData = [incallAdData objectAtIndex:currIncallAdIndex];
        
        currIncallAdIndex++;
        return adsData;
    }
    return nil;
}

/////////////////////////////////////////////////////////////////////////////////////

-(void) ShowCallFeedbackView:(CallFeedbackData*)data {
    CallFeedbackViewController *cfv = [CallFeedbackViewController alloc];
    
//    if ([[CloudCall2AppDelegate sharedInstance] ShowAllFeatures]) {
//        if (CCAdsData *adsData = [[CloudCall2AppDelegate sharedInstance] GetCurrIncallAdData]) {
//            if (NSData* imgData = [[CloudCall2AppDelegate sharedInstance] GetIncallImage:[adsData.image lastPathComponent]]) {
//                [cfv SetImageAd:imgData andImgURL:adsData.clickurl];
//            }
//        }
//    }
    
    cfv.callfeedbackdata = data;
    window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [window.rootViewController presentModalViewController:cfv animated:YES];
    [cfv release];
}

-(void) SendCallFeedback2Server:(CallFeedbackData*)data {
    CCLog(@"RechargeViaInAppPurchase:");
    if (callFeedbackMgr) {
        [callFeedbackMgr commit:data];
    }
}

-(void)AddGroupCallRecords:(NSArray*)records {
    if (groupcallMgr) {
        [groupcallMgr AddGroupRecords:records];
    }
}

-(void)UpdateGroupCallRecords:(NSArray*)records {
    if (groupcallMgr) {
        [groupcallMgr UpdateGroupRecords:records];
    }
}

-(void)DeleteGroupCallRecords:(NSArray*)records {
    if (groupcallMgr) {
        [groupcallMgr DeleteGroupRecords:records];
    }
}

-(void)DeleteGroupCallRecord:(NSString*)groupid {
    if (groupcallMgr) {
        [groupcallMgr DeleteGroupRecord:groupid];
    }
}

-(void)GetGroupCallRecords {
    if (groupcallMgr) {
        [groupcallMgr GetGroupRecords];
    }
}

- (void)loadSigninData
{
    [signinAdData removeAllObjects];
    AdResourceManager *manager = [[AdResourceManager alloc] init];
    [manager dbLoadAdsData:signinAdData andMyIndex:ADSMyindexSignin];
    [manager release];
}

-(CCAdsData*)GetCurrSigninAdData
{
    if (currSigninAdIndex >= [signinAdData count])
        currSigninAdIndex = 0;
    
    if (signinAdData && [signinAdData count]!=0) {
        CCAdsData *adsData = [signinAdData objectAtIndex:currSigninAdIndex];
        
        currSigninAdIndex++;
        return adsData;
    }
    return nil;
}

- (void)loadCallFeedBackData
{
    [callFeedBackData removeAllObjects];
    AdResourceManager *manager = [[AdResourceManager alloc] init];
    [manager dbLoadAdsData:callFeedBackData andMyIndex:ADSMyindexAlertView];
    [manager release];
}

- (CCAdsData*)GetCurrCallFeedBackData
{
    if (currCallFeedBackIndex >= [callFeedBackData count])
        currCallFeedBackIndex = 0;
    
    if (callFeedBackData && [callFeedBackData count]!=0) {
        CCAdsData *adsData = [callFeedBackData objectAtIndex:currCallFeedBackIndex];
        
        currCallFeedBackIndex++;
        return adsData;
    }
    return nil;
}

/////////////////////////////////////////////////////////////////////////////////////

- (void)messageBox:(NSString *)title message:(NSString *)message buttonName:(NSString *)buttonName {
	UIAlertView *alert = [[UIAlertView alloc] init];
	alert.title = title;
	alert.message = message;
	[alert addButtonWithTitle:buttonName];
	[alert show];
	[alert release];
}

-(void)getConfigFileSuccessed:(NSString*)currServ {
    g_currserv = currServ;
    NSString* strRegHost = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_REG_HOST];
    
    NSString* strCfg = [self LoadConfigFile];
    [self parseConfiguration:strCfg];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMoreView" object:nil];//刷新更多页面
    
    if (regAfterGetCfg) {
        regAfterGetCfg = NO;
        
        if (enteringForeground) {
            enteringForeground = NO;
            
            NSString* strRegHostNow = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_REG_HOST];
            if ([strRegHost isEqualToString:strRegHostNow] == NO) {
                [[NgnEngine sharedInstance].sipService stopStackSynchronously];
            }
        }
        
        NSString *impi = [self getUserName];
        NSString *passwd = [self getUserPassword];
        if ([impi isEqualToString:DEFAULT_IDENTITY_IMPI] || ![passwd length] || [passwd isEqualToString:DEFAULT_IDENTITY_PASSWORD]
            || [passwd isEqualToString:@"00000"] || [passwd isEqualToString:@"995995"]) {
            if (remoteNotif) {
                [remoteNotif release];
                remoteNotif = nil;
            }
            //            [self performSelectorOnMainThread:@selector(displayValidationView) withObject:nil waitUntilDone:NO];
            return;
        }
        //sipServer Login
        [loginManager sipLoginSuccessBlock:^{} sipLoginFailedBlock:^{}];
        [self xmppConnect];

        /*if (YES == [self queryConfigurationAndRegister]) {
         // Process push notification when app is not running
         if (remoteNotif) {
         if (launchremns) {
         delete launchremns;
         launchremns = 0;
         }
         launchremns = [self parseremotenotification:remoteNotif];
         [remoteNotif release];
         remoteNotif = nil;
         }
         }*/
    }
}

-(void)getConfigFileFailed:(NSError*)error {
    [loginManager sipLoginSuccessBlock:^{} sipLoginFailedBlock:^{}];
    return;
}

#pragma mark - DianJin
#if DianJin_Enable
- (void)getBalance {
	int result = [[DianJinOfferPlatform defaultPlatform] getBalance:self];
	if (result != DIAN_JIN_NO_ERROR) {
		CCLog(@"consume result = %d", result);
	}
}

- (void)consume:(float)amount {
	if (amount<=0.0) {
		[self messageBox:@"消费失败" message:[NSString stringWithFormat:@"消费金额不能为空,输入数据必须为数字!"] buttonName:@"确定"];
		return;
	}
	int result = [[DianJinOfferPlatform defaultPlatform] consume:amount delegate:self];
	if (result != DIAN_JIN_NO_ERROR) {
		CCLog(@"consume result = %d", result);
	}
}

- (void)getBalanceDidFinish:(NSDictionary *)dict {
	CCLog(@"%@", dict);
	NSString *boxMessage = nil;
	NSNumber *result = [dict objectForKey: @"result"];
	if ([result intValue] == DIAN_JIN_NO_ERROR) {
		NSNumber *balance = [dict objectForKey:@"balance"];
		if (balance != nil) {
			//_balanceLabel.text = [NSString stringWithFormat:@"%.2f", [balance floatValue]];
		}
	}
	else if ([result intValue] == DIAN_JIN_ERROR_NETWORK_FAIL) {
		boxMessage = @"网络连接错误";
	}
	else if ([result intValue] == DIAN_JIN_ERROR_USER_NOT_AUTHORIZED) {
		boxMessage = @"未授权的appId和appKey";
	}
	else {
		boxMessage = [NSString stringWithFormat:@"错误码:%d", [result intValue]];
	}
	if (boxMessage != nil) {
		[self messageBox:@"查询余额失败" message:boxMessage buttonName:@"确定"];
	}
}

- (void)consumeDidFinish:(NSDictionary *)dict {
	CCLog(@"%@", dict);
	NSNumber *result = [dict objectForKey: @"result"];
	NSString *boxMessage = nil;
	NSString *boxTitle = @"消费失败";
	switch ([result intValue]) {
		case DIAN_JIN_NO_ERROR:
			boxTitle = @"消费成功";
			boxMessage = @"";
			break;
		case DIAN_JIN_ERROR_NETWORK_FAIL:
			boxMessage = @"网络连接错误";
			break;
		case DIAN_JIN_ERROR_REQUES_CONSUNE:
			boxMessage = @"支付请求失败";
			break;
		case DIAN_JIN_ERROR_BALANCE_NO_ENOUGH:
			boxMessage = @"余额不足";
			break;
		case DIAN_JIN_ERROR_ACCOUNT_NO_EXIST:
			boxMessage = @"帐号不存在";
			break;
		case DIAN_JIN_ERROR_ORDER_SERIAL_REPEAT:
			boxMessage = @"订单号重复";
			break;
		case DIAN_JIN_ERROR_BEYOND_LARGEST_AMOUNT:
			boxMessage = @"一次性交易超出最大限定金额";
			break;
		case DIAN_JIN_ERROR_CONSUME_ID_NO_EXIST:
			boxMessage = @"不存在该类型的消费动作ID";
			break;
		case DIAN_JIN_ERROR_USER_NOT_AUTHORIZED:
			boxMessage = @"未授权的appId和appKey";
			break;
            
		default:
			boxMessage = [NSString stringWithFormat:@"未知错误 错误码为:%d", [result intValue]];
			break;
	}
	[self messageBox:boxTitle message:boxMessage buttonName:@"确定"];
}
#endif

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kTagActionAlertUpdateVersion:
            if (buttonIndex == 0) { // Cancel
                [versionUrl release];
                versionUrl = nil;
            } else if (buttonIndex == 1) { // Update
                if (versionUrl) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionUrl]];
                    [versionUrl release];
                    versionUrl = nil;
                }
            }
            break;
        case kTagAlertSignInRemind:
        {
            if (buttonIndex == 1)
            {
                [self GoBackToRootViewFirst];
                [self EnterSignInView];
            }
            break;
        }
        case kTagAlertMessagesRemind:
        {
            if (buttonIndex == 1)
            {
                [self GoBackToRootViewFirst];
                [self EnterMessagesView:@""];
            }
            break;
        }
        case kTagAlertGroupCallRemind:
        {
            if (buttonIndex == 1)
            {
                [self GoBackToRootViewFirst];
//                [self EnterGroupCallView];
            }
            break;
        }
        default:
            break;
    }
}

/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark immobViewDelegate methods
/**
 *email phone sms等所需要
 *返回当前添加immobView的ViewController
 */
//暂时不用,返回0
- (UIViewController *)immobViewController{
    
    return 0;
}

-(void)onLeaveApplication:(immobView *)immobView
{
    CCLog(@"onLeaveApplication");
}


/////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ADBannerViewDelegate methods

- (void)bannerViewWillLoadAd:(ADBannerView *)bannerview
{
    return;
}

-(void)bannerViewDidLoadAd:(ADBannerView *)bannerview
{
    if (adType!=AD_TYPE_IAD) return;

    UIViewController* view = tabBarController.selectedViewController;
    if ([view isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nc = (UINavigationController*)view;
        view = [nc topViewController];
    }
    UIViewController<BannerViewContainer>* bannerView = [self toBannerViewContainer:view];
    [self ShowAdBanner:bannerView];
}

-(void)bannerView:(ADBannerView *)bannerview didFailToReceiveAdWithError:(NSError *)error
{
    if (adType != AD_TYPE_IAD) {
        return;
    }
    
    UIViewController* view = tabBarController.selectedViewController;
    if ([view isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nc = (UINavigationController*)view;
        view = [nc topViewController];
    }
    UIViewController<BannerViewContainer>* bannerView = [self toBannerViewContainer:view];
    if (bannerView) {
        [bannerView hideBannerView:iadbanner adtype:adType animated:YES];
    }
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)bannerview willLeaveApplication:(BOOL)willLeave
{
    // While the banner is visible, we don't need to tie up Core Location to track the user location
    // so we turn off the map's display of the user location. We'll turn it back on when the ad is dismissed.
    
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)bannerview
{
    // Now that the banner is dismissed, we track the user's location again.
}


#pragma mark
#pragma mark 支付宝回调函数
/**
 *	@brief	支付宝回调函数,支付后回调应用
 *	@param 	application 	云通应用
 */
- (void)parseURL:(NSURL *)url application:(UIApplication *)application
{
	AlixPay *alixpay = [AlixPay shared];
	AlixPayResult *result = [alixpay handleOpenURL:url];
	if (result) {
		//是否支付成功
		if (9000 == result.statusCode) {
			/*
			 *用公钥验证签名
			 */
//			id<DataVerifier> verifier = CreateRSADataVerifier([[NSBundle mainBundle] objectForInfoDictionaryKey:@"RSA public key"]);
            id<DataVerifier> verifier = [[[RSADataVerifier alloc] initWithPublicKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"RSA public key"]] autorelease];
			if ([verifier verifyString:result.resultString withSign:result.signString]) {
                NSString *resultStr = NSLocalizedString(@"Prepaid Success!\nPlease check you account.Any question can be consulting us!", @"Prepaid Success!\nPlease check you account.Any question can be consulting us!");
                NotificationMessageManager *messageManager = [[[NotificationMessageManager alloc] init] autorelease];
                [messageManager GetNotificationMessages];
				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
																	 message:resultStr
																	delegate:nil
														   cancelButtonTitle:@"确定"
														   otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			}//验签错误
			else {
				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
																	 message:@"签名错误"
																	delegate:nil
														   cancelButtonTitle:@"确定"
														   otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			}
		}
		//如果支付失败,可以通过result.statusCode查询错误码
		else {
			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
																 message:result.statusMessage
																delegate:nil
													   cancelButtonTitle:@"确定"
													   otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}
		
	}
}

#pragma mark
#pragma mark Private Methods
- (void)sendRequestToCloudCall
{
    [self sendDefaultCloudCallRequest:kDefaultCloudCallUrl];
}

- (void)reloadAdsData
{
    [self LoadAdsData];
    [self loadSigninData];
    [self loadCallFeedBackData];
}

- (void)notificationUploadContact
{
    if ([[NgnEngine sharedInstance].contactService isLoading]) return;
    [self performSelector:@selector(uploadContacts2Server:) withObject:nil afterDelay:5];
}

/**
 *	@brief	检查通讯录是否有更新
 */
- (void)checkContactForUpload
{
    NgnContactMutableArray *_contacts = (NgnContactMutableArray*)[[NgnEngine sharedInstance].contactService contacts];
    NSMutableString *allContactMsg = [NSMutableString stringWithCapacity:50];       //用于生成md5值
    
    for (NgnContact* contact in _contacts) {
        if (!contact) continue;
        
        [allContactMsg appendString:contact.displayName];
        
        //号码
        for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers)
        {
			if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number)
            {
                NSString *number = [phoneNumber.number phoneNumFormat];
                
                //非数字号码,有可能是用户随便填写的,通过判断是否数字来决定,比如含有字母
                if (!IsPureNumber(number)) continue;
                
                [allContactMsg appendString:number];
			}
		}
    }
    
    NSString *newMd5String = [allContactMsg md5];
    NSString *oldMd5String = [[NgnEngine sharedInstance].configurationService getStringWithKey:GENERAL_CONTACT_MD5_STRING];
    
    CCLog(@"newMd5String : %@ oldMd5String : %@",newMd5String, oldMd5String);
    
    if (NSOrderedSame != [newMd5String compare:oldMd5String])
        [self uploadContacts2Server:NO];
    
}

/**
 *	@brief	创建各类必须的文件夹
 */
- (void)createDirectoryNecessary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *logDir = [self GetLogDirectoryPath];
    // 创建存放日志log文件夹
    if (![fileManager fileExistsAtPath:logDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:logDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建log文件夹失败");
        }
    }
    
    NSString *crashDir = GetCrashReportPath();
    // 创建存放日志crashDir文件夹
    if (![fileManager fileExistsAtPath:crashDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:crashDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建crashDir文件夹失败");
        }
    }
    
    // 创建存放cloudcall.cfg的文件夹
    NSString* cccfgdir = [self GetConfigDirectoryPath ];
    if (![fileManager fileExistsAtPath:cccfgdir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:cccfgdir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建存放cloudcall.cfg的文件夹失败");
        }
    }
    // 创建存放incall ads文件夹
    NSString *incallAdsDir = [self GetIncallAdsDirectoryPath];
    if (![fileManager fileExistsAtPath:incallAdsDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:incallAdsDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建incall ads文件夹失败");
        }
    }
    // 创建存放音质反馈广告文件夹
    NSString *callFeedBackDir = [self GetCallFeedBackDirectoryPath];
    if (![fileManager fileExistsAtPath:callFeedBackDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:callFeedBackDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建音质反馈广告文件夹失败");
        }
    }
    // 创建存放signin ads文件夹
    NSString *signinAdsDir = [self GetSigninAdsDirectoryPath];
    if (![fileManager fileExistsAtPath:signinAdsDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:signinAdsDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建signin ads文件夹失败");
        }
    }
    
    // 创建存放slotmachineAdsDir ads文件夹
    NSString *slotmachineAdsDir = [self GetSlotMachineImgDirectoryPath];
    if (![fileManager fileExistsAtPath:slotmachineAdsDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:slotmachineAdsDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建slotmachineAdsDir ads文件夹失败");
        }
    }
    
    // 创建存放CTBanner Ads文件夹
    NSString *ctbannerAdsPath = [self GetCTBannerAdsDirectoryPath];
    if (![fileManager fileExistsAtPath:ctbannerAdsPath isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:ctbannerAdsPath withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建CTBanner Ads文件夹失败");
        }
    }
    
    // 创建存放discoverItemsDir ads文件夹
    NSString *discoverItemsDir = [self GetDiscoverItemsDirDirectoryPath];
    if (![fileManager fileExistsAtPath:discoverItemsDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:discoverItemsDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建discoverItemsDir文件夹失败");
        }
    }
    
    //号码归属地数据库文件
    NSError *dbCopyError;
    NSString *areaOfPhoneNumberDBDirectoryPath = [self GetAreaOfPhoneNumberDBDirectoryPath];
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kAreaOfPhoneNumberDB];
    if (![fileManager fileExistsAtPath:areaOfPhoneNumberDBDirectoryPath]) {
        if(![fileManager copyItemAtPath:databasePathFromApp toPath:areaOfPhoneNumberDBDirectoryPath error:&dbCopyError]){
            CCLog(TAG, @"Failed to copy database to the file system: %@", dbCopyError);
        }
    }
    
    // 创建存放优惠券图片的文件夹
    NSString *couponDir = [self GetCouponImgDirectoryPath];
    if (![fileManager fileExistsAtPath:couponDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:couponDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建存放优惠券图片的文件夹失败");
        }
    }
    
    //创建存放IM缓存文件夹
    NSString *IMCachesDir = [self GetIMCachesDirectoryPath];
    if (![fileManager fileExistsAtPath:IMCachesDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:IMCachesDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建存放IM缓存文件夹失败");
        }
    }
}

/**
 *	@brief	用户连接上SIP服务器后执行的方法
 */
- (void)performSelectorAfterUserLogin
{
    [self createImserverInfoTable]; //创建IM服务器配置信息表
    [self initAddressOfImserver];   //初始化IM服务器地址并请求新地址
    [self createAllTable];          //创建个人IM数据库
    [self xmppConnect];             //连接IM服务器
}

/**
 *	@brief	创建IM服务器配置信息表
 */
- (void)createImserverInfoTable
{
    CCSqliteHelper *ccSqliteHelper = [[CCSqliteHelper alloc] init];
    [ccSqliteHelper createIMServerConfigInfoTable];
    [ccSqliteHelper release];
}

/**
 *	@brief	转换表情序号与表情文字
 *
 *	@param 	displayString 	展示的文字
 *
 *	@return	返回描述
 */
- (NSString *)exchangeFaceStringByDisplayString:(NSString *)displayString
{
    if ([NgnStringUtils isNullOrEmpty:displayString]) return @"";
    
    NSRange range_left = [displayString rangeOfString:@"["];
    NSRange range_right = [displayString rangeOfString:@"]" options:NSBackwardsSearch];
    
    if (range_left.length != NSNotFound && range_right.location != NSNotFound && range_right.location > range_left.location && range_right.location - range_left.location <= 6)
    {
        NSRange subRange = NSMakeRange(range_left.location + 1, range_right.location - 1);
        NSString *dictString = [displayString substringWithRange:subRange];
        
        NSDictionary *faceDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"000", @"色", @"001", @"惊恐", @"002", @"汗", @"003", @"委屈", @"004", @"坏笑", @"005", @"困", @"006", @"挑逗", @"007", @"快哭了", @"008", @"抓狂", @"009", @"叹气", @"010", @"吐舌", @"011", @"舒服", @"012", @"惊吓", @"013", @"闭嘴", @"014", @"发呆", @"015", @"鄙视", @"016", @"冷汗", @"017", @"歇菜", @"018", @"流泪", @"019", @"大笑", @"020", @"囧", @"021", @"害羞", @"022", @"哈哈", @"023", @"发怒", @"024", @"亲亲", @"025", @"飞吻", @"026", @"呲牙", @"027", @"微笑", @"028", @"开心", @"029", @"难过", @"030", @"生气", @"031", @"调皮", @"032", @"TMD", @"033", @"好棒", @"034", @"NO", @"035", @"拳头", @"036", @"胜利", @"037", @"STOP", @"038", @"心碎", @"039", @"爱心", @"040", @"玫瑰", @"041", @"便便", @"042", @"拜托", @"043", @"BYE", @"044", @"鼓掌", @"045", @"OK", @"046", @"逊", @"047", @"不要", @"048", @"钻戒", @"049", @"钻石", @"050", @"啤酒", @"051", @"猪头", @"052", @"亲爱的", @"053", @"礼物", @"054", @"枪毙", @"055", @"魔鬼", @"056", @"幽灵", @"057", @"鼾声", @"058", @"给力", @"059", @"左边", @"060", @"右边", @"061", @"炸弹", @"062", @"心跳", @"063", @"紫色心", @"064", @"星星", @"065", @"逃跑", @"066", @"汗水", @"067", @"问号", @"068", @"感叹号", @"069", @"米饭", @"070", @"面条", @"071", @"蛋糕", @"072", @"偷看", @"073", @"红唇", @"074", @"我爱你", @"075", @"双手", @"色", @"000", @"惊恐", @"001", @"汗", @"002", @"委屈", @"003", @"坏笑", @"004", @"困", @"005", @"挑逗", @"006", @"快哭了", @"007", @"抓狂", @"008", @"叹气", @"009", @"吐舌", @"010", @"舒服", @"011", @"惊吓", @"012", @"闭嘴", @"013", @"发呆", @"014", @"鄙视", @"015", @"冷汗", @"016", @"歇菜", @"017", @"流泪", @"018", @"大笑", @"019", @"囧", @"020", @"害羞", @"021", @"哈哈", @"022", @"发怒", @"023", @"亲亲", @"024", @"飞吻", @"025", @"呲牙", @"026", @"微笑", @"027", @"开心", @"028", @"难过", @"029", @"生气", @"030", @"调皮", @"031", @"TMD", @"032", @"好棒", @"033", @"NO", @"034", @"拳头", @"035", @"胜利", @"036", @"STOP", @"037", @"心碎", @"038", @"爱心", @"039", @"玫瑰", @"040", @"便便", @"041", @"拜托", @"042", @"BYE", @"043", @"鼓掌", @"044", @"OK", @"045", @"逊", @"046", @"不要", @"047", @"钻戒", @"048", @"钻石", @"049", @"啤酒", @"050", @"猪头", @"051", @"亲爱的", @"052", @"礼物", @"053", @"枪毙", @"054", @"魔鬼", @"055", @"幽灵", @"056", @"鼾声", @"057", @"给力", @"058", @"左边", @"059", @"右边", @"060", @"炸弹", @"061", @"心跳", @"062", @"紫色心", @"063", @"星星", @"064", @"逃跑", @"065", @"汗水", @"066", @"问号", @"067", @"感叹号", @"068", @"米饭", @"069", @"面条", @"070", @"蛋糕", @"071", @"偷看", @"072", @"红唇", @"073", @"我爱你", @"074", @"双手", @"075", nil];
        
        NSString *exchangeString = [faceDictionary objectForKey:dictString];
        
        if ([NgnStringUtils isNullOrEmpty:exchangeString])
            return displayString;
        else
            return [NSString stringWithFormat:@"[%@]", exchangeString];
    }
    
    return displayString;
}

/**
 *	@brief	初始化IM服务器配置
 */
- (void)initAddressOfImserver
{
    NSString *imserver_addr = [[NgnEngine sharedInstance].configurationService getStringWithKey:GENERAL_IMSERVER_ADDR];
    int imserver_port_http = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_IMSERVER_PORT_HTTP];
    int imserver_port = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_IMSERVER_PORT];
    
    if ([NgnStringUtils isNullOrEmpty:imserver_addr] || !imserver_port_http || !imserver_port)
    {
        [[NgnEngine sharedInstance].configurationService setStringWithKey:GENERAL_IMSERVER_ADDR andValue:kIMServer_Addr];
        [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_IMSERVER_PORT_HTTP andValue:kIMServer_Http_Port];
        [[NgnEngine sharedInstance].configurationService setIntWithKey:GENERAL_IMSERVER_PORT andValue:kIMServer_Port];
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:kGetImserverConfig forKey:@"reqType"];

    [[HttpRequest instance] addRequestWithEncrypt:kGetImserverConfigURL andMethod:@"POST" andContent:nil andTimeout:15
                         delegate:self successAction:@selector(receiveHttpResponse:andUserInfo:)
                        failureAction:@selector(requestHttpError:andUserInfo:) userInfo:userInfo];
    
}

#pragma mark - 
#pragma mark XMPP
- (void)xmppStreamReConnect:(NSTimer *)timer
{
    static int reConnectCount = 1; //大于32秒之后开始计算
    static int timerCount = 0;
    
    timerCount += (int)timer.timeInterval;
    
    if (timerCount == 4 || timerCount == 8 || timerCount == 16)
        [self xmppConnect];
    if (timerCount == (32*reConnectCount))
    {
        CCLog(@"reconnect %d times", reConnectCount+2);
        reConnectCount++;
        [self xmppConnect];
    }
}

- (void) setUpStream
{
    // 初始化
    xmppStream = [[XMPPStream alloc] init];
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    xmppStream.enableBackgroundingOnSocket = YES;
}

// 发送在线状态
- (void) goOnline
{
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
	[[self xmppStream] sendElement:presence];
}

// 发送下线状态
- (void) goOffline
{
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
	[presence addAttributeWithName:@"type" stringValue:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

- (void)xmppConnect
{
    NSString *userName = [self getUserName];
    NSString *passwd = [self getUserPassword];
    
    if ([userName isEqualToString:DEFAULT_IDENTITY_IMPI] || [passwd isEqualToString:DEFAULT_IDENTITY_PASSWORD])
    {
        CCLog(@"user didn't login, can't connect to xmpp");
        return;
    }
    
    if (![self.username isEqualToString:DEFAULT_IDENTITY_IMPI] || [self.username length] != 0)
    {
        NSString *imserver_addr = [[NgnEngine sharedInstance].configurationService getStringWithKey:GENERAL_IMSERVER_ADDR];
        int imserver_port = [[NgnEngine sharedInstance].configurationService getIntWithKey:GENERAL_IMSERVER_PORT];
        
        [self connectWithUSerName:userName passWord:passwd ipAddress:imserver_addr port:imserver_port];
    }
    
}

// 连接XMPP服务器
- (BOOL) connectWithUSerName:(NSString *)userName passWord:(NSString *)passWord ipAddress:(NSString *)ipAddress port:(ushort)usport
{
    //[MBProgressHUD showHUDAddedTo:self.window animated:YES];
    
    [self setUpStream];
    
    if (userName == nil || passWord == nil || ipAddress == nil)
    {
        return NO;
    }
    
    // 设置服务器地址和端口号
    [xmppStream setHostName:ipAddress];
    [xmppStream setHostPort:usport];
    [xmppStream setMyJID:[XMPPJID jidWithUser:userName deviceToken:[[NgnEngine sharedInstance].configurationService getStringWithKey:SECURITY_DEVICE_TOKEN] domain:ipAddress resource:[NgnSipStack platform]]];
//    password = passWord;
//    username = userName;
    
    // 连接服务器
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:15 error:&error])
    {
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:[NSString stringWithFormat:@"连接服务器%@失败", ipAddress]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"I know", @"I know"), nil];
        [alterView show];
        [alterView release];
        
        return NO;
    }
    
    return YES;
}

- (void) disConnect
{
    [self goOffline];
    [xmppStream disconnect];
}

- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
    CCLog(@"xmpp Stream Was Told To Disconnect");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    CCLog(@"xmpp Stream Did Disconnect  Error:%@", [error description]);
    NSString *myNum = [self getUserName];
    //在前台的的时候才启动定时器,进行重连
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground &&
        ![myNum isEqualToString:DEFAULT_IDENTITY_IMPI])
    {
        if (reConnectXmppTimer == nil)
        {
            reConnectXmppTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                              target:self
                                                            selector:@selector(xmppStreamReConnect:)
                                                            userInfo:nil
                                                             repeats:YES];
        }
    }
}

// 连接服务器成功，发送登录请求
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    //    isOpen = YES;
    NSError *error = nil;
    //验证密码
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        [MBProgressHUD hideHUDForView:self.window animated:YES];
    }
    
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    int unReadCount = [helper selectAllUnReadCountByReceiver:username];
    [self UnreadIMNum:unReadCount];
    [helper closeDatabase];
    [helper release];
    
    //登陆成功后停止xmpp重连定时器
    if (reConnectXmppTimer)
    {
        [reConnectXmppTimer invalidate];
        reConnectXmppTimer = nil;
    }
}

//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // 修改状态为上线
    [self goOnline];
    CCLog(@"登录IM成功");
    //[MBProgressHUD hideHUDForView:self.window animated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:@"userName"];
    [defaults setObject:password forKey:@"passWord"];
    [defaults synchronize];
}

- (NSString *)getMessageIdWithTimeAndUUID
{
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc] init];
    [dateformat setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *timeString = [dateformat stringFromDate:[NSDate date]];
    [dateformat release];
    
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    
    NSString *createMsgID = [NSString stringWithFormat:@"%@%@",timeString, result];
    
    return createMsgID;
}

// 收到iq消息
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    //  解析消息类型
    NSInteger fileType = FileType_Text;
    fileType = [[[iq elementForName:@"notification"] elementForName:@"fileType"] stringValueAsNSInteger];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        // 播放消息声音
        AudioServicesPlayAlertSound(soundID);
    }
    
    // 发送阅读消息请求
    NSString *serverMsgId = [[[iq elementForName:@"notification"] elementForName:@"id"] stringValue];
    [[IMWebInterface sharedInstance] sendReadChatMessageRequest:serverMsgId];
    
	CCLog(@"---------- xmppStream:didReceiveIQ: ----------");
    CCLog(@"%@", iq);
    
    NSString *message = [[[iq elementForName:@"notification"] elementForName:@"message"] stringValue];
    NSString *sendUser = [[[iq elementForName:@"notification"] elementForName:@"sender"] stringValue];
    NSString *receiver = [[[iq elementForName:@"notification"] elementForName:@"receiver"] stringValue];
    NSString *duration = [[[iq elementForName:@"notification"] elementForName:@"duration"] stringValue];
    NSInteger messageType = [[[iq elementForName:@"notification"] elementForName:@"type"] stringValueAsNSInteger];
    
    // 群组消息
    if (messageType == 3)
    {
        NSArray *seperateArray = [sendUser  componentsSeparatedByString:@"|"];
        sendUser = [seperateArray objectAtIndex:0];
    }
    
    unreadIM++;
    [self UnreadIMNum:unreadIM];
    
    NSDate *severDate = [NSDate dateWithTimeIntervalSince1970:[[[iq elementForName:@"notification"] elementForName:@"createTimestamp"] stringValueAsInt64]/1000];
    
    // Media资源完整URL
    NSString *serverFilePath = [NSString stringWithFormat:@"%@", [[[iq elementForName:@"notification"] elementForName:@"file"] stringValue]];       //2013-7-23 Young将相对URL改成完整地址
    
    NSString *orgFilePath = [NSString stringWithFormat:@"%@", [[[iq elementForName:@"notification"] elementForName:@"originalfile"] stringValue]];
    
    // 解析Media资源名字
    NSArray *nameSubArray = [[[[iq elementForName:@"notification"] elementForName:@"file"] stringValue] componentsSeparatedByString:@"/"];
    NSString *fileName = [nameSubArray lastObject];
        
    // 构建本地消息id
    NSString *localMessageId = [self getMessageIdWithTimeAndUUID];
    if (messageDelegate && [messageDelegate respondsToSelector:@selector(didReceiveNewMessage:sendUser:date:msgType:fileType:fileUrl:orgFileUrl:audioDuration:fileName:messageId:localMsgId:)])
    {
        [messageDelegate didReceiveNewMessage:message sendUser:sendUser date:severDate msgType:messageType fileType:fileType fileUrl:serverFilePath orgFileUrl:orgFilePath audioDuration:duration fileName:fileName messageId:serverMsgId localMsgId:localMessageId];
    }
    else if (messageDelegate == nil)
    {
        // 存入本地消息记录
        NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
        [messageDictionary setObject:localMessageId forKey:@"MessageId"];
        [messageDictionary setObject:sendUser forKey:@"Sender"];
        [messageDictionary setObject:receiver forKey:@"Receiver"];
        [messageDictionary setObject:message forKey:@"Message"];
        [messageDictionary setObject:[NSNumber numberWithInteger:messageType] forKey:@"MessageType"];
        [messageDictionary setObject:[NSNumber numberWithInteger:fileType] forKey:@"FileType"];
        [messageDictionary setObject:[NSNumber numberWithInteger:IMSendStatusSendSucc] forKey:@"SendStatus"];
        [messageDictionary setObject:serverMsgId forKey:@"ServerMsgId"];
        [messageDictionary setObject:[NSNumber numberWithInteger:0] forKey:KMessageHistoryTableColMsgReadStatus];
        
        // 图片
        if (fileType == FileType_Photo)
        {
            [messageDictionary setObject:serverFilePath forKey:@"MediaURL"];
            [messageDictionary setObject:orgFilePath forKey:@"OrgMediaURL"];
        }
        else if (fileType == FileType_Audio)
        {
            [messageDictionary setObject:[RecorderManager getPathByFileName:fileName ofType:@"spx"] forKey:@"MediaURL"];
            [messageDictionary setObject:serverFilePath forKey:@"OrgMediaURL"];
            [messageDictionary setObject:duration forKey:@"AudioDuration"];
            [messageDictionary setObject:[NSNumber numberWithInteger:1] forKey:KMessageHistoryTableColMsgReadStatus];
            
            //receive audio message need download
            [[IMDownLoadAudioFromServerModel sharedInstance] sendDownLoadAudioRequest:serverFilePath filePath:[RecorderManager getPathByFileName:fileName ofType:@"spx"] messgeId:localMessageId andAudioDuration:duration andSenderUser:sendUser andDate:severDate andPlay:NO];
        }
        else
        {
            [messageDictionary setObject:@"" forKey:@"MediaURL"];
            [messageDictionary setObject:@"" forKey:@"OrgMediaURL"];
        }
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        [messageDictionary setObject:[df stringFromDate:severDate] forKey:@"CreateTime"];
        [messageDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"Status"];
        [df release];
        
        SqliteHelper *helper = [[SqliteHelper alloc] init];
        [helper createDatabase];
        [helper insertDataToChatInfoTable:messageDictionary imageData:nil];
        [helper closeDatabase];
        [helper release];
        [messageDictionary release];
        
        // 推送消息(刷新通讯录界面)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMReceiveNewMessageNotification" object:nil];
    }
    
#if 1 // local notification
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        NSString* strContent = @"";
        if (fileType == FileType_Text)
        {
            strContent = message;
            
            NSRange range_left = [strContent rangeOfString:@"[0"];
            NSRange range_right = [strContent rangeOfString:@"]"];
            BOOL exchange = range_left.length != NSNotFound && range_right.location != NSNotFound && range_right.location - range_left.location == 4;
            
            while (exchange)
            {
                NSString *tmpFaceString = [strContent substringWithRange:NSMakeRange(range_left.location, range_right.location - range_left.location + 1)];
                NSString *tmpFaceNumber = [self exchangeFaceStringByDisplayString:tmpFaceString];
                NSRange replaceRange = NSMakeRange(range_left.location, tmpFaceString.length);
                strContent = [strContent stringByReplacingCharactersInRange:replaceRange withString:tmpFaceNumber];
                //判断是否需要继续替换
                if ((replaceRange.location + tmpFaceNumber.length) >= strContent.length) break;
                
                NSRange newRange = NSMakeRange(replaceRange.location + tmpFaceNumber.length, strContent.length - replaceRange.location - tmpFaceNumber.length);
                range_left = [strContent rangeOfString:@"[" options:NSCaseInsensitiveSearch range:newRange];
                range_right = [strContent rangeOfString:@"]" options:NSCaseInsensitiveSearch range:newRange];
                exchange = range_left.length != NSNotFound && range_right.location != NSNotFound && range_right.location - range_left.location == 4;
            }
        } else if (fileType == FileType_Photo) {
            strContent = NSLocalizedString(@"[Photo]", @"[Photo]");
        } else if (fileType == FileType_Audio) {
            strContent = NSLocalizedString(@"[Audio]", @"[Audio]");
        } else if (fileType == FileType_MedialURL) {
            strContent = NSLocalizedString(@"[Medial URL]", @"[Medial URL]");
        }
        
        UILocalNotification* localNotif = [[[UILocalNotification alloc] init] autorelease];
        NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:sendUser];
        NSString *displayName = sendUser;
        
        //判断联系人是否为空
        if (contact && contact != nil)
            displayName = contact.displayName;
        
        localNotif.alertBody = [NSString stringWithFormat:@"%@: %@", displayName, strContent];
        localNotif.soundName = @"myring.caf";
        localNotif.applicationIconBadgeNumber = ++[UIApplication sharedApplication].applicationIconBadgeNumber;
        localNotif.repeatInterval = 0;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: kNotifKey_IncomingMsg, kNotifKey, sendUser, kNotifKey_IncomingMsgNum, nil];
        localNotif.userInfo = userInfo;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    } else {
            [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
    }
#endif
    
	return YES;
}


// 登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    //[MBProgressHUD hideHUDForView:self.window animated:YES];
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"IM模块"
                                                        message:@"用户名或密码错误"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alterView show];
    [alterView release];
}

#pragma mark - 数据库部分
- (void) createAllTable
{
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    
    // 创建好友列表
    NSString *createTableSql1 = nil;
    createTableSql1 = [NSString stringWithFormat:@"create table if not exists %@ (ID integer primary key autoincrement, %@ text, %@ text, %@ text, %@ integer, %@ integer, %@ text)",
                       KFriendsTableName, KFriendsTableColNumber, KFriendsTableColLastTime, KFriendsTableColLastMsg, KFriendsTableColLastMsgType, KFriendsTableColLastFileType, KFriendsTableColMsgHisID];
    [helper createTable:createTableSql1];

    // 创建消息记录表
    NSString *createTableSql = nil;
    createTableSql = [NSString stringWithFormat:@"create table if not exists %@ (ID integer primary key autoincrement, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ integer, %@ BOLB, %@ integer, %@ integer, %@ text, %@ integer, %@ integer, %@ text, %@ integer)", KMessageHistoryTableName, KMessageHistoryTableColMsgId, KMessageHistoryTableColSender,
                      KMessageHistoryTableColReceiver, KMessageHistoryTableColMsg, KMessageHistoryTableColMediaURL, KMessageHistoryTableColOrgMediaURL, KMessageHistoryTableColAudioDuration, KMessageHistoryTableColImage, KMessageHistoryTableColMsgType,
                      KMessageHistoryTableColFileType, KMessageHistoryTableColCreateTime, KMessageHistoryTableColStatus, KMessageHistoryTableColSendStatus, KMessageHistoryTableColServerMsgId, KMessageHistoryTableColMsgReadStatus];
    [helper createTable:createTableSql];
    
    [helper closeDatabase];
    [helper release];
}

#pragma mark - BaiduMobAdViewDelegate
- (NSString *)publisherId
{
    return  kBaiduAppID;
}

- (NSString*) appSpec
{
    return kBaiduAppSpec;
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    [hud release];
}
@end
