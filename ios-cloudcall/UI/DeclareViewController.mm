//
//  DeclareViewController.m
//  CloudCall
//
//  Created by CloudCall on 12-8-24.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import "DeclareViewController.h"

@interface DeclareViewController ()

@end

@implementation DeclareViewController
@synthesize DeclareTextView;

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
    self.title = NSLocalizedString(@"Disclaimer", @"Disclaimer");
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToSetting:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    // Do any additional setup after loading the view from its nib.
    DeclareTextView.text = NSLocalizedString(@"Declare Content", @"Declare Content");
}

- (void) backToSetting: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)applicationDataFromFile:(NSString *)fileName{
    NSString *resourcePath=[[NSBundle mainBundle] resourcePath]; //资源文件夹路径
    //CCLog(@"%@",resourcePath);
    
    if (!resourcePath)
    {
        //CCLog(@"Documents directory not found!");
        return NO;
    }
    NSString *filePath = [resourcePath stringByAppendingPathComponent:fileName];
    NSString *data = [[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] autorelease];
    //CCLog(@"%@", data);
    return data;
}

@end
