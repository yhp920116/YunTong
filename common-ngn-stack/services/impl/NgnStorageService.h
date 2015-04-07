
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#	import "iOSNgnConfig.h"
#elif TARGET_OS_MAC
#	import "OSXNgnConfig.h"
#endif

#import "services/impl/NgnBaseService.h"
#import "services/INgnStorageService.h"

@interface NgnStorageService : NgnBaseService <INgnStorageService>{
	sqlite3 * database;
	NSMutableDictionary* favorites;
}

-(BOOL) load;


+(BOOL) createIAPRecordsTable:(sqlite3 *)db;

+(BOOL) createConfFavoritesNameTable:(sqlite3 *)db;
+(BOOL) createConfFavoritesNumberTable:(sqlite3 *)db;

//code by Sergio
+ (BOOL)createCallFeedBackTable:(sqlite3 *)db;
+ (BOOL)createCouponInfoTable:(sqlite3 *)db;

+ (BOOL)existCallModeOnTableHist_Event:(sqlite3 *)db;
@end
