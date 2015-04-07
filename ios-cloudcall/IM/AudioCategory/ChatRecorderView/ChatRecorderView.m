//
//  ChatRecorderView.m
//  Jeans
//
//  Created by Jeans on 3/24/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import "ChatRecorderView.h"
#import <QuartzCore/QuartzCore.h>

@interface ChatRecorderView(){
    NSArray         *peakImageAry;
    NSArray         *trashImageAry;
    BOOL            isPrepareDelete;
    BOOL            isTrashCanRocking;
}

@end

@implementation ChatRecorderView
@synthesize countDownLabel=_countDownLabel;
@synthesize metersView = _metersView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initilization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilization];
    }
    return self;
}

- (void)initilization{
    
    //初始化音量peak峰值图片数组
    peakImageAry = [[NSArray alloc]initWithObjects:
                    [UIImage imageNamed:@"mic_1.png"],
                    [UIImage imageNamed:@"mic_2.png"],
                    [UIImage imageNamed:@"mic_3.png"],
                    [UIImage imageNamed:@"mic_4.png"],
                    [UIImage imageNamed:@"mic_5.png"],nil];
}

- (void)dealloc {
    [peakImageAry release];
    [trashImageAry release];
    [_peakMeterIV release];
    [_countDownLabel release];
    [_metersView release];
    
    [super dealloc];
}

#pragma mark -还原显示界面
- (void)restoreDisplay{
    //还原录音图
    _peakMeterIV.image = [peakImageAry objectAtIndex:0];

    //还原倒计时文本
    _countDownLabel.text = @"向上滑动取消发送";
    _countDownLabel.backgroundColor = [UIColor clearColor];
}

#pragma mark - 更新音频峰值
- (void)updateMetersByAvgPower:(float)_avgPower{
    NSInteger imageIndex = 0;
    if (_avgPower >= 0.05 && _avgPower < 0.2)
        imageIndex = 0;
    else if (_avgPower >= 0.2 && _avgPower < 0.4)
        imageIndex = 1;
    else if (_avgPower >= 0.4 && _avgPower < 0.6)
        imageIndex = 2;
    else if (_avgPower >= 0.6 && _avgPower < 0.8)
        imageIndex = 3;
    else if (_avgPower >= 0.8)
        imageIndex = 4;
    
    _peakMeterIV.image = [peakImageAry objectAtIndex:imageIndex];
}

@end
