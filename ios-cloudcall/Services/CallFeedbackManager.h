//

#import <UIKit/UIKit.h>

@interface CallFeedbackData : NSObject {
    NSString *clgnum; // 主叫号码
    NSString *cldnum; // 被叫号码
    int duration; // 通话时长
    int type; //反馈方类型
    NSTimeInterval calltime; // 呼叫时间(输完号码，按下拨打键的时间)
    NSTimeInterval conntiontime; // 接通时间(对方接通，开始通话的时间)
    int calltype; //通话类型(直拨:1，好友之间的通话:2)
    NSString* nettype; // 网络类型(WIFI,3G,2G)
    int quality;	// 完全无法通话：1    一般：2   较好：3
    NSString* context; // 用户反馈的文本
}

@property(readonly, retain)  NSString *clgnum;
@property(readonly, retain)  NSString *cldnum;
@property(readonly)          int duration;
@property(readonly)          int type;
@property(readonly)          NSTimeInterval calltime;
@property(readonly)          NSTimeInterval conntiontime;
@property(readonly)          int calltype;
@property(readonly, retain)  NSString* nettype;
@property(readwrite)         int quality;
@property(nonatomic, retain) NSString* context;

-(CallFeedbackData*) initWithCallingNum:(NSString*)clgnum andCalledNum:(NSString*)cldnum andDuration:(int)duration andType:(int)type andCallTime:(NSTimeInterval)calltime andConnTime:(NSTimeInterval)conntiontime andCallType:(int)calltype andNetType:(NSString*)nettype;
@end


@interface CallFeedbackManager : NSObject {
    NSString*       mynum;
    NSTimer*        commitTimer;
    NSMutableDictionary* callfeedbacks;
    int committingnum;
}

-(void) start:(NSString*)mynum;
-(void) stop;

-(void) commit:(CallFeedbackData*)feedbackdata;

@end
