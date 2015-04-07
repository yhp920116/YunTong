//
//  NetWorkExcCell.h
//  CloudCall
//
//  Created by Sergio on 13-4-12.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetWorkExcCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UILabel *label;
@property (nonatomic,retain) IBOutlet UIButton *btnDetail;

- (void)setNetworkExcCell:(NSString *)labelString;
@end
