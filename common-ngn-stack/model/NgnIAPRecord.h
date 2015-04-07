
#if TARGET_OS_IPHONE
#	import <Foundation/Foundation.h>
#elif TARGET_OS_MAC
#endif

#import "media/NgnMediaType.h"
#import "model/NgnContact.h"

@interface NgnIAPRecord : NSObject {
	long long myid;
    NSString* mynumber;
	NSString *purchasedid;
    NSString *productid;
	NSTimeInterval purchaseddate;
    NSString* purchasedreceipt;
    
    NSString *oriproductid;
@private
	// to be used for any purpose (e.g. category)
	id opaque;
}

-(NgnIAPRecord*) initWithId: (long long)id andMyNumber:(NSString*)mynumber andPurchasedId: (NSString*)purchasedid andProductId: (NSString*)productid andPurchasedDate: (NSTimeInterval)purchasedate andPurchasedReceipt: receipt;
-(NgnIAPRecord*) initWithMyNumber:(NSString*)mynumber andPurchasedId: (NSString*)purchasedid andProductId: (NSString*)productid andPurchasedDate: (NSTimeInterval)purchasedate andPurchasedReceipt: receipt;
-(NSComparisonResult) compareSysNotificationByPurchaseTime: (NgnIAPRecord*)otherRecord;

@property(readonly) long long myid;
@property(readonly) NSString* mynumber;
@property(readonly) NSString *purchasedid;
@property(readonly) NSString *productid;
@property(readonly) NSTimeInterval purchaseddate;
@property(readonly) NSString* purchasedreceipt;

@property(readwrite, retain, nonatomic) NSString* oriproductid;
@property(readwrite, retain, nonatomic) id opaque;

@end