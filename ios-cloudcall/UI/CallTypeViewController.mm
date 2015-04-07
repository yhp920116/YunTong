//
//  CallTypeViewController.m
//  CloudCall
//
//  Created by Sergio on 13-5-17.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "CallTypeViewController.h"

@implementation CallTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"YunTong Type", @"YunTong Type");
    [self.navigationController setNavigationBarHidden:NO];
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(back:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    CGRect frame = CGRectMake(0, 0, 320, 460);
    
    if (iPhone5) {
        frame = CGRectMake(0, 0, 320, 550);
    }
    if (SystemVersion>=7)
    {
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height+20);
    }
    
    UIScrollView *introduceView = [[UIScrollView alloc] initWithFrame:frame];
    introduceView.delegate = self;
    introduceView.scrollEnabled = YES;
    introduceView.contentSize = CGSizeMake(320, 850);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -70, 320, 880)];
    imageView.image = [UIImage imageNamed:@"dial_way_introduce"];
    [introduceView addSubview:imageView];
    [imageView release];
    [self.view addSubview:introduceView];
    [introduceView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
