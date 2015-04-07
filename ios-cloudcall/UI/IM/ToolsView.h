//
//  ToolsView.h
//  CloudCall
//
//  Created by Sergio on 13-7-22.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

typedef enum {
    ToolsViewButtonTypeImage = 0,   //图片按钮
    ToolsViewButtonTypePhone        //通话按钮
}ToolsViewButtonType;

#import <UIKit/UIKit.h>

@protocol ToolsViewDelegate <NSObject>

-(void)selectedTools:(ToolsViewButtonType)btnType;

@end

@interface ToolsView : UIView
{
    id<ToolsViewDelegate> delegate;
}

@property (nonatomic,assign) id<ToolsViewDelegate> delegate;

- (void)loadToolsView;

@end
