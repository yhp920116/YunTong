/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@cloudcall.hk
 *       
 * This file is part of SkyBroad CloudCall Project
 *
 */
 
#ifndef WIPHONE_CONSTATNTS_H
#define WIPHONE_CONSTATNTS_H

/*#define SIPServerAddr     @"s1.cloudcall.hk"
#define SIPServerPort     @"9200"*/
#define ClientDisplayName @"CloudCall"

/* == Colors == */
#define kColorBlack				0x000000
#define kColorWhite				0xFFFFFF
#define kColorViolet			0x9900FF
#define kColorGray				0x736F6E
#define kColorBaloonOutTop		0xAFD662
#define kColorBaloonOutMiddle	0xBEDF7D
#define kColorBaloonOutBottom	0xD5E7B4
#define kColorBaloonOutBorder	0xC8E490
#define kColorBaloonInTop		0xDDDDDD
#define kColorBaloonInMiddle	0xD4D4D4
#define kColorBaloonInBottom	0xBEBEBE
#define kColorBaloonInBorder	0xBCBCBC

#define kColorsDarkBlack [NSArray arrayWithObjects: \
(id)[[UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7] CGColor], \
nil]
#define kColorsBlue [NSArray arrayWithObjects: \
(id)[[UIColor colorWithRed:.0f green:.0f blue:.5f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:0.f green:0.f blue:1.f alpha:0.7] CGColor], \
nil]
#define kColorsLightBlack [NSArray arrayWithObjects: \
(id)[[UIColor colorWithRed:.2f green:.2f blue:.2f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7] CGColor], \
nil]

#define kButtonStateAll (UIControlStateSelected | UIControlStateNormal | UIControlStateHighlighted | UIControlStateDisabled | UIControlStateApplication)


#define kCallTimerSuicide	1.5f

/* == Images for VideoCall Screen */
#define kImageVCMute	@"mute"
#define kImageVCMuteSel	@"muteSel"

#define kImageBaloonIn @"baloon_in"
#define kImageBaloonOut @"baloon_out"

enum {
    CallOptionInviteFriend,     //邀请好友成为云通用户
    CallOptionAddToContacts,    //增加到联系人
    CallOptionDialViaCellphone, //手机直拨
    CallOptionInnerCall,        //网内通话
    CallOptionLandCall,         //直拨
    CallOptionCallback,         //回拨
};


static BOOL IsPureNumber(NSString* string)
{
    NSScanner* scan = [NSScanner scannerWithString:string]; 
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}


// 正则判断手机号码地址格式
static BOOL IsMobileNumber(NSString *mobileNum) {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,183,187,188
     * 联通：130,131,132,145,152,155,156,185,186
     * 电信：133,134,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,183,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,145,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|45|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,134,153,180,189
     22         */
    NSString * CT = @"^1((33|34|53|8[09])[0-9])\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else 
    {
        return NO;
    }
}

class URI {
public:
    URI() { clear(); }
    
    bool parse(const char* contactHeader) {
        clear();
        if (!contactHeader || strlen(contactHeader) == 0)
            return false;
        
        //CCLog(@"contactHeader: %s", contactHeader);

        const char* strStart = 0;
        const char* strEnd = 0;
        
        strStart = strstr(contactHeader, "sip:");
        if (!strStart) 
            return false;
        
        strStart = contactHeader + strlen("sip:") + 1;
        
        strEnd = strstr(contactHeader, "@");
        if (!strEnd) 
            return false;
        
        strncpy(user, strStart, strEnd - strStart);
        //CCLog(@"user: '%s'", user);
        
        bool done = false;
        strStart = strEnd + 1;
        strEnd = strstr(strEnd, ":");
        if (!strEnd) {
            strEnd = strchr(contactHeader, ';');
            if (strEnd) {
                done = true;
            } else {
                strEnd = strchr(contactHeader, '>');
                if (strEnd)
                    done = true;
            }
        }
        
        strncpy(host, strStart, strEnd - strStart);
        //CCLog(@"host: '%s'", host);
        
        if (done) 
            return true;
        
        strStart = strEnd + 1;
        strEnd = strchr(strEnd, ';');
        if (!strEnd) {
            strEnd = strchr(contactHeader, '>');        
        }
        if (!strEnd) 
            return false;
        
        char strport[20];
        memset(strport, 0, sizeof(strport));
        strncpy(strport, strStart, strEnd - strStart);
        //CCLog(@"port: '%s'", strport);
        port = atoi(strport);
        
        return true;
    }

    char user[50];
    char host[50];
    unsigned short port;
private:
    void clear() {
        memset(user, 0, sizeof(user));
        memset(host, 0, sizeof(host));
        port = 0;
    }
};

#endif /* WIPHONE_CONSTATNTS_H */

