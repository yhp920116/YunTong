//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import "SqliteHelper.h"
#import "StaticUtils.h"

#define kNotificationImageViewSingleClick   @"kNotificationImageViewSingleClick"
#define kNotificationImageViewLongPress     @"kNotificationImageViewLongPress"
#define kNotificationBtnResendMsgEvent      @"kNotificationBtnResendMsgEvent"

@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIButton *avatarImage;

@end

@implementation UIBubbleTableViewCell

@synthesize bubbleData = _bubbleData;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarImage = _avatarImage;
@synthesize isAddProgress;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.bubbleData = nil;
    self.customView = nil;
    self.bubbleImage = nil;
    self.avatarImage = nil;
    [super dealloc];
}
#endif

- (void)setDataInternal:(NSBubbleData *)value
{
	self.bubbleData = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    if (!self.bubbleImage)
    {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];        
#endif
        [self addSubview:self.bubbleImage];
    }
    
    NSBubbleType type = self.bubbleData.type;
    
    CGFloat width = self.bubbleData.view.frame.size.width;
    CGFloat height = self.bubbleData.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.bubbleData.insets.left - self.bubbleData.insets.right;
    CGFloat y = 10;
    
    // Adjusting the x coordinate for avatar
    if (self.showAvatar)
    {
        [self.avatarImage removeFromSuperview];
#if !__has_feature(objc_arc)
        self.avatarImage = [UIButton buttonWithType:UIButtonTypeCustom];
#else
        self.avatarImage = [UIButton buttonWithType:UIButtonTypeCustom];
#endif
        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 10 : self.frame.size.width - 50;
        CGFloat avatarY = 10;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 40, 40);
        [self.avatarImage setImage:self.bubbleData.avatar forState:UIControlStateNormal];

        [self.avatarImage addTarget:self action:@selector(onAvatarClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.avatarImage];
        
//        CGFloat delta = 10+self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
//        if (delta > 0)
//            y = delta;
        
        if (type == BubbleTypeSomeoneElse)
            x += 54;
        if (type == BubbleTypeMine)
            x -= 54;
    }
    
    [self.customView removeFromSuperview];
    self.customView = self.bubbleData.view;
    CGRect labelRect;       //语音时长,发送失败标志,发送状态标志 的位置
    
    if (_bubbleData.fileType == FileType_Audio)
    {
        CGFloat audioFrameWidth = 0;
        if (self.bubbleData.audioDuration <= 40)
            audioFrameWidth = self.bubbleData.audioDuration*4;
        else
            audioFrameWidth = 160.0f;
        
        
        NSString *timeText = [NSString stringWithFormat:@"%d\"", self.bubbleData.audioDuration];
        //计算字符宽度
        UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        CGSize size = [(timeText ? timeText : @"") sizeWithFont:font constrainedToSize:CGSizeMake(40, 100) lineBreakMode:NSLineBreakByWordWrapping];
        
        if (type == BubbleTypeMine)
        {
            self.customView.frame = CGRectMake(x+27, y+9, width, height);
            self.bubbleImage.frame = CGRectMake(x-audioFrameWidth, y, width + self.bubbleData.insets.left + self.bubbleData.insets.right+audioFrameWidth, self.avatarImage.frame.size.height);
            labelRect = CGRectMake(self.bubbleImage.frame.origin.x-23, self.bubbleImage.frame.size.height/2 + 4, size.width, 15);
        }
        else
        {
            self.customView.frame = CGRectMake(x+8, y+9, width, height);
            self.bubbleImage.frame = CGRectMake(x, y, width + self.bubbleData.insets.left + self.bubbleData.insets.right+audioFrameWidth, self.avatarImage.frame.size.height);
            labelRect = CGRectMake(self.bubbleImage.frame.origin.x+self.bubbleImage.frame.size.width+5, self.bubbleImage.frame.size.height/2 + 3, size.width, 15);
            
            SqliteHelper *helper = [[SqliteHelper alloc] init];
            [helper createDatabase];
            BOOL isRead = [helper selectMsgReadStatusByMsgId:self.bubbleData.dataID];
            [helper closeDatabase];
            [helper release];
            
            if (!isRead)
            {
                UIImageView *unReadSymbol = (UIImageView *)[self.contentView viewWithTag:1000];
                if (unReadSymbol == nil)
                {
                    unReadSymbol = [[UIImageView alloc] initWithFrame:CGRectMake(labelRect.origin.x+labelRect.size.width+3, labelRect.origin.y, 10, 10)];
                    unReadSymbol.image = [UIImage imageNamed:@"unRead_audio_msg"];
                    unReadSymbol.tag = 1000;
                    [self.contentView addSubview:unReadSymbol];
                    [unReadSymbol release];
                }
            }
            else
            {
                UIImageView *unReadSymbol = (UIImageView *)[self.contentView viewWithTag:1000];
                if (unReadSymbol != nil)
                {
                    [unReadSymbol removeFromSuperview];
                    unReadSymbol = nil;
                }
            }
            
        }
        UILabel *durationLabel = [[[UILabel alloc] initWithFrame:labelRect] autorelease];
        durationLabel.numberOfLines = 0;
        durationLabel.lineBreakMode = NSLineBreakByWordWrapping;
        durationLabel.text = timeText;
        durationLabel.font = font;
        durationLabel.tag = 1001;
        durationLabel.textColor = [UIColor blueColor];
        durationLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:durationLabel];
    }
    else
    {
        self.customView.frame = CGRectMake(x + self.bubbleData.insets.left, y + self.bubbleData.insets.top, width, height);

        self.bubbleImage.frame = CGRectMake(x, y, width + self.bubbleData.insets.left + self.bubbleData.insets.right, height + self.bubbleData.insets.top + self.bubbleData.insets.bottom);
        labelRect = CGRectMake(self.bubbleImage.frame.origin.x-23, self.bubbleImage.frame.size.height/2 + 4, 15, 15);
    }
    
    [self addSubview:self.customView];
        
    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone_up"] stretchableImageWithLeftCapWidth:15 topCapHeight:27];

    }
    else {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine_up"] stretchableImageWithLeftCapWidth:15 topCapHeight:27];
        
        SqliteHelper *helper = [[SqliteHelper alloc] init];
        [helper createDatabase];
        IMMsgHistory *msghistory = [helper selectMessageRecordFromByMessageID:self.bubbleData.dataID];
        [helper closeDatabase];
        [helper release];
        
        UILabel *durationLabel  = (UILabel *)[self.contentView viewWithTag:1001];
        if (msghistory.SendStatus == IMSendStatusSendFail) {
            if (durationLabel != nil)
            {
                durationLabel.hidden = YES;
                //NSLog(@"durationLabel:%@", durationLabel.text);
            }
            //chong'fa
            UIButton *btnResend = [[UIButton alloc] initWithFrame:CGRectMake(labelRect.origin.x, (y + self.bubbleImage.frame.size.height) / 2 - 8, 20, 20)];
            [btnResend setTitle:@"" forState:UIControlStateNormal];
            [btnResend setBackgroundImage:[UIImage imageNamed:@"im_resend_up.png"] forState:UIControlStateNormal];
            [btnResend setBackgroundImage:[UIImage imageNamed:@"im_resend_down.png"] forState:UIControlStateHighlighted];
            [btnResend addTarget:self action:@selector(onResendButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btnResend];
            [btnResend release];        
        }
        else if(msghistory.SendStatus == IMSendStatusSending && _bubbleData.fileType != FileType_Photo)
        {
            if (durationLabel != nil)
                durationLabel.hidden = YES;
            
            //fa'song
            UIActivityIndicatorView *activityIndication = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityIndication setFrame:CGRectMake(labelRect.origin.x, (y + self.bubbleImage.frame.size.height) / 2 - 8, 20, 20)];
            [self.contentView addSubview:activityIndication];
            [activityIndication startAnimating];
            [activityIndication release];
            
        }
        else
        {
            if (durationLabel != nil)
                durationLabel.hidden = NO;
        }
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:self.bubbleImage.frame];
    
    button.userInteractionEnabled = YES;
    
    [button addTarget:self action:@selector(onImageViewSingleClick) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(setBubbleImageBGUp) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(setBubbleImageBGUp) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(setBubbleImageBGUp) forControlEvents:UIControlEventTouchDragOutside];
    //long press event
    UILongPressGestureRecognizer *viewLongGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onImageViewLongPress:)];
    [button addGestureRecognizer:viewLongGestureRecognizer];
    [viewLongGestureRecognizer release];
    
    [self addSubview:button];
    
    if (type == BubbleTypeMine && _bubbleData.fileType == FileType_Photo && self.bubbleData.progressView && self.bubbleData.progressView != nil && isAddProgress)
    {
        progressTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(refreshProcess) userInfo:nil repeats:YES];
        
        hud = [[MBProgressHUD alloc] initWithView:self.bubbleImage];
        hud.minSize = self.bubbleImage.frame.size;
        hud.labelFont = [UIFont systemFontOfSize:14];
        hud.labelText = [NSString stringWithFormat:@"%.0f%%",self.bubbleData.progressView.progress * 100];
        [self.customView addSubview:hud];
        [hud show:YES];
    }

    [self becomeFirstResponder];
}

- (void)onAvatarClick:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onAvatarClick" object:self.bubbleData];
}


/**
 *	@brief	ImageView Single Click
 */
- (void)onImageViewSingleClick
{
    [self setBubbleImageBGDown];
    //点击的时候,就把小红点去掉,原本应该在语音下载并播放完成之后才去掉小红点的.但是那样实现太麻烦了.
    if (self.bubbleData.fileType == FileType_Audio && self.bubbleData.type == BubbleTypeSomeoneElse)
    {
        UIImageView *unReadSymbol = (UIImageView *)[self.contentView viewWithTag:1000];
        if (unReadSymbol != nil)
        {
            [unReadSymbol removeFromSuperview];
            unReadSymbol = nil;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationImageViewSingleClick object:self.bubbleData];
    
//    [self setBubbleImageBGUp];
}

- (void)setBubbleImageBGUp
{
    NSBubbleType type = self.bubbleData.type;
    if (type == BubbleTypeSomeoneElse)
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone_up"] stretchableImageWithLeftCapWidth:15 topCapHeight:27];
    else
        
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine_up"] stretchableImageWithLeftCapWidth:15 topCapHeight:27];
}

- (void)setBubbleImageBGDown
{
    NSBubbleType type = self.bubbleData.type;
    if (type == BubbleTypeSomeoneElse)
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone_down"] stretchableImageWithLeftCapWidth:15 topCapHeight:27];
    else
        
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine_down"] stretchableImageWithLeftCapWidth:15 topCapHeight:27];
}

/**
 *	@brief	ImageView Long Press
 */
- (void)onImageViewLongPress:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationImageViewLongPress object:self.bubbleData];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setBubbleImageBGUp) userInfo:nil repeats:NO];
}

/**
 *	@brief	ImageView Long Press
 */
- (void)onResendButtonClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBtnResendMsgEvent object:self.bubbleData];
}

- (void)refreshProcess
{
    if (self.bubbleData.progressView && self.bubbleData.progressView != nil)
    {
        hud.labelText = [NSString stringWithFormat:@"%.0f%%",self.bubbleData.progressView.progress * 100];
        NSLog(@"progress:%.0f%%",self.bubbleData.progressView.progress * 100);
        
        if (self.bubbleData.progressView.progress == 1)
        {
            [progressTimer invalidate];
            progressTimer = nil;
            
            [hud hide:YES];
            
            if (hud) {
                [hud release];
                hud = nil;
            }
            
            self.bubbleData.progressView = nil;
        }
    }
    else
    {
        //防止重复执行
        if (progressTimer)
        {
            [progressTimer invalidate];
            progressTimer = nil;
        }
        
        if (hud)
        {
            [hud hide:YES];
            [hud release];
            hud = nil;
        }
    }
}

@end
