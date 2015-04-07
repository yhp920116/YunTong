//
//  ChatRecorderView.h
//  Jeans
//
//  Created by Jeans on 3/24/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRecorderViewRect       CGRectMake(110, iPhone5?198:160, 100, 100)

@interface ChatRecorderView : UIView

@property (retain, nonatomic) IBOutlet UIView *metersView;
@property (retain, nonatomic) IBOutlet UIImageView *peakMeterIV;
@property (retain, nonatomic) IBOutlet UILabel *countDownLabel;

//还原界面
- (void)restoreDisplay;

//更新音频峰值
- (void)updateMetersByAvgPower:(float)_avgPower;

@end
