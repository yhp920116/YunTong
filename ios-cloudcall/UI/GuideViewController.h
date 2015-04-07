//
//  EXTeachViewController.h
//  ZhuanPianYi
//
//  Created by chenqi on 12-7-11.
//  Copyright (c) 2012年 zhongxun music beijing LTD.,. All rights reserved.
//;

#import <UIKit/UIKit.h>

@interface GuideViewController : UIViewController<UIScrollViewDelegate>
{
    IBOutlet UIScrollView* mScrollView;
    UIPageControl *pageControl;
    int m_nIndex;
    CGPoint mStartPos;
    BOOL mIsFirstMove;
    
    int totalPages;
}

@end
