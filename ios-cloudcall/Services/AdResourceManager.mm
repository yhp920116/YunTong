//

#import "AdResourceManager.h"
#import "HttpRequest.h"
#import "CloudCall2AppDelegate.h"
#import "JSONKit.h"

@implementation CCAdData

@synthesize name;
@synthesize imageUrl;
@synthesize audioUrl;
@synthesize adUrl;
@synthesize adText;
@synthesize updateDate;
@synthesize type;
@synthesize adid;
@synthesize need2Update;

-(CCAdData*) initWithName:(NSString*)_name andImageUrl:(NSString*)_imageUrl andAudioUrl:(NSString*)_audioUrl andAdUrl:(NSString*)_adUrl andAdText:(NSString*)_adText andAdID:(int)_adID andType:(NSString*)_type andUpdateDate:(NSString*)_updateDate andNeed2Update:(BOOL)_need2Update {
    if ((self = [super init])) {
        self->name        = [_name retain];
        self->imageUrl    = [_imageUrl retain];
        self->audioUrl    = [_audioUrl retain];
        self->adUrl       = [_adUrl retain];
        self->adText      = [_adText retain];
        self->updateDate  = [_updateDate retain];
        self->type        = [_type retain];
        self->adid        = _adID;
        self->need2Update = _need2Update;
	}
	return self;
}

-(void) dealloc {
    [name release];
    [imageUrl release];
    [audioUrl release];
    [adUrl release];
    [adText release];
    [updateDate release];
    [type release];
    
    [super dealloc];
}

@end

@implementation CCAdsData
@synthesize adid;
@synthesize endtime;
@synthesize updatetime;
@synthesize type;
@synthesize myindex;
@synthesize image;
@synthesize ring;
@synthesize video;
@synthesize adtxt;
@synthesize clickAction;
@synthesize clickurl;
@synthesize need2Update;
@synthesize daySegments;

- (CCAdsData *)initWithAdID:(int)_adid andEndtime:(NSString *)_endtime andUpdateTime:(NSString *)_updatetime andType:(int)_type andMyindex:(int)_myindex andImage:(NSString *)_image andRing:(NSString *)_ring andVideo:(NSString *)_video andAdtext:(NSString *)_adtext andClickAction:(int)_clickAction andClickUrl:(NSString *)_clickurl andNeed2Update:(BOOL)_need2Update andDaySegments:(NSString *)_daySegments
{
    if (self = [super init]) {
        self.adid = _adid;
        self.endtime = _endtime;
        self.updatetime = _updatetime;
        self.type = _type;
        self.myindex = _myindex;
        self.image = _image;
        self.ring = _ring;
        self.video = _video;
        self.adtxt = _adtext;
        self.clickAction = _clickAction;
        self.clickurl = _clickurl;
        self.need2Update = _need2Update;
        self.daySegments = _daySegments;
    }
    return self;
}

- (void)dealloc
{
    [endtime release];
    [updatetime release];
    [image release];
    [ring release];
    [video release];
    [adtxt release];
    [clickurl release];
    [daySegments release];

    [super dealloc];
}

@end

@implementation CCAdStatisticsData
@synthesize _id;
@synthesize adid;
@synthesize show;
@synthesize click;
@synthesize issubmit;
@synthesize timebyhour;

- (CCAdStatisticsData *)initWithid:(int)id_ andAdID:(int)adid_ andShow:(int)show_ andClick:(int)click_ andIsSubmit:(int)issubmit_  andTime:(NSString *)_timebyhour
{
    if ((self = [super init])) {
        self->_id       = id_;
        self->adid      = adid_;
        self->show      = show_;
        self->click     = click_;
        self->issubmit  = issubmit_;
        self.timebyhour = _timebyhour;
	}
	return self;
}

- (void)dealloc
{
    [timebyhour release];
    [super dealloc];
}

@end

@interface AdResourceManager (Private)

-(BOOL)writeData2File:(NSData*)data toFileAtPath:(NSString*)aPath;


-(void) getAdDataFromNet:(NSMutableArray*)_asArray;
@end

@implementation AdResourceManager (Private)

-(BOOL)writeData2File:(NSData*)data toFileAtPath:(NSString*)aPath{
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

-(void)getAdDataFromNet:(NSMutableArray*)_adsArray {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (!_adsArray || [_adsArray count] == 0) {
        CCLog(@"AdResourceManager: getAdImageFromNet: adsArray is empty!!!");
        [pool release];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList;
    NSError *error = nil;
    NSString* fileName = @"";
    // fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:directory error:&error];
    
    // remove local directory (use ad name for directory name) if the directory is not found or need to update.
    for (NSString* f in fileList) {
        BOOL del = YES;
        for (CCAdData* a in _adsArray) {
            if (NSOrderedSame == [f caseInsensitiveCompare:a.name] && a.need2Update == NO) {
                del = NO;
                break;
            }
        }
        
        NSString* p = [directory stringByAppendingPathComponent:f];
        BOOL isDir;
        [fileManager fileExistsAtPath:p isDirectory:&isDir];
        if (del && isDir)
            [fileManager removeItemAtPath:p error:nil];
    }
    
    CCLog(@"%@, images count %d", directory, [_adsArray count]);
    
    BOOL updateAdData = NO;
    int i = 0;
    for (CCAdData* a in _adsArray) {
        CCLog(@" --------- imgfile %d, '%@', '%@'", a.need2Update, a.imageUrl, a.audioUrl);
        
        // 创建以广告名称命名的文件夹
        NSString* addir = [directory stringByAppendingPathComponent:a.name];
        if (![fileManager fileExistsAtPath:addir isDirectory:nil]) {
            if ([fileManager createDirectoryAtPath:addir withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
                CCLog(@"创建存放%@的文件夹失败", a.name);
            }
        }
        
        if (a.imageUrl && [a.imageUrl length]) {
            NSString* imgfile = [addir stringByAppendingPathComponent:[a.imageUrl lastPathComponent]];
            if (a.need2Update || ![fileManager fileExistsAtPath:imgfile isDirectory:nil]) {
                NSData* imageData = [[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:a.imageUrl]] autorelease];
                if (imageData) {
                    updateAdData = YES;
                    BOOL ret = [self writeData2File:imageData toFileAtPath:imgfile];
                    if (ret) {
                        a.need2Update = NO;
                    }
                } else {
                    CCLog(@"Get image failed %@", a.imageUrl);
                }
            }
        }
        
        if (a.audioUrl && [a.audioUrl length]) {
            NSString* audfile = [addir stringByAppendingPathComponent:[a.audioUrl lastPathComponent]];
            if (a.need2Update || ![fileManager fileExistsAtPath:audfile isDirectory:nil]) {
                NSData* audioData = [[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:a.audioUrl]] autorelease];
                if (audioData) {
                    updateAdData = YES;
                    BOOL ret = [self writeData2File:audioData toFileAtPath:audfile];
                    if (ret) {
                        a.need2Update = NO;
                    }
                } else {
                    CCLog(@"Get audio failed %@", a.audioUrl);
                }
            }
        }
    }
    
    NSString* filepath = [directory stringByAppendingPathComponent:filename];
    [AdResourceManager SaveAdsDataToFile:filepath andAdArray:_adsArray];
    
    if (updateAdData && self.delegate) {
        [self.delegate shouldContinueAfterGetAdDataFromNet];
    }
    
    [pool release];
}

@end

@implementation AdResourceManager
@synthesize submittingArray;
@synthesize adsDataArray;

-(AdResourceManager*) init
{
    if (self = [super init]){
        self.submittingArray = [NSMutableArray arrayWithCapacity:10];
        self.adsDataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

/**
 *	@brief	广告点击动作
 *
 *	@param 	actionUrl 	跳转url
 *	@param 	actionType 	动作类型
 */
- (void)adClickAction:(NSString *)actionUrl andActionType:(int)actionType andNavigation:(UINavigationController *)_navigationController
{
    switch (actionType)
    {
        CCLog(@"action url : %@", actionUrl);
        case ADActionTypeOpenInnerBrowser:  //内置浏览器打开url
        {
            [self OpenWebBrowser:actionUrl andNavigationController:_navigationController];
            break;
        }
        case ADActionTypeOpenOuterBrowser:  //外部浏览器打开url
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[actionUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            break;
        }
        case ADActionTypeGoToAppStore:      //跳转到appstore
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[actionUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            break;
        }
        case ADActionTypeShowFullScreen:    //全屏显示图片
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[actionUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            break;
        }
        case ADActionTypeDownloadApp:       //下载app
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[actionUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            break;
        }
        default:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[actionUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            break;
        }
    }
}

-(AdResourceManager*) initWithDirectory:(NSString*)_directory andListFileName:(NSString*)_filename {
    if ((self = [self init])) {
        self->directory = [_directory retain];
        self->filename = [_filename retain];
	}
	return self;
}

-(void) dealloc {
    [directory release];
    [filename release];
    [submittingArray release];
    [adsDataArray release];
    
    [super dealloc];
}

+(NSMutableArray*)LoadAdsDataFromFile:(NSString*)filepath {
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

+(void)SaveAdsDataToFile:(NSString*)filepath andAdArray:(NSMutableArray*)adData{
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

-(void) StartGetAdDataFromNetThread:(NSMutableArray*)_asArray {
    [self performSelectorInBackground:@selector(getAdDataFromNet:) withObject:_asArray];
}


#pragma mark -
#pragma mark HttpRequest API

- (void)getAdListSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo
{
	if(data == nil)	return;

    NSString *recvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *aStr = [recvString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //CCLog(@"AdResourceManager getAdListSucceeded: %@, '%@'", aStr, recvString);
    
    NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithDictionary:[aStr mutableObjectFromJSONString]];
    
    NSMutableArray* adlist = [root objectForKey:@"adlist"];
    CCLog(@"adlist='%@', %d", adlist, adlist.count);
    
    NSString* filepath = [directory stringByAppendingPathComponent:filename];
    NSMutableArray* currAdsArray = [AdResourceManager LoadAdsDataFromFile:filepath];
    
    NSMutableArray* newAdsArray = [[[NSMutableArray alloc] init] autorelease];
    for (NSMutableDictionary* d in adlist) {
        NSString* adUrl = [d objectForKey:@"adUrl"];
        NSString* adid = [d objectForKey:@"adid"];
        NSString* audioUrl = [d objectForKey:@"audioUrl"];
        NSString* imageUrl = [d objectForKey:@"imageUrl"];
        NSString* name = [d objectForKey:@"name"];
        NSString* text = [d objectForKey:@"text"];
        NSString* type = [d objectForKey:@"type"];
        NSString* updateDate = [d objectForKey:@"updateDate"];
        
        BOOL update = YES;
        for (CCAdData* a in currAdsArray) {
            NSComparisonResult upRet = [updateDate caseInsensitiveCompare:a.updateDate];
            if (NSOrderedSame == [a.name caseInsensitiveCompare:name] && (upRet == NSOrderedSame || upRet == NSOrderedAscending)) {
                update = NO;
                break;
            }
        }
        
        CCAdData* ad = [[CCAdData alloc] initWithName:name andImageUrl:imageUrl andAudioUrl:audioUrl andAdUrl:adUrl andAdText:text andAdID:[adid intValue] andType:type andUpdateDate:updateDate andNeed2Update:update];
        [newAdsArray addObject:ad];
        [ad release];
    }
    
    [root release];
    [recvString release];
    
    [self StartGetAdDataFromNetThread:newAdsArray];
}

- (void)getAdListFailed:(NSError *)error userInfo:(NSDictionary *)userInfo {
    return;
}

- (void)getAdsListFromServer:(NSString*)jsonString {    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    [[HttpRequest instance] addRequest:kDownloadListUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                         successTarget:self successAction:@selector(getAdListSucceeded:userInfo:)
                         failureTarget:self failureAction:@selector(getAdListFailed:userInfo:) userInfo:nil];
}

- (void)sendAdsRequest:(NSData *)jsonData andUserInfo:(NSMutableDictionary *)userInfo
{
    NSString *reqType = [userInfo objectForKey:@"reqType"];
    
    NSString *url = nil;
    if ([reqType isEqualToString:@"getAds"]){
        url = kGetAdsURL;
        notAllowToSubmitAdStat = NO;
    }
    else if([reqType isEqualToString:@"sendStat"]){
        url = kAdStatisticsURL;
        notAllowToSubmitAdStat = YES;
    }
    
    [[HttpRequest instance] addRequest:url andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                         successTarget:self successAction:@selector(sendAdsResponse:andUserInfo:)
                         failureTarget:self failureAction:@selector(sendAdsResponseError:andUserInfo:) userInfo:userInfo];
    
    if([reqType isEqualToString:@"sendStat"])
        [self dbUpdateADStatisticsDataStateSubmiting:ADStatisticsSubmiting];
}

- (void)sendAdsResponse:(NSData *)data andUserInfo:(NSMutableDictionary *)userInfo
{
    NSString *reqType = [userInfo objectForKey:@"reqType"];
    
    NSString *recvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *aStr = [recvString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithDictionary:[aStr mutableObjectFromJSONString]];
    
//    CCLog(@"1sendAdsResponse data:%@",root);
    
    if ([reqType isEqualToString:@"getAds"])
    {
        NSRange range = [aStr rangeOfString:@"time"];
        if (range.location != NSNotFound)
        {
            //服务器时间,用于计算与本地时间差
            NSString *strServTime = [root objectForKey:@"time"];
            //时间差计算;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            NSDate *servTime = [dateFormatter dateFromString:strServTime];
            [dateFormatter release];
            
            NSTimeInterval interval = [servTime timeIntervalSinceNow];
//            CCLog(@"---strServTime---%@---servTime---%@---timeIntervalWithServ---%d",strServTime,servTime,interval);
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setDouble:interval forKey:GENERAL_TimeIntervalWithServ];
            
            //将数据写入数据库
            [adsDataArray removeAllObjects];
            NSMutableArray *adsArray = [root objectForKey:@"ads"];
            
            for (NSMutableDictionary *anAd in adsArray)
            {
                @autoreleasepool {
                    int adid = [[anAd objectForKey:@"id"] intValue];
                    NSString *endtime = [anAd objectForKey:@"endtime"];
                    NSString *updatetime = [anAd objectForKey:@"updatetime"];
                    int type = [[anAd objectForKey:@"type"] intValue];
                    int myindex = [[anAd objectForKey:@"myindex"] intValue];
                    NSString *image = [anAd objectForKey:@"image"];
                    NSString *ring = [anAd objectForKey:@"ring"];
                    NSString *video = [anAd objectForKey:@"video"];
                    NSString *adtxt = [anAd objectForKey:@"adtxt"];
                    int clickAction = [[anAd objectForKey:@"clickAction"] intValue];
                    NSString *clickurl = [anAd objectForKey:@"clickurl"];
                    NSString *daySegments = [anAd objectForKey:@"daySegments"];
                    
                    (NSNull *)image == [NSNull null] ? image = nil : image;
                    (NSNull *)ring == [NSNull null] ? ring = nil : ring;
                    (NSNull *)video == [NSNull null] ? video = nil : video;
                    (NSNull *)daySegments == [NSNull null] ? daySegments = nil : daySegments;
                    
                    CCAdsData *ccAdsData = [[CCAdsData alloc] initWithAdID:adid andEndtime:endtime andUpdateTime:updatetime andType:type andMyindex:myindex andImage:image andRing:ring andVideo:video andAdtext:adtxt andClickAction:clickAction andClickUrl:clickurl andNeed2Update:NO andDaySegments:daySegments];
                    
                    [adsDataArray addObject:ccAdsData];
                    [ccAdsData release];
                }
              }
            
            [self performSelectorInBackground:@selector(dbAddOrUpdateAdsData) withObject:nil];
        }
        
    }
    else if ([reqType isEqualToString:@"sendStat"])
    {
        NSString *result = [root objectForKey:@"result"];
        
        //成功:减去提交的展示量与点击量,将提交状态设置为未提交
        //失败:将提交状态设置为未提交,数量不作限制
        if ([result isEqualToString:@"success"])
            [self dbUpdateADStatisticsDataAfterSubmitSuccess:submittingArray];
        else
            [self dbUpdateADStatisticsDataStateSubmitFail:ADStatisticsUnSubmit];
    }
    
    [recvString release];
    [root release];
}

- (void)sendAdsResponseError:(NSError *)error andUserInfo:(NSMutableDictionary *)userInfo
{
    NSString *reqType = [userInfo objectForKey:@"reqType"];
    
    if ([reqType isEqualToString:@"sendStat"])
    {
        notAllowToSubmitAdStat = NO;
        [self dbUpdateADStatisticsDataStateSubmitFail:ADStatisticsUnSubmit];
    }
}

#pragma mark
#pragma mark DBManager
- (NSString *)getCachesDirectoryPath
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [pathArray objectAtIndex:0];
    
    return documentPath;
}

- (FMDatabase *)getManageDB
{
    NSString *dbPath = [[self getCachesDirectoryPath] stringByAppendingPathComponent:kAdsDB];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    return db;
}

- (void)checkAdsDatabaseAndCreateTable
{
    FMDatabase *db = [self getManageDB];
    
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        CCLog(@"数据库打开失败");
        return;
    }
    
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    //判断数据库中是否已经存在表，如果不存在则创建
    
    //广告下载信息表
    if(![self tableExist:db withTable:kADsInfoTable])
    {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@(%@ INTEGER PRIMARY KEY, %@ TEXT, %@ TEXT, %@ INTEGER, %@ INTEGER, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ INTEGER, %@ TEXT, %@ INTEGER, %@ TEXT)", kADsInfoTable, kADStatisticsColId, kADsInfoColEndtime, kADsInfoColUpdateTime, kADsInfoColType, kADsInfoColMyindex, kADsInfoColImage, kADsInfoColRing, kADsInfoColVideo, kADsInfoColAdtxt, kADsInfoColClickAction, kADsInfoColClickUrl, kADsInfoColNeedUpdate, kADsInfoColDaySegments];
        [db executeUpdate:sql];
        CCLog(@"创建完成");
    }
    
    //广告统计信息表
    if(![self tableExist:db withTable:kADStatisticsTable])
    {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@(%@ INTEGER PRIMARY KEY, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ TEXT)", kADStatisticsTable, kADStatisticsColId, kADStatisticsColADId, kADStatisticsColShow, kADStatisticsColClick, kADStatisticsColIsSubmit, kADStatisticsColTimeByHour];
        [db executeUpdate:sql];
        CCLog(@"创建完成");
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
    
    //删除所有show和click为0且提交状态为未提交的记录
    [self dbDeleteADStatisticsDataNoNeed];
}

- (BOOL)tableExist:(FMDatabase *)db withTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT count(name) FROM sqlite_master WHERE type='table' and name='%@'", tableName];
    FMResultSet *rs = [db executeQuery:sql];
    if ([rs next])
    {
        int count = [rs intForColumnIndex:0];
        CCLog(@"tableExist count : %@ %d", rs, count);
        
        if (0 == count)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark
#pragma mark AdsDBManager
/**
 *	@brief	写入广告信息
 *
 *	@param 	adStatisticsArray 	传入参数 广告信息
 */
- (void)dbAddOrUpdateAdsData
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    //判断服务器是否存在
    NSMutableArray *oldAdsArray = [NSMutableArray arrayWithCapacity:10];
    NSString *sqlOldAds = [NSString stringWithFormat:@"select * from %@", kADsInfoTable];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    FMResultSet *oldAdsResult = [db executeQuery:sqlOldAds];
    
    while([oldAdsResult next])
    {
        @autoreleasepool {
            int adid = [oldAdsResult intForColumnIndex:0];
            NSString *endtime = [oldAdsResult stringForColumnIndex:1];
            NSString *updatetime = [oldAdsResult stringForColumnIndex:2];
            int type = [oldAdsResult intForColumnIndex:3];
            int myindex = [oldAdsResult intForColumnIndex:4];
            NSString *image = [oldAdsResult stringForColumnIndex:5];
            NSString *ring = [oldAdsResult stringForColumnIndex:6];
            NSString *video = [oldAdsResult stringForColumnIndex:7];
            NSString *adtext = [oldAdsResult stringForColumnIndex:8];
            int clickaction = [oldAdsResult intForColumnIndex:9];
            NSString *clickurl = [oldAdsResult stringForColumnIndex:10];
            BOOL need2Update = [oldAdsResult boolForColumnIndex:11];
            NSString *daySegments = [oldAdsResult stringForColumnIndex:12];
            
            CCAdsData *oldAdsData= [[CCAdsData alloc] initWithAdID:adid andEndtime:endtime andUpdateTime:updatetime andType:type andMyindex:myindex andImage:image andRing:ring andVideo:video andAdtext:adtext andClickAction:clickaction andClickUrl:clickurl andNeed2Update:need2Update andDaySegments:daySegments];
            [oldAdsArray addObject:oldAdsData];
            [oldAdsData release];
        }
    }
    
    for (CCAdsData *oldAdsData in oldAdsArray)
    {
        //默认是删除该文件,如果能在服务器返回的广告资源中找到该资源的id则不删除
        BOOL del = YES;
        
        for (CCAdsData *adsData in adsDataArray)
        {
            if (oldAdsData.adid == adsData.adid) del = NO;
        }
        
        if (del)    //删除
        {
            NSString *delSql = [NSString stringWithFormat:@"delete from %@ where %@ = %d", kADsInfoTable, kADsInfoColId, oldAdsData.adid];
            [db executeUpdate:delSql];
        }
        
    }
    
    NSMutableArray *updateAdsArray = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *noUpdateAdsArray = [NSMutableArray arrayWithCapacity:10];
    //批量add
    for (CCAdsData *adsData in adsDataArray)
    {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@ = %d", kADsInfoColUpdateTime, kADsInfoTable, kADsInfoColId, adsData.adid];
        FMResultSet *dbresult = [db executeQuery:sql];
        NSString *oldUpdateTime = nil;
        while([dbresult next])
        {
            oldUpdateTime = [dbresult stringForColumnIndex:0];
        }
        
        //判断是否存在
        if (!oldUpdateTime)     //不存在
        {
            //更新资源
            [updateAdsArray addObject:adsData];
            
            //插入新数据
            NSString *insertSql = [NSString stringWithFormat:@"insert into %@ values(%d,'%@','%@', %d, %d,'%@','%@','%@','%@',%d,'%@',%d, '%@')", kADsInfoTable, adsData.adid, adsData.endtime, adsData.updatetime, adsData.type, adsData.myindex, adsData.image, adsData.ring, adsData.video, adsData.adtxt, adsData.clickAction, adsData.clickurl, YES, adsData.daySegments];
            
            [db executeUpdate:insertSql];
            
            continue;
        }
        
        //判断是否需要更新
        BOOL update = NO;
        
        if (NSOrderedDescending == [adsData.updatetime compare:oldUpdateTime])
            update = YES;
        
        if (update)      //需要更新
        {
            [updateAdsArray addObject:adsData];
            
            //删除旧数据
            BOOL result = [self dbDeleteAnAdData:adsData.adid];
            
            if (result)
            {
                //插入新数据
                NSString *insertSql = [NSString stringWithFormat:@"insert into %@ values(%d,'%@','%@', %d, %d,'%@','%@','%@','%@',%d,'%@',%d,'%@')", kADsInfoTable, adsData.adid, adsData.endtime, adsData.updatetime, adsData.type, adsData.myindex, adsData.image, adsData.ring, adsData.video, adsData.adtxt, adsData.clickAction, adsData.clickurl, YES, adsData.daySegments];
                
                [db executeUpdate:insertSql];
            }
        }
        else
            [noUpdateAdsArray addObject:adsData];
    }
    
    //通知更新广告信息
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateAdsInfo object:nil];
    
    //下载需要更新的广告资源
    [self getAdsResourceFromNet:updateAdsArray andUpdate:YES];
    
    //检查不需更新的广告文件是否完整
    [self getAdsResourceFromNet:noUpdateAdsArray andUpdate:NO];
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	读取广告统计表所有信息
 *
 *	@param 	adStatisticsArray 	传出参数 结果集
 */
- (void)dbLoadAdsData:(NSMutableArray *)adsArray andMyIndex:(ADSMyindex)myindex
{    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where  %@ = %d",kADsInfoTable, kADsInfoColMyindex, myindex];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    FMResultSet *dbresult = [db executeQuery:sql];
    NSString *currTime = [[NSString alloc] initWithString:[self getTimeByServStandard]];
    
    while([dbresult next])
    {
        @autoreleasepool {
            int adid = [dbresult intForColumnIndex:0];
            NSString *endtime = [dbresult stringForColumnIndex:1];
            NSString *updatetime = [dbresult stringForColumnIndex:2];
            int type = [dbresult intForColumnIndex:3];
            int myindex = [dbresult intForColumnIndex:4];
            NSString *image = [dbresult stringForColumnIndex:5];
            NSString *ring = [dbresult stringForColumnIndex:6];
            NSString *video = [dbresult stringForColumnIndex:7];
            NSString *adtext = [dbresult stringForColumnIndex:8];
            int clickaction = [dbresult intForColumnIndex:9];
            NSString *clickurl = [dbresult stringForColumnIndex:10];
            BOOL need2Update = [dbresult boolForColumnIndex:11];
            NSString *daySegments = [dbresult stringForColumnIndex:12];
            
            //判断是否在展示时间内,不是的话就要
            BOOL show = NO;
            
            //时间段控制为空或不含有横杠字符,默认判断为显示
            NSRange range = [daySegments rangeOfString:@"-"];
            if ([NgnStringUtils isNullOrEmpty:daySegments] || range.location == NSNotFound)
            {
                show = YES;
            }
            else
            {
                //含有,号分隔符则分隔逐条对比
                NSRange flagRange = [daySegments rangeOfString:@","];
                if(flagRange.location != NSNotFound)
                {
                    NSArray *timesArray = [daySegments componentsSeparatedByString:@","];
                    
                    for (NSString *time in timesArray)
                    {
                        show = [self compareCurrTime:currTime toDisplayTime:time];
                        
                        if (show)
                            break;
                    }
                }
                else
                {
                    show = [self compareCurrTime:currTime toDisplayTime:daySegments];
                }
            }
            
            if (show)
            {
                CCAdsData *adsData= [[CCAdsData alloc] initWithAdID:adid andEndtime:endtime andUpdateTime:updatetime andType:type andMyindex:myindex andImage:image andRing:ring andVideo:video andAdtext:adtext andClickAction:clickaction andClickUrl:clickurl andNeed2Update:need2Update andDaySegments:daySegments];
                [adsArray addObject:adsData];
                [adsData release];
            }
        }
        
    }
    [currTime release];
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	删除广告
 *
 *	@param 	adid 	广告id
 */
- (BOOL)dbDeleteAnAdData:(int)adid
{
    BOOL success = NO;
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = %d", kADsInfoTable, kADsInfoColId, adid];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    success = [db executeUpdate:sql];
    
    if (!success || [db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
    
    return success;
}

/**
 *	@brief	更新更新标志
 */
- (void)dbUpdateADsUpdateStateByAdid:(int)adid
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"update %@ set %@ = 0 where %@ = %d", kADsInfoTable, kADsInfoColNeedUpdate, kADsInfoColId, adid];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    [db executeUpdate:sql];
    [sql release];
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

#pragma mark
#pragma mark AdStatisticsDBManager
/**
 *	@brief	读取广告统计表所有信息
 *
 *	@param 	adStatisticsArray 	传出参数 结果集
 */
- (void)dbLoadAdStatisticsData:(NSMutableArray *)adStatisticsArray andTimeByHour:(NSString *)timeByHour
{
    [adStatisticsArray removeAllObjects];
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = 0 and %@ = '%@' and (%@ <> 0 or %@ <> 0)",kADStatisticsTable, kADStatisticsColIsSubmit, kADStatisticsColTimeByHour, timeByHour, kADStatisticsColShow, kADStatisticsColClick];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    FMResultSet *dbresult = [db executeQuery:sql];
    
    while([dbresult next])
    {
        @autoreleasepool {
            int id_ = [dbresult intForColumnIndex:0];
            int adid = [dbresult intForColumnIndex:1];
            int show = [dbresult intForColumnIndex:2];
            int click = [dbresult intForColumnIndex:3];
            int issubmit = [dbresult intForColumnIndex:4];
            NSString *timebyhour = [dbresult stringForColumnIndex:5];
            
            CCAdStatisticsData *adStatisticsData= [[CCAdStatisticsData alloc] initWithid:id_ andAdID:adid andShow:show andClick:click andIsSubmit:issubmit andTime:timebyhour];
            
            [adStatisticsArray addObject:adStatisticsData];
            [adStatisticsData release];
        }
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	读取所有统计时间列表(唯一)
 *
 *	@param 	adStatisticsArray 	传出参数 结果集
 */
- (void)dbLoadAdStatisticsDataByDistinctTime:(NSMutableArray *)timeByHourArray
{
    [timeByHourArray removeAllObjects];
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"select distinct(%@) from %@ where %@ = 0 and (%@ <> 0 or %@ <> 0)", kADStatisticsColTimeByHour, kADStatisticsTable, kADStatisticsColIsSubmit, kADStatisticsColShow, kADStatisticsColClick];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    FMResultSet *dbresult = [db executeQuery:sql];
    
    while([dbresult next])
    {
        NSString *timebyhour = [dbresult stringForColumnIndex:0];
        
        //规范时间类似2013-10-16 14:00:00的长度是19
        if ([timebyhour hasPrefix:@"20"] && timebyhour.length == 19)
            [timeByHourArray addObject:timebyhour];
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	读取广告统计表所有信息
 *
 *	@param 	adStatisticsArray 	传出参数 结果集
 */
- (void)dbLoadAdStatisticsData:(CCAdStatisticsData *)adStatisticsData byAdid:(int)_adid
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = 0 and %@ = %d limit 1",kADStatisticsTable, kADStatisticsColIsSubmit, kADStatisticsColADId, _adid];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    FMResultSet *dbresult = [db executeQuery:sql];
    
    if([dbresult next])
    {
        int id_ = [dbresult intForColumnIndex:0];
        int adid = [dbresult intForColumnIndex:1];
        int show = [dbresult intForColumnIndex:2];
        int click = [dbresult intForColumnIndex:3];
        int issubmit = [dbresult intForColumnIndex:4];
        NSString *timebyhour = [dbresult stringForColumnIndex:5];
        
        adStatisticsData = [[[CCAdStatisticsData alloc] initWithid:id_ andAdID:adid andShow:show andClick:click andIsSubmit:issubmit andTime:timebyhour] autorelease];
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	读取广告统计表所有信息
 *
 *	@param 	_adid 	广告ID
 */
- (int)dbCountAdStatisticsDataByAdid:(int)_adid andTimeByHour:(NSString *)timeByHour
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = %d and %@ = '%@'",kADStatisticsTable, kADStatisticsColADId, _adid, kADStatisticsColTimeByHour, timeByHour];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    FMResultSet *dbresult = [db executeQuery:sql];
    
    int countOfAdid = 0;
    if([dbresult next])
    {
        countOfAdid = [dbresult intForColumnIndex:0];
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
    
    return  countOfAdid;
}

/**
 *	@brief	读取广告统计表所有信息
 */
- (void)dbCountAdStatisticsShowandClick
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT sum(%@) as totalshow,sum(%@) as totalclick FROM %@ where issubmit = 0",kADStatisticsColShow, kADStatisticsColClick, kADStatisticsTable];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    FMResultSet *dbresult = [db executeQuery:sql];
    
    if([dbresult next])
    {
        totalShow = [dbresult intForColumnIndex:0];
        totalClick = [dbresult intForColumnIndex:1];
    }
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	增加广告统计记录
 *
 *	@param 	addArray 	优惠券
 */
- (void)dbAddAdStatisticsData:(CCAdStatisticsData *)adStatisticsData
{
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    //add
    if(adStatisticsData)
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"insert into %@(%@,%@,%@,%@,%@) values(%d,%d,%d,%d,'%@')",kADStatisticsTable, kADStatisticsColADId, kADStatisticsColShow, kADStatisticsColClick, kADStatisticsColIsSubmit, kADStatisticsColTimeByHour, adStatisticsData.adid, adStatisticsData.show, adStatisticsData.click, adStatisticsData.issubmit, adStatisticsData.timebyhour];
        
//        CCLog(@"--- sql: %@ ---",sql);
        
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
 *	@brief	更新广告统计记录,增加展示/点击次数
 *
 *	@param 	column 	字段名
 *  @param  value   值
 */
- (void)dbUpdateADStatisticsData:(NSString *)column andValue:(int)value andAdid:(int)adid andTimeByHour:(NSString *)timeByHour
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"update %@ set %@ = %@ + %d where %@ = %d and %@ = '%@'", kADStatisticsTable, column, column, value, kADStatisticsColADId, adid, kADStatisticsColTimeByHour, timeByHour];
    
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
 *	@brief	更新广告统计记录,将次数与是否提交重置
 *
 *	@param 	column 	字段名
 *  @param  value   值
 */
- (void)dbUpdateADStatisticsDataAfterSubmitSuccess:(NSMutableArray *)updateArray
{
    if (!updateArray || [updateArray count] == 0) return;
    
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    for (CCAdStatisticsData *adStatData in updateArray)
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"update %@ set %@ = %@ - %d, %@ = %@ - %d,%@ = 0 where %@ = %d and %@ = '%@'", kADStatisticsTable, kADStatisticsColShow, kADStatisticsColShow, adStatData.show, kADStatisticsColClick, kADStatisticsColClick, adStatData.click, kADStatisticsColIsSubmit, kADStatisticsColADId, adStatData.adid, kADStatisticsColTimeByHour, adStatData.timebyhour];
        
        [db executeUpdate:sql];
        [sql release];
    }
    
    //允许用户提交
    notAllowToSubmitAdStat = NO;
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

/**
 *	@brief	重置提交状态
 */
- (void)dbUpdateADStatisticsDataStateSubmiting:(ADStatisticsSubmitState)submitState
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"update %@ set %@ = %d where %@ <> 0 or %@ <> 0", kADStatisticsTable, kADStatisticsColIsSubmit, submitState , kADStatisticsColShow, kADStatisticsColClick];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    [db executeUpdate:sql];
    [sql release];
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
    
    notAllowToSubmitAdStat = NO;
}

/**
 *	@brief	重置提交状态
 */
- (void)dbUpdateADStatisticsDataStateSubmitFail:(ADStatisticsSubmitState)submitState
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"update %@ set %@ = %d", kADStatisticsTable, kADStatisticsColIsSubmit, submitState];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    [db executeUpdate:sql];
    [sql release];
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
    
    notAllowToSubmitAdStat = NO;
}

/**
 *	@brief	删除所有show和click为0且提交状态为未提交的记录
 */
- (void)dbDeleteADStatisticsDataNoNeed
{
    FMDatabase *db = [self getManageDB];
    if (![db open]) {
        CCLog(@"Open database failed");
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"delete from %@ where %@ = 0 and %@ = 0 and %@ = 0",kADStatisticsTable, kADStatisticsColShow, kADStatisticsColClick, kADStatisticsColIsSubmit];
    
    //CCLog(@"--- sql: %@ ---",sql);
    
    [db executeUpdate:sql];
    [sql release];
    
    if ([db hadError])
    {
        CCLog(@"Failed! Reason:%@",db.lastErrorMessage);
    }
    
    [db close];
}

#pragma mark
#pragma mark Private Method
/**
 *	@brief	展示或点击时更新数据,展示次数>=100 或者 点击次数>=5 时提交
 *
 *	@param 	adid 	广告ID
 *	@param 	type 	类型: 展示 / 点击
 */
- (void)updateData:(int)adid andType:(ADStatisticsUpdateType)type

{
    NSString *timeByHour = [[NSString alloc] initWithString:[self getTimeByhour]];
    if (type == ADStatisticsUpdateTypeShow)
    {
        int countOfAdid = [self dbCountAdStatisticsDataByAdid:adid andTimeByHour:timeByHour];
        if (countOfAdid)
            [self dbUpdateADStatisticsData:kADStatisticsColShow andValue:1 andAdid:adid andTimeByHour:timeByHour];
        else
        {
            CCAdStatisticsData *adStatistics = [[CCAdStatisticsData alloc] initWithid:1 andAdID:adid andShow:1 andClick:0 andIsSubmit:0 andTime:timeByHour];
            [self dbAddAdStatisticsData:adStatistics];
            [adStatistics release];
        }
    }
    else if(type == ADStatisticsUpdateTypeClick)
    {
        [self dbUpdateADStatisticsData:kADStatisticsColClick andValue:1 andAdid:adid andTimeByHour:timeByHour];
    }
    
    //获取展示次数和点击次数
    totalShow = 0;
    totalClick = 0;
    [self dbCountAdStatisticsShowandClick];
    
    if (totalShow >= kTotalShowToSubmit || totalClick >= kTotalClickToSubmit)
    {
        //提交统计结果
        [self submitADStatisticsData];
    }
    
    [timeByHour release];
}

/**
 *	@brief	提交统计结果
 */
- (void)submitADStatisticsData
{
    if (notAllowToSubmitAdStat) return;
    
    //获取未提交数据的时间(唯一)
    NSMutableArray *timeByHourArray = [NSMutableArray arrayWithCapacity:10];
    [self dbLoadAdStatisticsDataByDistinctTime:timeByHourArray];
    
    if (!timeByHourArray || [timeByHourArray count] == 0) return;
    
    [submittingArray removeAllObjects];
    
    //根据时间获取广告的点击量与展示量
    NSMutableArray *records = [NSMutableArray arrayWithCapacity:10];
    for (NSString *timeByHour in timeByHourArray)
    {
        NSMutableArray *unSubmitArray = [NSMutableArray arrayWithCapacity:20];
        [self dbLoadAdStatisticsData:unSubmitArray andTimeByHour:timeByHour];
        
        if (!unSubmitArray || [unSubmitArray count] == 0) continue;
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:10];
        for (CCAdStatisticsData *adStatData in unSubmitArray)
        {
            NSNumber *adid = [NSNumber numberWithInt:adStatData.adid];
            NSNumber *show = [NSNumber numberWithInt:adStatData.show];
            NSNumber *click = [NSNumber numberWithInt:adStatData.click];
            
            NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:adid, @"id", show, @"show", click, @"click", nil];
            [items addObject:aItem];
            
            //记录上传的数据,成功后将这些数据减去
            [submittingArray addObject:adStatData];
        }
        
        NSDictionary *aRecord = [NSDictionary dictionaryWithObjectsAndKeys:timeByHour, @"timebyhour", items, @"items", nil];
        
        [records addObject:aRecord];
    }
    
    if (!records || [records count] == 0) return;
    
    //转换为json数据
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:records, @"records", nil];
    NSData *jsonData = [jsonDict JSONData];
    CCLog(@"------submitADStatisticsData------ : %@",[jsonDict JSONString]);
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setValue:@"sendStat" forKey:@"reqType"];
    //提交到服务器
    [self sendAdsRequest:jsonData andUserInfo:userInfo];
}

- (NSString *)getTimeByhour
{
    //与服务器时间对比差值
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSTimeInterval interval = [userDefault doubleForKey:GENERAL_TimeIntervalWithServ];//60 * 60 * 0;
    
    //计算服务器时间
    NSDate *serverDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    
    //格式化
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:00:00"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *strServerDate = [dateFormatter stringFromDate:serverDate];
    [dateFormatter release];
//    CCLog(@"------getTimeByhour------ : %@",strServerDate);
    
    return strServerDate;
}

- (NSString *)getTimeByServStandard
{
    //与服务器时间对比差值
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSTimeInterval interval = [userDefault doubleForKey:GENERAL_TimeIntervalWithServ];
    
    //计算服务器时间
    NSDate *serverDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    
    //格式化
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *strServerHour = [dateFormatter stringFromDate:serverDate];
    [dateFormatter release];
//    CCLog(@"------getHourByServStandard------ : %@",strServerDate);
    
    return strServerHour;
}

/**
 *	@brief	下载广告资源
 *
 *	@param 	updateAdsArray 	需要更新的列表
 */
- (void)getAdsResourceFromNet:(NSMutableArray *)updateAdsArray andUpdate:(BOOL)_update
{
    if (!updateAdsArray || [updateAdsArray count] == 0) return;
    
    for (CCAdsData *ccAdsData in updateAdsArray)
    {
        //ADSMyindexBanner = 0,   //0：首页banner；
        //ADSMyindexAlertView,    //1：音质反馈；
        //ADSMyindexSlotMachine,  //2：老虎机图片
        //ADSMyindexSignin,       //3：签到；
        //ADSMyindexScreen,       //4：大屏广告
        switch (ccAdsData.myindex)
        {
            case ADSMyindexBanner:
            {
                NSString *adsDir = [self getCTBannerAdsDirectoryPath];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *fileName = [ccAdsData.image lastPathComponent];
                NSString *filePath = [adsDir stringByAppendingPathComponent:fileName];
                
                BOOL fileExist = [fileManager fileExistsAtPath:filePath];
                //需要更新且文件已存在,删除
                if (fileExist && _update)
                    [fileManager removeItemAtPath:filePath error:nil];
                
                //需要更新或不需要更新但文件不存在,下载文件
                if (_update || (!fileExist && !_update)) {
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ccAdsData.image]];
                    if (imageData)
                        [self writeData2File:imageData toFileAtPath:filePath];
                    else
                        CCLog(@"ADSMyindexBanner get image failed adid : %d imageurl : %@", ccAdsData.adid, ccAdsData.image);
                }
                
                break;
            }
            case ADSMyindexAlertView:
            {
                NSString *adsDir = [self getCallFeedBackDirectoryPath];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *fileName = [ccAdsData.image lastPathComponent];
                NSString *filePath = [adsDir stringByAppendingPathComponent:fileName];
                
                BOOL fileExist = [fileManager fileExistsAtPath:filePath];
                //需要更新且文件已存在,删除
                if (fileExist && _update)
                    [fileManager removeItemAtPath:filePath error:nil];
                
                //需要更新或不需要更新但文件不存在,下载文件
                if (_update || (!fileExist && !_update)) {
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ccAdsData.image]];
                    if (imageData)
                        [self writeData2File:imageData toFileAtPath:filePath];
                    else
                        CCLog(@"ADSMyindexBanner get image failed adid : %d imageurl : %@", ccAdsData.adid, ccAdsData.image);
                }
                
                break;
            }
            case ADSMyindexSlotMachine:
            {
                NSString *adsDir = [self getSlotMachineImgDirectoryPath];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *fileName = [ccAdsData.image lastPathComponent];
                NSString *filePath = [adsDir stringByAppendingPathComponent:fileName];
                
                BOOL fileExist = [fileManager fileExistsAtPath:filePath];
                //需要更新且文件已存在,删除
                if (fileExist && _update)
                    [fileManager removeItemAtPath:filePath error:nil];
                
                //需要更新或不需要更新但文件不存在,下载文件
                if (_update || (!fileExist && !_update)) {
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ccAdsData.image]];
                    if (imageData)
                        [self writeData2File:imageData toFileAtPath:filePath];
                    else
                        CCLog(@"ADSMyindexSlotMachine get image failed adid : %d imageurl : %@", ccAdsData.adid, ccAdsData.image);
                }
                
                break;
            }
            case ADSMyindexSignin:  //3.签到广告 含图片跟声音
            {
                NSString *signinDir = [self getSigninAdsDirectoryPath];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                //图片
                if (ccAdsData.image && [ccAdsData.image length])
                {
                    NSString *imageFileName = [ccAdsData.image lastPathComponent];
                    NSString *imageFilePath = [signinDir stringByAppendingPathComponent:imageFileName];
                    
                    BOOL fileExist = [fileManager fileExistsAtPath:imageFilePath];
                    //需要更新且文件已存在,删除
                    if (fileExist && _update)
                        [fileManager removeItemAtPath:imageFilePath error:nil];
                    
                    //需要更新或不需要更新但是文件不存在,下载文件
                    if (_update || (!fileExist && !_update)) {
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ccAdsData.image]];
                        if (imageData)
                            [self writeData2File:imageData toFileAtPath:imageFilePath];
                        else
                            CCLog(@"ADSMyindexSignin get image failed adid : %d imageurl : %@", ccAdsData.adid, ccAdsData.image);
                    }
                }
                if (ccAdsData.ring && [ccAdsData.ring length])
                {
                    NSString *ringFileName = [ccAdsData.ring lastPathComponent];
                    NSString *ringFilePath = [signinDir stringByAppendingPathComponent:ringFileName];
                    
                    BOOL fileExist = [fileManager fileExistsAtPath:ringFilePath];
                    //需要更新且文件已存在,删除
                    if (fileExist && _update)
                        [fileManager removeItemAtPath:ringFilePath error:nil];
                    
                    //需要更新或不需要更新但是文件不存在,下载文件
                    if (_update || (!fileExist && !_update)) {
                        NSData *ringData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ccAdsData.ring]];
                        if (ringData)
                            [self writeData2File:ringData toFileAtPath:ringFilePath];
                        else
                            CCLog(@"ADSMyindexSignin get ring failed adid : %d imageurl : %@", ccAdsData.adid, ccAdsData.ring);
                    }
                }
                break;
            }
            case ADSMyindexScreen:  // 4.大屏广告/1.音质反馈 广告是用同一组广告资源
            {
                NSString *adsDir = [self getIncallAdsDirectoryPath];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *fileName = [ccAdsData.image lastPathComponent];
                NSString *filePath = [adsDir stringByAppendingPathComponent:fileName];
                
                BOOL fileExist = [fileManager fileExistsAtPath:filePath];
                //需要更新且文件已存在,删除
                if (fileExist && _update)
                    [fileManager removeItemAtPath:filePath error:nil];
                
                //需要更新或不需要更新但文件不存在,下载文件
                if (_update || (!fileExist && !_update)) {
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ccAdsData.image]];
                    if (imageData)
                        [self writeData2File:imageData toFileAtPath:filePath];
                    else
                        CCLog(@"ADSMyindexScreen get image failed adid : %d imageurl : %@", ccAdsData.adid, ccAdsData.image);
                }
                
                break;
            }
            default:
                break;
        }
        
        if (_update)
            [self dbUpdateADsUpdateStateByAdid:ccAdsData.adid];
    }
}

/**
 *	@brief	音质反馈广告图片存放
 */
- (NSString *)getCallFeedBackDirectoryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    return [dir stringByAppendingPathComponent:@"CallFeedBack"];
}


/**
 *	@brief	大屏广告图片存放
 */
- (NSString *)getIncallAdsDirectoryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    return [dir stringByAppendingPathComponent:@"Ads"];
}

/**
 */
- (NSString*)getSlotMachineImgDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    return [dir stringByAppendingPathComponent:@"SlotMachine"];
}

/**
 *	@brief	签到广告存放
 */
- (NSString*)getSigninAdsDirectoryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];

    return [dir stringByAppendingPathComponent:@"SigninAds"];
}

/**
 *	@brief	banner广告存放文件夹
 */
- (NSString *)getCTBannerAdsDirectoryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    
    return [dir stringByAppendingPathComponent:@"CTBannerAds"];
}

/**
 *	@brief	将现在时间与服务器时间对比,判断是否展示广告
 *
 *	@param 	currTime 	现在时间,以服务器时间为准(已加上与服务器的时间差)
 *	@param 	displayTime 	服务器获取的广告展示时间段
 *
 *	@return	返回对比结果
 */
- (BOOL)compareCurrTime:(NSString *)currTime toDisplayTime:(NSString *)displayTime
{
    //displayTime 格式 16:00
    NSArray *timeArray = [displayTime componentsSeparatedByString:@"-"];
    NSString *startTime = [timeArray objectAtIndex:0];
    NSString *endTime = [timeArray objectAtIndex:1];
    
    //现在时间等于开始时间 或者  现在时间大于开始时间小于结束时间
    if (NSOrderedSame == [currTime compare:startTime] || (NSOrderedAscending == [startTime compare:currTime] && NSOrderedAscending == [currTime compare:endTime]))
    {
        return YES;
    }
    return NO;
}

- (void)OpenWebBrowser:(NSString *)url andNavigationController:(UINavigationController *)_navigationController
{
    WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
    webBrowser.mode = TSMiniWebBrowserModeNavigation;
    
    webBrowser.barStyle = UIStatusBarStyleDefault;
    webBrowser.hidesBottomBarWhenPushed = YES;
    [_navigationController pushViewController:webBrowser animated:YES];
    
    [webBrowser release];
}

@end
