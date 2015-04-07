//
//  FacialView.m
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacialView.h"

@implementation FacialView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		//[self addSubview:loadFacial];
    }
    return self;
}
-(void)loadFacialView:(int)page size:(CGSize)size type:(int)type
{
    if (type == 0)
    {
        //row number
        for (int i=0; i<3; i++)
        {
            //column numer
            for (int y=0; y<7; y++)
            {
                //表情个数小于105
                if ((i * 7 + y + (page * 20)) > 76 && (i * y) != 12) continue;
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                
                if (i == 2 && y == 6)
                {
                    button.tag = 1111;
                    [button setImage:[UIImage imageNamed:@"btn_imemoji_del_up"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"btn_imemoji_del_down"] forState:UIControlStateHighlighted];
                    [button setFrame:CGRectMake(y * size.width + 8, i * size.height + 17, 29, 24)];
                }
                else
                {
                    NSString *imageName = [NSString stringWithFormat:@"%d",i * 7 + y + (page * 20)];
                    switch ([imageName length]) {
                        case 1:
                            imageName = [NSString stringWithFormat:@"00%@",imageName];
                            break;
                        case 2:
                            imageName = [NSString stringWithFormat:@"0%@",imageName];
                            break;
                        default:
                            break;
                    }
                    button.tag = i * 7 + y + (page * 20);
                    
                    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                    [button setFrame:CGRectMake(y * size.width + 15, i * size.height + 15, 30, 30)];
                }
                [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:button];
            }
        }
    }
	else
    {
        //ccEmojiView 云呼表情
        for (int i=0; i<2; i++) {
            //column numer
            for (int y=0; y<7; y++) {
                UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                NSString *imageName=[NSString stringWithFormat:@"%d",i*7+y+(page*28)];
                switch ([imageName length]) {
                    case 1:
                        imageName=[NSString stringWithFormat:@"00%@",imageName];
                        break;
                    case 2:
                        imageName=[NSString stringWithFormat:@"0%@",imageName];
                        break;
                    default:
                        break;
                }
                [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                [button setFrame:CGRectMake(0+y*size.width, 0+i*size.height, size.width, size.height)];
                button.tag=i*7+y+(page*28);
                [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:button];
            }
        }
    }
}


-(void)selected:(UIButton*)bt
{
	NSString *str=[NSString stringWithFormat:@"%d",bt.tag];
	
	switch ([str length]) {
		case 1:
			str=[NSString stringWithFormat:@"00%@",str];
			break;
		case 2:
			str=[NSString stringWithFormat:@"0%@",str];
			break;
		default:
			break;
	}
	[delegate selectedFacialView:str];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc
{
    [super dealloc];
}


@end
