//
//  RechargeCollectViewController.m
//  CloudCall
//
//  Created by Sergio on 13-6-21.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "RechargeCollectViewController.h"
#import "ReChargeViewController.h"
#import "AlipayRechargeViewController.h"
#import "WebBrowser.h"
#import "HttpRequest.h"
#import "JSONKit.h"
#import "Product.h"

@interface RechargeCollectViewController(loadRechargeList)
- (void)sendLoadRechargeListRequest:(NSData *)jsonData;
- (void)sendLoadRechargeListRespone:(NSData *)data andUserInfo:(NSDictionary *)userInfo;
- (void)sendLoadRechargeListResponeError:(NSData *)data andUserInfo:(NSDictionary *)userInfo;

@end

@implementation RechargeCollectViewController(loadRechargeList)
- (void)sendLoadRechargeListRequest:(NSData *)jsonData
{    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [[HttpRequest instance] addRequest:kLoadRechargeListUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                         successTarget:self successAction:@selector(sendLoadRechargeListRespone:andUserInfo:)
                         failureTarget:self failureAction:@selector(sendLoadRechargeListResponeError:andUserInfo:) userInfo:userInfo];
}

- (void)sendLoadRechargeListRespone:(NSData *)data andUserInfo:(NSDictionary *)userInfo
{
    NSString *recvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *aStr = [recvString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
//    CCLog(@"sendLoadRechargeListRespone:%@",aStr);
    NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithDictionary:[aStr mutableObjectFromJSONString]];
    
    NSString *result = [root objectForKey:@"result"];
    
    [rechargeArray removeAllObjects];
    if ([result isEqualToString:@"success"])
    {
        NSMutableArray *list = [root objectForKey:@"cardTypeList"];
        [rechargeArray removeAllObjects];
        
        for(NSDictionary *card in list)
        {
            float price = [[card objectForKey:@"price"] floatValue];
            NSString *subject = [card objectForKey:@"subject"];
            NSString *detail = [card objectForKey:@"detail"];
            NSString *typeId = [card objectForKey:@"typeid"];
            
            Product *aCard = [[Product alloc] initWithPrice:price andSubject:subject andDetail:detail andTypeId:typeId];
            [rechargeArray addObject:aCard];
            
            [aCard release];
        }
    }
    [self._tableView reloadData];
    [recvString release];
    [root release];
}

- (void)sendLoadRechargeListResponeError:(NSError *)error andUserInfo:(NSDictionary *)userInfo
{
    [rechargeArray removeAllObjects];
    [self._tableView reloadData];
}

@end

@implementation RechargeCollectViewController
@synthesize rechargeArray;
@synthesize _tableView;

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
    self.title = NSLocalizedString(@"Recharge", @"Recharge");
    
    //返回按钮
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(10, 0, 44, 44);
    [btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(backToProvious:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btnBack] autorelease];
    
    self.rechargeArray = [NSMutableArray arrayWithCapacity:10];
    [self sendLoadRechargeListRequest:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    [rechargeArray release];
    [_tableView release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods
- (IBAction)backToProvious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)OpenWebBrowser:(NSString *)url withBarTitle:(NSString *)title withType:(TSMiniWebBrowserType)type
{
    WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
    webBrowser.mode = TSMiniWebBrowserModeNavigation;
    webBrowser.type = type;
    [webBrowser setFixedTitleBarText:title];
    webBrowser.barStyle = UIStatusBarStyleDefault;
    webBrowser.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webBrowser animated:YES];
    
    [webBrowser release];
}

#pragma mark
#pragma mark table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [rechargeArray count];
            break;
        case 1:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if ([rechargeArray count])
                return 40.0f;
            else
                return 0;
            break;
        }
        case 1:
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if ([rechargeArray count])
            {
                UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(10, 0, 290, 35)] autorelease];
                UILabel *lblSelCard = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, 100, 32)];
                lblSelCard.font = [UIFont systemFontOfSize:15.0f];
                lblSelCard.text = NSLocalizedString(@"Please select a card", @"Please select a card");
                lblSelCard.backgroundColor = [UIColor clearColor];
                
                UILabel *lblAnnounce = [[UILabel alloc] initWithFrame:CGRectMake(148, 8, 144, 32)];
                lblAnnounce.font = [UIFont systemFontOfSize:12.0f];
                lblAnnounce.textColor = [UIColor colorWithRed:240.0/255.0 green:130.0/255.0 blue:0 alpha:1];
                lblAnnounce.text = @"*群呼不在包月套餐范围内          *包月套餐仅包含国内通话";
                lblAnnounce.backgroundColor = [UIColor clearColor];
                lblAnnounce.numberOfLines = 2;
                
                [headerView addSubview:lblSelCard];
                [headerView addSubview:lblAnnounce];
                
                [lblSelCard release];
                [lblAnnounce release];
                
                return headerView;
            }
            else
            {
                return nil;
            }
            break;
        }
        case 1:
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            static NSString *RechargeCollectCellSection1 = @"RechargeCollectCellSection1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RechargeCollectCellSection1];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RechargeCollectCellSection1] autorelease];
                cell.backgroundColor = [UIColor clearColor];
            }
            
            Product *product = [rechargeArray objectAtIndex:indexPath.row];
            
            cell.textLabel.text = product.subject;
            cell.detailTextLabel.text = product.detail;
            cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.minimumFontSize = 9.0f;
            
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
            break;
        }
        case 1:
        {
            static NSString *RechargeCollectCellSection2 = @"RechargeCollectCellSection2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RechargeCollectCellSection2];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RechargeCollectCellSection2] autorelease];
                cell.backgroundColor = [UIColor clearColor];
            }
            
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Recharge by YunTong Card", @"Recharge by YunTong Card");
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"More Preferential", @"More Preferential");
                    break;
                default:
                    break;
            }
            cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
            break;
        }
        default:
            return nil;
            break;
    }
}

#pragma mark
#pragma mark table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section)
    {
        case 0:
        {
            AlipayRechargeViewController *alipayRechargeViewController = [[AlipayRechargeViewController alloc] initWithNibName:@"AlipayRechargeViewController" bundle:nil];
            alipayRechargeViewController.product = [rechargeArray objectAtIndex:indexPath.row];
            alipayRechargeViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:alipayRechargeViewController animated:YES];
            [alipayRechargeViewController release];
            break;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    ReChargeViewController *rechargeViewController = [[ReChargeViewController alloc] initWithNibName:@"ReChargeViewController" bundle:nil];
                    rechargeViewController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:rechargeViewController animated:YES];
                    [rechargeViewController release];
                    break;
                }
                case 1:
                {
                    [self OpenWebBrowser:kTaobaoShopUrl withBarTitle:NSLocalizedString(@"Recharge", @"Recharge") withType:TSMiniWebBrowserTypeDefault];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

@end
