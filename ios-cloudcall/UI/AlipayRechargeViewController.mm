//
//  AlipayRechargeViewController.m
//  CloudCall
//
//  Created by Sergio on 13-6-24.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "AlipayRechargeViewController.h"
#import "AlixPay.h"
#import "AlixPayOrder.h"
#import "DataSigner.h"
#import "RSADataSigner.h"

@implementation AlipayRechargeViewController
@synthesize product;
@synthesize lblNumber;
@synthesize lblSubject;
@synthesize lblDetail;

#pragma mark
#pragma mark View Lifecycle
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
    self.navigationController.navigationBarHidden = NO;
    self.title = NSLocalizedString(@"Buy prepaid card", @"Buy prepaid card");
    self.lblNumber.text = [[CloudCall2AppDelegate sharedInstance] getUserName];
    self.lblSubject.text = product.subject;
    self.lblDetail.text = product.detail;
    
    //返回按钮
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(10, 0, 44, 44);
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(backToProvious:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btnBack] autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [product release];
    [lblNumber release];
    [lblSubject release];
    [lblDetail release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods
- (IBAction)backToProvious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rechargeByAlipay
{
    if (!product) return;
    
    /*
	 *商户的唯一的parnter和seller。
	 *本demo将parnter和seller信息存于（AlixPayDemo-Info.plist）中,外部商户可以考虑存于服务端或本地其他地方。
	 *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
	 */
	//如果partner和seller数据存于其他位置,请改写下面两行代码
	NSString *partner = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Partner"];
    NSString *seller = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Seller"];
	
	//partner和seller获取失败,提示
	if ([partner length] == 0 || [seller length] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Note Info", @"Note Info")
														message:@"缺少partner或者seller。"
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	/*
	 *生成订单信息及签名
	 *由于demo的局限性，本demo中的公私钥存放在AlixPayDemo-Info.plist中,外部商户可以存放在服务端或本地其他地方。
	 */
	//将商品信息赋予AlixPayOrder的成员变量
	AlixPayOrder *order = [[[AlixPayOrder alloc] init] autorelease];
	order.partner = partner;
	order.seller = seller;
    NSString *user_no = [[CloudCall2AppDelegate sharedInstance] getUserName];
	order.tradeNO = [NSString stringWithFormat:@"%@_%@_%@", user_no, product.typeId, [self generateTradeNO]]; //订单ID（由商家自行制定）
	order.productName = [NSString stringWithFormat:@"云通%@", product.subject]; //商品标题
	order.productDescription = product.detail; //商品描述
	order.amount = [NSString stringWithFormat:@"%.2f",product.price]; //商品价格
	order.notifyURL = kAlipayNotifyURL; //回调URL
	//应用注册scheme,在AlixPayDemo-Info.plist定义URL types,用于安全支付成功后重新唤起商户应用
    NSString *appScheme = kAppSchemeForAlipay;
	
	//将商品信息拼接成字符串
	NSString *orderSpec = [order description];
	CCLog(@"orderSpec = %@",orderSpec);
	
	//获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
//	id<DataSigner> signer = CreateRSADataSigner([[NSBundle mainBundle] objectForInfoDictionaryKey:@"RSA private key"]);
    id<DataSigner> signer = [[[RSADataSigner alloc] initWithPrivateKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"RSA private key"]] autorelease];
	NSString *signedString = [signer signString:orderSpec];
	
	//将签名成功字符串格式化为订单字符串,请严格按照该格式
	NSString *orderString = nil;
	if (signedString != nil) {
		orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        CCLog(@"signedString = %@",signedString);
        
        //获取安全支付单例并调用安全支付接口
        AlixPay * alixpay = [AlixPay shared];
        int ret = [alixpay pay:orderString applicationScheme:appScheme];
        
        if (ret == kSPErrorAlipayClientNotInstalled) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Note Info", @"Note Info")
                                                                 message:@"您还没有安装支付宝快捷支付，请先安装。"
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                       otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            [alertView setTag:123];
            [alertView show];
            [alertView release];
        }
        else if (ret == kSPErrorSignError) {
            NSLog(@"签名错误！");
        }
        
	}
}

/*
 *随机生成15位订单号,外部商户根据自己情况生成订单号
 */
- (NSString *)generateTradeNO
{
	CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFStringCreateCopy( NULL, uuidString);
    CFRelease(puuid);
    CFRelease(uuidString);
    return [result autorelease];
}

#pragma mark
#pragma mark table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *alipayRechargeViewControllerCell = @"AlipayRechargeViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:alipayRechargeViewControllerCell];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:alipayRechargeViewControllerCell] autorelease];
    }
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"  %@", NSLocalizedString(@"Recharge by Alipay", @"Recharge by Alipay")];
            cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
            break;
        case 1:
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark
#pragma mark table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
        case 0:
        {
            //支付宝充值
            [self rechargeByAlipay];
            break;
        }
        case 1:
        {
            //银联充值
            break;
        }
        default:
            break;
    }
}

#pragma mark
#pragma mark alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 123 && buttonIndex == 1)
    {
        NSString * URLString = @"http://itunes.apple.com/cn/app/id535715926?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
	}
}

@end
