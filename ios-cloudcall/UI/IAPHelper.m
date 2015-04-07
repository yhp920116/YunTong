//
//  IAPHelper.m
//  WeiCall
//
//  Created by guobiao chen on 12-4-16.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import "IAPHelper.h"

@implementation IAPNotificationArgs

@synthesize productId;
@synthesize purchasedId;
@synthesize purchaseddate;
@synthesize receipt;
@synthesize error;

-(IAPNotificationArgs*) initWithProductID:(NSString*)_productID andPurchasedID:(NSString*)_purchasedID andPurchasedDate:(NSTimeInterval)_purchaseddate andReceipt:(NSData *)_receipt andError:(NSError*)_error {
    if((self = [super init])){
        if (_productID)
            self->productId = [_productID copy];
        if (_purchasedID)
            self->purchasedId = [_purchasedID copy];
        self->purchaseddate = _purchaseddate;
        if (_receipt)
            self->receipt = [_receipt copy];
        if (_error)
            self->error = [_error copy];
	}
	return self;
}

- (void)dealloc {
    [productId release];
    [purchasedId release];
    [receipt release];
    [error release];
    
    [super dealloc];
}

@end

@implementation IAPHelper
@synthesize productIdentifiers = _productIdentifiers;
@synthesize products = _products;
@synthesize purchasedProducts = _purchasedProducts;
@synthesize request = _request;


+ (BOOL) CanPurchase {
    return ([SKPaymentQueue canMakePayments]);
}

- (void) SetObserver {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

//初始化产品标示符
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if (_productIdentifiers)
        [_productIdentifiers release];
    _productIdentifiers = [productIdentifiers retain];
    NSMutableSet *products = [NSMutableSet set];
    for (NSString * productIdentifier in _productIdentifiers) {
        //CCLog(@"initWithProductIdentifiers: %@", productIdentifier);
        [products addObject:productIdentifier];
    }
    self.purchasedProducts = products;
    //CCLog(@"initWithProductIdentifiers: count=%d", [self.purchasedProducts count]);
    
    return self;
}

//请求产品列表
- (void)requestProducts {
    /*for (NSString * str in _productIdentifiers) {
        CCLog(@"productId=%@", str);
    }*/
    self.request = [[[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers] autorelease];
    _request.delegate = self;
    [_request start];
}

//delegate 事件 获取产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {  
    self.products = response.products;
    //CCLog(@"<<<<<<<<<<< in app purchase products count=%d <<<<<<<<<<<<<<<<",[response.products count]);
    self.request = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:_products];    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recharge", @"Recharge") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")  otherButtonTitles:nil];
    [alerView show];
    [alerView release];
}

//存储支付信息 服务器
- (void)recordTransaction:(SKPaymentTransaction *)transaction {    
    //    
}

//支付成功后调用 设置支付标记 可修改的过程 这里是存到本地
- (void)provideContent:(SKPaymentTransaction *)transaction {
    IAPNotificationArgs* ina = [[[IAPNotificationArgs alloc] initWithProductID:transaction.payment.productIdentifier
                                                                andPurchasedID:transaction.transactionIdentifier
                                                              andPurchasedDate:[transaction.transactionDate timeIntervalSince1970]
                                                                    andReceipt:transaction.transactionReceipt andError:nil] autorelease];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotification object:ina];
}

//完成支付
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction: transaction];
    [self provideContent: transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

//恢复上次支付
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction: transaction];
    [self provideContent: transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

//支付失败后
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    IAPNotificationArgs* ina = [[[IAPNotificationArgs alloc] initWithProductID:transaction.payment.productIdentifier
                                                                andPurchasedID:transaction.transactionIdentifier
                                                              andPurchasedDate:[transaction.transactionDate timeIntervalSince1970]
                                                                    andReceipt:nil
                                                                      andError:transaction.error] autorelease];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotification object:ina];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];    
}

//delegate 事件 当支付信息改变时调用
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for (SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

//购买
- (void)buyProductIdentifier:(NSString *)productIdentifier {
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//销毁
- (void)dealloc
{
    [_productIdentifiers release];
    _productIdentifiers = nil;
    [_products release];
    _products = nil;
    [_purchasedProducts release];
    _purchasedProducts = nil;
    [_request release];
    _request = nil;
    [super dealloc];
}

@end


