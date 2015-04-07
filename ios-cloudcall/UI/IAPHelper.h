//
//  IAPHelper.h
//  WeiCall
//
//  Created by guobiao chen on 12-4-16.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

#define kProductsLoadedNotification         @"ProductsLoaded"
#define kProductPurchasedNotification       @"ProductPurchased"
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"


@interface IAPNotificationArgs : NSObject {
    NSString *productId;
    NSString *purchasedId;
    NSTimeInterval purchaseddate; // since EPOCH (00:00:00 UTC on 1 January 1970)
    NSData   *receipt;
    NSError  *error;
}

@property(readonly) NSString *productId;
@property(readonly) NSString *purchasedId;
@property(readonly) NSTimeInterval purchaseddate;
@property(readonly) NSData   *receipt;
@property(readonly) NSError  *error;

-(IAPNotificationArgs*) initWithProductID:(NSString*)productID andPurchasedID:(NSString*)purchasedID andPurchasedDate:(NSTimeInterval)purchaseddate andReceipt:(NSData*)receipt andError:(NSError*)error;

@end

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSSet * _productIdentifiers;    
    NSArray * _products;
    NSMutableSet * _purchasedProducts;
    SKProductsRequest * _request;
}

@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray * products;
@property (retain) NSMutableSet *purchasedProducts;
@property (retain) SKProductsRequest *request;

+(BOOL) CanPurchase;

- (void) SetObserver;
- (void) requestProducts;
- (id) initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void) buyProductIdentifier:(NSString *)productIdentifier;


@end
