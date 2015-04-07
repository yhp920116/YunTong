//
//  ConferencingViewController.m
//  CloudCall
//
//  Created by CloudCall on 13-2-20.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import "ConferencingViewController.h"
#import "CloudCall2AppDelegate.h"
#import <CoreTelephony/CTCall.h>
#import "ConferenceGridViewCell.h"
#import "GMGridViewCell+Extended.h"
#import "MobClick.h"
#import "StaticUtils.h"

#undef TAG
#define kTAG @"ConferenceViewController///: "
#define TAG kTAG

#define UpdateMyNumStatusNotify @"UpdateMyNumStatus"
#define UpdateConfMemberStatusNotify @"UpdateConfMemberStatus"
#define StartConfSuccNotify @"StartConfSucc"
#define StartConfFailedNotify @"StartConfFailed"
#define StopConfResNotify @"StopConfRes"
#define ConfStopAlready @"ConfStopAlready"

#define MAX_PARTICIPANTS 10

#define Conf_Server_Addr @"conf.cloudcall.hk"
#define Conf_Server_Addr_2nd @"219.137.27.92"

/////////////////////////////////////////////////////////////////
unsigned int CurrentMsgVer = 101;

/*
 100	没有权限
 101	余额不足
 103	会议主持人不能被删除
 200	会议号不存在
 201	会议发起人号码已存在于其它会议中（一个号码不能同时创建多个会议）
 202	被删除号码不存在
 300	单个会议的成员数量超出限制
 301	超出系统会议容量（系统内，会议总数或者会议成员总数超出限制）
 400	未知错误
 */
enum {
    ERROR_SUCC = 0,
    ERROR_TIMEOUT = 10,
    ERROR_WITHOUT_PERMISSION = 100,
    ERROR_INSUFFICIENT_BALANCE = 101,
    ERROR_ORIGINATOR_NOT_ALLOWED_DELETE = 103,
    ERROR_INVALID_CONF_ID = 200,
    ERROR_ORIGINATOR_IN_OTHER_CONF = 201,
    ERROR_EXCEEDED_PARTICIPANT_LIMIT = 300,
    ERROR_EXCEEDED_SERVER_LIMIT = 301,
    ERROR_NO_GROUP_MEMBERS = 302,
    ERROR_PARTICIPANT_NOT_FOUND = 202,
    ERROR_UNKNOWN = 400
};

typedef struct _CONF_MSG_HEADER {
    unsigned int msgtype;
    unsigned int msgver;
    unsigned int msglen;
} CONF_MSG_HEADER;

typedef struct _CONF_MSG {
    CONF_MSG_HEADER header;
    char msgcontent[1]; // 不定长
} CONF_MSG;

typedef struct _CONF_START_REQ {
    unsigned int flag; // reserve
    char user[50];
    char pwd[50];
    char members[1]; // 不定长
} CONF_START_REQ;

/*flag - 0为成功，其它值为错误号
 */
typedef struct _CONF_START_RES {
    unsigned int  confnum;
    unsigned int flag;
} CONF_START_RES;

typedef struct _CONF_DEL_MEM_REQ {
    unsigned int confnum;
    char user[50];
    char pwd[50];
    char member[1]; // 不定长
} CONF_DEL_MEM_REQ;

/* 说明：
 confnum：会议ID；
 flag ：0为成功，其它值为错误号，当flag为0时，confnum为创建的会议ID
 */
typedef struct _CONF_DEL_MEM_RES {
    unsigned int confnum;
    unsigned int flag;
} CONF_DEL_MEM_RES;

/* 本消息只能包含一个增加的号码，最大长度20 */
typedef struct _CONF_ADD_MEM_REQ {
    unsigned int confnum;
    char user[50];
    char pwd[50];
    char member[1]; // 不定长
} CONF_ADD_MEM_REQ;

/* 说明：
 confnum：会议ID；
 flag ：0为成功，其它值为错误号，当flag为0时，confnum为创建的会议ID
 */
typedef struct _CONF_ADD_MEM_RES {
    unsigned int confnum;
    unsigned int flag;
} CONF_ADD_MEM_RES;

typedef struct _CONF_STOP_REQ {
    unsigned int confnum;
    char user[50];
    char pwd[50];
} CONF_STOP_REQ;

/* 说明：
 confnum：会议ID；
 flag ：0为成功，其它值为错误号，当flag为0时，confnum为创建的会议ID
 */
typedef struct _CONF_STOP_RES {
    unsigned int confnum;
    unsigned int flag;
} CONF_STOP_RES;

/*
 Server -> Client
 每次只能包含一个会议成员的状态
 */
typedef struct _CONF_MEM_STATUS {
    unsigned int confnum;
    char content[1]; // 不定长
} CONF_MEM_STATUS;

///////////////////////////////////////////////////////////////////////////////

@interface ConferencingViewController(Private)

// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.


- (BOOL) hideAlertvView;
- (void) hideAlertvViewTimeout:(NSString*)errPrompt;
- (void) showAlertvView:(NSString*)prompt andExpire:(int)time andFailPrompt:(NSString*)failPrompt;

- (void) changeViewkeysPosition;
- (void) AppWillEnterForeground;
@end

@implementation ConferencingViewController(Private)

-(void) UpdateConferenceCallButtonDisplay{
    switch (confStatus) {
        case CONF_STATUS_NONE:
            break;
        case CONF_STATUS_STOP:
//            [self back];
            break;
        case CONF_STATUS_STARTING:
        case CONF_STATUS_TALKING:

            break;
        default:
            break;
            
    }
}

-(BOOL) hideAlertvView {
    if (!alertShow) return NO;
    alertShow = NO;
    if (alertProcess) {
        [alertProcess dismissWithClickedButtonIndex:0 animated:NO];
    }
    return YES;
}

- (void) hideAlertvViewTimeout:(NSString*)errPrompt{
    if (confStatus == CONF_STATUS_STARTING) {
        confStatus = CONF_STATUS_NONE;
        [self UpdateConferenceCallButtonDisplay];
        
        if (_socket) {
            if (CFSocketIsValid(_socket)) {
                CFSocketInvalidate(_socket);
            }
            CFRelease(_socket);
            _socket = nil;
        }
    }
    
    if (NO == [self hideAlertvView]) return;
    
    if (errPrompt) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                    message: NSLocalizedString(errPrompt, errPrompt)
                                                   delegate: self
                                          cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
        a.tag = ERROR_TIMEOUT;
        [a show];
        [a release];
    }
}

- (void) showAlertvView:(NSString*)prompt andExpire:(int)time andFailPrompt:(NSString*)failPrompt {
    alertProcess = [[UIAlertView alloc] initWithTitle:prompt
                                              message:nil
                                             delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles: nil];
    [alertProcess show];
    alertShow = YES;
    
	// Create and add the activity indicator
	UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	aiv.center = CGPointMake(alertProcess.bounds.size.width / 2.0f, alertProcess.bounds.size.height - 40.0f);
	[aiv startAnimating];
	[alertProcess addSubview:aiv];
	[aiv release];
    
    [alertProcess release];
    
	// Auto dismiss after expire
	[self performSelector:@selector(hideAlertvViewTimeout:) withObject:failPrompt afterDelay:time];
}

- (void) changeViewkeysPosition {
    switch (cpcallstate) {
        case CellPhoneCallStateNone:
        case CellPhoneCallStateImcoming:
        case CellPhoneCallStateDialing:
            break;
        case CellPhoneCallStateDisconnected:{
            if (viewoffset) {
                CGRect rect = [UIScreen mainScreen].applicationFrame;
                CGFloat fWidth = rect.size.width;
                CGFloat fHeight = rect.size.height;
                
                CGRect newRect = CGRectMake(0, fHeight+viewoffset-viewKeysHeight, fWidth, viewKeysHeight);
                self.viewKeys.frame = newRect;
                
                viewoffset = 0;
            }
            
            break;
        }
        case CellPhoneCallStateConnected: {
            if (viewoffset == 0) {
                viewoffset = 20;
                
                CGRect rect = [UIScreen mainScreen].applicationFrame;
                CGFloat fWidth = rect.size.width;
                CGFloat fHeight = rect.size.height;
                
                CGRect newRect = CGRectMake(0, fHeight-viewoffset-viewKeysHeight, fWidth, viewKeysHeight);
                self.viewKeys.frame = newRect;
            }
            break;
        }
        default:
            break;
    }
    if (viewoffset) {
        CGRect rect = [UIScreen mainScreen].applicationFrame;
        CGFloat fWidth = rect.size.width;
        CGFloat fHeight = rect.size.height;
        
        CGRect newRect = CGRectMake(0, fHeight-viewoffset-viewKeysHeight, fWidth, viewKeysHeight);
        self.viewKeys.frame = newRect;
    }
}

- (void) AppWillEnterForeground {
    CCLog(@"AppWillEnterForeground: %f", viewoffset);
    [self changeViewkeysPosition];
}
//////////////////////

@end



@interface ConferencingViewController(Sip_And_Network_Callbacks)
-(void) onNetworkEvent:(NSNotification*)notification;

@end

@implementation ConferencingViewController(Sip_And_Network_Callbacks)

//== Network events == //
-(void) onNetworkEvent:(NSNotification*)notification {
	NgnNetworkEventArgs *eargs = [notification object];
	
	switch (eargs.eventType) {
		case NETWORK_EVENT_STATE_CHANGED:
		default: {
			NgnNSLog(TAG,@"NetworkEvent reachable=%@ networkType=%i",
					 [NgnEngine sharedInstance].networkService.reachable ? @"YES" : @"NO", [NgnEngine sharedInstance].networkService.networkType);
			
			if ([NgnEngine sharedInstance].networkService.reachable) {
				//BOOL onMobileNework = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
                
                if (_socket) {
                    if (CFSocketIsValid(_socket)) {
                        CFSocketInvalidate(_socket);
                    }
                    CFRelease(_socket);
                    _socket = nil;
                }
                
                if (confStatus != CONF_STATUS_NONE && confStatus != CONF_STATUS_STOP) {
                    confStatus = CONF_STATUS_NONE;
                    confId = 0;
                    mynumstatus = CONF_MEMBER_STATUS_NONE;
                    [self UpdateConferenceCallButtonDisplay];
                    for (ConferenceMember* c in self.participantsCall) {
                        c.status = CONF_MEMBER_STATUS_NONE;
                    }
                    [_gmGridView reloadData];
                    
                    UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                message: NSLocalizedString(@"Network connection is changed!", @"Network connection is changed!")
                                                               delegate: self
                                                      cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                    [a show];
                    [a release];
                }
                
			} else {
                //network unreachable
                
                if (_socket) {
                    if (CFSocketIsValid(_socket)) {
                        CFSocketInvalidate(_socket);
                    }
                    CFRelease(_socket);
                    _socket = nil;
                }
                
                if (confStatus != CONF_STATUS_NONE && confStatus != CONF_STATUS_STOP) {
                    confStatus = CONF_STATUS_NONE;
                    confId = 0;
                    mynumstatus = CONF_MEMBER_STATUS_NONE;
                    [self UpdateConferenceCallButtonDisplay];
                    for (ConferenceMember* c in self.participantsCall) {
                        c.status = CONF_MEMBER_STATUS_NONE;
                    }
                    [_gmGridView reloadData];
                    
                    UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                message: NSLocalizedString(@"Network connection is disconnected!", @"Network connection is disconnected!")
                                                               delegate: self
                                                      cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                    [a show];
                    [a release];
                }
            }
			
			break;
		}
	}
}
@end


@interface ConferencingViewController(ConfInterfaces)

- (void) Connect2ConfServer;
- (void) RecvFromConfServer;
- (void) StartConf;
- (void) StopConf;
- (void) AddConfMember:(NSString*)members;
- (void) DeleteConfMember:(NSString*)members;

@end

@implementation ConferencingViewController(ConfInterfaces)


static void ServerConnectCallBack (CFSocketRef socket, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void* info) {
    switch (callbackType) {
        case kCFSocketReadCallBack:
            break;
        case kCFSocketAcceptCallBack:
            break;
        case kCFSocketConnectCallBack:
            break;
        case kCFSocketDataCallBack:
            break;
        case kCFSocketWriteCallBack:
            break;
        default:
            break;
    }
    
    if (data) {
        CCLog(@"Connected"); // 服务器那边已经提过，连接事件时该指针用于存放报错
    } else {
        CCLog(@"Connect to conf server successfully");
        if (info) {
            ConferencingViewController* c = (ConferencingViewController*)info;
            if (c->confStatus == CONF_STATUS_NONE || c->confStatus == CONF_STATUS_STOP) {
                [c StartConf];
                
                [c performSelectorInBackground:@selector(RecvFromConfServer) withObject:nil];
            }
        }
    }
}

- (void) Connect2ConfServer {
    //////////////////////创建套接字//////////////
    CFSocketContext CTX = { 0, self, NULL, NULL, NULL };
    _socket = CFSocketCreate(kCFAllocatorDefault,
                             PF_INET,
                             SOCK_STREAM,
                             IPPROTO_TCP,
                             kCFSocketConnectCallBack, // 类型，表示连接时调用
                             ServerConnectCallBack,    // 调用的函数
                             &CTX);
    
    ////////////////////////////设置地址///////////////////
    const char *serverAddr = 0;
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    if (NO == appDelegate.useSecondConfServ) {
        struct hostent *host = gethostbyname([Conf_Server_Addr UTF8String]);
        if (!host) {
            herror("resolv");
            return;
        }
        struct in_addr **list = (struct in_addr **)host->h_addr_list;
        serverAddr = inet_ntoa(*list[0]);
    } else {
        NSString* s = Conf_Server_Addr_2nd;
        serverAddr = [s UTF8String];
    }
    CCLog(@"serverAddr: %s", serverAddr);
    struct sockaddr_in addr;
    memset(&addr , 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(Conf_Server_PORT);
    addr.sin_addr.s_addr = inet_addr(serverAddr);
    
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8*)&addr, sizeof(addr));
    
    /////////////////////////////执行连接/////////////////////
    CFSocketConnectToAddress(_socket, address, -1);
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();   // 获取当前运行循环
    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0); //定义循环对象
    CFRunLoopAddSource(cfrl, source, kCFRunLoopCommonModes); //将循环对象加入当前循环中
    CFRelease(source);
    CFRelease(address);
}

- (void)UpdateViewDisplay:(NSString*)s {
    [self updateTitleText];
    if ([s isEqualToString:UpdateMyNumStatusNotify]) {
        if (confStatus == CONF_STATUS_NONE) {
            [self UpdateConferenceCallButtonDisplay];
        }
    } else if ([s isEqualToString:UpdateConfMemberStatusNotify]) {
        [_gmGridView reloadData];
    } else if ([s isEqualToString:StartConfSuccNotify]) {
        [self hideAlertvView];
//        UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
//                                                    message: NSLocalizedString(@"Start conference successfully, a call will reach to your cellphone.", @"Start conference successfully, a call will reach to your cellphone.")
//                                                   delegate: self
//                                          cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
//        [a show];
//        [a release];
        
        [_gmGridView reloadData];
    } else if ([s isEqualToString:StartConfFailedNotify]) {
        [self hideAlertvView];
    } else if ([s isEqualToString:StopConfResNotify] || [s isEqualToString:ConfStopAlready]) {
        confStatus = CONF_STATUS_NONE;
        confId = 0;
        mynumstatus = CONF_MEMBER_STATUS_NONE;
        [self UpdateConferenceCallButtonDisplay];
        for (ConferenceMember* c in self.participantsCall) {
            c.status = CONF_MEMBER_STATUS_NONE;
        }
        
        [_gmGridView reloadData];
        
        if (_socket) {
            if (CFSocketIsValid(_socket)) {
                CFSocketInvalidate(_socket);
            }
            CFRelease(_socket);
            _socket = nil;
        }
    }
}

///////////////////监听来自服务器的信息///////////////////
- (void) RecvFromConfServer {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    BOOL running = YES;
    BOOL isReponse = NO;
    while (running && _socket && CFSocketIsValid(_socket)) {
        CONF_MSG_HEADER msgheader;
        memset(&msgheader, 0, sizeof(CONF_MSG_HEADER));
        int r = recv(CFSocketGetNative(_socket), &msgheader, sizeof(CONF_MSG_HEADER), 0);
        if (r <= 0) {
            CCLog(@"RecvFromConfServer: recv CONF_MSG_HEADER error %d\n", r);
            break;
        }
        msgheader.msgtype = ntohl(msgheader.msgtype);
        msgheader.msgver  = ntohl(msgheader.msgver);
        msgheader.msglen  = ntohl(msgheader.msglen);
        
        CCLog(@"RecvFromConfServer: recv msgtype=%d, msglen=%d\n", msgheader.msgtype, msgheader.msglen);
        
        if (msgheader.msgtype <= CONF_MSG_NONE || msgheader.msgtype >= CONF_MSG_MAX){
            CCLog(@"RecvFromConfServer: invalid msg type\n");
            break;
        }
        
        char* msgcontent = new char[msgheader.msglen+8];
        memset(msgcontent, 0, msgheader.msglen+8);
        r = recv(CFSocketGetNative(_socket), msgcontent, msgheader.msglen, 0);
        if (r <= 0) {
            CCLog(@"RecvFromConfServer: recv reponse error %d\n", r);
            
            delete []msgcontent;
            break;
        }
        [NgnStringUtils DecryptString:msgcontent andLength:msgheader.msglen];
        
        switch (msgheader.msgtype) {
            case CONF_MSG_START_RES : {
                CONF_START_RES* startRes = (CONF_START_RES*)msgcontent;
                startRes->confnum = ntohl(startRes->confnum);
                startRes->flag = ntohl(startRes->flag);
                
                BOOL succ = NO;
                NSString* errString = nil;
                switch (startRes->flag) {
                    case ERROR_SUCC :
                        succ = YES;
                        break;
                    case ERROR_WITHOUT_PERMISSION :
                        errString = NSLocalizedString(@"Without permission", @"Without permission");
                        break;
                    case ERROR_INSUFFICIENT_BALANCE :
                        errString = NSLocalizedString(@"Insufficient balance", @"Insufficient balance");
                        break;
                    case ERROR_ORIGINATOR_IN_OTHER_CONF :
                        errString = NSLocalizedString(@"The originator has joined in the other conference", @"The originator has joined in the other conference");
                        break;
                    case ERROR_EXCEEDED_PARTICIPANT_LIMIT : {
                        CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
                        errString = [NSString stringWithFormat:NSLocalizedString(@"Exceeded participant limit", @"Exceeded participant limit"), appDelegate.maxconfmembers];
                        break;
                    }
                    case ERROR_EXCEEDED_SERVER_LIMIT :
                        errString = NSLocalizedString(@"Exceeded server limit", @"Exceeded server limit");
                        break;
                    case ERROR_UNKNOWN :
                        errString = NSLocalizedString(@"Unknown error", @"Unknown error");
                        break;
                    case ERROR_NO_GROUP_MEMBERS:
                    {
                        errString = NSLocalizedString(@"No other participant", @"No other participant");
                        break;
                    }
                }
                
                CCLog(@"RecvFromConfServer: CONF_MSG_START_RES %@\n", succ ? @"Success" : @"Failed");
                if (succ) {
                    confStatus = CONF_STATUS_TALKING;
                    confId = startRes->confnum;
                    
                    mynumstatus = CONF_MEMBER_STATUS_CALLING;
                    for (ConferenceMember* c in self.participantsCall) {
                        c.status = CONF_MEMBER_STATUS_CALLING;
                    }
                } else {
                    confStatus = CONF_STATUS_NONE;
                    running = NO;
                    
                    mynumstatus = CONF_MEMBER_STATUS_NONE;
                    for (ConferenceMember* c in self.participantsCall) {
                        c.status = CONF_MEMBER_STATUS_NONE;
                    }
                    
                    if (errString) {
                        NSString* str = [NSString stringWithFormat:@"%@ (%d)", errString, startRes->flag];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                        message: str
                                                                       delegate: nil
                                                              cancelButtonTitle: nil
                                                              otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                        alert.tag = startRes->flag;
                        [alert show];
                        [alert release];
                    }
                }
                
                [self performSelectorOnMainThread:@selector(UpdateViewDisplay:) withObject: succ ? StartConfSuccNotify : StartConfFailedNotify waitUntilDone:YES];
                
                break;
            }
            case CONF_MSG_DEL_MEM_RES : {
                CONF_DEL_MEM_RES* deleteMemRes = (CONF_DEL_MEM_RES*)msgcontent;
                deleteMemRes->confnum = ntohl(deleteMemRes->confnum);
                deleteMemRes->flag = ntohl(deleteMemRes->flag);
                
                BOOL succ = NO;
                
                /*100	没有权限
                 103	会议主持人不能被删除
                 200	会议号不存在
                 202	被删除号码不存在
                 400	未知错误*/
                NSString* errString = nil;
                switch (deleteMemRes->flag) {
                    case ERROR_SUCC :
                        succ = YES;
                        break;
                    case ERROR_WITHOUT_PERMISSION :
                        errString = NSLocalizedString(@"Without permission", @"Without permission");
                        break;
                    case ERROR_INVALID_CONF_ID :
                        errString = NSLocalizedString(@"Invalid conference ID", @"Invalid conference ID");
                        break;
                    case ERROR_PARTICIPANT_NOT_FOUND :
                        errString = NSLocalizedString(@"The participant is not found in current conference", @"The participant is not found in current conference");
                        break;
                    case ERROR_UNKNOWN :
                        errString = NSLocalizedString(@"Unknown error", @"Unknown error");
                        break;
                }
                CCLog(@"RecvFromConfServer: CONF_MSG_DEL_MEM_RES %@\n", succ ? @"Success" : @"Failed");
                
                if (errString) {
                    NSString* str = [NSString stringWithFormat:@"%@ (%d)", errString, deleteMemRes->flag];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                    message: str
                                                                   delegate: nil
                                                          cancelButtonTitle: nil
                                                          otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                    [alert show];
                    [alert release];
                }
                
                break;
            }
            case CONF_MSG_ADD_MEM_RES : {
                CONF_ADD_MEM_RES* addMemRes = (CONF_ADD_MEM_RES*)msgcontent;
                addMemRes->confnum = ntohl(addMemRes->confnum);
                addMemRes->flag = ntohl(addMemRes->flag);
                
                BOOL succ = NO;
                if (addMemRes->flag != ERROR_SUCC)
                    participantsTalkingCount--;
                
                /*100	没有权限
                 200	会议号不存在
                 300	单个会议的成员数量超出限制
                 301	超出系统会议容量
                 400	未知错误*/
                NSString* errString = nil;
                switch (addMemRes->flag) {
                    case ERROR_SUCC :
                        succ = YES;
                        break;
                    case ERROR_WITHOUT_PERMISSION :
                        errString = NSLocalizedString(@"Without permission", @"Without permission");
                        break;
                    case ERROR_INVALID_CONF_ID :
                        errString = NSLocalizedString(@"Invalid conference ID", @"Invalid conference ID");
                        break;
                    case ERROR_EXCEEDED_PARTICIPANT_LIMIT :
                        errString = NSLocalizedString(@"Exceeded participant limit", @"Exceeded participant limit");
                        break;
                    case ERROR_EXCEEDED_SERVER_LIMIT :
                        errString = NSLocalizedString(@"Exceeded server limit", @"Exceeded server limit");
                        break;
                    case ERROR_UNKNOWN :
                        errString = NSLocalizedString(@"Unknown error", @"Unknown error");
                        break;
                }
                
                CCLog(@"RecvFromConfServer: CONF_MSG_ADD_MEM_RES %@\n", succ ? @"Success" : @"Failed");
                
                if (errString) {
                    NSString* str = [NSString stringWithFormat:@"%@ (%d)", errString, addMemRes->flag];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                    message: str
                                                                   delegate: nil
                                                          cancelButtonTitle: nil
                                                          otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                    [alert show];
                    [alert release];
                }
                
                break;
            }
            case CONF_MSG_STOP_RES : {
                CONF_STOP_RES* stopRes = (CONF_STOP_RES*)msgcontent;
                stopRes->confnum = ntohl(stopRes->confnum);
                stopRes->flag = ntohl(stopRes->flag);
                
                if (self->confId != stopRes->confnum) {
                    CCLog(@"RecvFromConfServer: recv reponse confid %d is NOT my confid %d\n", stopRes->confnum, self->confId);
                    return;
                }
                
                BOOL succ = (stopRes->flag == ERROR_SUCC);
                CCLog(@"RecvFromConfServer: CONF_MSG_STOP_RES %@\n", succ ? @"Success" : @"Failed");
                
                CCLog(@"CONF_MSG_STOP_RES\n");
                
                running = NO;
                [self performSelectorOnMainThread:@selector(UpdateViewDisplay:) withObject:StopConfResNotify waitUntilDone:YES];
                
                break;
            }
            case CONF_MSG_MEM_STATUS :{
                CONF_MEM_STATUS* memStatusMsg = (CONF_MEM_STATUS*)msgcontent;
                memStatusMsg->confnum = ntohl(memStatusMsg->confnum);
                
                CCLog(@"RecvFromConfServer: CONF_MSG_MEM_STATUS confid %d\n", memStatusMsg->confnum);
                
                if (self->confId != memStatusMsg->confnum) {
                    CCLog(@"RecvFromConfServer: recv CONF_MSG_MEM_STATUS confid %d is NOT my confid %d\n",memStatusMsg->confnum, self->confId);
                    break;
                }
                NSString* strData = [[NSString alloc] initWithUTF8String:memStatusMsg->content];
                
                NSArray *as = [strData componentsSeparatedByString:@":"];
                if (as && as.count == 2) {
                    NSString* number =    [as objectAtIndex:0];
                    NSString* strstatus = [as objectAtIndex:1];
                    number    = [number stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    strstatus = [strstatus stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    
                    CONF_MEMBER_STATUS status = (CONF_MEMBER_STATUS)[strstatus intValue];
                    
                    BOOL isMyNum = NO;
                    BOOL found = NO;
                    CCLog(@"CONF_MSG_MEM_STATUS: %@, %@", number, [ConferenceMember strConfMenberStatus:status]);
                    if ([[ConferenceMember strConfMenberStatus:status] isEqualToString:NSLocalizedString(@"Quit", @"Quit")])
                    {
                        participantsTalkingCount--;
                    }
                    
                    NSString* myNum = nil;//self->cellMyNum.labelNumber.text;
                    if ([myNum isEqualToString:number]) {
                        mynumstatus = status;
                        isMyNum = YES;
                        found = YES;
                    } else {
                        for (ConferenceMember* c in self.participantsCall) {
                            if ([c.participant.Number isEqualToString:number]) {
                                c.status = status;
                                found = YES;
                                break;
                            }
                        }
                    }
                    
                    if (found) {
                        [self performSelectorOnMainThread:@selector(UpdateViewDisplay:) withObject:isMyNum?UpdateMyNumStatusNotify:UpdateConfMemberStatusNotify waitUntilDone:YES];
                        
                        int iQuit = 0;
                        for (ConferenceMember* c in self.participantsCall) {
                            if (c.status == CONF_MEMBER_STATUS_QUIT || c.status == CONF_MEMBER_STATUS_NONE) {
                                iQuit++;
                            }
                        }
                        
                        if (iQuit == [self.participantsCall count]
                            && (mynumstatus == CONF_MEMBER_STATUS_QUIT || mynumstatus == CONF_MEMBER_STATUS_NONE)) {
                            [self StopConf];
                        }
                    }
                }
                else
                {
                    if (as)
                        CCLog(@"RecvFromConfServer:as.coutn= %d", as.count);
                    else
                        CCLog(@"as is nil");
                }
                [strData release];
                
                break;
            }
        }
        
        delete []msgcontent;
    }
    
    [self performSelectorOnMainThread:@selector(UpdateViewDisplay:) withObject:ConfStopAlready waitUntilDone:YES];
    
    [pool release];
    
    CCLog(@"RecvFromConfServer eixt");
}

/////////////////////////发送信息给服务器////////////////////////

- (void) StartConf {
    if (confStatus == CONF_STATUS_TALKING || confStatus == CONF_STATUS_STARTING)
        return;
    
    confStatus = CONF_STATUS_STARTING;
    
    if (_socket && CFSocketIsValid(_socket)) {
        NSString* strmembers = [[[NSString alloc] initWithString:mynum] autorelease];
        for (ConferenceMember* m in participantsCall) {
            strmembers = [strmembers stringByAppendingFormat:@"%@%@", [strmembers length] ? @"," : @"", m.participant.Number];
        }
        
        CCLog(@"StartConf header %ld, body len=%d", sizeof(CONF_MSG_HEADER), [strmembers length]);
        
        unsigned int msgboydlen = sizeof(CONF_START_REQ) + [strmembers length];
        
        unsigned int len = sizeof(CONF_MSG_HEADER) + msgboydlen;
        
        char* data = new char[len];
        memset(data, 0, len);
        
        CONF_MSG* msg = (CONF_MSG*)data;
        msg->header.msgtype = htonl(CONF_MSG_START);
        msg->header.msgver  = htonl(CurrentMsgVer);
        msg->header.msglen  = htonl(msgboydlen);
        
        CONF_START_REQ* startReq = (CONF_START_REQ*)msg->msgcontent;
        strcpy(startReq->user, [mynum cStringUsingEncoding:NSASCIIStringEncoding]);
        strcpy(startReq->pwd,  [mypwd cStringUsingEncoding:NSASCIIStringEncoding]);
        strcpy(startReq->members, [strmembers cStringUsingEncoding:NSASCIIStringEncoding]);
        
        [NgnStringUtils EncryptString:(char*)startReq andLength:msgboydlen];
        
        int r = send(CFSocketGetNative(_socket), data, len, 0);
        CCLog(@"StartConf r=%d", r);
        
        delete [] data;
    }
}

- (void) StopConf {
    if (confStatus != CONF_STATUS_TALKING)
        return;
    
    confStatus = CONF_STATUS_STOP;
    
    if (_socket && CFSocketIsValid(_socket) && confId) {
        unsigned int msgbodylen = sizeof(CONF_STOP_REQ);
        
        unsigned int len = sizeof(CONF_MSG_HEADER) + msgbodylen;
        char* data = new char[len];
        memset(data, 0, len);
        
        CONF_MSG* msg = (CONF_MSG*)data;
        msg->header.msgtype = htonl(CONF_MSG_STOP);
        msg->header.msgver  = htonl(CurrentMsgVer);
        msg->header.msglen  = htonl(msgbodylen);
        
        CONF_STOP_REQ* stopReq = (CONF_STOP_REQ*)msg->msgcontent;
        stopReq->confnum = htonl(confId);
        strcpy(stopReq->user, [mynum cStringUsingEncoding:NSASCIIStringEncoding]);
        strcpy(stopReq->pwd,  [mypwd cStringUsingEncoding:NSASCIIStringEncoding]);
        
        [NgnStringUtils EncryptString:(char*)stopReq andLength:msgbodylen];
        
        int r = send(CFSocketGetNative(_socket), data, len, 0);
        CCLog(@"StopConf r=%d", r);
        
        delete []data;
    }
}

- (void) AddConfMember:(NSString*)member {
    participantsTalkingCount++;
    if (confStatus != CONF_STATUS_TALKING) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                        message: NSLocalizedString(@"Can not add participant into a not talking conference.", @"Can not add participant into a not talking conference.")
                                                       delegate: self
                                              cancelButtonTitle: nil
                                              otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
        return;
    }
    
    if (_socket && CFSocketIsValid(_socket) && confId && (member && [member length])) {
        CCLog(@"AddConfMember: %@", member);
        
        unsigned int msgbodylen = sizeof(CONF_ADD_MEM_REQ) + [member length];
        
        unsigned int len = sizeof(CONF_MSG_HEADER) + msgbodylen;
        char* data = new char[len];
        memset(data, 0, len);
        
        CONF_MSG* msg = (CONF_MSG*)data;
        msg->header.msgtype = htonl(CONF_MSG_ADD_MEM);
        msg->header.msgver  = htonl(CurrentMsgVer);
        msg->header.msglen  = htonl(msgbodylen);
        
        CCLog(@"AddConfMember: msgtype=0x%x", msg->header.msgtype);
        
        CONF_ADD_MEM_REQ* addMemReq = (CONF_ADD_MEM_REQ*)msg->msgcontent;
        addMemReq->confnum = htonl(confId);
        strcpy(addMemReq->user, [mynum cStringUsingEncoding:NSASCIIStringEncoding]);
        strcpy(addMemReq->pwd, [mypwd cStringUsingEncoding:NSASCIIStringEncoding]);
        strcpy(addMemReq->member, [member cStringUsingEncoding:NSASCIIStringEncoding]);
        
        [NgnStringUtils EncryptString:(char*)addMemReq andLength:msgbodylen];
        
        int r = send(CFSocketGetNative(_socket), data, len, 0);
        CCLog(@"addconfmemb r=%d", r);
        
        delete []data;
    }
}

- (void) DeleteConfMember:(NSString*)member {
    if (confStatus != CONF_STATUS_TALKING) {
        return;
    }
    
    if (_socket && CFSocketIsValid(_socket) && confId && (member && [member length])) {
        CCLog(@"DeleteConfMember: %@", member);
        
        unsigned int msgbodylen = sizeof(CONF_DEL_MEM_REQ) + [member length];
        
        unsigned int len = sizeof(CONF_MSG_HEADER) + msgbodylen;
        char* data = new char[len];
        memset(data, 0, len);
        
        CONF_MSG* msg = (CONF_MSG*)data;
        msg->header.msgtype = htonl(CONF_MSG_DEL_MEM);
        msg->header.msgver  = htonl(CurrentMsgVer);
        msg->header.msglen  = htonl(msgbodylen);
        
        CONF_DEL_MEM_REQ* delMemReq = (CONF_DEL_MEM_REQ*)msg->msgcontent;
        delMemReq->confnum = htonl(confId);
        strcpy(delMemReq->user, [mynum cStringUsingEncoding:NSASCIIStringEncoding]);
        strcpy(delMemReq->pwd,  [mypwd cStringUsingEncoding:NSASCIIStringEncoding]);
        strcpy(delMemReq->member, [member cStringUsingEncoding:NSASCIIStringEncoding]);
        
        [NgnStringUtils EncryptString:(char*)delMemReq andLength:msgbodylen];
        
        int r = send(CFSocketGetNative(_socket), data, len, 0);
        CCLog(@"DeleteConfMember: %@, r=%d, %d", member, r, msg->header.msglen);
        
        delete []data;
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
@end

@implementation ConferencingViewController
@synthesize participantsCall;

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
    _socket = nil;
    confId = 0;
    confStatus = CONF_STATUS_NONE;
    mynumstatus = CONF_MEMBER_STATUS_NONE;
    
    viewKeysHeight = self.viewKeys.frame.size.height;
    callcenter = [[CTCallCenter alloc] init];
    callcenter.callEventHandler = ^(CTCall* call) {
        cpcallstate = CellPhoneCallStateNone;
        if (call.callState == CTCallStateDisconnected) {
            cpcallstate = CellPhoneCallStateDisconnected;
            CCLog(@"CTCallStateDisconnected: viewoffset %f, %f", viewoffset, viewKeysHeight);
        } else if (call.callState == CTCallStateDialing) {
            cpcallstate = CellPhoneCallStateDialing;
            CCLog(@"CTCallStateDialing: viewoffset %f", viewoffset);
        } else if (call.callState == CTCallStateConnected) {
            cpcallstate = CellPhoneCallStateConnected;
            CCLog(@"CTCallStateConnected: viewoffset %f", viewoffset);
        }
        if ([CloudCall2AppDelegate runInBackground] == NO) {
            [self performSelectorOnMainThread:@selector(changeViewkeysPosition) withObject: nil waitUntilDone:YES];
        }
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(AppWillEnterForeground) name:kAppWillEnterForegroundNotification object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkEvent:) name:kNgnNetworkEventArgs_Name object:nil];
    
    if (cmMyNumber == nil)
    {
        ParticipantInfo* pi = [[ParticipantInfo alloc] init];
        pi.Number = [[CloudCall2AppDelegate sharedInstance] getUserName];
        pi.Name = NSLocalizedString(@"My Number", @"My Number");
        cmMyNumber = [[ConferenceMember alloc] initWithParticipant:pi andStatus:CONF_MEMBER_STATUS_NONE];
        [pi release];
    }
    [participantsCall insertObject:cmMyNumber atIndex:0];
    [super viewDidLoad];
    if (SystemVersion >= 7.0)
    {
        _gmGridView.frame = CGRectMake(_gmGridView.frame.origin.x, _gmGridView.frame.origin.y + 20, _gmGridView.frame.size.width, _gmGridView.frame.size.height);
    }

    _gmGridView.sortingDelegate = nil;
    _gmGridView.actionDelegate = nil;
    
    self->barButtonItemBack.hidden = YES;
    self->barButtonItemMore.hidden = YES;
    buttonSelectedAll.hidden = YES;
    buttonSave.hidden = YES;
    
    [self.buttonCall setBackgroundImage:[UIImage imageNamed:@"conference_stop_normal.png"] forState:UIControlStateNormal];
    [self.buttonCall setBackgroundImage:[UIImage imageNamed:@"conference_stop_down.png"] forState:UIControlStateHighlighted];
    [buttonCall setTitle:NSLocalizedString(@"End GroupCall", @"End GroupCall") forState:UIControlStateNormal];
    [buttonCall removeTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttonCall addTarget:self action:@selector(buttonEndCallEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    participantsTalkingCount = [participantsCall count];
    
    [self showAlertvView:NSLocalizedString(@"Conference starting...", @"Conference starting...") andExpire:20 andFailPrompt:NSLocalizedString(@"Start conference failed, please try again later!", @"Start conference failed, please try again later!")];
    if (_socket && CFSocketIsValid(_socket)) {
        [self StartConf];
    } else {
        [self Connect2ConfServer];
    }
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"GroupCall_calling"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"GroupCall_calling"];
}

- (void)dealloc
{
    [participantsCall release];
    
    [super dealloc];
}

-(void)doneWithNumberPad {
    NSString *strNum = [self.txtFieldAdd text];
    do {
        if ([strNum length]) {
            if (![strNum cStringUsingEncoding:NSASCIIStringEncoding]) {
                NSString* strPrompt = NSLocalizedString(@"Invalid phone number", @"Invalid phone number");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                message: strPrompt
                                                               delegate: self
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                
                break;
            }
            
            if ([strNum isEqualToString:mynum]) {
                NSString* strPrompt = NSLocalizedString(@"This number already exist in conference.", @"This number already exist in conference.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                message: strPrompt
                                                               delegate: self
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                
                break;
            }
            
            for (int i=0; i<[participantsCall count]; i++) {
                ConferenceMember* cm = [participantsCall objectAtIndex:i];
                if ([cm.participant.Number isEqualToString:strNum]) {
//                    NSString* strPrompt = NSLocalizedString(@"This number already exist in conference.", @"This number already exist in conference.");
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
//                                                                    message: strPrompt
//                                                                   delegate: self
//                                                          cancelButtonTitle: nil
//                                                          otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
//                    [alert show];
//                    [alert release];
                    
                    break;
                }
            }
            

            ParticipantInfo* participant = [[ParticipantInfo alloc] init];
            NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber: strNum];
            participant.Number = strNum;
            if (contact && contact.displayName && [contact.displayName length]) {
                participant.Name = contact.displayName;
                participant.picture = contact.picture;
                
                for (NgnPhoneNumber* phoneNumber in contact.phoneNumbers) {
                    if (phoneNumber && phoneNumber.type == NgnPhoneNumberType_Number && phoneNumber.number) {
                        NSString* tmpPhoneNum = [phoneNumber.number phoneNumFormat];
                        
                        if ([tmpPhoneNum isEqualToString:strNum]) {
                            participant.Description = phoneNumber.description;
                            break;
                        }
                    }
                }
            } else {
                participant.Name = NSLocalizedString(@"No Name", @"No Name");
            }
            
            ConferenceMember* cm = [[ConferenceMember alloc] initWithParticipant:participant andStatus:CONF_MEMBER_STATUS_NONE];
            [participantsCall addObject:cm];
            [cm release];
            
            [participant release];
            
            [_gmGridView insertObjectAtIndex:[participantsCall count] - 1 withAnimation:(GMGridViewItemAnimation)(GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll)];
            
            self.txtFieldAdd.text = @"";
        }
    } while (0);
    
    if ([self.txtFieldAdd isFirstResponder])
        [self.txtFieldAdd resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonEndCallEvent:(id)sender
{
    if (confStatus == CONF_STATUS_TALKING) {
        [self StopConf];
    }
    [self back];
}

- (void)back
{
    [callcenter release];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateTitleText
{
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    NSString *tempTitleString = nil;
    tempTitleString = [NSString stringWithFormat:@"%@ (%d/%d)", conffavorite.name, participantsTalkingCount, appDelegate.maxconfmembers];
    if (participantsTalkingCount > appDelegate.maxconfmembers)
    {
        self.labelMaxconfMembers.hidden = NO;
        self.labelTitle.textColor = [UIColor redColor];
    }
    else
    {
        self.labelMaxconfMembers.hidden = YES;
        self.labelTitle.textColor = [UIColor whiteColor];
    }
    self.labelTitle.text = tempTitleString;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    [self updateTitleText];
    return participantsCall ? [participantsCall count] : 0;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        return CGSizeMake(145, 80);
    }
    else
    {
        return CGSizeMake(145, 80);
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //CCLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[[GMGridViewCell alloc] init] autorelease];
        cell.deleteButtonIcon = [UIImage imageNamed:@"delete_member.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        ConferenceGridViewCell *gridViewCell = [[ConferenceGridViewCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [gridViewCell SetDelegate:self];
        cell.contentView = gridViewCell;
        [gridViewCell release];
    }
    ConferenceGridViewCell *gridViewCell = (ConferenceGridViewCell*)cell.contentView;
    ConferenceMember *cm = [participantsCall objectAtIndex:index];
    if ([cm.participant.Number isEqualToString:mynum])
    {
        gridViewCell.selectedImage.hidden = YES;
        cell.deleteButton.hidden = YES;
    }
    else
    {
        gridViewCell.selectedImage.hidden = NO;
        cell.deleteButton.hidden = NO;
    }
    
    if ((cm.status == CONF_MEMBER_STATUS_QUIT || cm.status == CONF_MEMBER_STATUS_NONE) && confStatus == CONF_STATUS_TALKING) {
        gridViewCell.buttonIsAdd = YES;
        [gridViewCell.buttonAction setTitle:NSLocalizedString(@"Call", @"Call") forState:UIControlStateNormal];
        [gridViewCell.buttonAction setBackgroundImage:[UIImage imageNamed:@"conferenceCell_button_normal.png"] forState:UIControlStateNormal];
        [gridViewCell.buttonAction setBackgroundImage:[UIImage imageNamed:@"conferenceCell_button_normal.png"] forState:UIControlStateHighlighted];
    } else {
        gridViewCell.buttonIsAdd = NO;
        [gridViewCell.buttonAction setTitle:NSLocalizedString(@"Hangup", @"Hangup") forState:UIControlStateNormal];
        [gridViewCell.buttonAction setBackgroundImage:[UIImage imageNamed:@"decline_normal.png"] forState:UIControlStateNormal];
        [gridViewCell.buttonAction setBackgroundImage:[UIImage imageNamed:@"decline_press.png"] forState:UIControlStateHighlighted];
    }
    gridViewCell.callingStatus.hidden = NO;
    gridViewCell.selectedImage.hidden = YES;
    if (![cm.participant.Number isEqualToString:mynum])
    {
        gridViewCell.buttonAction.hidden = NO;
    }
    else
    {
        gridViewCell.buttonAction.hidden = YES;
    }
    
    gridViewCell.name.text = cm.participant.Name;
    gridViewCell.name.adjustsFontSizeToFitWidth = YES;
    gridViewCell.phoneNumber.text = cm.participant.Number;
    gridViewCell.number = cm.participant.Number;
    gridViewCell.callingStatus.text = [ConferenceMember strConfMenberStatus:cm.status];
    
    if ([cm.participant.Number isEqualToString:mynum])
    {
        gridViewCell.selectedImage.hidden = YES;
        cell.deleteButton.hidden = YES;
        
        //显示本机号码头像
        NgnContact* contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber: mynum];
        dispatch_queue_t queue = dispatch_queue_create (DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
        dispatch_async(queue, ^{
            if (contact && contact.picture != nil)
            {
                UIImage *avatarImage = [StaticUtils createRoundedRectImage:[UIImage imageWithData:contact.picture] size:CGSizeMake(80, 80)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    gridViewCell.headPortrait.image = avatarImage;
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    gridViewCell.headPortrait.image = [StaticUtils createRoundedRectImage:[UIImage imageNamed:@"contact_head.png"] size:CGSizeMake(80, 80)];
                });
            }
        });
        dispatch_release(queue);
    }
    else
    {
        dispatch_queue_t queue = dispatch_queue_create (DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
        dispatch_async(queue, ^{
            if ([cm.participant.picture bytes] != nil)
            {
                UIImage *avatarImage = [StaticUtils createRoundedRectImage:[UIImage imageWithData:cm.participant.picture] size:CGSizeMake(80, 80)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    gridViewCell.headPortrait.image = avatarImage;
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    gridViewCell.headPortrait.image = [StaticUtils createRoundedRectImage:[UIImage imageNamed:@"contact_head.png"] size:CGSizeMake(80, 80)];
                });
            }
        });
        dispatch_release(queue);
    }
    
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    
}

#pragma mark ConferenceGridViewCellDelegate

-(void) shouldContinueAfterParticipantCellClick:(NSString*)number andIsAdd:(BOOL)add {
    if (add) {
        
        if (confStatus == CONF_STATUS_TALKING) {
            CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
            if (participantsTalkingCount+1 > appDelegate.maxconfmembers) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                                message: NSLocalizedString(@"Reach the max participants limit!", @"Reach the max participants limit!")
                                                               delegate: self
                                                      cancelButtonTitle: nil
                                                      otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
                [alert show];
                [alert release];
                
                return;
            }
            
            [self AddConfMember:number];
            [self updateTitleText];
            
            for (ConferenceMember* cm in participantsCall) {
                if ([cm.participant.Number isEqualToString:number]) {
                    cm.status = CONF_MEMBER_STATUS_CALLING;
                    
                    [_gmGridView reloadData];
                    
                    break;
                }
            }
        }
    } else {
        if (confStatus == CONF_STATUS_STARTING) {
            UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                        message: NSLocalizedString(@"Can not delete participant when conference is starting, please try again later!", @"Can not delete participant when conference is starting, please try again later!")
                                                       delegate: self
                                              cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
            [a show];
            [a release];
            return;
        }
        
        for (ConferenceMember* cm in participantsCall) {
            if ([cm.participant.Number isEqualToString:number]) {
                
                NSString* num = [[[NSString alloc] initWithString:cm.participant.Number] autorelease];
                [self DeleteConfMember:num];
                
                [_gmGridView reloadData];
                
                break;
            }
        }
    }
}

#pragma mark ParticipantPickerDelegate
-(void) shouldContinueAfterPickingContacts: (NSMutableArray*) contacts{
    CCLog(@"shouldContinueAfterPickingContacts");
    for (int i=0; i<[contacts count]; i++) {
        ParticipantInfo* pi = [contacts objectAtIndex:i];
        
        if ([pi.Number isEqualToString:mynum]) {
            NSString* strPrompt = [NSString stringWithFormat:@"%@ %@", pi.Name, NSLocalizedString(@"already exist in conference.", @"already exist in conference.")];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                            message: strPrompt
                                                           delegate: self
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            
            continue;
        }
        
        BOOL found = NO;
        for (int i=0; i<[participantsCall count]; i++) {
            ConferenceMember* c = [participantsCall objectAtIndex:i];
            if ([c.participant.Number isEqualToString:pi.Number]) {
                found = YES;
                break;
            }
        }
        if (found) {
//            NSString* strPrompt = [NSString stringWithFormat:@"%@ %@", pi.Name, NSLocalizedString(@"already exist in conference.", @"already exist in conference.")];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
//                                                            message: strPrompt
//                                                           delegate: self
//                                                  cancelButtonTitle: nil
//                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
//            [alert show];
//            [alert release];
            
            continue;
        }
        
        ConferenceMember* cm = [[ConferenceMember alloc] initWithParticipant:pi andStatus:CONF_MEMBER_STATUS_NONE];
        [participantsCall addObject:cm];
        [cm release];
    }
    [_gmGridView reloadData];

}

#pragma mark ParticipantPickerFromGroupDelegate
-(void) shouldContinueAfterPickingFromGroup:(NSMutableArray *)contacts{
    CCLog(@"shouldContinueAfterPickingFromGroup");
    for (int i=0; i<[contacts count]; i++) {        
        ParticipantInfo* pi = [contacts objectAtIndex:i];
        
        if ([pi.Number isEqualToString:mynum]) {
            NSString* strPrompt = [NSString stringWithFormat:@"%@ %@", pi.Name, NSLocalizedString(@"already exist in conference.", @"already exist in conference.")];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
                                                            message: strPrompt
                                                           delegate: self
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            
            continue;
        }
        
        BOOL found = NO;
        for (int i=0; i<[participantsCall count]; i++) {
            ConferenceMember* c = [participantsCall objectAtIndex:i];
            if ([c.participant.Number isEqualToString:pi.Number]) {
                found = YES;
                break;
            }
        }
        if (found) {
//            NSString* strPrompt = [NSString stringWithFormat:@"%@ %@", pi.Name, NSLocalizedString(@"already exist in conference.", @"already exist in conference.")];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"GroupCall", @"GroupCall")
//                                                            message: strPrompt
//                                                           delegate: self
//                                                  cancelButtonTitle: nil
//                                                  otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
//            [alert show];
//            [alert release];
            
            continue;
        }
        
        ConferenceMember* cm = [[ConferenceMember alloc] initWithParticipant:pi andStatus:CONF_MEMBER_STATUS_NONE];
        [participantsCall addObject:cm];
        [cm release];
    }
    [_gmGridView reloadData];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)_alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (_alertView.tag) {
        case ERROR_INVALID_CONF_ID:
        case ERROR_ORIGINATOR_IN_OTHER_CONF:
        case ERROR_TIMEOUT:
            [self back];
            break;
        default:
            break;
    }
}

@end
