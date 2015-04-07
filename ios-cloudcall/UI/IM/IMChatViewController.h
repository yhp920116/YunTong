//
//  IMChatViewController.h

#import <UIKit/UIKit.h>
#import "CloudCall2AppDelegate.h"
#import "UIBubbleTableViewDelegate.h"
#import "RecorderManager.h"
#import "ChatRecorderView.h"
#import "NSBubbleData.h"
#import "FacialView.h"
#import "ToolsView.h"
#import "../MBProgressHUD.h"
#import "IMWebInterface.h"
#import "IMSelectImgViewController.h"
#import "../CMPopTipView.h"
#import "RecorderManager.h"
#import "PlayerManager.h"
#import "MPNotificationView.h"
#import "UIBubbleTableView.h"
#import "EGORefreshTableHeaderView.h"

#define kTagActionSheetTextMessage				1
#define kTagActionSheetVideoCall				2
#define kTagActionSheetAddToFavorites			3
#define kTagActionSheetChooseFavoriteMediaType	4
#define kTagActionSheetCallOut  				5
#define kTagAlertCallOutViaCellPhone            11
#define kTagActionSheetSelectImageSource		12
#define kTagActionSheetDelAMsg                  13
#define kTagActionSheetDelAllMsg                14

#define kPopTipViewHeight                       25

typedef enum
{
    LongPressManageTypeCopy = 21,
    LongPressManageTypeDel = 22,
    LongPressManageTypeDelAll = 23
}LongPressManageType;

@interface IMChatViewController : UIViewController <UIBubbleTableViewDelegate , UITextFieldDelegate,UITextViewDelegate, IMXMPPDelegate, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, facialViewDelegate, ToolsViewDelegate, IMSelectImgDelegate, CMPopTipViewDelegate, RecordingDelegate, PlayingDelegate, EGORefreshTableHeaderDelegate>
{
    
    UIButton *barButtonItemBack;
    
    UIImage *mineAvatar;
    UIImage *friendAvatar;
    
    // 底部视图
    UIView *accsoryView;
    
    // message
    UITextView *inputField;
    
    //表情按钮
    UIButton *emojiButton;
    
    //语音按钮
    UIButton *audioButton;

    // 展示聊天内容的UIBubble
    UIBubbleTableView *chatContentTable;
    
    // 存放气泡文字要展示的内容
    NSMutableArray *bubbleData;
    
    // 长按录音按钮
    UIButton *recordAudioButton;
    
    // 当前计数,初始为0
    CGFloat curCount;
    
    // 录音界面
    ChatRecorderView *recorderView;
            
    UIView *faceView;
    UIScrollView *scrollView1;
//    UIScrollView *scrollView2;
    UIPageControl *pageControl;
    
    UIButton *btnDefaultFace;
    UIButton *btnCloudCallFace;
    UIButton *btnSendMsg;
    
    UITextField *faceTextField;
    
    ToolsView *toolsView;
    UITextField *toolsField;
    
    BOOL isKeyBoardShow;
    
    NSMutableArray *calloption;
    NSString* dialNumber;
    BOOL videocallout;
    
    NSString *manageMsgID;
    NSString *manageMsg;
    NSString *serverMsgId;
    NSString *lastPlayAudioPath;
    
    CMPopTipView *popTipView;
    id currentPopTipViewSender;
    
    //语音播放动画
    NSBubbleData *clickBubbleDateView;
    NSMutableArray *playingAnimationArray;
    
    NSTimer *playAudioTimer;
    int playAudioCount;
    
    int initNumberOfMsg;
    int loadNumberOfMsg;
    BOOL isLoading;
    
    NSDictionary *faceDictionary;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
}
@property (nonatomic, retain) UIView *accsoryView;

// 录音的原始文件
@property (nonatomic, retain) UIImage *mineAvatar;
@property (nonatomic, retain) UIImage *friendAvatar;
@property (nonatomic, retain) NSBubbleData *clickBubbleDateView;
@property (nonatomic, retain) NSMutableArray *playingAnimationArray;

@property (copy, nonatomic) NSString *originWav;
@property (copy, nonatomic) NSString *recordFileName;
@property (copy, nonatomic) NSString *friendAccount;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, assign) BOOL isAddChat;
@property (retain, nonatomic) NSString *manageMsgID;
@property (retain, nonatomic) NSString *manageMsg;
@property (retain, nonatomic) NSString *serverMsgId;
@property (retain, nonatomic) NSString *lastPlayAudioPath;

@property (retain, nonatomic) id currentPopTipViewSender;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) int initNumberOfMsg;

@end
