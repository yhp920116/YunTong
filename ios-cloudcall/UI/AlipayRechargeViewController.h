//
//  AlipayRechargeViewController.h
//  CloudCall
//
//  Created by Sergio on 13-6-24.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudCall2AppDelegate.h"
#import "Product.h"

#define kAppSchemeForAlipay @"Alipay2088901012551910"

@interface AlipayRechargeViewController : UIViewController
{
    Product *product;
}

@property (nonatomic,retain) Product *product;
@property (nonatomic,retain) IBOutlet UILabel *lblNumber;
@property (nonatomic,retain) IBOutlet UILabel *lblSubject;
@property (nonatomic,retain) IBOutlet UILabel *lblDetail;

@end
