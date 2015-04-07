//
//  ProductInfoViewController.m
//  WeiCall
//
//  Created by guobiao chen on 12-4-16.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import "IAPRechargeViewController.h"
#import "IAPHelperRecharge.h"
#import "IAPProductCell.h"
#import "ReChargeViewController.h"
#import "CloudCall2AppDelegate.h"

#import "CCGTMBase64.h"

@interface IAPRechargeViewController(Private)

- (void) backToSetting: (id)sender;
@end

@implementation  IAPRechargeViewController(Private)
//////////////////////
- (void) checktimeout:(NSString*)prompt{
    [self hideHud];

    UIAlertView *a = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Recharge", @"Recharge")
                                                message: prompt
                                               delegate: self
                                      cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"OK", @"OK"), nil];
    [a show];
    [a release];
}

//////////////////////

- (void) backToSetting: (id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

@implementation  IAPRechargeViewController

@synthesize hud = _hud;
@synthesize tableView;
@synthesize cardRechargeCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
//关闭显示框
-(void)dismissHUD:(id)arg
{
    [self hideHud];
    self.hud = nil;
}

//充值卡充值
- (IBAction)cardRecharge:(id)sender
{
    ReChargeViewController *rechargeViewController = [[ReChargeViewController alloc] initWithNibName:@"ReChargeViewController" bundle:nil];
    rechargeViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rechargeViewController animated:YES];
    [rechargeViewController release];
}

//加载
- (void)productsLoaded:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self hideHud];
    [self.tableView reloadData];
}

//超时
- (void)timeout:(id)arg
{
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:5.0];
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge")
                                                message:NSLocalizedString(@"Connection timed out, please try again later.", @"Connection timed out, please try again later.")
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                      otherButtonTitles: nil];
    [a show];
    [a release];
}

- (void)showHud
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
}

- (void)hideHud
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
}

//网络连接失败
-(void)displayNotConnectionUI
{
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:5.0];
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge")
                                                message:NSLocalizedString(@"No network connection", @"No network connection")
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                      otherButtonTitles: nil];
    [a show];
    [a release];
}

-(void)loadProducts
{
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);
    NSMutableArray* productids = appDelegate.rechargeProducts;
    
    CCLog(@"loadProducts: %d", [productids count]);
    if ([productids count] == 0) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge")
														message:NSLocalizedString(@"Recharge service is unavailable, please try again later.", @"Recharge service is unavailable, please try again later.")
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles: nil];
		[a show];
		[a release];
        return;
    }
    
    NSSet *productIdentifiers = [NSSet setWithArray:productids];
    [[IAPHelperRecharge sharedInstance] requestProducts:productIdentifiers];
    [self showHud];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    
    _hud.labelText = NSLocalizedString(@"Loading...", @"Loading...");
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:50];
}


-(IBAction)refresh:(id)sender
{
    [self loadProducts];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"Recharge", @"Recharge");
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToSetting:) forControlEvents: UIControlEventTouchUpInside];    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if ([[CloudCall2AppDelegate sharedInstance] ShowAllFeatures])
    {
        self.tableView.tableHeaderView = self.cardRechargeCell;
    }
    
    UIButton *barButtonRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    barButtonRefresh.frame = CGRectMake(256, 0, 60, 44);
    [barButtonRefresh setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    barButtonRefresh.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [barButtonRefresh setBackgroundImage:[UIImage imageNamed:@"SyncContact_up.png"] forState:UIControlStateNormal];
    [barButtonRefresh setBackgroundImage:[UIImage imageNamed:@"SyncContact_down.png"] forState:UIControlStateHighlighted];
    [barButtonRefresh addTarget:self action:@selector(refresh:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:barButtonRefresh] autorelease];
    
    if ([NgnEngine sharedInstance].networkService.reachable)
    {
        if ([IAPHelperRecharge sharedInstance].products == nil)
        {
            [self loadProducts];
        }
    }
    else
    {
        [self displayNotConnectionUI];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(RechargeStatus:) name:kRechargeStatusNotification object: nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[IAPHelperRecharge sharedInstance].products count];
}

-(UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IAPProductCell* cell = (IAPProductCell*)[_tableView dequeueReusableCellWithIdentifier: kIAPProductCellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"IAPProductCell" owner:self options:nil] lastObject];
	}
    
    // Configure the cell.
    SKProduct *product = [[IAPHelperRecharge sharedInstance].products objectAtIndex:indexPath.row];

    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    
    NSString* strTitle = [NSString stringWithFormat:@"%@ - %@", product.localizedTitle, formattedString];
    NSString* strDes = product.localizedDescription;
    [cell SetProductInfo:strTitle andDescription:strDes];

    [cell.buttonRecharge setTitle:NSLocalizedString(@"Recharge", @"Recharge") forState:UIControlStateNormal];
    cell.buttonRecharge.tag = indexPath.row;
    [cell.buttonRecharge addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
	return cell;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SKProduct *product = [[IAPHelperRecharge sharedInstance].products objectAtIndex:indexPath.row];
    NSString* strDes = product.localizedDescription;    
    return [IAPProductCell getHeight:strDes constrainedWidth:_tableView.frame.size.width];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

// 按下购买按钮触发购买事件
- (IBAction)buyButtonTapped:(id)sender
{
    UIButton *buyButton = (UIButton *)sender;    
    SKProduct *product = [[IAPHelperRecharge sharedInstance].products objectAtIndex:buyButton.tag];
    
    if (productTitle) {
        [productTitle release];
        productTitle = nil;
    }
    productTitle = [product.localizedTitle retain];
    
    CCLog(@"Buying %@ %@...", product.productIdentifier, productTitle);
    [[IAPHelperRecharge sharedInstance] buyProductIdentifier:product.productIdentifier];
    
    [self showHud];
    _hud.labelText = [NSString stringWithFormat:NSLocalizedString(@"Recharging %@...", @"Recharging %@..."), productTitle];
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:60*1.5];
}

// 购买成功后触发的通知
- (void)productPurchased:(NSNotification *)notification {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self hideHud];
    
    IAPNotificationArgs* ina = (IAPNotificationArgs*)notification.object;    
    NSString *productId = ina.productId;    
    NSString *purchasedId = ina.purchasedId;
    CCLog(@"productPurchased: %@', '%@'", productId, purchasedId);
    
    NSString* title = productTitle?productTitle:@"";
    if ([title length] == 0) {
        return;
    }
    
    NSString* stprompt = [NSString stringWithFormat:NSLocalizedString(@"Buy %@ successfully!", @"Buy %@ successfully!"), title];
    stprompt = [stprompt stringByAppendingFormat:@"\n%@", NSLocalizedString(@"Checking the recharge result...", @"Checking the recharge result...")];
    NSString* failprompt = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Check the recharge result timeout!", @"Check the recharge result timeout!"), NSLocalizedString(@"Check your balance later if it has benn increased and contact our customer service if you have any question.", @"Check your balance later if it has benn increased and contact our customer service if you have any question.")];    
    [self showHud];
    _hud.labelText = stprompt;
    [self performSelector:@selector(checktimeout:) withObject:failprompt afterDelay:60*1.5];
    
    // Save into database
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSString* encryptedProductId = [CCGTMBase64 stringByEncodingBytes: [productId UTF8String] length:[productId length]];
    CCLog(@"encryptedProductId='%@'", encryptedProductId);
    //CCLog(@"encryptedReceipt='%@'", ina.receipt);
    
    NSString *recieptString = [CCGTMBase64 stringByEncodingData:ina.receipt];
    //CCLog(@"recieptString='%@'", recieptString);    
    NgnIAPRecord* record = [[NgnIAPRecord alloc] initWithMyNumber:mynum
                                                   andPurchasedId:purchasedId
                                                     andProductId:encryptedProductId
                                                 andPurchasedDate:ina.purchaseddate
                                              andPurchasedReceipt:recieptString];
    [[NgnEngine sharedInstance].storageService addIAPRecord:record];
    
    record.oriproductid = [[[NSString alloc] initWithString:productId] autorelease];
    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*) [[UIApplication sharedApplication] delegate]);    
    [appDelegate IAPRecharge:record];
    
    if (productPurchaseid) {
        [productPurchaseid release];
        productPurchaseid = nil;
    }
    productPurchaseid = [record.purchasedid retain];
    
    [record release];
    
#if 0 // for debug
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:ina.paymentTransaction.transactionDate];
    [dateFormatter release];
    
    CCLog(@"Purchased: quantity='%d', product_id='%@', transaction_id='%@', purchase_date='%@', original_transaction_id='%@', bid='%@', bvrs='%@'",
          1, productId, ina.paymentTransaction.transactionIdentifier, timeStamp, purchasedId,
          [[NSBundle mainBundle] bundleIdentifier], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]);
    
    NSError *jsonError = nil;
    NSDictionary *info = [NSDictionary dictionaryWithObject:recieptData forKey:@"receipt-data"];
    CCLog(@"Purchased: jsonData='%@'", info);
    
    NSData* jsonData = nil;
    if (SystemVersion >= 5.0) {
        jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&jsonError];
    } else {
        jsonData = [info JSONData];
    }
    
    //CCLog(@"Purchased: jsonData='%s'", [jsonData bytes]);
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [jsonData length]];
    
    NSMutableURLRequest *Request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString* confUrl = [NSString stringWithFormat:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    [Request setURL:[NSURL URLWithString: confUrl]];
    [Request setHTTPMethod:@"POST"];
    [Request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //[Request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [Request setHTTPBody:jsonData];
    
    NSError *resError = [[NSError alloc] init];
    NSHTTPURLResponse *ResponseCode = nil;
    NSData *ResponseData = [NSURLConnection
                            sendSynchronousRequest:Request
                            returningResponse:&ResponseCode
                            error:&resError];
    
    NSString *strResult = [[NSString alloc] initWithData:ResponseData encoding:NSUTF8StringEncoding];
    CCLog(@"iap receipt verify res=%@", strResult);
    [resError release];
    /////////////////
#endif
}

// 购买失败后触发的通知
- (void)productPurchaseFailed:(NSNotification *)notification {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self hideHud];
    
    IAPNotificationArgs* ina = (IAPNotificationArgs *)notification.object;
    CCLog(@"productPurchaseFailed: %@', %d", ina.productId, ina.error.code);
    if (ina.error.code != SKErrorPaymentCancelled) {
        NSString* title = @"";
        NSArray *products = [IAPHelperRecharge sharedInstance].products;
        for (SKProduct *p in products) {
            if ([p.productIdentifier isEqualToString:ina.productId]) {
                title = p.localizedTitle;
                break;
            }
        }
        NSString* str = [NSString stringWithFormat:NSLocalizedString(@"Recharging %@...", @"Recharging %@..."), title];
        UIAlertView *a = [[[UIAlertView alloc] initWithTitle:str message:ina.error.localizedDescription
                                                        delegate:nil 
                                               cancelButtonTitle:nil 
                                               otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil] autorelease];
        [a show];
    }    
}

- (void) RechargeStatus:(NSNotification *)notification {
    IAPRechargeStatusNotificationArgs* irsna = (IAPRechargeStatusNotificationArgs *)notification.object;
    CCLog(@"RechargeStatus: '%@', '%@'", irsna.purchasedId, productPurchaseid);    
    if (nil == productPurchaseid || NO == [productPurchaseid isEqualToString:irsna.purchasedId])
        return;
        
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self hideHud];
    
    NSString* title = productTitle?productTitle:@"";
    if ([title length] == 0) {
        NSArray *products = [IAPHelperRecharge sharedInstance].products;
        for (SKProduct *p in products) {
            if ([p.productIdentifier isEqualToString:irsna.productId]) {
                title = p.localizedTitle;
                break;
            }
        }
    }
    
    NSString* strPrompt = @"";
    if (irsna.success) {
        strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Recharge %@ successfully!", @"Recharge %@ successfully!"), title];
    } else {
        switch (irsna.errorcode) {
            case RechargeStatusConnectServerFailed:
                strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Recharge %@ faild!", @"Recharge %@ faild!"), title];
                strPrompt = [strPrompt stringByAppendingFormat:@"\n%@ (%d)", NSLocalizedString(@"Connect to server failed", @"Connect to server failed"), irsna.errorcode];               
                break;
            case RechargeStatusInvalidCard:
                strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Recharge %@ faild!", @"Recharge %@ faild!"), title];
                strPrompt = [strPrompt stringByAppendingFormat:@"\n%@ (%d)", NSLocalizedString(@"Invalid card", @"Invalid card"), irsna.errorcode];
                break;
            case RechargeStatusInvalidCardOrPassword:
                strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Recharge %@ faild!", @"Recharge %@ faild!"), title];
                strPrompt = [strPrompt stringByAppendingFormat:@"\n%@ (%d)", NSLocalizedString(@"Invalid card or password", @"Invalid card or password"), irsna.errorcode];
                break;
            case RechargeStatusCardIncludingIllegalChar:
                strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Recharge %@ faild!", @"Recharge %@ faild!"), title];
                strPrompt = [strPrompt stringByAppendingFormat:@"\n%@ (%d)", NSLocalizedString(@"Invalid card including illegal character", @"Invalid card including illegal character"), irsna.errorcode];
                break;
            case RechargeStatusIllegalOperation:
                strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Recharge %@ faild!", @"Recharge %@ faild!"), title];
                strPrompt = [strPrompt stringByAppendingFormat:@"\n%@ (%d)", NSLocalizedString(@"InvalidCardIncludingIllegal", @"InvalidCardIncludingIllegal"), irsna.errorcode];
                break;
            case RechargeStatusNotCloudCallUser:
                strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Recharge %@ faild!", @"Recharge %@ faild!"), title];
                strPrompt = [strPrompt stringByAppendingFormat:@"\n%@ (%d)", NSLocalizedString(@"Not a YunTong user", @"Not a YunTong user"), irsna.errorcode];
                break;
            case RechargeStatusExecutionFailed:
                strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Recharge %@ faild!", @"Recharge %@ faild!"), title];
                strPrompt = [strPrompt stringByAppendingFormat:@"\n%@ (%d)", NSLocalizedString(@"Server execution failed", @"Server execution failed"), irsna.errorcode];
                break;
            case RechargeStatusAppSotreFaild:
                strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Recharge %@ faild!", @"Recharge %@ faild!"), title];
                strPrompt = [strPrompt stringByAppendingFormat:@"\n%@ (%d)", NSLocalizedString(@"App Sotre verfiy faild", @"App Sotre verfiy faild"), irsna.errorcode];
                break;
            default:
                strPrompt = [NSString stringWithFormat:NSLocalizedString(@"Recharge %@ faild!", @"Recharge %@ faild!"), title];
                strPrompt = [strPrompt stringByAppendingFormat:@" (%d)", irsna.errorcode];
                break;
        }
    }

    UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge") message:strPrompt delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    [a show];
    [a release];
    
    if (productTitle) {
        [productTitle release];
        productTitle = nil;
    }
    if (productPurchaseid) {
        [productPurchaseid release];
        productPurchaseid = nil;
    }
}

- (void)viewDidUnload
{
    self.hud = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [tableView release];
    tableView = nil;
    
    self.hud = nil;
    [_hud release];
    _hud = nil;
    
    [alert release];

    [productTitle release];
    productTitle = nil;
    [productPurchaseid release];
    productPurchaseid = nil;
    
    [super dealloc];
}

@end
