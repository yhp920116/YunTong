
/* Vincent, GZ, 2012-08-02 */


#import "NgnIAPRecord.h"

@implementation NgnIAPRecord

@synthesize myid;
@synthesize mynumber;
@synthesize purchasedid;
@synthesize productid;
@synthesize purchaseddate;
@synthesize purchasedreceipt;

@synthesize oriproductid;
@synthesize opaque;

-(NgnIAPRecord*) initWithId: (long long)_id andMyNumber:(NSString*)_mynumber andPurchasedId: (NSString*)_purchasedid andProductId: (NSString*)_productid andPurchasedDate:(NSTimeInterval)_purchaseddate andPurchasedReceipt: receipt
{
	if((self = [super init])){
		self->myid = _id;
        self->mynumber = [_mynumber retain];
		self->purchasedid = [_purchasedid retain];
		self->productid = [_productid retain];
        self->purchaseddate = _purchaseddate;
        self->purchasedreceipt = [receipt retain];
	}
	return self;
}

-(NgnIAPRecord*) initWithMyNumber:(NSString*)_mynumber andPurchasedId: (NSString*)_purchasedid andProductId: (NSString*)_productid andPurchasedDate: (NSTimeInterval)_purchaseddate andPurchasedReceipt:(NSString*)receipt
{
	return [self initWithId:0 andMyNumber:_mynumber andPurchasedId:_purchasedid andProductId:_productid andPurchasedDate: _purchaseddate andPurchasedReceipt: receipt];
}

-(NSComparisonResult) compareSysNotificationByPurchaseTime: (NgnIAPRecord*)otherRecord {
	return self.purchaseddate > otherRecord.purchaseddate;
}

-(void)dealloc{
    [mynumber release];
    [purchasedid release];
    [productid release];
    
    if (oriproductid)
        [oriproductid release];
	
	[super dealloc];
}

@end

