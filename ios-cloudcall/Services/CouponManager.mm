//
//  CouponManager.m
//  CloudCall
//
//  Created by CloudCall on 13-5-9.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//
#import "CloudCall2AppDelegate.h"
#import "CouponManager.h"
#import "JSONKit.h"
#import "HttpRequest.h"

@interface CouponManager (Private)

-(BOOL)writeData2File:(NSData*)data toFileAtPath:(NSString*)aPath;

@end

@implementation CouponManager (Private)

-(BOOL)writeData2File:(NSData *)data toFileAtPath:(NSString*)aPath{
    if (!data || !aPath || ![aPath length])
        return NO;
    
    @try {
        if ((data == nil) || ([data length] <= 0))
            return NO;
        
        [data writeToFile:aPath atomically:YES];
        
        return YES;
    } @catch (NSException *e) {
        CCLog(@"create thumbnail exception.");
    }
    
    return NO;
}

@end

@implementation CouponManager
@synthesize delegate;

-(CouponManager*) initWithDirectory:(NSString*)_directory andListFileName:(NSString*)_filename {
    if ((self = [super init])) {
        self->directory = [_directory retain];
        self->filename = [_filename retain];
	}
	return self;
}

-(void) dealloc {
    [directory release];
    [filename release];
    [delegate release];
    
    [super dealloc];
}

+ (NSMutableArray*)LoadCouponsDataFromFile:(NSString*)filepath {
    NSMutableArray* t = [[NSMutableArray alloc] initWithContentsOfFile:filepath];
    
    NSMutableArray* adData = [[NSMutableArray alloc] init];
    for (NSMutableDictionary* d in t) {
        NSString* adUrl = [d objectForKey:@"adUrl"];
        NSString* adid = [d objectForKey:@"adid"];
        NSString* audioUrl = [d objectForKey:@"audioUrl"];
        NSString* imageUrl = [d objectForKey:@"imageUrl"];
        NSString* name = [d objectForKey:@"name"];
        NSString* text = [d objectForKey:@"text"];
        NSString* type = [d objectForKey:@"type"];
        NSString* updateDate = [d objectForKey:@"updateDate"];
        
        CCAdData *add = [[CCAdData alloc] initWithName:name andImageUrl:imageUrl andAudioUrl:audioUrl andAdUrl:adUrl andAdText:text andAdID:[adid intValue] andType:type andUpdateDate:updateDate andNeed2Update:NO];
        [adData addObject:add];
        [add release];
    }
    
    [t release];
    
    return [adData autorelease];
}

+ (void)SaveCouponsDataToDB:(NSString*)filepath andAdArray:(NSMutableArray*)adData{
    NSString *errorDesc;
    NSDictionary *innerDict;
    NSString *name;
    
    NSMutableArray* ads = [[NSMutableArray alloc] init];
    for (CCAdData* a in adData) {
        NSMutableDictionary* d = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  a.adUrl,   @"adUrl",
                                  [NSString stringWithFormat:@"%d", a.adid], @"adid",
                                  a.audioUrl,      @"audioUrl",
                                  a.imageUrl,       @"imageUrl",
                                  a.name,       @"name",
                                  a.adText,    @"text",
                                  a.updateDate,    @"updateDate",
                                  a.type,   @"type",
                                  nil];
        
        [ads addObject:d];
    }
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:(id)ads format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDesc];
    
    // 这个plistData为创建好的plist文件，用其writeToFile方法就可以写成文件。下面是代码：
    // 存文件
    if (plistData) {
        [plistData writeToFile:filepath atomically:YES];
    } else {
        CCLog(@"%@", errorDesc);
        [errorDesc release];
    }
    
    [ads release];
}

#pragma mark -
#pragma mark HttpRequest API
- (void)recvRespFromServerSucceeded:(NSData *)data userInfo:(NSMutableDictionary *)userInfo
{
	if(data == nil)	return;
    
    NSString* msgtype = [userInfo objectForKey:@"msgtype"];
    
    NSString *recvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *aStr = [recvString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithDictionary:[aStr mutableObjectFromJSONString]];
    //CCLog(@"%@ recvRespFromServerSucceeded aStr:%@", msgtype, aStr);
    
    #pragma mark -- kDownloadCouponList Respone --
    if ([msgtype isEqualToString:kDownloadCouponList])
    {
        NSMutableArray* coupon_list = [root objectForKey:@"coupon_list"];
        //CCLog(@"coupon_list='%@', %d", coupon_list, coupon_list.count);

        NSMutableArray* localCouponsArray = [self dbLoadCouponData:kDBLoadAllCouponsData];
        
        NSMutableArray* addCouponsArray = [[NSMutableArray alloc] init];
        NSMutableArray* updateCouponsArray = [[NSMutableArray alloc] init];
        
        //服务器数据检查
        for (NSMutableDictionary* d in coupon_list)
        {
            NSString* coupon_id = [d objectForKey:@"coupon_type_id"];
            NSString* coupon_type_id = [d objectForKey:@"coupon_type_id"];
            NSString* coupon_name = [d objectForKey:@"coupon_name"];
            NSString* coupon_price = [d objectForKey:@"coupon_price"];
            NSString* coupon_detail = [d objectForKey:@"coupon_detail"];
            NSString* coupon_thumbnail_url = [d objectForKey:@"coupon_thumbnail_url"];
            NSString* coupon_image_url = [d objectForKey:@"coupon_image_url"];
            NSString* coupon_validity = [d objectForKey:@"coupon_validity"];
            NSString* coupon_total = [d objectForKey:@"coupon_total"];
            NSString* coupon_remain = [d objectForKey:@"coupon_remain"];
            NSString* coupon_classify = [d objectForKey:@"coupon_classify"];
            NSString* coupon_brand = [d objectForKey:@"coupon_brand"];
            NSString* province = [d objectForKey:@"province"];
            NSString* city = [d objectForKey:@"city"];
            NSString* shop_id = [d objectForKey:@"shop_id"];
            NSString* update_time = [d objectForKey:@"update_time"];
            NSString* coupon_type = [d objectForKey:@"coupon_type"];
            BOOL available = [[d objectForKey:@"available"] boolValue];
            available = available ? available : YES;
            
            BOOL exist = NO;
            for (CouponData *localCoupon in localCouponsArray)
            {
                //存在,是否update
                if ([coupon_id isEqualToString:localCoupon.coupon_id]) {
                    exist = YES;
                    
                    NSComparisonResult upRet = [update_time caseInsensitiveCompare:localCoupon.update_time];
                    if (upRet == NSOrderedDescending)
                    {
                        CouponData *aCoupon = [[CouponData alloc] initWithId:coupon_id andTypeId:coupon_type_id andWho:kDBLoadAllCouponsData andName:coupon_name andPrice:coupon_price andDetail:coupon_detail andThumbNailUrl:coupon_thumbnail_url andImageUrl:coupon_image_url andValidity:coupon_validity andTotal:coupon_total andRemain:coupon_remain andClassify:coupon_classify andBrand:coupon_brand andProvince:province andCity:city andShopId:shop_id andUpdateTime:update_time andType:coupon_type andAvailable:available andThumbNailUrlLocal:@"" andImageUrlLocal:@""];
                        [updateCouponsArray addObject:aCoupon];
                        [aCoupon release];
                        break;
                    }
                }
            }
            
            //不存在,add
            if (!exist)
            {
                CouponData *aCoupon = [[CouponData alloc] initWithId:coupon_id andTypeId:coupon_type_id andWho:kDBLoadAllCouponsData andName:coupon_name andPrice:coupon_price andDetail:coupon_detail andThumbNailUrl:coupon_thumbnail_url andImageUrl:coupon_image_url andValidity:coupon_validity andTotal:coupon_total andRemain:coupon_remain andClassify:coupon_classify andBrand:coupon_brand andProvince:province andCity:city andShopId:shop_id andUpdateTime:update_time andType:coupon_type andAvailable:available andThumbNailUrlLocal:@"" andImageUrlLocal:@""];
                [addCouponsArray addObject:aCoupon];
                [aCoupon release];
            }
        }
        
        //本地数据检查
        for (CouponData *localCoupon in localCouponsArray)
        {
            BOOL exist = NO;
            for (NSMutableDictionary* d in coupon_list)
            {
                NSString* coupon_id = [d objectForKey:@"coupon_type_id"];
                if ([localCoupon.coupon_id isEqualToString:coupon_id]) {
                    exist = YES;
                    break;
                }
            }
            if (!exist)
            {
                //删除该优惠券
                [self dbDeleteACouponData:localCoupon.coupon_id andWho:@"all"];
            }
        }
        
        //添加优惠券
        if ([addCouponsArray count] > 0)
            [self dbAddCouponData:addCouponsArray];

        //更新优惠券
        if ([updateCouponsArray count] > 0)
            [self dbUpdateCouponData:updateCouponsArray];
        
        [addCouponsArray release];
        [updateCouponsArray release];
        
        if ([self.delegate respondsToSelector:@selector(shouldContinueAfterGetCouponsDataFromNet:)])
            [self.delegate shouldContinueAfterGetCouponsDataFromNet:userInfo];
    }
    #pragma mark -- kDownloadCollectCoupons Respone --
    else if ([msgtype isEqualToString:kDownloadCollectCoupons])
    {
        NSMutableArray* coupon_list = [root objectForKey:@"coupon_list"];
        CCLog(@"coupon_list='%@', %d", coupon_list, coupon_list.count);
        
        NSString *user_number = [[CloudCall2AppDelegate sharedInstance] getUserName];
        NSMutableArray* localCouponsArray = [self dbLoadCouponData:user_number];
        
        NSMutableArray* addCouponsArray = [[NSMutableArray alloc] init];
        NSMutableArray* updateCouponsArray = [[NSMutableArray alloc] init];
        
        //服务器数据检查
        for (NSMutableDictionary* d in coupon_list)
        {
            NSString* coupon_id = [d objectForKey:@"coupon_id"];
            NSString* coupon_type_id = [d objectForKey:@"coupon_type_id"];
            NSString* coupon_name = [d objectForKey:@"coupon_name"];
            NSString* coupon_price = [d objectForKey:@"coupon_price"];
            NSString* coupon_detail = [d objectForKey:@"coupon_detail"];
            NSString* coupon_thumbnail_url = [d objectForKey:@"coupon_thumbnail_url"];
            NSString* coupon_image_url = [d objectForKey:@"coupon_image_url"];
            NSString* coupon_validity = [d objectForKey:@"coupon_validity"];
            NSString* coupon_total = [d objectForKey:@"coupon_total"];
            NSString* coupon_remain = [d objectForKey:@"coupon_remain"];
            NSString* coupon_classify = [d objectForKey:@"coupon_classify"];
            NSString* coupon_brand = [d objectForKey:@"coupon_brand"];
            NSString* province = [d objectForKey:@"province"];
            NSString* city = [d objectForKey:@"city"];
            NSString* shop_id = [d objectForKey:@"shop_id"];
            NSString* update_time = [d objectForKey:@"update_time"];
            NSString* coupon_type = [d objectForKey:@"coupon_type"];
            BOOL available = [[d objectForKey:@"available"] boolValue];
            available = available ? available : YES;
            
            BOOL exist = NO;
            for (CouponData *localCoupon in localCouponsArray)
            {
                //存在,是否update
                if ([coupon_id isEqualToString:localCoupon.coupon_id]) {
                    exist = YES;
                    
                    NSComparisonResult upRet = [update_time caseInsensitiveCompare:localCoupon.update_time];
                    if (upRet == NSOrderedDescending)
                    {
                        CouponData *aCoupon = [[CouponData alloc] initWithId:coupon_id andTypeId:coupon_type_id andWho:user_number andName:coupon_name andPrice:coupon_price andDetail:coupon_detail andThumbNailUrl:coupon_thumbnail_url andImageUrl:coupon_image_url andValidity:coupon_validity andTotal:coupon_total andRemain:coupon_remain andClassify:coupon_classify andBrand:coupon_brand andProvince:province andCity:city andShopId:shop_id andUpdateTime:update_time andType:coupon_type andAvailable:available andThumbNailUrlLocal:@"" andImageUrlLocal:@""];
                        [updateCouponsArray addObject:aCoupon];
                        [aCoupon release];
                        break;
                    }
                }
            }
            
            //不存在,add
            if (!exist)
            {
                CouponData *aCoupon = [[CouponData alloc] initWithId:coupon_id andTypeId:coupon_type_id andWho:user_number andName:coupon_name andPrice:coupon_price andDetail:coupon_detail andThumbNailUrl:coupon_thumbnail_url andImageUrl:coupon_image_url andValidity:coupon_validity andTotal:coupon_total andRemain:coupon_remain andClassify:coupon_classify andBrand:coupon_brand andProvince:province andCity:city andShopId:shop_id andUpdateTime:update_time andType:coupon_type andAvailable:available andThumbNailUrlLocal:@"" andImageUrlLocal:@""];
                [addCouponsArray addObject:aCoupon];
                [aCoupon release];
            }
        }
        
        //本地数据检查
        for (CouponData *localCoupon in localCouponsArray)
        {
            BOOL exist = NO;
            for (NSMutableDictionary* d in coupon_list)
            {
                NSString* coupon_id = [d objectForKey:@"coupon_id"];
                if ([localCoupon.coupon_id isEqualToString:coupon_id]) {
                    exist = YES;
                    break;
                }
            }
            if (!exist)
            {
                //删除该优惠券
                [self dbDeleteACouponData:localCoupon.coupon_id andWho:localCoupon.coupon_who];
            }
        }
        
        //添加优惠券
        if ([addCouponsArray count] > 0)
            [self dbAddCouponData:addCouponsArray];
        
        //更新优惠券
        if ([updateCouponsArray count] > 0)
            [self dbUpdateCouponData:updateCouponsArray];
        
        [addCouponsArray release];
        [updateCouponsArray release];
        
        if ([self.delegate respondsToSelector:@selector(shouldContinueAfterGetCouponsDataFromNet:)])
            [self.delegate shouldContinueAfterGetCouponsDataFromNet:userInfo];
    }
    #pragma mark -- kDeleteCollectCoupons Respone --
    else if ([msgtype isEqualToString:kDeleteCollectCoupons])
    {
        NSString *result = [root objectForKey:@"result"];
        [userInfo setObject:result forKey:@"requestresult"];
        
        if ([self.delegate respondsToSelector:@selector(shouldContinueAfterGetCouponsDataFromNet:)])
            [self.delegate shouldContinueAfterGetCouponsDataFromNet:userInfo];
    }
    #pragma mark -- kUpdateCollectCoupons Respone --
    else if ([msgtype isEqualToString:kUpdateCollectCoupons])
    {
        NSString *result = [root objectForKey:@"result"];
        [userInfo setObject:result forKey:@"requestresult"];
        
        if ([self.delegate respondsToSelector:@selector(shouldContinueAfterGetCouponsDataFromNet:)])
            [self.delegate shouldContinueAfterGetCouponsDataFromNet:userInfo];
    }
    
    [root release];
    [recvString release];
}

- (void)recvRespFromServerFailed:(NSError *)error userInfo:(NSMutableDictionary *)userInfo
{
    [userInfo setObject:@"error" forKey:@"requestresult"];
    [userInfo setObject:error forKey:@"errmsg"];
    
    if ([self.delegate respondsToSelector:@selector(shouldContinueAfterGetCouponsDataFromNet:)])
        [self.delegate shouldContinueAfterGetCouponsDataFromNet:userInfo];
}

- (void)sendRequest2Server:(NSData *)jsonData andType:(NSString *)reqType
{
    NSString *url;
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
	[userInfo setObject:reqType forKey:@"msgtype"];
    
    if ([reqType isEqualToString:kDownloadCollectCoupons])
        url = kCollectionCouponsListUrl;
    else if ([reqType isEqualToString:kDeleteCollectCoupons])
    {
        url = kDeleteCouponsUrl;
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *aStr = [jsonString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithDictionary:[aStr mutableObjectFromJSONString]];
        NSArray *contextArray = [root objectForKey:@"context"];
        NSDictionary *context = [contextArray objectAtIndex:0];
        NSString *coupon_id = [context objectForKey:@"coupon_id"];
        
        [userInfo setObject:coupon_id forKey:@"coupon_id"];
        
        [jsonString release];
        [root release];
    }
    else if ([reqType isEqualToString:kUpdateCollectCoupons])
    {
        url = kUpdateCouponsUrl;
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *aStr = [jsonString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithDictionary:[aStr mutableObjectFromJSONString]];
        NSArray *contextArray = [root objectForKey:@"context"];
        NSDictionary *context = [contextArray objectAtIndex:0];
        NSString *coupon_id = [context objectForKey:@"coupon_id"];
        
        [userInfo setObject:coupon_id forKey:@"coupon_id"];
        
        [jsonString release];
        [root release];
    }
    else
        url = kCouponsListUrl;
        
    [[HttpRequest instance] addRequest:url andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                         successTarget:self successAction:@selector(recvRespFromServerSucceeded:userInfo:)
                         failureTarget:self failureAction:@selector(recvRespFromServerFailed:userInfo:) userInfo:userInfo];
}

#pragma mark
#pragma mark DBManager
- (NSString *)getDocumentPath
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [pathArray objectAtIndex:0];
    
    return documentPath;
}

- (FMDatabase *)getManageDB
{
    NSString *dbPath = [[self getDocumentPath] stringByAppendingPathComponent:kDefaultDB];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    return db;
}

/**
 *	@brief	读取优惠券
 *
 *	@param 	CouponType 	操作类型
 */
- (NSMutableArray *)dbLoadCouponData:(NSString *)coupon_who
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:10];
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from couponinfo where coupon_who = '%@'",coupon_who];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    FMResultSet *dbresult = [db executeQuery:sql];
    
    while([dbresult next])
    {
        NSString *coupon_id = [dbresult stringForColumnIndex:0];
        NSString *coupon_who = [dbresult stringForColumnIndex:1];
        NSString *coupon_type_id = [dbresult stringForColumnIndex:2];
        NSString *coupon_name = [dbresult stringForColumnIndex:3];
        NSString *coupon_price = [dbresult stringForColumnIndex:4];
        NSString *coupon_detail = [dbresult stringForColumnIndex:5];
        NSString *coupon_thumbnail_url = [dbresult stringForColumnIndex:6];
        NSString *coupon_image_url = [dbresult stringForColumnIndex:7];
        NSString *coupon_validity = [dbresult stringForColumnIndex:8];
        NSString *coupon_total = [dbresult stringForColumnIndex:9];
        NSString *coupon_remain = [dbresult stringForColumnIndex:10];
        NSString *coupon_classify = [dbresult stringForColumnIndex:11];
        NSString *coupon_brand = [dbresult stringForColumnIndex:12];
        NSString *province = [dbresult stringForColumnIndex:13];
        NSString *city = [dbresult stringForColumnIndex:14];
        NSString *shop_id = [dbresult stringForColumnIndex:15];
        NSString *update_time = [dbresult stringForColumnIndex:16];
        NSString *coupon_type = [dbresult stringForColumnIndex:17];
        BOOL available = [dbresult boolForColumnIndex:18];
        NSString *thumbnail_url_local = [dbresult stringForColumnIndex:19];
        NSString *image_url_local = [dbresult stringForColumnIndex:20];
        
        CouponData *couponData = [[CouponData alloc] initWithId:coupon_id
                                                      andTypeId:coupon_type_id
                                                         andWho:coupon_who
                                                        andName:coupon_name
                                                       andPrice:coupon_price
                                                      andDetail:coupon_detail
                                                andThumbNailUrl:coupon_thumbnail_url
                                                    andImageUrl:coupon_image_url
                                                    andValidity:coupon_validity
                                                       andTotal:coupon_total
                                                      andRemain:coupon_remain
                                                    andClassify:coupon_classify
                                                       andBrand:coupon_brand
                                                    andProvince:province
                                                        andCity:city
                                                      andShopId:shop_id
                                                  andUpdateTime:update_time
                                                        andType:coupon_type
                                                   andAvailable:available
                                           andThumbNailUrlLocal:thumbnail_url_local
                                               andImageUrlLocal:image_url_local];
        
        [result addObject:couponData];
        [couponData release];
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
    
    //CCLog(@"---result : %@---",result);
    
    return result;
}

/**
 *	@brief	读取优惠券
 *
 *	@param 	coupon_id 	优惠券id
 *	@param 	_who        优惠券属主
 */
- (CouponData *)dbLoadCouponDataByCouponId:(NSString *)coupon_id andWho:(NSString *)_who
{
    CouponData *couponData = nil;
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from couponinfo where coupon_id = '%@' and coupon_who = '%@'",coupon_id , _who];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    FMResultSet *dbresult = [db executeQuery:sql];
    
    if([dbresult next])
    {
        NSString *coupon_id = [dbresult stringForColumnIndex:0];
        NSString *coupon_who = [dbresult stringForColumnIndex:1];
        NSString *coupon_type_id = [dbresult stringForColumnIndex:2];
        NSString *coupon_name = [dbresult stringForColumnIndex:3];
        NSString *coupon_price = [dbresult stringForColumnIndex:4];
        NSString *coupon_detail = [dbresult stringForColumnIndex:5];
        NSString *coupon_thumbnail_url = [dbresult stringForColumnIndex:6];
        NSString *coupon_image_url = [dbresult stringForColumnIndex:7];
        NSString *coupon_validity = [dbresult stringForColumnIndex:8];
        NSString *coupon_total = [dbresult stringForColumnIndex:9];
        NSString *coupon_remain = [dbresult stringForColumnIndex:10];
        NSString *coupon_classify = [dbresult stringForColumnIndex:11];
        NSString *coupon_brand = [dbresult stringForColumnIndex:12];
        NSString *province = [dbresult stringForColumnIndex:13];
        NSString *city = [dbresult stringForColumnIndex:14];
        NSString *shop_id = [dbresult stringForColumnIndex:15];
        NSString *update_time = [dbresult stringForColumnIndex:16];
        NSString *coupon_type = [dbresult stringForColumnIndex:17];
        BOOL available = [dbresult boolForColumnIndex:18];
        NSString *thumbnail_url_local = [dbresult stringForColumnIndex:19];
        NSString *image_url_local = [dbresult stringForColumnIndex:20];
        
        couponData = [[[CouponData alloc] initWithId:coupon_id
                                                      andTypeId:coupon_type_id
                                                         andWho:coupon_who
                                                        andName:coupon_name
                                                       andPrice:coupon_price
                                                      andDetail:coupon_detail
                                                andThumbNailUrl:coupon_thumbnail_url
                                                    andImageUrl:coupon_image_url
                                                    andValidity:coupon_validity
                                                       andTotal:coupon_total
                                                      andRemain:coupon_remain
                                                    andClassify:coupon_classify
                                                       andBrand:coupon_brand
                                                    andProvince:province
                                                        andCity:city
                                                      andShopId:shop_id
                                                  andUpdateTime:update_time
                                                        andType:coupon_type
                                                   andAvailable:available
                                           andThumbNailUrlLocal:thumbnail_url_local
                                               andImageUrlLocal:image_url_local] autorelease];
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
    
    if (couponData)
        return couponData;
    else
        return nil;
}

- (NSString *)dbLoadColumnData:(NSString *)which_column ByColumn:(NSString *)bycolumn AndValue:(NSString *)value
{
    NSString *result = @"";
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"select %@ from couponinfo where %@ = '%@'",which_column, bycolumn , value];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    FMResultSet *dbresult = [db executeQuery:sql];
    
    if([dbresult next])
    {
        result = [dbresult stringForColumnIndex:0];
    }

        
    if ([db hadError])
    {
        //CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
    
    //CCLog(@"---result : %@---",result);
    
    return result;
}

/**
 *	@brief	增加优惠券
 *
 *	@param 	addArray 	优惠券
 */
- (void)dbAddCouponData:(NSMutableArray *)addArray
{
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    //批量add
    for (CouponData *newCoupon in addArray)
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"insert into couponinfo values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@',%d,'','')",newCoupon.coupon_id, newCoupon.coupon_who, newCoupon.coupon_type_id,newCoupon.coupon_name ,newCoupon.coupon_price ,newCoupon.coupon_detail ,newCoupon.coupon_thumbnail_url ,newCoupon.coupon_image_url ,newCoupon.coupon_validity ,newCoupon.coupon_total ,newCoupon.coupon_remain ,newCoupon.coupon_classify ,newCoupon.coupon_brand ,newCoupon.province ,newCoupon.city ,newCoupon.shop_id ,newCoupon.update_time , newCoupon.type, newCoupon.available];
        
        //CCLog(@"--- sql: %@ ---",sql);
        
        [db executeUpdate:sql];
        [sql release];
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	删除优惠券
 *
 *	@param 	coupon_id 	优惠券id
 */
- (void)dbDeleteACouponData:(NSString *)coupon_id andWho:(NSString *)_who
{
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql;
    
    if ([NgnStringUtils isNullOrEmpty:_who])
        sql = [NSString stringWithFormat:@"delete from couponinfo where coupon_id = '%@'" , coupon_id];
    else
        sql = [NSString stringWithFormat:@"delete from couponinfo where coupon_id = '%@' and coupon_who = '%@'", coupon_id, _who];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    BOOL success = [db executeUpdate:sql];
        
    if (!success || [db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	更新优惠券
 *
 *	@param 	updateArray 	优惠券
 */
- (void)dbUpdateCouponData:(NSMutableArray *)updateArray
{
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    //批量update
    for (CouponData *newCoupon in updateArray)
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"update couponinfo set coupon_who = '%@',coupon_type_id = '%@',coupon_name = '%@',coupon_price = '%@',coupon_detail = '%@',coupon_thumbnail_url = '%@',coupon_image_url = '%@',coupon_validity = '%@',coupon_total = '%@',coupon_remain = '%@',coupon_classify = '%@',coupon_brand = '%@',province = '%@',city = '%@',shop_id = '%@',update_time = '%@',coupon_type = '%@',available = %d,coupon_thumbnail_url_local = '',coupon_image_url_local = '' where coupon_id = '%@')",newCoupon.coupon_who, newCoupon.coupon_type_id,newCoupon.coupon_name ,newCoupon.coupon_price ,newCoupon.coupon_detail ,newCoupon.coupon_thumbnail_url ,newCoupon.coupon_image_url ,newCoupon.coupon_validity ,newCoupon.coupon_total ,newCoupon.coupon_remain ,newCoupon.coupon_classify ,newCoupon.coupon_brand ,newCoupon.province ,newCoupon.city ,newCoupon.shop_id ,newCoupon.update_time , newCoupon.type, newCoupon.available ,newCoupon.coupon_id];
        
        //CCLog(@"--- sql: %@ ---",sql);
        
        [db executeUpdate:sql];
        [sql release];
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	更新优惠券
 *
 *	@param 	column 	字段名 
 *  @param  value   值
 */
- (void)dbUpdateCouponData:(NSString *)column andValue:(NSString *)value andCouponID:(NSString *)couponid
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"update couponinfo set %@ = '%@' where coupon_type_id = '%@'", column, value, couponid];
    
    //CCLog(@"--- sql: %@ ---",sql);
        
    [db executeUpdate:sql];
    [sql release];
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	更新优惠券
 *
 *	@param 	column 	字段名
 *  @param  value   值
 */
- (void)dbUpdateCouponDataAfterUsed:(NSString *)couponid
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"update couponinfo set available = 0 where coupon_id = '%@'", couponid];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    [db executeUpdate:sql];
    [sql release];
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}
@end
