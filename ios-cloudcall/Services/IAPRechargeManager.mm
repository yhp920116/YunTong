//

#import "IAPRechargeManager.h"
#import "HttpRequest.h"
#import "CloudCall2AppDelegate.h"
#import "JSONKit.h"
#import "CCGTMBase64.h"
#import "NgnEngine.h"

static const int g_recharge_attmpt_seconds = 180;

@implementation IAPRechargeStatusNotificationArgs

@synthesize success;
@synthesize errorcode;
@synthesize purchasedId;
@synthesize productId;

-(IAPRechargeStatusNotificationArgs*) initWithStatus:(BOOL)_success andErrorCode:(RechargeStatusDef)_errorcode andPurchasedID:(NSString*)_purchasedID andProductID:(NSString*)_productId {
    if ((self = [super init])) {
        self->success     = _success;
        self->errorcode   = _errorcode;
        self->purchasedId = [_purchasedID retain];
        self->productId   = [_productId retain];
	}
	return self;
}

- (void)dealloc {
    [purchasedId release];
    [productId release];
    
    [super dealloc];
}

@end

@interface IAPRechargeManager (Private)

-(void) startTimer;
-(void) stopTimer;

-(void) rechargeTimerCallback;
-(void) rechargeSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo;
-(void) rechargeFailed:(NSError *)error userInfo:(NSDictionary *)userInfo;
-(void) recharge2Server:(NgnIAPRecord*)iapRecord;
@end

@implementation IAPRechargeManager (Private)

-(void)rechargeTimerCallback {
	CCLog(@"IAPRechargeManager rechargeTimerCallback, count=%d, %d", [recharges count], [products count]);
    if (0 == [recharges count]) {
        [self stopTimer];
        return;
    }

    NSEnumerator * enumeratorValue = [recharges objectEnumerator];
    for (NgnIAPRecord* r in enumeratorValue) {
        if (r.oriproductid == nil) {
            NSData* d = [CCGTMBase64 decodeString:r.productid];
            r.oriproductid = [[[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] autorelease];
        }
        
        if (r.oriproductid) {
            NSDate *purchaseddate = [NSDate dateWithTimeIntervalSince1970:r.purchaseddate];
            NSTimeInterval offset = [[NSDate date] timeIntervalSinceDate:purchaseddate];
            if (g_recharge_attmpt_seconds < offset) {
                [self recharge2Server:r];
                break;
            }
        }
    }
}

-(void) startTimer {
    if (!rechargeTimer) {
        rechargeTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:20] interval:g_recharge_attmpt_seconds
                                                   target:self selector:@selector(rechargeTimerCallback) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:rechargeTimer forMode:NSRunLoopCommonModes];
    }
}

-(void) stopTimer{
    if(rechargeTimer) {
		[rechargeTimer invalidate];
		[rechargeTimer release];
		rechargeTimer = nil;
	}
}


-(void) rechargeSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo{
    if (rechargingnum)
        rechargingnum--;
    
    NgnIAPRecord* r = [userInfo objectForKey:@"iparecord"];
    if (!r)
        return;
    
    CCLog(@"IAPRechargeManager rechargeSucceeded: %@, %d", r.purchasedid, rechargingnum);

    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *root = [aStr mutableObjectFromJSONString];
    NSString* result      = [root objectForKey:@"result"];
    NSString* errcode     = [root objectForKey:@"text"];
    NSString* purchasedID = [root objectForKey:@"purchasedID"];
    CCLog(@"IAPRechargeManager rechargeSucceeded result='%@', errorcode='%@', purchasedID='%@'", result, errcode, purchasedID);
    
    BOOL succ = [result caseInsensitiveCompare:@"success"] == NSOrderedSame;
    RechargeStatusDef ecode = (RechargeStatusDef)[errcode intValue];
    NSString* productid = [[NSString alloc] initWithString: (purchasedID && [purchasedID length]) ? purchasedID : r.purchasedid];
    CCLog(@"IAPRechargeManager rechargeSucceeded productid='%@' '%@'", productid, r.purchasedid);
    IAPRechargeStatusNotificationArgs* irsna = [[[IAPRechargeStatusNotificationArgs alloc] initWithStatus:succ andErrorCode:ecode andPurchasedID:productid andProductID:r.oriproductid] autorelease];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRechargeStatusNotification object:irsna];
    
    if (succ) {
        NSString* str = [NSString stringWithFormat:@"%f", r.purchaseddate];
        [recharges removeObjectForKey:str];
        
        [[NgnEngine sharedInstance].storageService deleteIAPRecord:productid];
    } else {
        switch (ecode) {
            case RechargeStatusConnectServerFailed:
                break;
            case RechargeStatusInvalidCard:
            case RechargeStatusInvalidCardOrPassword:
            case RechargeStatusCardIncludingIllegalChar:
            case RechargeStatusIllegalOperation:
            case RechargeStatusNotCloudCallUser:
            case RechargeStatusExecutionFailed:
            case RechargeStatusAppSotreFaild: {
                NSString* str = [NSString stringWithFormat:@"%f", r.purchaseddate];
                [recharges removeObjectForKey:str];
                
                [[NgnEngine sharedInstance].storageService deleteIAPRecord:productid];
                
                break;
            }
        }
    }

    if ([recharges count]) {
        [self startTimer];
    }
    
    [productid release];
    [aStr release];
}

-(void) rechargeFailed:(NSError *)error userInfo:(NSDictionary *)userInfo{
    CCLog(@"IAPRechargeManager::rechargeFailed : error='%@', %d", error, rechargingnum);
    if (rechargingnum)
        rechargingnum--;
    
    NgnIAPRecord* r = [userInfo objectForKey:@"iparecord"];
    if (!r)
        return;
    
    RechargeStatusDef ecode = RechargeStatusConnectServerFailed;
    NSString* productid = [[NSString alloc] initWithString: r.purchasedid];
    CCLog(@"IAPRechargeManager rechargeFailed productid='%@' '%@'", productid, r.purchasedid);
    IAPRechargeStatusNotificationArgs* irsna = [[[IAPRechargeStatusNotificationArgs alloc] initWithStatus:NO andErrorCode:ecode andPurchasedID:productid andProductID:r.oriproductid] autorelease];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRechargeStatusNotification object:irsna];
    
    if ([recharges count]) {
        [self startTimer];
    }
}

- (void) recharge2Server:(NgnIAPRecord*)iapRecord{    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:iapRecord.purchaseddate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    
    NSDictionary *receiptData = [NSDictionary dictionaryWithObject:iapRecord.purchasedreceipt forKey:@"receipt-data"];
    //CCLog(@"IAPRechargeManager::recharge2Server: receiptData='%@'", receiptData);
    NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:
                             mynum, @"telnumber",
                             iapRecord.oriproductid, @"product_id",
                             timeStamp, @"purchase_date",
                             iapRecord.purchasedid, @"original_transaction_id",
                             [[NSBundle mainBundle] bundleIdentifier], @"bid",
                             [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"bvrs",
                             receiptData, @"receipt", nil];
    
    NSError *error = nil;
    NSDictionary *receiptDict = [NSPropertyListSerialization propertyListWithData:[CCGTMBase64 decodeString:iapRecord.purchasedreceipt]
                                                                          options:NSPropertyListImmutable format:nil error:&error];
    //CCLog(@"IAPRechargeManager::recharge2Server: receiptDict:'%@'", receiptDict);
    NSString* environment = nil;
    if (receiptDict) {
        environment = [receiptDict objectForKey:@"environment"];
    }
    CCLog(@"IAPRechargeManager::recharge2Server: 1 environment='%@'", environment);
    if (!environment && [environment length] == 0) {
        environment = @"AppStore";
    }
    CCLog(@"IAPRechargeManager::recharge2Server: 2 environment='%@'", environment);
    
    NSData *jsonData = nil;
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @"appstore", @"rechargetype", environment, @"environment", content, @"context", nil];
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            NSError *error;
            jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
            NSString *json = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
            CCLog(@"IAPRechargeManager::recharge2Server: json data:%@", json);
        }
    } else {
        jsonData = [body JSONData];
    }
    
    if (jsonData && [jsonData length]) {

        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
        [userInfo setObject:iapRecord forKey:@"iparecord"];
        [[HttpRequest instance] addRequest:kRechargelUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:30
                             successTarget:self successAction:@selector(rechargeSucceeded:userInfo:)
                             failureTarget:self failureAction:@selector(rechargeFailed:userInfo:) userInfo:userInfo];
        [userInfo release];
        rechargingnum++;
    }
}

@end

@implementation IAPRechargeManager

@synthesize products;

-(void) start:(NSString*)_mynum{
    if (mynum) {
        [mynum release];
        mynum = nil;
    }
    mynum = [_mynum retain];
    // Load iap records
    if (recharges == nil) {
        recharges = [[NSMutableDictionary alloc] init];
        
        NSMutableArray* array = [[NSMutableArray alloc] init];
        [[NgnEngine sharedInstance].storageService dbLoadIAPRecords:array andMyNumber:mynum];
        
        for (NgnIAPRecord* r in array) {
            NSString* str = [NSString stringWithFormat:@"%f", r.purchaseddate];
            [recharges setObject:r forKey:str];
        }
        CCLog(@"IAPRechargeManager LoadIapRecords: count=%d", [recharges count]);
        
        [array release];
    }
    
    if (recharges && [recharges count])
        [self startTimer];
}

-(void) stop{    
    [self stopTimer];
    
    if (mynum) {
        [mynum release];
        mynum = nil;
    }
    
    if (recharges) {
        [recharges release];
        recharges = nil;
    }    
}

-(void) updateAfterValidation:(NSString*)_mynum {
    if ([mynum isEqualToString:_mynum] == NO) {
        [self stop];
        [self start:_mynum];
    }
}

- (void)recharge:(NgnIAPRecord*)iapRecord{
    NSString* str = [NSString stringWithFormat:@"%f", iapRecord.purchaseddate];
    [recharges setObject:iapRecord forKey:str];
    [self recharge2Server:iapRecord];
}

-(void)dealloc {
    [self stop];
    
    [super dealloc];
}

@end
