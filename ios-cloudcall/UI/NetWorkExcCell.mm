//
//  NetWorkExcCell.m
//  CloudCall
//
//  Created by Sergio on 13-4-12.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "NetWorkExcCell.h"

@implementation NetWorkExcCell
@synthesize label;
@synthesize btnDetail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNetworkExcCell:(NSString *)labelString
{
    self.label.text = labelString;
    self.backgroundColor = [UIColor colorWithRed:252.0/255.0 green:228.0/255.0 blue:214.0/255.0 alpha:1.0];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:206.0/255.0 blue:183.0/255.0 alpha:1.0];
}

- (void)dealloc
{
    [label release];
    [btnDetail release];
    
    [super dealloc];
}
@end
