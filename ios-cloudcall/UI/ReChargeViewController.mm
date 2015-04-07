//
//  ReChargeViewController.m
//  CloudCall
//
//  Created by Sergio on 13-1-23.
//  Copyright (c) 2013年 SkyBroad. All rights reserved.
//

#import "ReChargeViewController.h"
#import "iOSNgnStack.h"
#import "NgnEngine.h"
#import "CloudCall2AppDelegate.h"
#import "HttpRequest.h"

#import "JSONKit.h"

@implementation ReChargeViewController
@synthesize strValidCode;
@synthesize phoneNum;
@synthesize cardNum;
@synthesize cardPwd;
@synthesize validCode;
@synthesize btnSurRecharge;
@synthesize validCodeBGView;
@synthesize lable1;
@synthesize lable2;
@synthesize lable3;
@synthesize lable4;

#pragma mark
#pragma mark View Liftcycle
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
    
    self.navigationItem.title = NSLocalizedString(@"Recharge by YunTong Card", @"Recharge by YunTong Card");
    [self.btnSurRecharge setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
    [self.btnSurRecharge setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateHighlighted];
    self.btnSurRecharge.titleLabel.textAlignment = UITextAlignmentCenter;
    NSString *num = [[CloudCall2AppDelegate sharedInstance] getUserName];
    self.phoneNum.text = num;
    
    //返回按钮
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(10, 0, 44, 44);
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(back:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btnBack] autorelease];
    
    //验证码部分
    [validCodeBGView setBackgroundColor:[self getRandomColor]];
    
    //背景图添加点击更换验证码事件
    validCodeBGView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeValidCode:)];
    [validCodeBGView addGestureRecognizer:singleTap];
    
    pointArray = [[[NSMutableArray alloc] initWithCapacity:6] retain];
    [self getNumber];
    [self getLocation];
    
    //键盘工具栏
    UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.items = [NSArray arrayWithObjects:
                             [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                             [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(touchBGEndingEditing:)] autorelease],
                             nil];
    [keyboardToolbar sizeToFit];
    self.phoneNum.inputAccessoryView = keyboardToolbar;
    self.cardNum.inputAccessoryView = keyboardToolbar;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [phoneNum release];
    [cardNum release];
    [cardPwd release];
    [validCode release];
    [btnSurRecharge release];
    
    [validCodeBGView release];
    [lable1 release];
    [lable2 release];
    [lable3 release];
    [lable4 release];
    
    [strValidCode release];
    [pointArray release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods
/**
 *	@brief	点击返回按钮返回到上一层
 */
- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *	@brief	点击背景隐藏键盘
 */
- (IBAction)touchBGEndingEditing:(id)sender
{
    [self.view endEditing:YES];
}


/**
 *	@brief	点击确定充值
 */
- (IBAction)btnRechargeClick:(id)sender
{
    BOOL networkState = [[NgnEngine sharedInstance].networkService isReachable];
    
    if (!networkState)
    {
        //改变验证码
        [self changeValidCode:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge")message:NSLocalizedString(@"Unreachable", @"Unreachable") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    //判断输入的各项值是否合法
    BOOL accessToSubmit = [self checkRechargeInfoOfPhoneNum];
    
    if (!accessToSubmit) {
        return;
    }
    
    NSString *telnumber = self.phoneNum.text;
    NSString *cardnumber = self.cardNum.text;
    NSString *cardpassword = self.cardPwd.text;
    
    NSError *error;
    
    //设置充值数据
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:telnumber,@"telnumber",cardnumber,@"cardnumber",cardpassword,@"cardpassword",nil];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:@"normal", @"rechargetype", context, @"context", nil];
    NSData* jsonBody = nil;
    if (SystemVersion >= 5.0) {
        if([NSJSONSerialization isValidJSONObject:body])
        {
            jsonBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
            NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
            CCLog(@"btnRechargeClick-->%@",json);
        }
    } else {
        jsonBody = [body JSONData];
        
        NSString *json = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
        CCLog(@"btnRechargeClick-->%@",json);
    }
    
    [self getDataFromNet:jsonBody];
}

//判断各项值是否合法
- (BOOL)checkRechargeInfoOfPhoneNum   //:(NSString *)pNum andCardNum:(NSString *)cNumandCardPwd:(NSString *)cPwd andValidCode:(NSString *)vCode
{
    //获取输入的各项值
    NSString *strPhoneNum = self.phoneNum.text;
    if ([strPhoneNum length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge")message:NSLocalizedString(@"Please input the phone number first", @"Please input the phone number first") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
        //改变验证码
        [self changeValidCode:nil];
        return NO;
    }
    
    NSString *strCardNum = self.cardNum.text;
    if ([strCardNum length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge") message:NSLocalizedString(@"Please enter the the card number!", @"Please enter the the card number!") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
        //改变验证码
        [self changeValidCode:nil];
        return NO;
    }
    else if ([strCardNum length] == 8)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge") message:NSLocalizedString(@"Invalid card number!", @"Invalid card number!") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
        //改变验证码
        [self changeValidCode:nil];
        return NO;
    }
    
    NSString *strCardPwd = self.cardPwd.text;
    if ([strCardPwd length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge") message:NSLocalizedString(@"Please enter the password of the card!", @"Please enter the password of the card!") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
        //改变验证码
        [self changeValidCode:nil];
        return NO;
    }
    else if([strCardPwd length] == 8)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge") message:NSLocalizedString(@"Invalid password!", @"Invalid password!") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
        //改变验证码
        [self changeValidCode:nil];
        return NO;
    }
    
    NSString *sValidCode = self.validCode.text;
    if ([sValidCode length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge") message:NSLocalizedString(@"Please enter the valid code!", @"Please enter the valid code!") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
        //改变验证码
        [self changeValidCode:nil];
        return NO;
    }
    else if(![sValidCode isEqualToString:strValidCode])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge") message:NSLocalizedString(@"Invalid valid code!", @"Invalid valid code!") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
        //改变验证码
        [self changeValidCode:nil];
        return NO;
    }
    return YES;
}

#pragma mark
#pragma mark Http Request
/**
 *	@brief	向服务器发送https请求数据
 *
 *	@param 	strType 	请求类型
 *	@param 	data 	发送的参数
 */
- (void)getDataFromNet:(NSData*)data
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@", kRechargelUrl];
        
    [[HttpRequest instance] addRequest:urlString andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:data andTimeout:15
                         successTarget:self successAction:@selector(rechargeSucceeded:userInfo:)
                         failureTarget:self failureAction:@selector(rechargeFailed:userInfo:) userInfo:nil];
}

/**
 *	@brief	充值成功处理
 *
 *	@param 	data 	返回数据
 *	@param 	userInfo
 */
-(void) rechargeSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo
{
    NSString *aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *recvString = [aStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CCLog(@"ReChargeViewController didReceiveData:%@", recvString);
    
    NSRange range = [recvString rangeOfString:@"result"];
    if (range.location != NSNotFound) {
        NSMutableDictionary *root = [recvString mutableObjectFromJSONString];
        NSString *result = [root objectForKey:@"result"];
        NSString *text = [root objectForKey:@"text"];
        
        if ([result isEqualToString:@"success"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge")
                                                            message:text
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge")
                                                            message:text
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    else
    {
        //错误信息
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge") message:[NSString stringWithFormat:NSLocalizedString(@"Recharge %@ faild!", @"Recharge %@ faild!"),@""] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    //改变验证码
    [self changeValidCode:nil];
    [aStr release];
}

/**
 *	@brief	充值失败
 *
 *	@param 	error 	错误信息
 *	@param 	userInfo 	
 */
-(void) rechargeFailed:(NSError *)error userInfo:(NSDictionary *)userInfo
{
    //改变验证码
    [self changeValidCode:nil];
}

#pragma mark
#pragma mark ValidCode
/**
 *	@brief	生成随机颜色
 *
 *	@return	颜色
 */
-(UIColor *)getRandomColor
{
    UIColor *color=[UIColor clearColor];
    switch ((arc4random()%5)) {
        case 0:
            color=[UIColor yellowColor];
            break;
        case 1:
            color=[UIColor redColor];
            break;
        case 2:
            color=[UIColor orangeColor];
            break;
        case 3:
            color=[UIColor cyanColor];
            break;
        case 4:
            color=[UIColor magentaColor];
            break;
        case 5:
            color=[UIColor purpleColor];
            break;
        default:
            
            break;
    }
    return  color;
}

/**
 *	@brief	生成验证码
 */
-(void)getNumber
{
    self.strValidCode = [NSMutableString stringWithCapacity:6];
    for(NSInteger i = 0; i < 4; i++) //得到四个随机字符，取四次，可自己设长度
    {
        int arr = arc4random() % 15 + 150;
        number = arc4random() % 9 + 0;
        switch (i) {
                
            case 0:
                self.lable1.text = [NSString stringWithFormat:@"%d",number];
                self.lable1.frame = CGRectMake(lable1.frame.origin.x, arr, lable1.frame.size.width, lable1.frame.size.height);
                break;
            case 1:
                self.lable2.text = [NSString stringWithFormat:@"%d",number];
                self.lable2.frame = CGRectMake(lable2.frame.origin.x, arr, lable2.frame.size.width, lable2.frame.size.height);
                break;
            case 2:
                self.lable3.text = [NSString stringWithFormat:@"%d",number];
                self.lable3.frame = CGRectMake(lable3.frame.origin.x, arr, lable3.frame.size.width, lable3.frame.size.height);
                break;
            case 3:
                self.lable4.text = [NSString stringWithFormat:@"%d",number];
                self.lable4.frame = CGRectMake(lable4.frame.origin.x, arr, lable4.frame.size.width, lable4.frame.size.height);
                break;
            default:
                break;
        }
        [strValidCode appendString:[NSString stringWithFormat:@"%d",number]];
    }
}

/**
 *	@brief	更换验证码
 *
 */
-(IBAction)changeValidCode:(id)sender
{
    [self getLocation];
    [self getNumber];
    [validCodeBGView setBackgroundColor:[self getRandomColor]];
}

/**
 *	@brief	生成背景图干扰线
 */
- (void)getLocation
{
    [pointArray removeAllObjects];
    for(int j = 0; j<6; j++)
    {
        int pointx = arc4random() % 110;
        int pointy = arc4random() % 30;
        CGPoint point = CGPointMake(pointx, pointy);
        NSValue *points = [NSValue valueWithCGPoint:point];
        [pointArray addObject:points];        
    }
    [validCodeBGView sharePoints:pointArray];
    [validCodeBGView setNeedsDisplay];
}

@end
