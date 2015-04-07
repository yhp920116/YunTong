
/* Vincent, GZ, 2012-03-07 */

#import "NgnStorageService.h"
#import "NgnStringUtils.h"
#import "NgnFavoriteEventArgs.h"
#import "NgnNotificationCenter.h"
#import "NgnConferenceFavorite.h"
#import "NgnCallFeedBackData.h"

#undef TAG
#define kTAG @"NgnStorageService///: "
#define TAG kTAG

#undef kDataBaseName
#define kDataBaseName @"DataBase.db"

// 'kDataBaseVersion' defines the current version of the database on the source code (objective-c) view.
// The database itself contains this reference. Each time the storage service is loaded we check that these
// two values are identical. If these two values are different then, we delete the data base stored in the device
// and replace it with the new one.
// You should increment this value if you change the database version and don't forget to do the same in the .sql file.
// If you are not using WeiCall test project then, please provide your own version id by subclassing '-databaseVersion'
#define kDataBaseVersion 0

#define kFavoritesTableName @"favorites"
#define kFavoritesColIdName @"id"
#define kFavoritesColMediaTypeName @"mediaType"
#define kFavoritesColNumberName @"number"

@interface NgnStorageService (DataBase)
+(BOOL) hasColumnWithName:(sqlite3 *)db andTableName:(NSString *)tableName andColumnName:(NSString *)columnName;
+(BOOL) hasTableWithName:(sqlite3 *)db andTableName:(NSString *)tableName;
+(BOOL) databaseCheckAndCopy:(NgnBaseService<INgnStorageService>*) service;
+(int) databaseVersion: (sqlite3 *)db;
-(BOOL) databaseOpen;
-(BOOL) databaseLoadData;
-(BOOL) databaseExecSQL: (NSString*)sqlQuery;
-(BOOL) databaseClose;
@end

@implementation NgnStorageService (DataBase)

static NSString* sDataBasePath = nil;
static BOOL sDataBaseInitialized = NO;


+(BOOL) hasTableWithName:(sqlite3 *)db andTableName:(NSString *)tableName {
    NSString * sqlStatement = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@';", tableName];
    sqlite3_stmt *statementChk;
    int r = sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlStatement], -1, &statementChk, nil);
    BOOL exist = NO;
    if (sqlite3_step(statementChk) == SQLITE_ROW)
    {
        exist = YES;
    }
    sqlite3_finalize(statementChk);
    return exist;
}

/**
 *	@brief	判断表中是否存在某个字段
 *
 *	@param 	db 	数据库
 *	@param 	tableName 	表名
 *	@param 	columnName 	列名
 *
 *	@return	是否存在
 */
+(BOOL) hasColumnWithName:(sqlite3 *)db andTableName:(NSString *)tableName andColumnName:(NSString *)columnName
{
    NSString * sqlStatement = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@' AND sql like '%%%@%%';", tableName, columnName];
    sqlite3_stmt *statementChk;
    int r = sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlStatement], -1, &statementChk, nil);
    BOOL exist = NO;
    if (sqlite3_step(statementChk) == SQLITE_ROW)
    {
        exist = YES;
    }
    sqlite3_finalize(statementChk);
    return exist;
}

+(BOOL) databaseCheckAndCopy:(NgnBaseService<INgnStorageService>*) service{
	if(sDataBaseInitialized){
		return YES;
	}
// For backward compatibility, we have to continue to use diff folders
#if TARGET_OS_IPHONE
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
#elif TARGET_OS_MAC
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"cc"];
#endif
	sDataBasePath = [documentsDir stringByAppendingPathComponent:kDataBaseName];

	sqlite3 *db = nil;
	NSError* error = nil;
	
	NgnNSLog(TAG, @"databasePath:%@", sDataBasePath);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
	// create the folder if it doesn't exist
	BOOL isDirectory = NO;
	BOOL exists = [fileManager fileExistsAtPath:documentsDir isDirectory:&isDirectory];
	if(!exists){
		BOOL created = [fileManager createDirectoryAtPath:documentsDir withIntermediateDirectories:YES attributes:nil error:&error];
		if(!created){
			NgnNSLog(TAG, @"Failed to create folder (%@) to the file system: %@", documentsDir, error);
            [fileManager release];
			return NO;
		}
	}
#endif	
	
	//
	// if we are here this means that the database has been upgraded/downgraded or this is a new installation
	//
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDataBaseName];
	NgnNSLog(TAG, @"creating (copy) new database from:%@", databasePathFromApp);
	
	if(![fileManager copyItemAtPath:databasePathFromApp toPath:sDataBasePath error:&error]){
//		[fileManager release];
		NgnNSLog(TAG, @"Failed to copy database to the file system: %@", error);
//		return NO;
	}
	
    if([fileManager fileExistsAtPath: sDataBasePath]){
		// query for the database version
		
		if(sqlite3_open([sDataBasePath UTF8String], &db) != SQLITE_OK){
			NgnNSLog(TAG,@"Failed to open database from: %@", sDataBasePath);
			return NO;
		}
        
        [NgnStorageService createIAPRecordsTable:db];
        
        [NgnStorageService createConfFavoritesNameTable:db];
        [NgnStorageService createConfFavoritesNumberTable:db];
        
        //code by Sergio
        //生成通话质量反馈表,用于无法与服务器通讯时将反馈信息保存在数据库,等待重新提交
        [NgnStorageService createCallFeedBackTable:db];
        
        //生成优惠券信息表
        [NgnStorageService createCouponInfoTable:db];
        
        //判断通话记录表是否存在callmode这个字段
        [NgnStorageService existCallModeOnTableHist_Event:db];
        
		int storedVersion = [NgnStorageService databaseVersion:db];
		int sourceCodeVersion = [service databaseVersion];
		sqlite3_close(db), db = nil;
		if(storedVersion != sourceCodeVersion){
			NgnNSLog(TAG,@"database changed v-stored=%i and database v-code=%i", storedVersion, sourceCodeVersion);
			// remove the file (database already closed)
			[fileManager removeItemAtPath:sDataBasePath error:nil];
		}
		else {
			NgnNSLog(TAG,@"No changes: database v-current=%i", storedVersion);
			sDataBaseInitialized = YES;
			// database already closed
			return YES;
		}
	}

	sDataBaseInitialized = YES;
	return YES;
}

+(int) databaseVersion: (sqlite3 *)db {
    static sqlite3_stmt *compiledStatement = nil;
    int databaseVersion = -1;
	
    if(sqlite3_prepare_v2(db, "PRAGMA user_version;", -1, &compiledStatement, NULL) == SQLITE_OK) {
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            databaseVersion = sqlite3_column_int(compiledStatement, 0);
            NgnNSLog(TAG,@"found databaseVersion=%d", databaseVersion);
        }
        NgnNSLog(TAG,@"used databaseVersion=%d", databaseVersion);
    } else {
        NgnNSLog(TAG,@"Failed to get databaseVersion %s", sqlite3_errmsg(db) );
    }
    sqlite3_finalize(compiledStatement);
	
    return databaseVersion;
}

-(BOOL) databaseOpen{
	if(!self->database && sqlite3_open([sDataBasePath UTF8String], &self->database) != SQLITE_OK){
		NgnNSLog(TAG,@"Failed to open database from: %@", sDataBasePath);
		return NO;
	}
	return YES;
}

-(BOOL) databaseLoadData{
	BOOL ok = YES;
	int ret;
	sqlite3_stmt *compiledStatement = nil;
	NSString* sqlQueryFavorites = [@"select " stringByAppendingFormat:@"%@,%@,%@ from %@", 
								   kFavoritesColIdName, kFavoritesColNumberName, kFavoritesColMediaTypeName, kFavoritesTableName];
	
	/* === Load favorites === */
	[self->favorites removeAllObjects];
	if((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryFavorites], -1, &compiledStatement, NULL)) == SQLITE_OK) {
		long long id_;
		NSString* number;
		NgnMediaType_t mediaType;
		while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
			id_ = sqlite3_column_int(compiledStatement, 0);
			number = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 1)];
			mediaType = (NgnMediaType_t)sqlite3_column_int(compiledStatement, 2);
			NgnFavorite* favorite = [[NgnFavorite alloc] initWithId:id_ 
														  andNumber:number
													   andMediaType:mediaType];
			if(favorite){
				[self->favorites setObject:favorite forKey:[NSNumber numberWithLongLong: favorite.myid]];
				[favorite release];
			}
		}
	}
	sqlite3_finalize(compiledStatement), compiledStatement = nil;
	
	return ok;
}

-(BOOL) databaseClose{
	@synchronized(self){
		if(self->database){
			sqlite3_close(self->database);
			self->database = nil;
		}
	}
	return YES;
}


-(BOOL) databaseExecSQL: (NSString*)sqlQuery{
	BOOL ok = YES;
	@synchronized(self){
		int ret;
		sqlite3_stmt *compiledStatement;
		
		if(!self->database){
			NgnNSLog(TAG, @"Invalid database");
			ok = NO;
			goto done;
		}
		
		if((ret = sqlite3_prepare_v2(self->database, [sqlQuery UTF8String], -1, &compiledStatement, NULL)) == SQLITE_OK) {
			ok = (SQLITE_DONE == sqlite3_step(compiledStatement));
		}
		else {
			NgnNSLog(TAG, @"error: %s", sqlite3_errmsg(self->database));
			ok = NO;
		}
		
		sqlite3_finalize(compiledStatement);
	}
done:
	return ok;
}

@end


@implementation NgnStorageService

-(NgnStorageService*) init{
	if((self = [super init])){
		self-> favorites = [[NSMutableDictionary alloc] init]; 
	}
	return self;
}

-(void) dealloc{
	[self->favorites release];
	
	[super dealloc];
}

// to be overrided: used by Telekom, Tiscali and Alcated-Lucent
-(BOOL) load{
	return [self databaseLoadData];
}

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	BOOL ok = YES;
	
	if([NgnStorageService databaseCheckAndCopy:self]){
		if((ok = [self databaseOpen])){
			ok &= [self load];
		}
	}
	return ok;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	BOOL ok = YES;
	
	ok = [self databaseClose];
	
	return ok;
}

//
// INgnStorageService
//

-(int) databaseVersion{
	return kDataBaseVersion;
}

-(sqlite3 *) database{
	return self->database;
}

-(BOOL) execSQL: (NSString*)sqlQuery{
	return [self databaseExecSQL: sqlQuery];
}	

-(NSDictionary*) favorites{
	return self->favorites;
}

-(NgnFavorite*) favoriteWithNumber:(NSString*)number andMediaType:(NgnMediaType_t)mediaType{
	for (NgnFavorite *favorite in [self->favorites allValues]) {
		if([favorite.number isEqualToString:number] && favorite.mediaType == mediaType){
			return favorite;
		}
	}
	return nil;
}

-(NgnFavorite*) favoriteWithNumber:(NSString*)number{
	for (NgnFavorite *favorite in [self->favorites allValues]) {
		if([favorite.number isEqualToString:number]){
			return favorite;
		}
	}
	return nil;
}

-(BOOL) addFavorite: (NgnFavorite*) favorite{
	if(favorite){
		NSString* sqlStatement = [[@"insert into " stringByAppendingFormat:@"%@ (%@,%@) values", kFavoritesTableName, kFavoritesColNumberName, kFavoritesColMediaTypeName]
								  stringByAppendingFormat:@"('%@',%d)", favorite.number, (int)favorite.mediaType
								  ];
        if([self databaseExecSQL:sqlStatement]){
			favorite.myid = (long long)sqlite3_last_insert_rowid(self->database);
			[self->favorites setObject:favorite forKey: [NSNumber numberWithLongLong: favorite.myid]];
			
			NgnFavoriteEventArgs *eargs = [[[NgnFavoriteEventArgs alloc] initWithFavoriteId:favorite.myid andEventType:FAVORITE_ITEM_ADDED andMediaType:favorite.mediaType] autorelease];
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnFavoriteEventArgs_Name object:eargs];
			
			return YES;
		}
	}
	return NO;
}

-(BOOL) deleteFavorite: (NgnFavorite*) favorite{
	if(favorite){
		NSString* sqlStatement = [[@"delete from " stringByAppendingFormat:@"%@", kFavoritesTableName]
								  stringByAppendingFormat:@" where %@=%lld", kFavoritesColIdName, favorite.myid];
		if([self databaseExecSQL:sqlStatement]){
			[self->favorites removeObjectForKey:[NSNumber numberWithLongLong:favorite.myid]];
			
			NgnFavoriteEventArgs *eargs = [[[NgnFavoriteEventArgs alloc] initWithFavoriteId:favorite.myid andEventType:FAVORITE_ITEM_REMOVED andMediaType:favorite.mediaType] autorelease];
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnFavoriteEventArgs_Name object:eargs];
			
			return YES;
		}
	}
	return NO;
}

-(BOOL) deleteFavoriteWithId: (long long) id_{
	NgnFavorite* favorite = [self->favorites objectForKey:[NSNumber numberWithLongLong:id_]];
	return [self deleteFavorite:favorite];
}

-(BOOL) clearFavorites{
	NSString* sqlStatement = [@"delete from " stringByAppendingFormat:@"%@", kFavoritesTableName];
	if([self databaseExecSQL:sqlStatement]){
		[self->favorites removeAllObjects];
		
		NgnFavoriteEventArgs *eargs = [[[NgnFavoriteEventArgs alloc] initWithType:FAVORITE_RESET andMediaType: MediaType_All] autorelease];
		[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnFavoriteEventArgs_Name object:eargs];
		
		return YES;
	}
	return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// system_notification

#define kSysNotifyTable               @"system_notification"
#define kSysNotifyTableColId          @"id"
#define kSysNotifyTableColMyNumber    @"mynumber"
#define kSysNotifyTableColContent     @"content"
#define kSysNotifyTableColReceiveTime @"receivetime"
#define kSysNotifyTableColRead        @"read"

-(BOOL) dbLoadSystemNofitication:(NSMutableArray*)sysnotification andMyNumber:(NSString*)mynum {
    if (!mynum)
        return NO;
    
    BOOL ok = YES;
	int ret;
    
    sqlite3_stmt *compiledStatement = nil;
    NSString* sqlQueryString = [[@"select " stringByAppendingFormat:@"%@,%@,%@,%@ from %@", kSysNotifyTableColId, kSysNotifyTableColContent, kSysNotifyTableColReceiveTime, kSysNotifyTableColRead, kSysNotifyTable] stringByAppendingFormat:@" where %@='%@' order by %@ desc", kSysNotifyTableColMyNumber, mynum, kSysNotifyTableColReceiveTime];

    /* === Load sys notification === */
    [sysnotification removeAllObjects];
    if((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryString], -1, &compiledStatement, NULL)) == SQLITE_OK) {
        long long id_;
        NSString* content;
        double receivetime = 0;
        BOOL read;
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            id_ = sqlite3_column_int(compiledStatement, 0);
            content = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 1)];
            receivetime = sqlite3_column_double(compiledStatement, 2);
            read = sqlite3_column_int(compiledStatement, 3);
            
            NgnSystemNotification* sysnotify = [[NgnSystemNotification alloc] initWithId:id_ andMyNumber:mynum andContent:content andReceiveTime:receivetime andRead:read];            
            [sysnotification addObject:sysnotify];
            [sysnotify release];
        }
    }
    sqlite3_finalize(compiledStatement), compiledStatement = nil;    
    
	return ok;
}

-(unsigned int) getUnreadSystemNotificationNum:(NSString*)mynum {
    if (!mynum)
        return 0;
    
    BOOL ok = YES;
	int ret;
    unsigned int num = 0;    
    sqlite3_stmt *compiledStatement = nil;
    NSString* sqlQueryString = [[@"select " stringByAppendingFormat:@"%@ from %@", kSysNotifyTableColId, kSysNotifyTable] stringByAppendingFormat:@" where %@=0 and %@='%@' order by %@ desc", kSysNotifyTableColRead, kSysNotifyTableColMyNumber, mynum, kSysNotifyTableColReceiveTime];
    if ((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryString], -1, &compiledStatement, NULL)) == SQLITE_OK) {
        while (sqlite3_step(compiledStatement) == SQLITE_ROW) {            
            num++;
        }
    }
    sqlite3_finalize(compiledStatement), compiledStatement = nil;    
    
	return num;
}

-(BOOL) addSystemNofitication:(NgnSystemNotification*)sysnotify { 
    if (!sysnotify)
        return NO;
    
    BOOL ok = NO;
    NSString* sqlStatement = [@"insert into " stringByAppendingFormat:@"%@ (%@,%@,%@,%@) values(?,?,?,?)", kSysNotifyTable, kSysNotifyTableColMyNumber, kSysNotifyTableColContent, kSysNotifyTableColReceiveTime, kSysNotifyTableColRead];
	sqlite3_stmt *compiledStatement;
	int ret;
    if ((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, NULL)) == SQLITE_OK) {
        sqlite3_bind_text(compiledStatement, 1, [NgnStringUtils toCString: sysnotify.mynumber], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 2, [NgnStringUtils toCString: sysnotify.content], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(compiledStatement, 3, sysnotify.receivetime);
        sqlite3_bind_int(compiledStatement, 4, sysnotify.read ? 1 : 0);
        
        ok = ((ret = sqlite3_step(compiledStatement)) == SQLITE_DONE);
    }
    sqlite3_finalize(compiledStatement);
        
    if(ok) {
        long long myid = (long long)sqlite3_last_insert_rowid(self->database);
    }

	return ok;
}

-(BOOL) updateSystemNofitication: (long long)_id andRead:(BOOL)read {
    BOOL ok = NO;
	int ret;

    sqlite3_stmt *quireState = nil;
    NSString* sqlUpdateStatement = [[@"update " stringByAppendingFormat:@"%@ set %@=?", kSysNotifyTable, kSysNotifyTableColRead]
                                        stringByAppendingFormat:@" where %@=?", kSysNotifyTableColId];        
    if((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlUpdateStatement], -1, &quireState, NULL)) == SQLITE_OK) {
        sqlite3_bind_int(quireState, 1, read ? 1 : 0);
        sqlite3_bind_int(quireState, 2, _id);
            
        ok = ((ret = sqlite3_step(quireState))==SQLITE_DONE);
    }
    sqlite3_finalize(quireState);
	
	return ok;
}

-(BOOL) deleteSystemNofitication:  (long long)_id {
	if (_id) {
        BOOL ret = NO;        
		NSString* sqlStatement = [[@"delete from " stringByAppendingFormat:@"%@", kSysNotifyTable]
                                  stringByAppendingFormat:@" where %@=%lld", kSysNotifyTableColId, _id];
		ret = [self databaseExecSQL:sqlStatement];
        return ret;
	}
	return NO;
}

-(BOOL) deleteSystemNofiticationIsNotMyNumber: (NSString*)mynum {
	if (mynum) {
        BOOL ret = NO;
		NSString* sqlStatement = [[@"delete from " stringByAppendingFormat:@"%@", kSysNotifyTable]
                                  stringByAppendingFormat:@" where %@<>%@", kSysNotifyTableColMyNumber, mynum];
		ret = [self databaseExecSQL:sqlStatement];
        return ret;
	}
	return NO;
}

-(BOOL) deleteSystemNofiticationWithMyNum: (NSString*)mynum {
	if (mynum) {
        BOOL ret = NO;
		NSString* sqlStatement = [[@"delete from " stringByAppendingFormat:@"%@", kSysNotifyTable]
                                  stringByAppendingFormat:@" where %@=%@", kSysNotifyTableColMyNumber, mynum];
		ret = [self databaseExecSQL:sqlStatement];
        return ret;
	}
	return NO;
}

-(BOOL) clearSystemNofitication {
    BOOL ret = NO;    
	NSString* sqlStatement = [@"delete from " stringByAppendingFormat:@"%@", kSysNotifyTable];
    ret = [self databaseExecSQL:sqlStatement];
    return ret;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define kIapRecordsTable                    @"iap_records"
#define kIapRecordsTableColId               @"id"
#define kIapRecordsTableColMyNumber         @"mynumber"
#define kIapRecordsTableColPurchasedId      @"purchasedid"
#define kIapRecordsTableColProductId        @"productid"
#define kIapRecordsTableColTime             @"time"
#define kIapRecordsTableColPurchasedReceipt @"purchasedreceipt"

+(BOOL) createIAPRecordsTable:(sqlite3 *)db {
    BOOL ok = NO;
    
    if ([NgnStorageService hasTableWithName:db andTableName:kIapRecordsTable]) {
        NSString* sqlStatement = [NSString stringWithFormat:@"select * from %@", kIapRecordsTable];
        sqlite3_stmt *compiledStatement = nil;
        int rc = sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, nil);
        if (compiledStatement) {
            sqlite3_finalize(compiledStatement), compiledStatement = nil;
        }        
        if (rc == SQLITE_OK) {            
            BOOL columnExists = NO;
            sqlite3_stmt *selectStmt;
            NSString* sqlQuire = [NSString stringWithFormat:@"select %@ from %@", kIapRecordsTableColPurchasedReceipt, kIapRecordsTable];
            if (sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlQuire], -1, &selectStmt, nil) == SQLITE_OK)
                columnExists = YES;
            
            if (NO == columnExists) {
                ok = NO;
                sqlite3_stmt *compiledStatement = nil;
                NSString* sqlQuireStatement = [NSString stringWithFormat:@"alter table %@ add column %@ text", kIapRecordsTable, kIapRecordsTableColPurchasedReceipt];
                int ret = sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlQuireStatement], -1, &compiledStatement, nil);
                if (sqlite3_step(compiledStatement)==SQLITE_DONE) {             
                    ok = YES;
                }
                sqlite3_finalize(compiledStatement), compiledStatement = nil;
                return ok;
            }
        }
        
        return YES;
    }
    
    ok = NO;
    NSString* sqlStatement = [NSString stringWithFormat:@"CREATE TABLE %@(%@ INTEGER PRIMARY KEY, %@ TEXT, %@ TEXT, %@ TEXT, %@ DOUBLE, %@ TEXT)", kIapRecordsTable, kIapRecordsTableColId,
                        kIapRecordsTableColMyNumber, kIapRecordsTableColPurchasedId, kIapRecordsTableColProductId, kIapRecordsTableColTime, kIapRecordsTableColPurchasedReceipt];
    sqlite3_stmt *compiledStatement = nil;
    sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, nil);
    if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
        ok = YES;
    }
    sqlite3_finalize(compiledStatement), compiledStatement = nil;
    
    return ok;
}

-(BOOL) dbLoadIAPRecords:(NSMutableArray*)iaprecords andMyNumber:(NSString*)mynum {
    if (!mynum)
        return NO;
    
    BOOL ok = YES;
	int ret;
    
    sqlite3_stmt *compiledStatement = nil;
    NSString* sqlQueryString = [[@"select " stringByAppendingFormat:@"%@,%@,%@,%@,%@ from %@", kIapRecordsTableColId, kIapRecordsTableColPurchasedId, kIapRecordsTableColProductId, kIapRecordsTableColTime, kIapRecordsTableColPurchasedReceipt, kIapRecordsTable] stringByAppendingFormat:@" where %@=%@", kIapRecordsTableColMyNumber, mynum];
    
    /* === Load iap records === */
    [iaprecords removeAllObjects];
    if ((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryString], -1, &compiledStatement, NULL)) == SQLITE_OK)
    {
        long long id_;
        NSString* purchasedid;
        NSString* productid;
        NSTimeInterval purchaseddate = 0;
        NSString* purchasedreceipt;
        while (sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            id_ = sqlite3_column_int(compiledStatement, 0);
            purchasedid = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 1)];
            productid = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 2)];
            purchaseddate = sqlite3_column_double(compiledStatement, 3);
            purchasedreceipt = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 4)];
            
            NgnLog(@"dbLoadIAPRecords: purchasedid=%@", purchasedid);
            
            NgnIAPRecord* record = [[NgnIAPRecord alloc] initWithId:id_ andMyNumber:mynum andPurchasedId:purchasedid andProductId:productid andPurchasedDate:purchaseddate andPurchasedReceipt:purchasedreceipt];
            [iaprecords addObject:record];
            [record release];
        }
    }
    sqlite3_finalize(compiledStatement), compiledStatement = nil;
    
	return ok;
}

-(BOOL) addIAPRecord:(NgnIAPRecord*)record {
    if (!record)
        return NO;

    int ret = 0;
    BOOL found = NO;
    sqlite3_stmt *compiledStatement = nil;
    
    NSString* sqlQueryString = [[@"select " stringByAppendingFormat:@"%@, %@ from %@", kIapRecordsTableColId, kIapRecordsTableColTime, kIapRecordsTable]
                                stringByAppendingFormat:@" where %@='%@' and %@='%@'", kIapRecordsTableColMyNumber, record.mynumber, kIapRecordsTableColPurchasedId, record.purchasedid];
    NgnLog(@"sqlQueryString=%@", sqlQueryString);
    if ((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryString], -1, &compiledStatement, NULL)) == SQLITE_OK) {
        while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            found = YES;
        }
    }
    sqlite3_finalize(compiledStatement), compiledStatement = nil;
    
    if (found)
        return YES;
    
    BOOL ok = NO;
    NSString* sqlStatement = [@"insert into " stringByAppendingFormat:@"%@ (%@,%@,%@,%@,%@) values(?,?,?,?,?)", kIapRecordsTable, kIapRecordsTableColMyNumber, kIapRecordsTableColPurchasedId, kIapRecordsTableColProductId, kIapRecordsTableColTime, kIapRecordsTableColPurchasedReceipt];
	ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, NULL);
    if (ret == SQLITE_OK) {
        sqlite3_bind_text(compiledStatement, 1, [NgnStringUtils toCString: record.mynumber], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 2, [NgnStringUtils toCString: record.purchasedid], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 3, [NgnStringUtils toCString: record.productid], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(compiledStatement, 4, record.purchaseddate);
        sqlite3_bind_text(compiledStatement, 5, [NgnStringUtils toCString: record.purchasedreceipt], -1, SQLITE_TRANSIENT);
        
        ok = ((ret = sqlite3_step(compiledStatement)) == SQLITE_DONE);
    }
    sqlite3_finalize(compiledStatement);
    
    if(ok) {
        long long myid = (long long)sqlite3_last_insert_rowid(self->database);
    }
    
	return ok;
}

-(BOOL) deleteIAPRecord: (NSString*) purchasedid {
	if (purchasedid) {
        BOOL ret = NO;
		NSString* sqlStatement = [[@"delete from " stringByAppendingFormat:@"%@", kIapRecordsTable]
                                  stringByAppendingFormat:@" where %@=%@", kIapRecordsTableColPurchasedId, purchasedid];
		ret = [self databaseExecSQL:sqlStatement];
        return ret;
	}
	return NO;
}

-(BOOL) deleteIAPRecordIsNotMyNumber: (NSString*)mynum {
	if (mynum) {
        BOOL ret = NO;
		NSString* sqlStatement = [[@"delete from " stringByAppendingFormat:@"%@", kIapRecordsTable]
                                  stringByAppendingFormat:@" where %@<>%@", kIapRecordsTableColMyNumber, mynum];
		ret = [self databaseExecSQL:sqlStatement];
        return ret;
	}
	return NO;
}

-(BOOL) clearIAPRecords {
    BOOL ret = NO;
	NSString* sqlStatement = [@"delete from " stringByAppendingFormat:@"%@", kIapRecordsTable];
    ret = [self databaseExecSQL:sqlStatement];
    return ret;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// conf_favorites

#define kConfFavoritesNameTable         @"conf_group_call_name"
#define kConfFavoritesNameColId         @"id"
#define kConfFavoritesNameColMynumber   @"mynumber"
#define kConfFavoritesNameColName       @"name"
#define kConfFavoritesNameColUuid       @"uuid"
#define kConfFavoritesNameColType       @"type"
#define kConfFavoritesNameColUpdateTime @"updatetime"
#define kConfFavoritesNameColEditStatus @"editstatus"

#define kConfFavoritesNumberTable          @"conf_group_call_number"
#define kConfFavoritesNumberColId          @"id"
#define kConfFavoritesNumberColPhoneNumber @"phonenumber"
#define kConfFavoritesNumberColUuid        @"uuid"

+(BOOL) createConfFavoritesNameTable:(sqlite3 *)db {
    BOOL ok = YES;
    
    if ([NgnStorageService hasTableWithName:db andTableName:kConfFavoritesNameTable]) {
        NSString* sqlStatement = [NSString stringWithFormat:@"select * from %@", kConfFavoritesNameTable];
        sqlite3_stmt *compiledStatement = nil;
        int rc = sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, nil);
        
        if (compiledStatement) {
            sqlite3_finalize(compiledStatement), compiledStatement = nil;
        }
        
        if (rc == SQLITE_OK) {
            {
                BOOL columnExists = NO;
                sqlite3_stmt *selectStmt;
                NSString* sqlQuire = [NSString stringWithFormat:@"select %@ from %@", kConfFavoritesNameColType, kConfFavoritesNameTable];
                if (sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlQuire], -1, &selectStmt, nil) == SQLITE_OK)
                    columnExists = YES;
                
                if (NO == columnExists) {
                    ok = NO;
                    sqlite3_stmt *compiledStatement = nil;
                    NSString* sqlQuireStatement = [NSString stringWithFormat:@"alter table %@ add column %@ integer", kConfFavoritesNameTable, kConfFavoritesNameColType];
                    int ret = sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlQuireStatement], -1, &compiledStatement, nil);
                    if (sqlite3_step(compiledStatement)==SQLITE_DONE) {
                        ok = YES;
                    }
                    sqlite3_finalize(compiledStatement), compiledStatement = nil;
                }
            }
            
            {
                BOOL columnExists = NO;
                sqlite3_stmt *selectStmt;
                NSString* sqlQuire = [NSString stringWithFormat:@"select %@ from %@", kConfFavoritesNameColUpdateTime, kConfFavoritesNameTable];
                if (sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlQuire], -1, &selectStmt, nil) == SQLITE_OK)
                    columnExists = YES;
                
                if (NO == columnExists) {
                    ok = NO;
                    sqlite3_stmt *compiledStatement = nil;
                    NSString* sqlQuireStatement = [NSString stringWithFormat:@"alter table %@ add column %@ double", kConfFavoritesNameTable, kConfFavoritesNameColUpdateTime];
                    int ret = sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlQuireStatement], -1, &compiledStatement, nil);
                    if (sqlite3_step(compiledStatement)==SQLITE_DONE) {
                        ok = YES;
                    }
                    sqlite3_finalize(compiledStatement), compiledStatement = nil;
                    return ok;
                }
            }
            
            {
                BOOL columnExists = NO;
                sqlite3_stmt *selectStmt;
                NSString* sqlQuire = [NSString stringWithFormat:@"select %@ from %@", kConfFavoritesNameColEditStatus, kConfFavoritesNameTable];
                if (sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlQuire], -1, &selectStmt, nil) == SQLITE_OK)
                    columnExists = YES;
                
                if (NO == columnExists) {
                    ok = NO;
                    sqlite3_stmt *compiledStatement = nil;
                    NSString* sqlQuireStatement = [NSString stringWithFormat:@"alter table %@ add column %@ integer", kConfFavoritesNameTable, kConfFavoritesNameColEditStatus];
                    int ret = sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlQuireStatement], -1, &compiledStatement, nil);
                    if (sqlite3_step(compiledStatement)==SQLITE_DONE) {
                        ok = YES;
                    }
                    sqlite3_finalize(compiledStatement), compiledStatement = nil;
                    return ok;
                }
            }
        }

        return YES;
    }

    
    if (NO == [NgnStorageService hasTableWithName:db andTableName:kConfFavoritesNameTable]) {
        NSString* sqlStatement = [NSString stringWithFormat:@"CREATE TABLE %@(%@ INTEGER PRIMARY KEY, %@ TEXT, %@ TEXT, %@ TEXT, %@ INTEGER, %@ DOUBLE, %@ INTEGER)",
                                  kConfFavoritesNameTable, kConfFavoritesNameColId, kConfFavoritesNameColMynumber, kConfFavoritesNameColName,
                                  kConfFavoritesNameColUuid, kConfFavoritesNameColType, kConfFavoritesNameColUpdateTime, kConfFavoritesNameColEditStatus];
        sqlite3_stmt *compiledStatement = nil;
        sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, nil);
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            ok = YES;
        } else {
            ok = NO;
        }
        sqlite3_finalize(compiledStatement), compiledStatement = nil;
    }
    
    return ok;
}

-(BOOL) dbLoadConfFavorites:(NSMutableArray*)conffavorites andMyNumber:(NSString *)mynumber andStatus:(ConfEditStatusDef)status{
    BOOL ok = YES;
	int ret;
    
    sqlite3_stmt *compiledStatement = nil;
    NSString* sqlQueryConfFavorites = [@"select " stringByAppendingFormat:@"%@,%@,%@,%@,%@,%@ from %@ where %@='%@' and %@=%d",
                                       kConfFavoritesNameColId, kConfFavoritesNameColMynumber, kConfFavoritesNameColName,
                                       kConfFavoritesNameColUuid, kConfFavoritesNameColType, kConfFavoritesNameColUpdateTime,
                                       kConfFavoritesNameTable, kConfFavoritesNameColMynumber, mynumber, kConfFavoritesNameColEditStatus, status];
        
    /* === Load conf_favorites === */
    if((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryConfFavorites], -1, &compiledStatement, NULL)) == SQLITE_OK) {
        long long id_;
        NSString *mynumber;
        NSString *name;
        NSString *uuid;
        ConfTypeDef type;
        NSTimeInterval time;
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            id_ = sqlite3_column_int(compiledStatement, 0);
            mynumber = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 1)];
            name = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 2)];
            uuid = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 3)];
            type = (ConfTypeDef)sqlite3_column_int(compiledStatement, 4);
            time = sqlite3_column_double(compiledStatement, 5);
            
            NgnConferenceFavorite* conffavorite = [[NgnConferenceFavorite alloc] initWithId:id_
                                                                                andMyNumber:mynumber
                                                                                    andName:name
                                                                                    andUuid:uuid
                                                                                    andType:type
                                                                                    andUpdateTime:time
                                                                                    andStatus:status];
            NgnLog(@"dbLoadConfFavorites: mynumber=%@, name=%@, type=%d, time=%f, type=%d", mynumber, name, type, time, status);
                
            [conffavorites addObject:conffavorite];
            [conffavorite release];
        }
    }
    sqlite3_finalize(compiledStatement), compiledStatement = nil;    
    
	return ok;
}

-(BOOL) dbCheckConfFavorite:(NSString*)mynumber andName:(NSString *)name{
    BOOL found = NO;
	int ret;
    
    sqlite3_stmt *compiledStatement = nil;
    NSString* sqlQueryConfFavorites = [[@"select " stringByAppendingFormat:@"%@,%@ from %@",
                                        kConfFavoritesNameColId, kConfFavoritesNameColUuid, kConfFavoritesNameTable] stringByAppendingFormat:@" where %@='%@'", kConfFavoritesNameColMynumber, mynumber];
    if (name != nil)
    {
        sqlQueryConfFavorites = [sqlQueryConfFavorites stringByAppendingFormat:@" and %@='%@'", kConfFavoritesNameColName, name];
    }
    
    /* === check conf_favorites === */
    ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryConfFavorites], -1, &compiledStatement, NULL);
    if (ret == SQLITE_OK) {
        long long id_;
        while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            id_ = sqlite3_column_int(compiledStatement, 0);
            found = YES;
        }
    }
    sqlite3_finalize(compiledStatement), compiledStatement = nil;
    
	return found;
}

-(BOOL) dbCheckConfFavoriteWithUUID:(NSString*)uuid andMyNumber:(NSString*)mynumber {
    BOOL found = NO;
	int ret;
    
    sqlite3_stmt *compiledStatement = nil;
    NSString* sqlQueryConfFavorites = [[@"select " stringByAppendingFormat:@"%@,%@ from %@",
                                        kConfFavoritesNameColId, kConfFavoritesNameColUuid, kConfFavoritesNameTable] stringByAppendingFormat:@" where %@='%@' and %@='%@'", kConfFavoritesNameColMynumber, mynumber, kConfFavoritesNameColUuid, uuid];    
    /* === check conf_favorites === */
    ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryConfFavorites], -1, &compiledStatement, NULL);
    if (ret == SQLITE_OK) {
        long long id_;
        while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
            id_ = sqlite3_column_int(compiledStatement, 0);
            found = YES;
        }
    }
    sqlite3_finalize(compiledStatement), compiledStatement = nil;
    
	return found;
}

-(BOOL) dbAddConfFavorite:(NgnConferenceFavorite*)favorite{
    NgnLog(@"dbAddConfFavorite group=%@, time=%f", favorite.name, favorite.updatetime);
	if (favorite.mynumber && favorite.name && favorite.uuid){
		NSString* sqlStatement = [[@"insert into " stringByAppendingFormat:@"%@ (%@,%@,%@,%@,%@,%@) values", kConfFavoritesNameTable,
                                   kConfFavoritesNameColMynumber, kConfFavoritesNameColName, kConfFavoritesNameColUuid, kConfFavoritesNameColType, kConfFavoritesNameColUpdateTime,kConfFavoritesNameColEditStatus]
								  stringByAppendingFormat:@"('%@', '%@', '%@', %d, %f, %d)", favorite.mynumber, favorite.name, favorite.uuid, favorite.type, favorite.updatetime, favorite.status];
        if([self databaseExecSQL:sqlStatement]){
			long long myid = (long long)sqlite3_last_insert_rowid(self->database);			
			return YES;
		}
	}
	return NO;
}

-(BOOL) dbUpdateConfFavorite:(NgnConferenceFavorite *)favorite{
    NgnLog(@"dbUpdateConfFavorite group=%@, time=%f, status=%d", favorite.name, favorite.updatetime, favorite.status);
    BOOL ok = NO;
	int ret;
	if (favorite.uuid && favorite.name) {
        sqlite3_stmt *quireState = nil;
        NSString* sqlUpdateStatement = [[@"update " stringByAppendingFormat:@"%@ set %@=?, %@=?, %@=?, %@=?",
                                         kConfFavoritesNameTable, kConfFavoritesNameColName, kConfFavoritesNameColType, kConfFavoritesNameColUpdateTime, kConfFavoritesNameColEditStatus]
                                        stringByAppendingFormat:@" where %@='%@'", kConfFavoritesNameColUuid, favorite.uuid];
        if((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlUpdateStatement], -1, &quireState, NULL)) == SQLITE_OK) {
            sqlite3_bind_text(quireState, 1, [NgnStringUtils toCString: favorite.name], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(quireState, 2, favorite.type);
            sqlite3_bind_double(quireState, 3, favorite.updatetime);
            sqlite3_bind_int(quireState, 4, favorite.status);
            
            ok = ((ret = sqlite3_step(quireState))==SQLITE_DONE);
        }
        sqlite3_finalize(quireState);
	}
    
	return ok;
}

-(BOOL) dbDeleteConfFavorite:(NSString *)uuid {
	if(uuid){
        BOOL ret1 = NO;
        BOOL ret2 = NO;
        
		NSString* sqlStatement = [[@"delete from " stringByAppendingFormat:@"%@", kConfFavoritesNameTable]
                        stringByAppendingFormat:@" where %@='%@'", kConfFavoritesNameColUuid, uuid];
		ret1 = [self databaseExecSQL:sqlStatement];
        
        sqlStatement = [[@"delete from " stringByAppendingFormat:@"%@", kConfFavoritesNumberTable]
								  stringByAppendingFormat:@" where %@='%@'", kConfFavoritesNumberColUuid, uuid];
		ret2 = [self databaseExecSQL:sqlStatement];
        
        return (ret1 && ret2);
	}
	return NO;
}

+(BOOL) createConfFavoritesNumberTable:(sqlite3 *)db {
    BOOL ok = YES;
    
    if (NO == [NgnStorageService hasTableWithName:db andTableName:kConfFavoritesNumberTable]) {
        NSString* sqlStatement = [NSString stringWithFormat:@"CREATE TABLE %@(%@ INTEGER PRIMARY KEY, %@ TEXT, %@ TEXT)", kConfFavoritesNumberTable, kConfFavoritesNumberColId, kConfFavoritesNumberColPhoneNumber, kConfFavoritesNumberColUuid];
        sqlite3_stmt *compiledStatement = nil;
        sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, nil);
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            ok = YES;
        } else {
            ok = NO;
        }
        sqlite3_finalize(compiledStatement), compiledStatement = nil;
    }
    
    return ok;
}

-(BOOL) dbLoadConfParticipants:(NSMutableArray*)participantNumber Uuid:(NSString *)uuid{
    BOOL ok = YES;
	int ret;
    if (uuid) {
        sqlite3_stmt *compiledStatement = nil;
        NSString* sqlQueryConfFavorites = [[@"select " stringByAppendingFormat:@"%@,%@ from %@",
                                            kConfFavoritesNumberColId, kConfFavoritesNumberColPhoneNumber, kConfFavoritesNumberTable] stringByAppendingFormat:@" where %@='%@'", kConfFavoritesNumberColUuid, uuid];
        
        /* === Load conf_favorites === */
        [participantNumber removeAllObjects];
        if((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryConfFavorites], -1, &compiledStatement, NULL)) == SQLITE_OK) {
            long long id_;
            NSString* number;
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                id_ = sqlite3_column_int(compiledStatement, 0);
                number = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 1)];
                
                [participantNumber addObject:number];
            }
        }
        sqlite3_finalize(compiledStatement), compiledStatement = nil;
    }
    
	return ok;
}

-(BOOL) dbAddConfParticipant:(NSString *)uuid andPhoneNum:(NSString*)number{
	if (number && uuid){
		NSString* sqlStatement = [[@"insert into " stringByAppendingFormat:@"%@ (%@,%@) values", kConfFavoritesNumberTable, kConfFavoritesNumberColPhoneNumber, kConfFavoritesNumberColUuid]
								  stringByAppendingFormat:@"('%@', '%@')", number, uuid];
        if([self databaseExecSQL:sqlStatement]){
			long long myid = (long long)sqlite3_last_insert_rowid(self->database);
			return YES;
		}
	}
	return NO;
}

-(BOOL) dbDeleteConfParticipant:(NSString *)uuid withPhoneNumber:(NSString *)phoneNumber{
    BOOL ret1 = NO;
    BOOL ret2 = NO;
    
    NSString *sqlStatement = [@"delete from " stringByAppendingFormat:@"%@ where %@='%@' and %@='%@'", kConfFavoritesNumberTable, kConfFavoritesNumberColUuid, uuid, kConfFavoritesNumberColPhoneNumber, phoneNumber];
    ret2 = [self databaseExecSQL:sqlStatement];
    
    return (ret1 && ret2);
}

-(BOOL) dbClearConfParticipants:(NSString *)uuid{
    BOOL ret = NO;
    NSString *sqlStatement = [@"delete from " stringByAppendingFormat:@"%@ where %@='%@'", kConfFavoritesNumberTable, kConfFavoritesNumberColUuid, uuid];
    ret = [self databaseExecSQL:sqlStatement];
    
    return ret;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark Call_Feed_Back
#define kCallFeedBackTable         @"call_feed_back"
#define kCallFeedBackColId         @"id"
#define kCallFeedBackColData       @"data"
#define kCallFeedBackColFlag       @"flag"

+ (BOOL)createCallFeedBackTable:(sqlite3 *)db {
    BOOL ok = YES;
    
    if (NO == [NgnStorageService hasTableWithName:db andTableName:kCallFeedBackTable]) {
        NSString* sqlStatement = [NSString stringWithFormat:@"CREATE TABLE %@(%@ INTEGER PRIMARY KEY, %@ TEXT, %@ INTEGER)", kCallFeedBackTable, kCallFeedBackColId, kCallFeedBackColData, kCallFeedBackColFlag];
        sqlite3_stmt *compiledStatement = nil;
        sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, nil);
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            ok = YES;
        } else {
            ok = NO;
        }
        sqlite3_finalize(compiledStatement), compiledStatement = nil;
    }
    
    return ok;
}

/**
 *	@brief	query dataset from table
 *
 *	@param 	feedBackArray 	output param,is a resultset
 *
 *	@return	result
 */
- (BOOL)dbLoadCallFeedBack:(NSMutableArray *)feedBackArray
{
    BOOL ok = YES;
	int ret;
    
    sqlite3_stmt *compiledStatement = nil;
    NSString* sqlQueryFeedBackData = [@"select " stringByAppendingFormat:@"%@,%@,%@ from %@ where flag != 0",
                                       kCallFeedBackColId, kCallFeedBackColData, kCallFeedBackColFlag, kCallFeedBackTable];
    
    //query data from call_feed_back
    [feedBackArray removeAllObjects];
    if((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryFeedBackData], -1, &compiledStatement, NULL)) == SQLITE_OK) {
        int id_;
        NSString* data;
        int flag = 1;
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            id_ = sqlite3_column_int(compiledStatement, 0);
            data = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 1)];
            flag = sqlite3_column_int(compiledStatement, 2);
            
            NgnCallFeedBackData* aFeedBack= [[NgnCallFeedBackData alloc] initWithId:id_ andData:data andFlag:flag];            
            [feedBackArray addObject:aFeedBack];
            [aFeedBack release];
        }
    }
    sqlite3_finalize(compiledStatement), compiledStatement = nil;
    
	return ok;
}

/**
 *	@brief	insert a record to table
 *
 *	@param 	data 	prepare to server
 *
 *	@return	result
 */
- (int)addCallFeedBack:(NSString *)data
{
    int myid = -1;
	if (data){
		NSString* sqlStatement = [[@"insert into " stringByAppendingFormat:@"%@ (%@,%@) values", kCallFeedBackTable, kCallFeedBackColData, kCallFeedBackColFlag]
								  stringByAppendingFormat:@"('%@', %d)", data, 1];
        //CCLog(@"addCallFeedBack:%@",sqlStatement);
        if([self databaseExecSQL:sqlStatement]){
			myid = (int)sqlite3_last_insert_rowid(self->database);
		}
	}
	return myid;
}

/**
 *	@brief	update a record from table
 *
 *  @param  id
 *
 *	@return	result
 */
- (BOOL)updateCallFeedBack: (int)feedbackid
{
    BOOL ok = NO;
	int ret;
	if(feedbackid){
        sqlite3_stmt *stmt = nil;
        NSString* sqlUpdateStatement = [[@"update " stringByAppendingFormat:@"%@ set %@=0", kCallFeedBackTable, kCallFeedBackColFlag]
                                        stringByAppendingFormat:@" where %@=%d", kCallFeedBackColId, feedbackid];
        if((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlUpdateStatement], -1, &stmt, NULL)) == SQLITE_OK) {
            //sqlite3_bind_text(quireState, 1, [NgnStringUtils toCString: name], -1, SQLITE_TRANSIENT);
            ok = ((ret = sqlite3_step(stmt))==SQLITE_DONE);
        }
        sqlite3_finalize(stmt);
	}
	return ok;
}

/**
 *	@brief	delete a record from table
 *
 *  @param  id
 *
 *	@return	result
 */
- (BOOL)deleteCallFeedBack: (int)feedbackid
{
	if(feedbackid){
        BOOL ret = NO;
        
		NSString* sqlStatement = [[@"delete from " stringByAppendingFormat:@"%@", kCallFeedBackTable]
                                  stringByAppendingFormat:@" where %@=%d", kCallFeedBackColId, feedbackid];
		ret = [self databaseExecSQL:sqlStatement];
        return ret;
	}
	return NO;
}

/**
 *	@brief	delete all data table call_feed_back
 *
 *	@return	result
 */
- (BOOL)clearCallFeedBack
{
    BOOL ret = NO;
    
	NSString* sqlStatement = [@"delete from " stringByAppendingFormat:@"%@", kCallFeedBackTable];
    ret = [self databaseExecSQL:sqlStatement];
    
    return ret;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark CouponInfo
#define kCouponInfoTable            @"couponinfo"
#define kcoupon_id                  @"coupon_id"
#define kcoupon_who                 @"coupon_who"
#define kcoupon_type_id             @"coupon_type_id"
#define kcoupon_name                @"coupon_name"
#define kcoupon_price               @"coupon_price"
#define kcoupon_detail              @"coupon_detail"
#define kcoupon_thumbnail_url       @"coupon_thumbnail_url"
#define kcoupon_image_url           @"coupon_image_url"
#define kcoupon_validity            @"coupon_validity"
#define kcoupon_total               @"coupon_total"
#define kcoupon_remain              @"coupon_remain"
#define kcoupon_classify            @"coupon_classify"
#define kcoupon_brand               @"coupon_brand"
#define kprovince                   @"province"
#define kcity                       @"city"
#define kshop_id                    @"shop_id"
#define kupdate_time                @"update_time"
#define kcoupon_type                @"coupon_type"
#define kavailable                  @"available"
#define kcoupon_thumbnail_url_local @"coupon_thumbnail_url_local"
#define kcoupon_image_url_local     @"coupon_image_url_local"

+ (BOOL)createCouponInfoTable:(sqlite3 *)db {
    BOOL ok = YES;
    
    if (NO == [NgnStorageService hasTableWithName:db andTableName:kCouponInfoTable]) {
        NSString* sqlStatement = [NSString stringWithFormat:@"CREATE TABLE %@(%@ TEXT, %@ TEXT, %@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ BOOLEAN, %@ TEXT, %@ TEXT, PRIMARY KEY(%@,%@))", kCouponInfoTable, kcoupon_id, kcoupon_who, kcoupon_type_id,kcoupon_name,kcoupon_price,kcoupon_detail,kcoupon_thumbnail_url,kcoupon_image_url,kcoupon_validity,kcoupon_total,kcoupon_remain,kcoupon_classify,kcoupon_brand,kprovince,kcity,kshop_id,kupdate_time, kcoupon_type, kavailable, kcoupon_thumbnail_url_local, kcoupon_image_url_local, kcoupon_id, kcoupon_who];
        sqlite3_stmt *compiledStatement = nil;
        sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, nil);
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            ok = YES;
        } else {
            ok = NO;
        }
        sqlite3_finalize(compiledStatement), compiledStatement = nil;
    }
    
    return ok;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark hist_event

#define kHistEventTable @"hist_event"
/**
 *	@brief	判断hist_event是否存在callmode这个字段
 *
 *	@return	存在:Yes 不存在:NO
 */
+ (BOOL)existCallModeOnTableHist_Event:(sqlite3 *)db
{
    BOOL ok = YES;
    
    if (NO == [NgnStorageService hasColumnWithName:db andTableName:kHistEventTable andColumnName:@"CallMode TINYINT(8)"]) {
        NSString* sqlStatement = @"ALTER TABLE hist_event ADD COLUMN CallMode TINYINT(8)";
        sqlite3_stmt *compiledStatement = nil;
        sqlite3_prepare_v2(db, [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, nil);
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            ok = YES;
        } else {
            ok = NO;
        }
        sqlite3_finalize(compiledStatement), compiledStatement = nil;
    }
    
    return ok;
}

@end
