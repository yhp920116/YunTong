//
//  IMChatViewController.m
//

#import "IMChatViewController.h"
#import "IMWebInterface.h"
#import "RecorderManager.h"
#import "PlayerManager.h"

#import "PersonalInfoNewViewController.h"
#import "IMDownLoadAudioFromServerModel.h"
#import "SqliteHelper.h"
#import "EGOCache.h"
#import "FacialView.h"
#import "StaticUtils.h"

#import "CloudCall2AppDelegate.h"

#import <QuartzCore/QuartzCore.h>

#import "CloudCall2Constants.h"

#define kNotificationImageViewSingleClick   @"kNotificationImageViewSingleClick"
#define kNotificationImageViewLongPress     @"kNotificationImageViewLongPress"
#define kNotificationBtnResendMsgEvent      @"kNotificationBtnResendMsgEvent"
#define kSendMsgSuccessfulNotification      @"SendMsgSuccessfulNotification"
#define kSendMsgFailureNotification         @"SendMsgFailureNotification"

//@interface IMChatViewController ()
//
//@end

#define Button_Default_Face_Tag 1011
#define Button_CC_Face_Tag      1012
#define Button_Send_Tag         1013

@implementation IMChatViewController

@synthesize mineAvatar;
@synthesize friendAvatar;

@synthesize accsoryView;
@synthesize originWav;
@synthesize recordFileName;
@synthesize isGroup;
@synthesize isAddChat;
@synthesize friendAccount;
@synthesize manageMsgID;
@synthesize manageMsg;
@synthesize serverMsgId;
@synthesize lastPlayAudioPath;

@synthesize currentPopTipViewSender;

@synthesize clickBubbleDateView;
@synthesize playingAnimationArray;

@synthesize isPlaying;
@synthesize initNumberOfMsg;

#pragma mark
#pragma mark View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    calloption = [[NSMutableArray alloc] init];
    self.playingAnimationArray = [NSMutableArray arrayWithCapacity:10];
    
    if (initNumberOfMsg > 50)
        initNumberOfMsg = 50;
    else if(initNumberOfMsg == 0 || initNumberOfMsg < 12)
        initNumberOfMsg = 12;
    
    loadNumberOfMsg = initNumberOfMsg;
    
    if (iPhone5)
        self.view.frame = CGRectMake(0, 0, 320, 504);
    else
        self.view.frame = CGRectMake(0, 0, 320, 416);
    
    
    NgnContact *receiverContact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:friendAccount];
    //标题
    if (receiverContact && receiverContact.displayName)
        self.title = [NSString stringWithFormat:@"%@", receiverContact.displayName];
    else
        self.title = friendAccount;
    //对方头像
    self.friendAvatar = [StaticUtils createRoundedRectImage:(receiverContact.picture ? [UIImage imageWithData:receiverContact.picture] : [UIImage imageNamed:@"contact_noavatar_icon"]) size:CGSizeMake(80, 80)];
        
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];  
    NgnContact *senderContact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:mynum];
    //自己头像
    self.mineAvatar = [StaticUtils createRoundedRectImage:(senderContact.picture ? [UIImage imageWithData:senderContact.picture] : [UIImage imageNamed:@"contact_noavatar_icon"]) size:CGSizeMake(80, 80)];
    
    // 存放聊天内容的数据
    bubbleData = [[NSMutableArray alloc] init];
    
    faceDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"000", @"色", @"001", @"惊恐", @"002", @"汗", @"003", @"委屈", @"004", @"坏笑", @"005", @"困", @"006", @"挑逗", @"007", @"快哭了", @"008", @"抓狂", @"009", @"叹气", @"010", @"吐舌", @"011", @"舒服", @"012", @"惊吓", @"013", @"闭嘴", @"014", @"发呆", @"015", @"鄙视", @"016", @"冷汗", @"017", @"歇菜", @"018", @"流泪", @"019", @"大笑", @"020", @"囧", @"021", @"害羞", @"022", @"哈哈", @"023", @"发怒", @"024", @"亲亲", @"025", @"飞吻", @"026", @"呲牙", @"027", @"微笑", @"028", @"开心", @"029", @"难过", @"030", @"生气", @"031", @"调皮", @"032", @"TMD", @"033", @"好棒", @"034", @"NO", @"035", @"拳头", @"036", @"胜利", @"037", @"STOP", @"038", @"心碎", @"039", @"爱心", @"040", @"玫瑰", @"041", @"便便", @"042", @"拜托", @"043", @"BYE", @"044", @"鼓掌", @"045", @"OK", @"046", @"逊", @"047", @"不要", @"048", @"钻戒", @"049", @"钻石", @"050", @"啤酒", @"051", @"猪头", @"052", @"亲爱的", @"053", @"礼物", @"054", @"枪毙", @"055", @"魔鬼", @"056", @"幽灵", @"057", @"鼾声", @"058", @"给力", @"059", @"左边", @"060", @"右边", @"061", @"炸弹", @"062", @"心跳", @"063", @"紫色心", @"064", @"星星", @"065", @"逃跑", @"066", @"汗水", @"067", @"问号", @"068", @"感叹号", @"069", @"米饭", @"070", @"面条", @"071", @"蛋糕", @"072", @"偷看", @"073", @"红唇", @"074", @"我爱你", @"075", @"双手", @"色", @"000", @"惊恐", @"001", @"汗", @"002", @"委屈", @"003", @"坏笑", @"004", @"困", @"005", @"挑逗", @"006", @"快哭了", @"007", @"抓狂", @"008", @"叹气", @"009", @"吐舌", @"010", @"舒服", @"011", @"惊吓", @"012", @"闭嘴", @"013", @"发呆", @"014", @"鄙视", @"015", @"冷汗", @"016", @"歇菜", @"017", @"流泪", @"018", @"大笑", @"019", @"囧", @"020", @"害羞", @"021", @"哈哈", @"022", @"发怒", @"023", @"亲亲", @"024", @"飞吻", @"025", @"呲牙", @"026", @"微笑", @"027", @"开心", @"028", @"难过", @"029", @"生气", @"030", @"调皮", @"031", @"TMD", @"032", @"好棒", @"033", @"NO", @"034", @"拳头", @"035", @"胜利", @"036", @"STOP", @"037", @"心碎", @"038", @"爱心", @"039", @"玫瑰", @"040", @"便便", @"041", @"拜托", @"042", @"BYE", @"043", @"鼓掌", @"044", @"OK", @"045", @"逊", @"046", @"不要", @"047", @"钻戒", @"048", @"钻石", @"049", @"啤酒", @"050", @"猪头", @"051", @"亲爱的", @"052", @"礼物", @"053", @"枪毙", @"054", @"魔鬼", @"055", @"幽灵", @"056", @"鼾声", @"057", @"给力", @"058", @"左边", @"059", @"右边", @"060", @"炸弹", @"061", @"心跳", @"062", @"紫色心", @"063", @"星星", @"064", @"逃跑", @"065", @"汗水", @"066", @"问号", @"067", @"感叹号", @"068", @"米饭", @"069", @"面条", @"070", @"蛋糕", @"071", @"偷看", @"072", @"红唇", @"073", @"我爱你", @"074", @"双手", @"075", nil];

    self->barButtonItemBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self->barButtonItemBack.frame = CGRectMake(0, 0, 44, 44);
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [self->barButtonItemBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [self->barButtonItemBack addTarget:self action:@selector(onButtonToolBarItemClick:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self->barButtonItemBack] autorelease];
    
    UIButton *btnContactDetail = [UIButton buttonWithType:UIButtonTypeCustom];
    btnContactDetail.frame = CGRectMake(0, 0, 44, 44);
    [btnContactDetail setImage:[UIImage imageNamed:@"btn_imcondetail_down.png"] forState:UIControlStateNormal];
    [btnContactDetail setImage:[UIImage imageNamed:@"btn_imcondetail_up.png"] forState:UIControlStateHighlighted];
    [btnContactDetail addTarget:self action:@selector(goToContactDetail) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btnContactDetail] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageHasLoaded:) name:@"ImageLoadedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wavHasBeenReady:) name:@"wavMediaIsReadyNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onImageViewSingleClick:) name:kNotificationImageViewSingleClick object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onImageViewLongPress:) name:kNotificationImageViewLongPress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBtnResendMsgEvent:) name:kNotificationBtnResendMsgEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateMsgSendStatus) name:kSendMsgSuccessfulNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateMsgSendStatus) name:kSendMsgFailureNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAvatarClick:) name:@"onAvatarClick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactEvent:) name:kNgnContactEventArgs_Name object:nil];
    
    //加载聊天数据
    [self loadMsgHistoryData];
    
    // 展示聊天内容的气泡Table
    chatContentTable = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
    chatContentTable.bubbleDataDelegate = self;
    
    
    // 分组条件为间隔60秒
    chatContentTable.snapInterval = 60;
    
    // 允许显示头像
    chatContentTable.showAvatars = YES;
    [self.view addSubview:chatContentTable];
    
    
    //初始化表情页
    [self initFaceView];

    accsoryView = [[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, 320, 44)] autorelease];
    accsoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"im_toolbar_bg.png"]];
    
    inputField = [[UITextView alloc] initWithFrame:CGRectMake(45, 6, 190, 32)];
    inputField.returnKeyType = UIReturnKeySend;
    inputField.layer.cornerRadius = 6;
    inputField.layer.masksToBounds = YES;
    inputField.delegate = self;
    inputField.font = [UIFont systemFontOfSize:16.0f];
    inputField.backgroundColor = [UIColor whiteColor];
    inputField.scrollEnabled = YES;
    inputField.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    [accsoryView addSubview:inputField];
    [inputField release];
    
    recordAudioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordAudioButton.frame = CGRectMake(37, 2, 206, 41);
    [recordAudioButton setBackgroundImage:[UIImage imageNamed:@"im_recordAudioButton_up.png"] forState:UIControlStateNormal];
    [recordAudioButton setBackgroundImage:[UIImage imageNamed:@"im_recordAudioButton_down.png"] forState:UIControlStateHighlighted];
    [recordAudioButton addTarget:self action:@selector(recordAudioDown:) forControlEvents:UIControlEventTouchDown];
    [recordAudioButton addTarget:self action:@selector(recordAudioUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [recordAudioButton addTarget:self action:@selector(recordAudioUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [recordAudioButton addTarget:self action:@selector(recordAudioDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [recordAudioButton addTarget:self action:@selector(recordAudioDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [recordAudioButton addTarget:self action:@selector(recordAudioCancel:) forControlEvents:UIControlEventTouchCancel];
    [recordAudioButton setTitle:NSLocalizedString(@"Hold to Talk", @"Hold to Talk") forState:UIControlStateNormal];
    [[recordAudioButton titleLabel] setFont:[UIFont systemFontOfSize:17.0f]];
    [recordAudioButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [recordAudioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [accsoryView addSubview:recordAudioButton];
    
    recordAudioButton.hidden = YES;
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(275, 4, 43, 38);
    [moreButton setImage:[UIImage imageNamed:@"btn_immore_up.png"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"btn_immore_down.png"] forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(chosePicture) forControlEvents:UIControlEventTouchUpInside];
    [accsoryView addSubview:moreButton];
    
    faceTextField = [[UITextField alloc] initWithFrame:CGRectMake(-50, 0, 2, 2)];
    faceTextField.delegate = self;
    faceTextField.borderStyle = UITextBorderStyleLine;
    faceTextField.backgroundColor = [UIColor whiteColor];
    faceTextField.inputView = faceView;
    [accsoryView addSubview:faceTextField];
    [faceTextField release];
    
    //工具页面
    toolsView = [[ToolsView alloc] initWithFrame:CGRectMake(0, 0, 320, 81)];
    [toolsView loadToolsView];
    toolsView.delegate = self;
    
    //工具页面调出的textfield,实际上是看不到的,只是为了弹出工具页面而已
    toolsField = [[UITextField alloc] initWithFrame:CGRectMake(-50, 0, 2, 2)];
    toolsField.delegate = self;
    toolsField.borderStyle = UITextBorderStyleLine;
    toolsField.backgroundColor = [UIColor whiteColor];
    toolsField.inputView = toolsView;
    [accsoryView addSubview:toolsField];
    [toolsField release];
    
    emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    emojiButton.frame = CGRectMake(240, 5, 35, 35);
    [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_up.png"] forState:UIControlStateNormal];
    [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_down.png"] forState:UIControlStateHighlighted];
    [emojiButton addTarget:self action:@selector(choseEmoji) forControlEvents:UIControlEventTouchUpInside];
    [accsoryView addSubview:emojiButton];
    
    audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    audioButton.frame = CGRectMake(5, 5, 35, 35);
    [audioButton setBackgroundImage:[UIImage imageNamed:@"audio_up.png"] forState:UIControlStateNormal];
    [audioButton setBackgroundImage:[UIImage imageNamed:@"audio_down.png"] forState:UIControlStateHighlighted];
    [audioButton addTarget:self action:@selector(audioButtonAction:) forControlEvents:UIControlEventTouchDown];
    [accsoryView addSubview:audioButton];
    
    [self.view addSubview:accsoryView];
    
    isLoading = NO;
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - chatContentTable.bounds.size.height, self.view.frame.size.width, chatContentTable.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [self->chatContentTable addSubview:_refreshHeaderView];
    // update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden: NO];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [(CloudCall2AppDelegate *)[[UIApplication sharedApplication] delegate] setMessageDelegate:self];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [(CloudCall2AppDelegate*)[[UIApplication sharedApplication] delegate] setMessageDelegate:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [mineAvatar release];
    [friendAvatar release];
    [clickBubbleDateView release];
    [lastPlayAudioPath release];
    
    [originWav release];
    
    [faceView release];
    [toolsView release];
    
    if (calloption) {
        [calloption release];
        calloption = nil;
    }
    
    if (faceDictionary) {
        [faceDictionary release];
        faceDictionary = nil;
    }
    
    if (dialNumber)
    {
        [dialNumber release];
        dialNumber = nil;
    }
    
    if (manageMsgID) {
        [manageMsgID release];
        manageMsgID = nil;
    }
    if (manageMsg) {
        [manageMsg release];
        manageMsg = nil;
    }
    if (serverMsgId) {
        [serverMsgId release];
        serverMsgId = nil;
    }
    if (recorderView != nil)
    {
        recorderView = nil;
    }
    if(currentPopTipViewSender)
    {
    	[currentPopTipViewSender release];
    	currentPopTipViewSender = nil;
    }
    
    if (_refreshHeaderView) {
        [_refreshHeaderView removeFromSuperview];
    }
    
    [super dealloc];
    
}

#pragma mark
#pragma mark Private Methods
- (void)loadMsgHistoryData
{
    if (isLoading) return;
    
    isLoading = YES;
    
    // 读取历史聊天记录
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    NSMutableArray *dataArray = [helper selectMessageRecordFromUser:friendAccount andRccordNumber:loadNumberOfMsg];
    [helper updateUnReadMsgByUserId:friendAccount];
    [helper closeDatabase];
    [helper release];
    
    //已读消息,刷新消息列表页面
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"IMReceiveNewMessageNotification" object:nil];
    // 构建界面
    for (IMMsgHistory *imMsg in dataArray)
    {
        // 自己发送的
        if ([imMsg.Receiver isEqualToString:friendAccount])
        {
            NSBubbleData *mineBubble = nil;
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            // 如果是图片
            if (imMsg.FileType == FileType_Photo)
            {
                mineBubble = [NSBubbleData dataWithImage:[[EGOCache currentCache] imageForKey:imMsg.MessageId] date:[df dateFromString:imMsg.CreateTime] type:BubbleTypeMine];
                mineBubble.fileType = FileType_Photo;
            }
            // 如果是语音
            else if (imMsg.FileType == FileType_Audio)
            {
                mineBubble = [NSBubbleData dataWithAudioPath:imMsg.MediaURL audioTimeLength:imMsg.AudioDuration date:[df dateFromString:imMsg.CreateTime] type:BubbleTypeMine];
                mineBubble.fileType = FileType_Audio;
            }
            //   文字信息
            else if (imMsg.FileType == FileType_Text)
            {
                mineBubble = [NSBubbleData dataWithText:imMsg.Message date:[df dateFromString:imMsg.CreateTime] type:BubbleTypeMine];
                mineBubble.fileType = FileType_Text;
            }
            [df release];

            mineBubble.dataID = imMsg.MessageId;
            mineBubble.avatar = self.mineAvatar;
            [bubbleData addObject:mineBubble];
        }
        else
        {
            NSBubbleData *mineBubble = nil;
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            // 如果是图片
            if (imMsg.FileType == FileType_Photo)
            {
                mineBubble = [NSBubbleData dataWithImage:nil pictureUrl:imMsg.MediaURL date:[df dateFromString:imMsg.CreateTime] type:BubbleTypeSomeoneElse];
                mineBubble.fileType = FileType_Photo;
            }
            // 如果是语音
            else if (imMsg.FileType == FileType_Audio)
            {
                mineBubble = [NSBubbleData dataWithAudioPath:imMsg.MediaURL audioTimeLength:imMsg.AudioDuration date:[df dateFromString:imMsg.CreateTime] type:BubbleTypeSomeoneElse];
                mineBubble.fileType = FileType_Audio;
            }
            //   文字信息
            else if (imMsg.FileType == FileType_Text)
            {
                mineBubble = [NSBubbleData dataWithText:imMsg.Message date:[df dateFromString:imMsg.CreateTime] type:BubbleTypeSomeoneElse];
                mineBubble.fileType = FileType_Text;
            }
            [df release];
            mineBubble.dataID = imMsg.MessageId;
            mineBubble.avatar = self.friendAvatar;
            [bubbleData addObject:mineBubble];
            
        }
    }
}

- (void)initFaceView
{
    faceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    faceView.backgroundColor = [UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1];
    
    //默认表情页
    scrollView1 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 170)];
    scrollView1.delegate = self;
    scrollView1.backgroundColor = [UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1];
    for (int i=0; i < 6; i++)
    {
        FacialView *fview = [[FacialView alloc] initWithFrame:CGRectMake(2.5 * i + 317.5 * i, 0, 315, 144)];
        [fview loadFacialView:i size:CGSizeMake(45, 45) type:0];
        fview.delegate = self;
        [scrollView1 addSubview:fview];
        [fview release];
    }
    scrollView1.contentSize = CGSizeMake(320 * 4, 170);
    scrollView1.pagingEnabled = YES;
    scrollView1.showsHorizontalScrollIndicator = NO;
    scrollView1.showsVerticalScrollIndicator = NO;
    
    [faceView addSubview:scrollView1];
    [scrollView1 release];
    
    //云通表情页
//    scrollView2 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 170)];
//    scrollView2.delegate = self;
//    scrollView2.backgroundColor = [UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1];
//    for (int i=0; i<4; i++)
//    {
//        FacialView *fview = [[FacialView alloc] initWithFrame:CGRectMake(2.5 * i + 317.5 * i, 0, 315, 144)];
//        [fview loadFacialView:i size:CGSizeMake(24, 24) type:1];
//        fview.delegate = self;
//        [scrollView2 addSubview:fview];
//        [fview release];
//    }
//    scrollView2.contentSize = CGSizeMake(320 * 4, 170);
//    scrollView2.pagingEnabled = YES;
//    scrollView2.showsHorizontalScrollIndicator = NO;
//    scrollView2.showsVerticalScrollIndicator = NO;
//    
//    [faceView insertSubview:scrollView2 belowSubview:scrollView1];
//    [scrollView2 release];
    
    //页面小白点
    int pageControlHeight = 15;
    pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, scrollView1.frame.size.height - pageControlHeight, 320, pageControlHeight)] autorelease];
    [pageControl setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:pageControl];
    pageControl.numberOfPages = 4;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor clearColor];
    
    [faceView addSubview:pageControl];
    
    //默认表情按钮
    btnDefaultFace = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDefaultFace.frame = CGRectMake(0, 176, 120, 40);
    btnDefaultFace.tag = Button_Default_Face_Tag;
    [btnDefaultFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_press.png"] forState:UIControlStateNormal];
    [btnDefaultFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_press.png"] forState:UIControlStateHighlighted];
    [btnDefaultFace setTitle:NSLocalizedString(@"Default", @"Default") forState:UIControlStateNormal];
    btnDefaultFace.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [btnDefaultFace addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:btnDefaultFace];
    
    //云通表情按钮
    btnCloudCallFace = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCloudCallFace.frame = CGRectMake(120, 176, 120, 40);
    btnCloudCallFace.tag = Button_CC_Face_Tag;
    [btnCloudCallFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_normal.png"] forState:UIControlStateNormal];
    [btnCloudCallFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_normal.png"] forState:UIControlStateHighlighted];
//    [btnCloudCallFace setTitle:@"云通表情" forState:UIControlStateNormal];
    btnCloudCallFace.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [btnCloudCallFace addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:btnCloudCallFace];
    
    //发送按钮
    btnSendMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSendMsg.frame = CGRectMake(240, 176, 80, 40);
    btnSendMsg.tag = Button_Send_Tag;
    [btnSendMsg setBackgroundImage:[UIImage imageNamed:@"btn_imsend_up.png"] forState:UIControlStateNormal];
    [btnSendMsg setBackgroundImage:[UIImage imageNamed:@"btn_imsend_down.png"] forState:UIControlStateHighlighted];
    [btnSendMsg setTitle:NSLocalizedString(@"Send", @"Send") forState:UIControlStateNormal];
    btnSendMsg.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [btnSendMsg addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:btnSendMsg];
}

- (IBAction)onButtonToolBarItemClick: (id)sender {
    if (sender == barButtonItemBack) {
        [self stopPlayAudio];

        if (playAudioTimer)
        {
            [playAudioTimer invalidate];
            playAudioTimer = nil;
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        if (isAddChat)
            [self.navigationController popToRootViewControllerAnimated:YES];
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)buttonClicked:(UIButton *)sender
{
    switch (sender.tag)
    {
        case Button_Default_Face_Tag:
        {
            [btnDefaultFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_press.png"] forState:UIControlStateNormal];
            [btnDefaultFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_press.png"] forState:UIControlStateHighlighted];
            [btnCloudCallFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_normal.png"] forState:UIControlStateNormal];
            [btnCloudCallFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_normal.png"] forState:UIControlStateHighlighted];
            [faceView bringSubviewToFront:scrollView1];
            pageControl.numberOfPages = 4;
            pageControl.currentPage = 0;
            [faceView bringSubviewToFront:pageControl];
            break;
        }
        case Button_CC_Face_Tag:
        {
//            [btnDefaultFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_normal.png"] forState:UIControlStateNormal];
//            [btnDefaultFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_normal.png"] forState:UIControlStateHighlighted];
//            [btnCloudCallFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_press.png"] forState:UIControlStateNormal];
//            [btnCloudCallFace setBackgroundImage:[UIImage imageNamed:@"tab_imemoji_press.png"] forState:UIControlStateHighlighted];
//            [faceView bringSubviewToFront:scrollView2];
//            pageControl.numberOfPages = 4;
//            pageControl.currentPage = 0;
//            [faceView bringSubviewToFront:pageControl];
            break;
        }
        case Button_Send_Tag:
            [self sendInputMsg];
            break;
        case LongPressManageTypeCopy:
        {
            NSString *inputString = self.manageMsg;
            
            NSRange range_left = [inputString rangeOfString:@"["];
            NSRange range_right = [inputString rangeOfString:@"]"];
            BOOL exchange = range_left.length != NSNotFound && range_right.location != NSNotFound && range_right.location > range_left.location && range_right.location - range_left.location <= 6;
            
            while (exchange)
            {
                NSString *tmpFaceString = [inputString substringWithRange:NSMakeRange(range_left.location, range_right.location - range_left.location + 1)];
                NSString *tmpFaceNumber = [self exchangeFaceStringByDisplayString:tmpFaceString];
                NSRange replaceRange = NSMakeRange(range_left.location, tmpFaceString.length);
                inputString = [inputString stringByReplacingCharactersInRange:replaceRange withString:tmpFaceNumber];
                //判断是否需要继续替换
                if ((replaceRange.location + tmpFaceNumber.length) >= inputString.length) break;
                
                NSRange newRange = NSMakeRange(replaceRange.location + tmpFaceNumber.length, inputString.length - replaceRange.location - tmpFaceNumber.length);
                range_left = [inputString rangeOfString:@"[" options:NSCaseInsensitiveSearch range:newRange];
                range_right = [inputString rangeOfString:@"]" options:NSCaseInsensitiveSearch range:newRange];
                exchange = range_left.length != NSNotFound && range_right.location != NSNotFound && range_right.location > range_left.location && range_right.location - range_left.location <= 6;
            }
            
            //长按复制
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:inputString];
            
            [popTipView dismissAnimated:YES];
            popTipView = nil;
            break;
        }
        case LongPressManageTypeDel:
        {
            CCLog(@"LongPressManageTypeDel");
            
            //长按删除
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Really want to delete this message?", @"Really want to delete this message?")
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                       destructiveButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                            otherButtonTitles:nil, nil];
            actionSheet.tag = kTagActionSheetDelAMsg;
            [actionSheet showInView:self.view];
            [actionSheet release];
            
            [popTipView dismissAnimated:YES];
            popTipView = nil;
            break;
        }
        case LongPressManageTypeDelAll:     //暂时没有这个功能
        {
            CCLog(@"LongPressManageTypeDelAll");
            //长按删除全部
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定删除与该好友聊天的全部消息?"
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                       destructiveButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                            otherButtonTitles:nil, nil];
            actionSheet.tag = kTagActionSheetDelAllMsg;
            [actionSheet showInView:self.view];
            [actionSheet release];
            
            [popTipView dismissAnimated:YES];
            popTipView = nil;
            break;
        }
        default:
            break;
    }
}

- (void)sendInputMsg
{
    if (inputField.text.length > 0)
    {
        NSString *inputString = [NSString stringWithString:inputField.text];
        
        NSRange range_left = [inputString rangeOfString:@"["];
        NSRange range_right = [inputString rangeOfString:@"]"];
        BOOL exchange = range_left.length != NSNotFound && range_right.location != NSNotFound && range_right.location > range_left.location && range_right.location - range_left.location <= 6;
        
        while (exchange)
        {
            NSString *tmpFaceString = [inputString substringWithRange:NSMakeRange(range_left.location, range_right.location - range_left.location + 1)];
            NSString *tmpFaceNumber = [self exchangeFaceStringByDisplayString:tmpFaceString];
            CCLog(@"tmpFaceString : %@ , tmpFaceNumber : %@", tmpFaceString , tmpFaceNumber);
            NSRange replaceRange = NSMakeRange(range_left.location, tmpFaceString.length);
            inputString = [inputString stringByReplacingCharactersInRange:replaceRange withString:tmpFaceNumber];
            CCLog(@"inputString : %@", inputString);
            //判断是否需要继续替换
            if ((replaceRange.location + tmpFaceNumber.length) >= inputString.length) break;
            
            NSRange newRange = NSMakeRange(replaceRange.location + tmpFaceNumber.length, inputString.length - replaceRange.location - tmpFaceNumber.length);
            range_left = [inputString rangeOfString:@"[" options:NSCaseInsensitiveSearch range:newRange];
            range_right = [inputString rangeOfString:@"]" options:NSCaseInsensitiveSearch range:newRange];
            exchange = range_left.length != NSNotFound && range_right.location != NSNotFound && range_right.location > range_left.location && range_right.location - range_left.location <= 6;
        }
        
        // 存入本地消息记录
        NSMutableDictionary *messageDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
        NSString *messageId =[self getMessageIdWithTimeAndUUID];
        NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];
        
        NSBubbleData *mineBubble = [NSBubbleData dataWithText:inputString date:[NSDate date] type:BubbleTypeMine];
        mineBubble.avatar = self.mineAvatar;
        mineBubble.dataID = messageId;
        mineBubble.fileType = FileType_Text;
        
        [bubbleData addObject:mineBubble];
        [messageDictionary setObject:messageId forKey:@"MessageId"];
        [messageDictionary setObject:username forKey:@"Sender"];
        [messageDictionary setObject:friendAccount forKey:@"Receiver"];
        [messageDictionary setObject:inputString forKey:@"Message"];
        [messageDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"MessageType"];
        [messageDictionary setObject:[NSNumber numberWithInteger:FileType_Text] forKey:@"FileType"];
        [messageDictionary setObject:@"" forKey:@"MediaURL"];
        [messageDictionary setObject:@"" forKey:@"OrgMediaURL"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        [messageDictionary setObject:[df stringFromDate:[NSDate date]] forKey:@"CreateTime"];
        [df release];
        [messageDictionary setObject:[NSNumber numberWithInteger:1] forKey:@"Status"];
        [messageDictionary setObject:[NSNumber numberWithInteger:IMSendStatusSending] forKey:@"SendStatus"];
        [messageDictionary setObject:@"" forKey:@"ServerMsgId"];
        [messageDictionary setObject:[NSNumber numberWithInteger:0] forKey:KMessageHistoryTableColMsgReadStatus];
        
        SqliteHelper *helper = [[SqliteHelper alloc] init];
        [helper createDatabase];
        [helper insertDataToChatInfoTable:messageDictionary imageData:nil];
        [helper closeDatabase];
        [helper release];
        
        [[IMWebInterface sharedInstance] sendChatMessageRequest:username
                                                             to:friendAccount message:inputString type:isGroup?@"1":@"0" andMsgID:messageId];
        
        
        //    [inputField resignFirstResponder];
        [inputField setText:@""];
        
        //重新刷新tableView
        [self needReloadTable];
    }
}

- (void)makeCall
{
    BOOL ret = NO;
    if ([[NgnEngine sharedInstance].sipService isRegistered]) {
        
        BOOL on3G = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
        BOOL use3G = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
        if (on3G && !use3G) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                            message:NSLocalizedString(@"Only 3G network is available. Please enable 3G and try again.", @"Only 3G network is available. Please enable 3G and try again.")
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alert show];
            [alert release];
            
            return ;
        }
        
        
        if (friendAccount) {
            ret = [self showCallOptView:friendAccount andVideoCall:NO];
            /*ret = [CallViewController makeAudioCallWithRemoteParty: ngnphonenum.number
             andSipStack:[[NgnEngine sharedInstance].sipService getSipStack]];
             */
        }
        
        if (ret == YES){
            return;
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Call out error", @"Call out error")
                                                        message:NSLocalizedString(@"Could not make call, server not ready", @"Could not make call, server not ready")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
        [alert release];
    }
}

-(BOOL) showCallOptView:(NSString*)number andVideoCall:(BOOL)videocall{
    if (dialNumber) {
        [dialNumber release];
        dialNumber = nil;
    }
    dialNumber = [[NSString alloc] initWithString:number];
    videocallout = videocall;
    
    // 'Vincent' is (not) a WeiCall user, call out via:
    NSString* strPrompt = NSLocalizedString(@"call out via", @"call out via");
    
    if ([calloption count])
    {
        [calloption removeAllObjects];
    }
    
    BOOL landsenabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_LANDS_CALL_ENABLE];
    BOOL callbackenabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_CALLBACK_ENABLE];
    BOOL innetCallEnabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_INNET_CALL_ENABLE];
    BOOL phoneCallenabled = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_PHONE_CALL_ENABLE];
    if (innetCallEnabled)
        [calloption addObject: [NSNumber numberWithInt:CallOptionInnerCall]];
    if (landsenabled)
        [calloption addObject: [NSNumber numberWithInt:CallOptionLandCall]];
    if (callbackenabled)
        [calloption addObject: [NSNumber numberWithInt:CallOptionCallback]];
    if (phoneCallenabled)
        [calloption addObject: [NSNumber numberWithInt:CallOptionDialViaCellphone]];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"call out via", @"call out via")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                         destructiveButtonTitle:innetCallEnabled ? NSLocalizedString(@"YunTong Friends Call", @"YunTong Friends Call") : nil
                                              otherButtonTitles:landsenabled ? NSLocalizedString(@"YunTong Direct Call", @"YunTong Direct Call") : nil,
                            callbackenabled ? NSLocalizedString(@"YunTong Callback", @"YunTong Callback") : nil,
                            phoneCallenabled ? NSLocalizedString(@"Cell Phone", @"Cell Phone") : nil, nil];
    
    
    //#if 1
    //            if (videocallout) {
    //                [CallViewController makeAudioVideoCallWithRemoteParty:dialNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] andCalloutMode:CALL_OUT_MODE_INNER];
    //            } else {
    //                [CallViewController makeAudioCallWithRemoteParty:dialNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] andCalloutMode:CALL_OUT_MODE_INNER];
    //            }
    //#else
    //            [calloption addObject: [NSNumber numberWithInt:CallOptionInnerCall]];
    //            sheet = [[UIActionSheet alloc] initWithTitle:strPrompt
    //                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
    //                                  destructiveButtonTitle:NSLocalizedString(@"YunTong Friends Call", @"YunTong Friends Call")
    //                                       otherButtonTitles:nil,/*NSLocalizedString(@"Cell Phone", @"Cell Phone"),*/ nil];
    //#endif
    
    if (sheet) {
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        sheet.tag = kTagActionSheetCallOut;
        [sheet showInView:self.parentViewController.tabBarController.view];
        [sheet release];
    }
    
    return YES;
}

//头像点击
- (void)onAvatarClick:(NSNotification *)notification
{
    NSBubbleData *dataBubble = (NSBubbleData *)notification.object;
    if (dataBubble.type == BubbleTypeMine)
    {
        PersonalInfoNewViewController *personalInfo = [[PersonalInfoNewViewController alloc] initWithNibName:@"PersonalInfoNewViewController" bundle:nil];
        [self.navigationController pushViewController:personalInfo animated:YES];
        [personalInfo release];
    }
    else
    {
        [self goToContactDetail];
    }
}

/**
 *	@brief	消息单元格单击事件通知
 *
 *	@param 	notification 	通知
 */
- (void)onImageViewSingleClick:(NSNotification *)notification
{
    NSBubbleData *data = (NSBubbleData *)notification.object;
    
//    CCLog(@"data DataID : %@", data.dataID);
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    IMMsgHistory *msghistory = [helper selectMessageRecordFromByMessageID:data.dataID];
    
    if (msghistory.FileType == FileType_Photo) {
        IMSelectImgViewController *controller = [[IMSelectImgViewController alloc] initWithNibName:@"IMSelectImgViewController" bundle:nil];
        controller.viewType = IMSelectImgViewTypeOrgImg;
        controller.smallImageUrl = msghistory.MediaURL;
        controller.orgImageUrl = msghistory.OrgMediaURL;
        controller.msgID = data.dataID;
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    else if (msghistory.FileType == FileType_Audio)
    {
        if (self.clickBubbleDateView)
        {
            UIImageView *imageView = (UIImageView *)clickBubbleDateView.view;
            if (clickBubbleDateView.type == BubbleTypeMine)
                imageView.image = [UIImage imageNamed:@"micMine"];
            else
                imageView.image = [UIImage imageNamed:@"micSomeone"];
        }

        self.clickBubbleDateView = data;
        playAudioCount = 4;
        [self.playingAnimationArray removeAllObjects];
        if (clickBubbleDateView.type == BubbleTypeMine)
        {
            [playingAnimationArray addObjectsFromArray:[NSArray arrayWithObjects:@"", @"micMine_1.png", @"micMine_2.png", @"micMine_3.png", nil]];
        }
        else
        {
            [playingAnimationArray addObjectsFromArray:[NSArray arrayWithObjects:@"", @"micSomeone_1.png", @"micSomeone_2.png", @"micSomeone_3.png", nil]];
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExist = [fileManager fileExistsAtPath:msghistory.MediaURL];
        if (fileExist == NO && msghistory.OrgMediaURL != nil && data.type == 1 /*1 = BubbleTypeSomeoneElse*/)
        {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            //receive audio message need download
            [[IMDownLoadAudioFromServerModel sharedInstance] sendDownLoadAudioRequest:msghistory.OrgMediaURL filePath:msghistory.MediaURL messgeId:msghistory.MessageId andAudioDuration:[NSString stringWithFormat:@"%d", msghistory.AudioDuration] andSenderUser:msghistory.Sender andDate:[df dateFromString:msghistory.CreateTime]andPlay:YES];
            [df release];
            
        }
        else
        {
            [self startPlayAudioPath:msghistory.MediaURL];
            
            BOOL isRead = [helper selectMsgReadStatusByMsgId:data.dataID];
            
            //是否已读
            if (!isRead)
            {
                //更新为已读
                [helper updateMsgReadStatusByMsgId:data.dataID andIMMsgReadStatus:IMMsgReadStatusOfRead];
            }
        }
    }

    [helper closeDatabase];
    [helper release];
}

/**
 *	@brief	消息单元长按事件通知
 *
 *	@param 	notification 	通知
 */
- (void)onImageViewLongPress:(NSNotification *)notification
{
    NSBubbleData *data = (NSBubbleData *)notification.object;
//    CCLog(@"data DataID : %@", data.dataID);
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    IMMsgHistory *msghistory = [helper selectMessageRecordFromByMessageID:data.dataID];
    [helper closeDatabase];
    [helper release];
    
    if (popTipView && currentPopTipViewSender == data.view) return;
    
    //释放上一个弹出框
    if (popTipView) {
        [popTipView dismissAnimated:YES];
        popTipView = nil;
    }
    
    if (msghistory.FileType == FileType_Text)
    {
        UIButton *btnCopy = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnCopy setFrame:CGRectMake(0, 0, 45, kPopTipViewHeight)];
        [btnCopy setTitle:NSLocalizedString(@"Copy", @"Copy") forState:UIControlStateNormal];
        [btnCopy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCopy setTitle:NSLocalizedString(@"Copy", @"Copy") forState:UIControlStateHighlighted];
        [btnCopy setTitleColor:[UIColor colorWithRed:0.0/255.0 green:120.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [btnCopy.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        btnCopy.tag = LongPressManageTypeCopy;
        [btnCopy addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDel setFrame:CGRectMake(45, 0, 46, kPopTipViewHeight)];
        [btnDel setTitle:NSLocalizedString(@"Delete", @"Delete") forState:UIControlStateNormal];
        [btnDel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnDel setTitle:NSLocalizedString(@"Delete", @"Delete") forState:UIControlStateHighlighted];
        [btnDel setTitleColor:[UIColor colorWithRed:0.0/255.0 green:120.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [btnDel.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [btnDel setBackgroundImage:[UIImage imageNamed:@"im_managebtn.png"] forState:UIControlStateNormal];
        [btnDel setBackgroundImage:[UIImage imageNamed:@"im_managebtn.png"] forState:UIControlStateHighlighted];
        btnDel.tag = LongPressManageTypeDel;
        [btnDel addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnCopy.frame.size.width + btnDel.frame.size.width, kPopTipViewHeight)];
        [popView setBackgroundColor:[UIColor clearColor]];
        [popView addSubview:btnCopy];
        [popView addSubview:btnDel];
        
        if (manageMsgID) {
            [manageMsgID release];
            manageMsgID = nil;
        }
        self.manageMsgID = [[NSString alloc] initWithString:msghistory.MessageId];
        
        self.serverMsgId = msghistory.ServerMsgId;
        
        if (manageMsg) {
            [manageMsg release];
            manageMsg = nil;
        }
        manageMsg = [[NSString alloc] initWithString:msghistory.Message];
        popTipView = [[CMPopTipView alloc] initWithCustomView:popView];
        [popView release];
    }
//    else if (msghistory.FileType == FileType_Photo)
//    {
//        UIView *popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnDel.frame.size.width, kPopTipViewHeight)];
//        [popView setBackgroundColor:[UIColor blackColor]];
//        [popView addSubview:btnDel];
//        
//        if (manageMsgID) {
//            [manageMsgID release];
//            manageMsgID = nil;
//        }
//        manageMsgID = [[NSString alloc] initWithString:msghistory.MessageId];
//        
//        popTipView = [[CMPopTipView alloc] initWithCustomView:popView];
//        popTipView.backgroundColor = [UIColor clearColor];
//        popTipView.delegate = self;
//        popTipView.dismissTapAnywhere = YES;
//        [popTipView autoDismissAnimated:YES atTimeInterval:5.0];
//        [popTipView presentPointingAtView:data.view inView:self.view animated:YES];
//        
//        [popView release];
//    }
    else
    {
        UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDel setFrame:CGRectMake(0, 0, 45, kPopTipViewHeight)];
        [btnDel setTitle:NSLocalizedString(@"Delete", @"Delete") forState:UIControlStateNormal];
        [btnDel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnDel setTitle:NSLocalizedString(@"Delete", @"Delete") forState:UIControlStateHighlighted];
        [btnDel setTitleColor:[UIColor colorWithRed:0.0/255.0 green:120.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [btnDel.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        btnDel.tag = LongPressManageTypeDel;
        [btnDel addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnDel.frame.size.width, kPopTipViewHeight)];
        [popView setBackgroundColor:[UIColor clearColor]];
        [popView addSubview:btnDel];
        
        if (manageMsgID) {
            [manageMsgID release];
            manageMsgID = nil;
        }
        self.manageMsgID = [[NSString alloc] initWithString:msghistory.MessageId];
        
        self.serverMsgId = msghistory.ServerMsgId;
        
        popTipView = [[CMPopTipView alloc] initWithCustomView:popView];
        [popView release];
    }
    
    popTipView.backgroundColor = [UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0];
    popTipView.delegate = self;
    popTipView.dismissTapAnywhere = YES;
    [popTipView autoDismissAnimated:YES atTimeInterval:5.0];
    [popTipView presentPointingAtView:data.view inView:self.view animated:YES];
    
    self.currentPopTipViewSender = data.view;
}

/**
 *	@brief	消息发送状态更新事件
 *
 *	@param 	通知 kNotificationBtnResendMsgEvent
 */
- (void)onBtnResendMsgEvent:(NSNotification *)notification
{
    NSBubbleData *data = (NSBubbleData *)notification.object;
    //    CCLog(@"data DataID : %@", data.dataID);
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    IMMsgHistory *msghistory = [helper selectMessageRecordFromByMessageID:data.dataID];
    
    if (msghistory.FileType == FileType_Text)           //文字
    {
        [helper updateMessageSendStatusByMsgID:data.dataID andSendStatus:IMSendStatusSending andServerMsgId:@""];
        [[IMWebInterface sharedInstance] sendChatMessageRequest:msghistory.Sender
                                                             to:msghistory.Receiver
                                                        message:msghistory.Message
                                                           type:[NSString stringWithFormat:@"%d", msghistory.MessageType]
                                                       andMsgID:msghistory.MessageId];
    }
    else if (msghistory.FileType == FileType_Photo)     //图片
    {
        if (msghistory.OrgMediaURL)
        {
            [helper updateMessageSendStatusByMsgID:data.dataID andSendStatus:IMSendStatusSending andServerMsgId:@""];
            //从本地获取图片文件再次发送
            NSData *imageData = [NSData dataWithContentsOfFile:msghistory.OrgMediaURL];
            
            [[IMWebInterface sharedInstance] sendChatMediaResourceRequest:msghistory.Sender
                                                                       to:msghistory.Receiver
                                                                     data:imageData
                                                                 fileType:@"1"
                                                                     type:[NSString stringWithFormat:@"%d", msghistory.MessageType]
                                                                 andMsgID:msghistory.MessageId
                                                             andAudioTime:[NSString stringWithFormat:@"%d", msghistory.AudioDuration]];
        }
    }
    else if (msghistory.FileType == FileType_Audio)     //声音
    {
        [helper updateMessageSendStatusByMsgID:data.dataID andSendStatus:IMSendStatusSending andServerMsgId:@""];
        [[IMWebInterface sharedInstance] sendChatMediaResourceRequest:msghistory.Sender
                                                                   to:msghistory.Receiver
                                                                 data:[NSData dataWithContentsOfFile:msghistory.MediaURL]
                                                             fileType:@"2"
                                                                 type:@"1"
                                                             andMsgID:msghistory.MessageId
                                                         andAudioTime:[NSString stringWithFormat:@"%d", msghistory.AudioDuration]];
    }
    
    [helper closeDatabase];
    [helper release];
    
    [self needReloadTable];
}

/**
 *	@brief	消息发送状态更新事件
 *
 *	@param 	notification 	通知
 */
- (void)onUpdateMsgSendStatus
{
    [self needReloadTable];
}

- (void)saveMsgImage:(UIImage *)image andMsgID:(NSString *)msgID
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    NSString *myAccount = [[CloudCall2AppDelegate sharedInstance] getUserName];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*)[[UIApplication sharedApplication] delegate]);
    NSString *IMCachesDir = [appDelegate GetIMCachesDirectoryPath];
    NSString *myDir = [IMCachesDir stringByAppendingPathComponent:myAccount];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 创建存放IM个人cache文件夹
    if (![fileManager fileExistsAtPath:myDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:myDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建存放IM个人cache文件夹失败");
        }
    }
    NSString *fileName = [NSString stringWithFormat:@"%@_small.jpg",msgID];
    
    NSString *filePath = [myDir stringByAppendingPathComponent:fileName];
    
    [self writeData2File:imageData toFileAtPath:filePath];
}

- (NSString *)saveMsgData:(NSData *)imageData andMsgID:(NSString *)msgID
{
    NSString *myAccount = [[CloudCall2AppDelegate sharedInstance] getUserName];
    
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*)[[UIApplication sharedApplication] delegate]);
    NSString *IMCachesDir = [appDelegate GetIMCachesDirectoryPath];
    NSString *myDir = [IMCachesDir stringByAppendingPathComponent:myAccount];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 创建存放IM个人cache文件夹
    if (![fileManager fileExistsAtPath:myDir isDirectory:nil]) {
        if ([fileManager createDirectoryAtPath:myDir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
            CCLog(@"创建存放IM个人cache文件夹失败");
        }
    }
    NSString *fileName = [NSString stringWithFormat:@"%@_org.jpg",msgID];
    
    NSString *filePath = [myDir stringByAppendingPathComponent:fileName];
    
    [self writeData2File:imageData toFileAtPath:filePath];
    
    return filePath;
}

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

- (NSString *)getMessageIdWithTimeAndUUID
{
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*)[[UIApplication sharedApplication] delegate]);    
    return [appDelegate getMessageIdWithTimeAndUUID];
}

- (void)updatePlayingAudioStats:(NSTimer *)_timer
{
    UIImageView *imageView = (UIImageView *)clickBubbleDateView.view;
    CCLog(@"---------%@.....retainCount:%d", [playingAnimationArray objectAtIndex:playAudioCount%4], [self retainCount]);
    imageView.image = [UIImage imageNamed:[playingAnimationArray objectAtIndex:playAudioCount%4]];
    playAudioCount++;
}

- (NSString *)exchangeFaceStringByDisplayString:(NSString *)displayString
{
    if ([NgnStringUtils isNullOrEmpty:displayString]) return @"";
    
    NSRange range_left = [displayString rangeOfString:@"["];
    NSRange range_right = [displayString rangeOfString:@"]" options:NSBackwardsSearch];
    
    if (range_left.length != NSNotFound && range_right.location != NSNotFound && range_right.location > range_left.location && range_right.location - range_left.location <= 6)
    {
        NSRange subRange = NSMakeRange(range_left.location + 1, range_right.location - 1);
        NSString *dictString = [displayString substringWithRange:subRange];
        
        NSString *exchangeString = [faceDictionary objectForKey:dictString];
        
        if ([NgnStringUtils isNullOrEmpty:exchangeString])
            return displayString;
        else
            return [NSString stringWithFormat:@"[%@]", exchangeString];
    }
    
    return displayString;
}

- (void)goToContactDetail
{
    BOOL inContact = YES;
    NgnContact *receiverContact = nil;
    receiverContact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:friendAccount];
    if (!receiverContact || receiverContact == nil)
    {
        //该号码不在通讯录
        inContact = NO;
        CFStringRef phoneNumberLabelValue = ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel);
        NSMutableArray *phoneNumbers = [NSMutableArray arrayWithCapacity:2];
        NgnPhoneNumber* ngnPhoneNumber = [[[NgnPhoneNumber alloc] initWithNumber:friendAccount
                                                                  andDescription:(NSString *)phoneNumberLabelValue
                                                                         andType: NgnPhoneNumberType_Number] autorelease];
        [phoneNumbers addObject: ngnPhoneNumber];
        CFRelease(phoneNumberLabelValue);
        
        receiverContact = [[[NgnContact alloc] initWithDisplayName:friendAccount andFirstName:@"" andLastName:@"" andPhoneNumbers:phoneNumbers andPicture:nil andDisplayMsg:nil andDisplayMsgRange:NSMakeRange(0, 0)] autorelease];
    }
    
    ContactDetailsController *contactDetailsController = [[ContactDetailsController alloc] initWithNibName: @"ContactDetails" bundle:nil];
    [contactDetailsController setIsHideBtnEdit:YES];
    contactDetailsController.contact = receiverContact;
    contactDetailsController.isInContact = inContact;
    contactDetailsController.isHightLight = YES;
    contactDetailsController.hightNumber = friendAccount;
    contactDetailsController.fromIMChatView = YES;
    [self.navigationController pushViewController: contactDetailsController animated: YES];
    [contactDetailsController release];
}

-(void) onContactEvent:(NSNotification*)notification
{
	NgnContact *receiverContact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:friendAccount];
    //标题
    if (receiverContact && receiverContact.displayName)
        self.title = [NSString stringWithFormat:@"%@", receiverContact.displayName];
    else
        self.title = friendAccount;
}

#pragma mark -
#pragma mark UIBubbleTableViewDelegate implementation
- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

- (void)bubbleTableViewDidScrollTableView
{
    if (isKeyBoardShow)
        [self.view endEditing:YES];
}

- (void)bubbleTableViewDidScrollToReloadTableView:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)bubbleTableViewScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    int allMsgcount = [helper selectCountAllMessageRecordByUser:friendAccount];
    [helper closeDatabase];
    [helper release];
    
    if (isLoading || allMsgcount <= loadNumberOfMsg)
    {
        [self performSelector:@selector(finishLoadingDataForTableView) withObject:nil afterDelay:2];
        
        return;
    }
    
    [self slideToLoadMoreData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return isLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

/**
 *	@brief EGORefreshTableHeaderDelegate Util Methods
 */
- (void)slideToLoadMoreData
{
    loadNumberOfMsg += initNumberOfMsg;
    [bubbleData removeAllObjects];
    [self loadMsgHistoryData];
    [self needReloadTable];
    
    //通知加载完成,隐藏加载框
    [self performSelector:@selector(finishLoadingDataForTableView) withObject:nil afterDelay:2];
    
//    [chatContentTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)finishLoadingDataForTableView
{
	//  model should call this when its done loading
	isLoading = NO;
	[_refreshHeaderView performSelectorOnMainThread:@selector(egoRefreshScrollViewDataSourceDidFinishedLoading:) withObject:chatContentTable waitUntilDone:NO];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == faceTextField)
    {
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"btn_keyboard_up.png"] forState:UIControlStateNormal];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"btn_keyboard_down.png"] forState:UIControlStateHighlighted];
        
        [audioButton setBackgroundImage:[UIImage imageNamed:@"audio_up.png"] forState:UIControlStateNormal];
        [audioButton setBackgroundImage:[UIImage imageNamed:@"audio_down.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_up.png"] forState:UIControlStateNormal];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_down.png"] forState:UIControlStateHighlighted];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_up.png"] forState:UIControlStateNormal];
    [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_down.png"] forState:UIControlStateHighlighted];
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self sendInputMsg];
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView != inputField)
    {
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"btn_keyboard_up.png"] forState:UIControlStateNormal];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"btn_keyboard_down.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_up.png"] forState:UIControlStateNormal];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_down.png"] forState:UIControlStateHighlighted];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text; {
    if ([text isEqualToString:@"\n"]) {
        [self sendInputMsg];
        return NO;
    }
    return YES;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([faceTextField isFirstResponder])
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = page;
    }
}

#pragma mark - MessageDelegate
- (void) didReceiveNewMessage:(NSString *)message
                     sendUser:(NSString *)sendUser
                         date:(NSDate *)date
                      msgType:(int)msgType
                     fileType:(NSInteger)fileType
                      fileUrl:(NSString *)fileUrl
                   orgFileUrl:(NSString *)orgFileUrl
                audioDuration:(NSString *)audioDuration
                     fileName:(NSString *)fileName
                    messageId:(NSString *) messageId
                   localMsgId:(NSString *) localMsgId
{
    // 如果消息发送者是当前聊天界面的用户
    if ([sendUser isEqualToString:friendAccount])
    {
        NSBubbleData *elseBubble = nil;
        // 文字消息
        if (fileType == FileType_Text)
        {
            NSBubbleData *elseBubble = [NSBubbleData dataWithText:message date:date type:BubbleTypeSomeoneElse];
            elseBubble.fileType = FileType_Text;
            elseBubble.dataID = localMsgId;
            elseBubble.avatar = self.friendAvatar;
            [bubbleData addObject:elseBubble];
            [chatContentTable reloadData];
        }
        // 图片
        else if (fileType == FileType_Photo)
        {
            NSBubbleData *elseBubble = [NSBubbleData dataWithImage:[UIImage imageNamed:@"missingAvatar"] pictureUrl:fileUrl date:date type:BubbleTypeSomeoneElse];
            elseBubble.fileType = FileType_Photo;
            elseBubble.dataID = localMsgId;
            elseBubble.avatar = self.friendAvatar;
            [bubbleData addObject:elseBubble];
            [chatContentTable reloadData];
        }
        // 音频
        else if (fileType == FileType_Audio)
        {
            [[IMDownLoadAudioFromServerModel sharedInstance] sendDownLoadAudioRequest:fileUrl filePath:[RecorderManager getPathByFileName:fileName ofType:@"spx"] messgeId:localMsgId andAudioDuration:audioDuration andSenderUser:sendUser andDate:date andPlay:NO];
        }
        
        if (chatContentTable.contentSize.height > chatContentTable.frame.size.height)
        {
            [chatContentTable setContentOffset:CGPointMake(0, chatContentTable.contentSize.height - chatContentTable.frame.size.height)];
        }
    }
    else
    {
        NgnContact *receiverContact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber:sendUser];
        
        NSString *displayName = sendUser;
        if (receiverContact) {
            displayName = receiverContact.displayName;
        }
        UIImage *avatar = receiverContact.picture?[UIImage imageWithData:receiverContact.picture]:[UIImage imageNamed:@"contact_noavatar_icon.png"];
        //状态栏显示别人的消息
        // 文字消息
        if (fileType == FileType_Text)
        {
            NSString *strContent = message;
            
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
            
            [MPNotificationView notifyWithText:[NSString stringWithFormat:@"%@:",displayName]
                                        detail:strContent
                                         image:avatar
                                   andDuration:2.0f];
        }
        // 图片
        else if (fileType == FileType_Photo)
        {
            [MPNotificationView notifyWithText:[NSString stringWithFormat:@"%@:",displayName]
                                        detail:NSLocalizedString(@"[Photo]", @"[Photo]")
                                         image:avatar
                                   andDuration:2.0f];
        }
        // 音频
        else if (fileType == FileType_Audio)
        {
            [MPNotificationView notifyWithText:[NSString stringWithFormat:@"%@:",displayName]
                                        detail:NSLocalizedString(@"[Audio]", @"[Audio]")
                                         image:avatar
                                   andDuration:2.0f];
        }
    }
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];
    // 存入本地消息记录
    NSMutableDictionary *messageDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    [messageDictionary setObject:localMsgId forKey:@"MessageId"];
    [messageDictionary setObject:sendUser forKey:@"Sender"];
    [messageDictionary setObject:username forKey:@"Receiver"];
    [messageDictionary setObject:message forKey:@"Message"];
    [messageDictionary setObject:[NSNumber numberWithInteger:msgType] forKey:@"MessageType"];
    [messageDictionary setObject:[NSNumber numberWithInteger:fileType] forKey:@"FileType"];
    [messageDictionary setObject:[NSNumber numberWithInteger:0] forKey:KMessageHistoryTableColMsgReadStatus];
    
    // 图片
    if (fileType == FileType_Photo)
    {
        [messageDictionary setObject:fileUrl forKey:@"MediaURL"];
        [messageDictionary setObject:orgFileUrl forKey:@"OrgMediaURL"];
    }
    else if (fileType == FileType_Audio)
    {
        [messageDictionary setObject:[RecorderManager getPathByFileName:fileName ofType:@"spx"] forKey:@"MediaURL"];
        [messageDictionary setObject:audioDuration forKey:@"AudioDuration"];
        [messageDictionary setObject:fileUrl forKey:@"OrgMediaURL"];
        [messageDictionary setObject:[NSNumber numberWithInteger:1] forKey:KMessageHistoryTableColMsgReadStatus];
        
        if (![sendUser isEqualToString:friendAccount])
            [[IMDownLoadAudioFromServerModel sharedInstance] sendDownLoadAudioRequest:fileUrl filePath:[RecorderManager getPathByFileName:fileName ofType:@"spx"] messgeId:localMsgId andAudioDuration:audioDuration andSenderUser:sendUser andDate:date andPlay:NO];
    }
    else
    {
        [messageDictionary setObject:@"" forKey:@"MediaURL"];
        [messageDictionary setObject:@"" forKey:@"OrgMediaURL"];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [messageDictionary setObject:[df stringFromDate:date] forKey:@"CreateTime"];
    [df release];
    
    if ([sendUser isEqualToString:friendAccount])
    {
        [messageDictionary setObject:[NSNumber numberWithInteger:1] forKey:@"Status"];
    }
    else
    {
        // 未读
        [messageDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"Status"];
    }
    [messageDictionary setObject:messageId forKey:@"ServerMsgId"];
    
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    [helper insertDataToChatInfoTable:messageDictionary imageData:nil];
    [helper closeDatabase];
    [helper release];
}

#pragma mark - UI Event Handle
- (void) audioButtonAction:(UIButton *) button
{
    [inputField resignFirstResponder];
    [faceTextField resignFirstResponder];
    [toolsField resignFirstResponder];
    
    button.selected = ! button.selected;
    
    if ([button isSelected])
    {
        [button setBackgroundImage:[UIImage imageNamed:@"btn_keyboard_up.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"btn_keyboard_down.png"] forState:UIControlStateHighlighted];
        
        recordAudioButton.hidden = NO;
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"audio_up.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"audio_down.png"] forState:UIControlStateHighlighted];
        
        recordAudioButton.hidden = YES;
    }
}

- (void) choseEmoji
{
    recordAudioButton.hidden = YES;
    
    if([faceTextField isFirstResponder])
    {
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_up.png"] forState:UIControlStateNormal];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_down.png"] forState:UIControlStateHighlighted];
        
        [faceTextField resignFirstResponder];
        [inputField becomeFirstResponder];
    }
    else
    {
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"btn_keyboard_up.png"] forState:UIControlStateNormal];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"btn_keyboard_down.png"] forState:UIControlStateHighlighted];
        
        [inputField resignFirstResponder];
        [faceTextField becomeFirstResponder];
    }
}
- (void) chosePicture
{
    recordAudioButton.hidden = YES;
    
    if ([toolsField isFirstResponder])
    {
        [toolsField resignFirstResponder];
    }
    else
    {
        [audioButton setBackgroundImage:[UIImage imageNamed:@"audio_up.png"] forState:UIControlStateNormal];
        [audioButton setBackgroundImage:[UIImage imageNamed:@"audio_down.png"] forState:UIControlStateHighlighted];
        
        [toolsField becomeFirstResponder];
        [inputField resignFirstResponder];
        [faceTextField resignFirstResponder];
    }
}

#pragma mark - 按住说话
- (void)recordAudioDown:(id)sender
{
    CCLog(@"---Down");
    [self beginRecordByFileName];
}

- (void)recordAudioUpInside:(id)sender
{
    CCLog(@"---UpInside");
    [self removeRecoderView];

    if (curCount < 1.0)
    {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = NSLocalizedString(@"Too short to record", @"Too short to record");
        [HUD show:YES];
        [HUD hide:YES afterDelay:1];
        [HUD release];
        
        [[RecorderManager sharedManager] cancelRecording];
    }
    else
    {
        [[RecorderManager sharedManager] stopRecording];
    }
}

- (void)recordAudioUpOutside:(id)sender
{
    CCLog(@"---UpOutside");
    // 停止录音
    CCLog(@"Cancel send audio message");
    [[RecorderManager sharedManager] cancelRecording];
}

- (void)recordAudioDragEnter:(id)sender
{
    CCLog(@"---DragEnter");
    recorderView.countDownLabel.text = @"向上滑动取消发送";
    recorderView.countDownLabel.backgroundColor = [UIColor clearColor];
}

- (void)recordAudioDragExit:(id)sender
{
    CCLog(@"---DragExit");
    recorderView.countDownLabel.text = @"松开手指取消发送";
    recorderView.countDownLabel.backgroundColor = [UIColor redColor];
}

- (void)recordAudioCancel:(id)sender
{
    CCLog(@"---Cancel send audio message");
    // 停止录音
    [[RecorderManager sharedManager] cancelRecording];
}

- (void) removeRecoderView
{
    if (recorderView != nil)
    {
        [recorderView removeFromSuperview];
        recorderView = nil;
    }
}

#pragma mark - 开始录音
- (void)beginRecordByFileName
{
    [self stopPlayAudio];
    
    //设置文件名
    recordFileName = [self getMessageIdWithTimeAndUUID];
    NSString *recordFilePath = [RecorderManager getPathByFileName:recordFileName ofType:@"spx"];
    
    //还原计数
    curCount = 0;
    
    [RecorderManager sharedManager].delegate = self;
    [[RecorderManager sharedManager] startRecording:recordFilePath];
    
    //显示录音界面
    [self initRecordView];   
}

#pragma mark - 初始化录音界面
- (void)initRecordView
{
    if (recorderView == nil)
    {
        recorderView = (ChatRecorderView*)[[[[NSBundle mainBundle]loadNibNamed:@"ChatRecorderView" owner:self options:nil] lastObject] retain];
        recorderView.frame = self.view.frame;
        recorderView.metersView.layer.cornerRadius = 9.0;
        recorderView.metersView.layer.masksToBounds = YES;
        recorderView.metersView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        recorderView.metersView.layer.borderWidth = 1.0;
        recorderView.metersView.frame = kRecorderViewRect;
        [self.view addSubview:recorderView];
        [recorderView release];
    }
    //还原界面显示
    [recorderView restoreDisplay];
}

#pragma mark - UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [toolsField resignFirstResponder];
    
    if(buttonIndex == actionSheet.cancelButtonIndex) return;
    
    switch (actionSheet.tag)
    {
        case kTagActionSheetSelectImageSource:
        {
            if (buttonIndex == 0)
            {
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    CCLog(@"Error:没有照相设备");
                }
                else
                {
                    UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
                    cameraPicker.delegate = self;
                    cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)])
                    {
                        [self presentViewController:cameraPicker animated:YES completion:nil];
                    }
                    else
                    {
                        [self presentModalViewController:cameraPicker animated:YES];
                    }
                    [cameraPicker release];
                }
            }
            else if (buttonIndex == 1)
            {
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                {
                    CCLog(@"Error:无图片库");
                }
                else
                {
                    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
                    photoPicker.delegate = self;
                    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)])
                    {
                        [self presentViewController:photoPicker animated:YES completion:nil];
                    }
                    else
                    {
                        [self presentModalViewController:photoPicker animated:YES];
                    }
                    
                    [photoPicker release];
                }
            }
            
            break;
        }
        case kTagActionSheetDelAMsg:
        {
            SqliteHelper *helper = [[SqliteHelper alloc] init];
            [helper createDatabase];
            BOOL result = [helper deleteChatDataWithMsgId:manageMsgID andUserId:friendAccount];
            [helper closeDatabase];
            [helper release];
            
            if (result)
            {
                [bubbleData removeAllObjects];
                [self loadMsgHistoryData];
                [self needReloadTable];
                [manageMsgID release];
                manageMsgID = nil;
                
                [serverMsgId release];
                serverMsgId = nil;
                isLoading = NO;
            }
            else
            {
                //删除失败了
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                     message:NSLocalizedString(@"Fail to Delete", @"Fail to Delete")
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                           otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alertView show];
                [alertView release];
            }
            
            break;
        }
        case kTagActionSheetDelAllMsg:
        {
            SqliteHelper *helper = [[SqliteHelper alloc] init];
            [helper createDatabase];
            BOOL result = [helper deleteChatDataWithUserId:friendAccount];
            [helper closeDatabase];
            [helper release];
            
            if (result){
                [bubbleData removeAllObjects];
                [self loadMsgHistoryData];
                [self needReloadTable];
                
                [manageMsgID release];
                manageMsgID = nil;
                
                [serverMsgId release];
                serverMsgId = nil;
            }
            else
            {
                //删除失败了
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"Alert")
                                                                    message:NSLocalizedString(@"Fail to Delete", @"Fail to Delete")
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                [alertView show];
                [alertView release];
            }
            
            break;
        }
        case kTagActionSheetCallOut:
        {
            /*if (buttonIndex == (landsenabled ? 2 : 1)) {
             NSString* dialurl = [@"tel://" stringByAppendingString:dialNum];
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialurl]];
             break;
             }*/
            CALL_OUT_MODE mode = CALL_OUT_MODE_NONE;
            if ([calloption count])
            {
                int opt = [[calloption objectAtIndex:buttonIndex] integerValue];
                [calloption removeAllObjects];
                switch (opt)
                {
                    case CallOptionInnerCall:
                        mode = CALL_OUT_MODE_INNER;
                        break;
                    case CallOptionLandCall:
                        mode = CALL_OUT_MODE_LNAD;
                        break;
                    case CallOptionCallback:
                        mode = CALL_OUT_MODE_CALL_BACK;
                        break;
                    case CallOptionAddToContacts:
                        break;
                    case CallOptionDialViaCellphone:
                    {
                        BOOL ftime = [[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_FIRST_TIME_DIAL_VIA_CELL_PHONE];
                        if (ftime) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Note Info", @"Note Info")
                                                                            message:NSLocalizedString(@"The call will go out via your cell phone and you would be charged by your mobile service provide for this call.", @"The call will go out via your cell phone and you would be charged by your mobile service provide for this call.")
                                                                           delegate:self
                                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                            alert.tag = kTagAlertCallOutViaCellPhone;
                            [alert show];
                            [alert release];
                            
                            [[NgnEngine sharedInstance].configurationService setBoolWithKey:GENERAL_FIRST_TIME_DIAL_VIA_CELL_PHONE andValue:NO];
                            return;
                        }
                        
                        NSString* dialurl = [@"tel://" stringByAppendingString:dialNumber];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialurl]];
                        return;
                    }
                }
                
            }
    #if 0
            BOOL found = [[NgnEngine sharedInstance].contactService dbIsWeiCallUser:dialNum];
            if (weicall && !found) {
                // No WeiCall User, could not make WeiCall call
                [self showInviteMessageView:dialNum andContentType:kContentTypeDefault];
                break;
            }
    #endif
            if (videocallout) {
                [CallViewController makeAudioVideoCallWithRemoteParty:dialNumber andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] andCalloutMode:mode];
            } else {
                [CallViewController makeAudioCallWithRemoteParty:dialNumber andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] andCalloutMode:mode];
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    if (actionSheet.tag == kTagActionSheetCallOut)
    {
        if (SystemVersion < 7.0)
        {
            int i = 0;
            NSArray *subviews = [actionSheet subviews];
            for (UIView *v in subviews) {
                if ([v isKindOfClass:[UIButton class]]) {
                    UIButton *b = (UIButton*)v;
                    [b setBackgroundImage:[UIImage imageNamed:(i==actionSheet.cancelButtonIndex) ? @"Action_Sheet_BG_Red.png" : @"Action_Sheet_BG_Blue.png"] forState:UIControlStateNormal];
                    [b setBackgroundImage:[UIImage imageNamed:(i==actionSheet.cancelButtonIndex) ? @"Action_Sheet_BG_Red_Pressed.png" : @"Action_Sheet_BG_Blue_Pressed.png"] forState:UIControlStateHighlighted];
                    b.titleLabel.textColor = [UIColor whiteColor];
                    i++;
                }
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [picker dismissModalViewControllerAnimated:YES];
    }
    
    UIImage *imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    IMSelectImgViewController *selectImgViewController = [[IMSelectImgViewController alloc] initWithNibName:@"IMSelectImgViewController" bundle:nil];
    selectImgViewController.selectedImg = imagePicked;
    selectImgViewController.selectImgDelegate = self;
    selectImgViewController.viewType = IMSelectImgViewTypeSelectImg;
    [self.navigationController pushViewController:selectImgViewController animated:YES];
    [selectImgViewController release];
}

#pragma mark - VoiceRecordeDelegate
// 图片下载完成 刷新界面列表
- (void) imageHasLoaded:(NSNotification *)notification
{
    UIImage *image = (UIImage *)notification.object;
    NSString *msgID = [notification.userInfo objectForKey:@"dataID"];
    
    [self saveMsgImage:image andMsgID:msgID];
    
    [chatContentTable reloadData];
}

- (void) needReloadTable
{
    CCLog(@"刷新列表");
    [chatContentTable reloadData];
    
    if (chatContentTable.contentSize.height > chatContentTable.frame.size.height)
    {
        [chatContentTable setContentOffset:CGPointMake(0, chatContentTable.contentSize.height - chatContentTable.frame.size.height)];
    }
}

// 音频下载完成
- (void) wavHasBeenReady:(NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    CCLog(@"%@", [notification description]);
    NSString *localMsgId = [userInfo objectForKey:@"messageId"];
    NSString *filePath = [userInfo objectForKey:@"FilePath"];
    NSNumber *isplay = [userInfo objectForKey:@"isPlay"];
    NSString *senderUser = [userInfo objectForKey:@"senderUser"];
    NSString *duration = [userInfo objectForKey:@"audioDuration"];
    NSDate *date = [userInfo objectForKey:@"date"];
    
    if ([senderUser isEqualToString:friendAccount])
    {
        NSBubbleData *elseBubble =  [NSBubbleData dataWithAudioPath:filePath audioTimeLength:[duration intValue] date:date type:BubbleTypeSomeoneElse];
        elseBubble.fileType = FileType_Audio;
        elseBubble.dataID = localMsgId;
        elseBubble.avatar = self.friendAvatar;
        [bubbleData addObject:elseBubble];
        
        [self needReloadTable];
    }
    
    if ([isplay boolValue] == YES)
    {
        // 播放
        [self startPlayAudioPath:filePath];
    }

}

#pragma mark - Recording & Playing Delegate
- (void)recordingFinishedWithFileName:(NSString *)audioFilePath time:(NSTimeInterval)interval {
    CCLog(@"录音结束");
    //该函数可能还是子线程,造成页面显示不正确
    dispatch_async(dispatch_get_main_queue(), ^{
    NSData *audioData = [NSData dataWithContentsOfFile:audioFilePath];
    CCLog(@"recordFilePath=%@, lenght=%d", audioFilePath, [audioData length]);
    
    // 加入界面元素
    NSString *messageId= [self getMessageIdWithTimeAndUUID];
    NSBubbleData *mineBubble = [NSBubbleData dataWithAudioPath:audioFilePath audioTimeLength:[[NSNumber numberWithFloat:curCount] integerValue] date:[NSDate date] type:BubbleTypeMine];
    mineBubble.avatar = self.mineAvatar;
    mineBubble.dataID = messageId;
    mineBubble.fileType = FileType_Audio;
    [bubbleData addObject:mineBubble];
    
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];
    // 存入本地消息记录
    NSMutableDictionary *messageDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    [messageDictionary setObject:messageId forKey:@"MessageId"];
    [messageDictionary setObject:username forKey:@"Sender"];
    [messageDictionary setObject:friendAccount forKey:@"Receiver"];
    [messageDictionary setObject:@"" forKey:@"Message"];
    [messageDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"MessageType"];
    [messageDictionary setObject:[NSNumber numberWithInteger:FileType_Audio] forKey:@"FileType"];
    [messageDictionary setObject:audioFilePath forKey:@"MediaURL"];
    [messageDictionary setObject:@"" forKey:@"OrgMediaURL"];
    [messageDictionary setObject:[NSString stringWithFormat:@"%d", (int)curCount] forKey:@"AudioDuration"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [messageDictionary setObject:[df stringFromDate:[NSDate date]] forKey:@"CreateTime"];
    [df release];
    [messageDictionary setObject:[NSNumber numberWithInteger:1] forKey:@"Status"];
    [messageDictionary setObject:[NSNumber numberWithInteger:IMSendStatusSending] forKey:@"SendStatus"];
    [messageDictionary setObject:@"" forKey:@"ServerMsgId"];
    [messageDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"MsgReadStatus"];
    
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    [helper insertDataToChatInfoTable:messageDictionary imageData:nil];
    [helper closeDatabase];
    [helper release];
    
    [self needReloadTable];
    
    if (isGroup)
    {
        [[IMWebInterface sharedInstance] sendChatMediaResourceRequest:username to:friendAccount data:audioData fileType:@"2" type:@"1" andMsgID:messageId andAudioTime:[NSString stringWithFormat:@"%d", (int)curCount]];
    }
    else
    {
        [[IMWebInterface sharedInstance] sendChatMediaResourceRequest:username to:friendAccount data:audioData fileType:@"2" type:@"0" andMsgID:messageId andAudioTime:[NSString stringWithFormat:@"%d", (int)curCount]];
    }
    });
}

- (void)recordingTimeout {
    CCLog(@"录音超时");
    
    //这里录音超时不准确,会到60.8秒左右
    
    curCount = 0;
}

- (void)recordingStopped {
    [self removeRecoderView];
}

- (void)recordingFailed:(NSString *)failureInfoString {
    curCount = 0;
    //录音失败时 移除录音视图
    [self removeRecoderView];
    CCLog(@"failed:%@", failureInfoString);
}

//更新音频峰值
- (void)levelMeterChanged:(float)levelMeter {
    //CCLog(@"-------%f", curCount);
    //更新峰值
    [recorderView updateMetersByAvgPower:levelMeter];
    
    //倒计时
    if (curCount >= [[RecorderManager sharedManager] maxRecordTime] - 10 && curCount < [[RecorderManager sharedManager] maxRecordTime])
    {
        //剩下10秒
        recorderView.countDownLabel.text = [NSString stringWithFormat:@"录音剩下:%d秒",(int)([[RecorderManager sharedManager] maxRecordTime]-curCount)];
    }
    else if (curCount >= [[RecorderManager sharedManager] maxRecordTime])
    {
        //时间到
        [[RecorderManager sharedManager] stopRecording];
        [self removeRecoderView];
    }
    curCount += 0.1f;
}

- (void)playingStoped {
    self.isPlaying = NO;
    CCLog(@"停止播放");
    
    CCLog(@"retainCount = %d", [self retainCount]);
    self.lastPlayAudioPath = nil;
    
    if (playAudioTimer)
    {
        [playAudioTimer invalidate];
        playAudioTimer = nil;
    }
    
    UIImageView *imageView = (UIImageView *)clickBubbleDateView.view;
    
    if (clickBubbleDateView.type == BubbleTypeMine)
    {
        imageView.image = [UIImage imageNamed:@"micMine"];
    }
    else
    {
        imageView.image = [UIImage imageNamed:@"micSomeone"];
    }
}

#pragma mark - 播放音频
- (void) startPlayAudioPath:(NSString *)localAudioPath
{
    
    if ([lastPlayAudioPath isEqualToString:localAudioPath])
    {
        [self stopPlayAudio];  //再次点击时停止播放
    }
    else
    {
        //[playManager stopPlaying];      //这里不管是否正在播放都要先停止上一个语音
        
        if (playAudioTimer)
        {
            [playAudioTimer invalidate];
            playAudioTimer = nil;
        }
        
        //启动播放音频效果动画
        playAudioTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self
                                                        selector:@selector(updatePlayingAudioStats:)
                                                        userInfo:nil
                                                         repeats:YES];
        
        [PlayerManager sharedManager].delegate = nil;
        //播放前停止上一次播放,已经PlayerManager内部实现
        [[PlayerManager sharedManager] playAudioWithFileName:localAudioPath delegate:self];
        self.lastPlayAudioPath = localAudioPath;

        self.isPlaying = YES;
    }
}

- (void) stopPlayAudio
{
    if (self.isPlaying)
    {
        [[PlayerManager sharedManager] stopPlaying];
    }
}

#pragma mark - FacialViewDelegate
-(void)selectedFacialView:(NSString*)str
{
    if ([str isEqualToString:@"1111"])
    {
        NSString *oldText = inputField.text;
        NSRange cursor = inputField.selectedRange;
        NSRange range_left = [oldText rangeOfString:@"[" options:NSBackwardsSearch];
        NSRange range_right = [oldText rangeOfString:@"]" options:NSBackwardsSearch];
        
        NSString *newText = oldText;
        if (range_left.location != NSNotFound && range_left.location != NSNotFound && range_left.location < range_right.location && range_right.location == cursor.location - 1)
            newText = [oldText substringToIndex:range_left.location];
        else
        {
            if ([oldText length])
                newText = [oldText substringToIndex:[oldText length] - 1];
        }
        
        inputField.text = newText;
    }
    else
    {
        NSMutableString *faceString = [[[NSMutableString alloc] initWithString:@"["] autorelease];
        NSString *displayText = [faceDictionary objectForKey:str];
        [faceString appendString:displayText];
        [faceString appendString:@"]"];
        
        NSRange cursor = inputField.selectedRange;
        NSString *leftString = @"";
        NSString *rightString = @"";
        
        if (cursor.location == 0 && inputField.text.length > 0)
        {
            rightString = [inputField.text substringFromIndex:0];
        }
        else if(cursor.location > 0 && cursor.location < inputField.text.length)
        {
            leftString = [inputField.text substringToIndex:cursor.location];
            rightString = [inputField.text substringFromIndex:cursor.location];
        }
        else if(cursor.location == inputField.text.length)
        {
            leftString = inputField.text;
        }
        
        inputField.text = [NSString stringWithFormat:@"%@%@%@",leftString,faceString,rightString];
        
        inputField.selectedRange = NSMakeRange(leftString.length + faceString.length,0);
    }
}

#pragma mark
#pragma mark ToolsViewDelegate
- (void)selectedTools:(ToolsViewButtonType)btnType
{
    switch (btnType)
    {
        case ToolsViewButtonTypeImage:    //选择图片
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
            actionSheet.tag = kTagActionSheetSelectImageSource;
            [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
            [actionSheet release];
            
            break;
        }
        case ToolsViewButtonTypePhone:      //打电话
        {
            [self makeCall];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark
#pragma mark IMSelectImgDelegate
- (void)selectedImageType:(UIImage *)image
{
    UIProgressView *progressView = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
    
    NSString *messageId = [self getMessageIdWithTimeAndUUID];
    NSBubbleData *mineBubble = [NSBubbleData dataWithImage:image date:[NSDate date] type:BubbleTypeMine];
    mineBubble.avatar = self.mineAvatar;
    mineBubble.dataID = messageId;
    mineBubble.fileType = FileType_Photo;
    mineBubble.progressView = progressView;
    [bubbleData addObject:mineBubble];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [[EGOCache currentCache] setData:imageData forKey:messageId];
    
    NSString *saveLocalPath = [self saveMsgData:imageData andMsgID:messageId];
    NSString *username = [[CloudCall2AppDelegate sharedInstance] getUserName];
    // 存入本地消息记录
    NSMutableDictionary *messageDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    [messageDictionary setObject:messageId forKey:@"MessageId"];
    [messageDictionary setObject:username forKey:@"Sender"];
    [messageDictionary setObject:friendAccount forKey:@"Receiver"];
    [messageDictionary setObject:@"" forKey:@"Message"];
    [messageDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"MessageType"];
    [messageDictionary setObject:[NSNumber numberWithInteger:FileType_Photo] forKey:@"FileType"];
    [messageDictionary setObject:@"" forKey:@"MediaURL"];
    [messageDictionary setObject:saveLocalPath forKey:@"OrgMediaURL"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [messageDictionary setObject:[df stringFromDate:[NSDate date]] forKey:@"CreateTime"];
    [df release];
    [messageDictionary setObject:[NSNumber numberWithInteger:1] forKey:@"Status"];
    [messageDictionary setObject:[NSNumber numberWithInteger:IMSendStatusSending] forKey:@"SendStatus"];
    [messageDictionary setObject:@"" forKey:@"ServerMsgId"];
    [messageDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"MsgReadStatus"];
    
    SqliteHelper *helper = [[SqliteHelper alloc] init];
    [helper createDatabase];
    [helper insertDataToChatInfoTable:messageDictionary imageData:nil];
    [helper closeDatabase];
    [helper release];
    
    [self needReloadTable];
    
    NSString* strFileType = [NSString stringWithFormat:@"%d", FileType_Photo];
    if (isGroup)
    {
        [[IMWebInterface sharedInstance] sendChatMediaResourceRequest:username to:friendAccount data:imageData fileType:strFileType type:@"1" andMsgID:messageId andAudioTime:nil];
    }
    else
    {
        [[IMWebInterface sharedInstance] sendChatMediaResourceRequest:username to:friendAccount data:imageData fileType:strFileType type:@"0" andMsgID:messageId andAudioTime:nil andProcessView:progressView];
    }
}

#pragma mark
#pragma mark CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)_popTipView
{
    // Any cleanup code, such as releasing a CMPopTipView instance variable, if necessary
    popTipView = nil;
    self.currentPopTipViewSender = nil;
}

#pragma mark
#pragma mark UIKeyboardWillShowNotification
// 键盘展示
- (void) keyBoardWillShow:(NSNotification *) notification
{
    NSDictionary* info = [notification userInfo];
    
    // 获取键盘大小
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // 获取动画时间
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        accsoryView.frame = CGRectMake(0, self.view.frame.size.height - 44 - keyboardSize.height, 320, 44);
        chatContentTable.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - 44 - keyboardSize.height);
        if (chatContentTable.contentSize.height > chatContentTable.frame.size.height)
        {
            [chatContentTable setContentOffset:CGPointMake(0, chatContentTable.contentSize.height - chatContentTable.frame.size.height)];
        }
    }];
    
    isKeyBoardShow = YES;
}

// 键盘消失
- (void) keyBoardWillHide:(NSNotification *) notification
{
    NSDictionary* info = [notification userInfo];
    
    // 获取动画时间
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        accsoryView.frame = CGRectMake(0, self.view.frame.size.height - 44, 320, 44);
        chatContentTable.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - 44);
        if (chatContentTable.contentSize.height > chatContentTable.frame.size.height)
        {
            [chatContentTable setContentOffset:CGPointMake(0, chatContentTable.contentSize.height - chatContentTable.frame.size.height)];
        }
    } completion:^(BOOL finished) {
    }];
    
    isKeyBoardShow = NO;
}
@end
