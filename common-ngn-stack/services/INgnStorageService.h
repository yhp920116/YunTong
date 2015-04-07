
#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

#import <sqlite3.h>
#import "model/NgnFavorite.h"
#import "model/NgnSystemNotification.h"
#import "model/NgnIAPRecord.h"
#import "model/NgnConferenceFavorite.h"

@protocol INgnStorageService <INgnBaseService>

-(int) databaseVersion;
-(sqlite3 *) database;
-(BOOL) execSQL: (NSString*)sqlQuery;
-(NSDictionary*) favorites;
-(NgnFavorite*) favoriteWithNumber:(NSString*)number andMediaType:(NgnMediaType_t)mediaType;
-(NgnFavorite*) favoriteWithNumber:(NSString*)number;
-(BOOL) addFavorite: (NgnFavorite*) favorite;
-(BOOL) deleteFavorite: (NgnFavorite*) favorite;
-(BOOL) deleteFavoriteWithId: (long long) id;
-(BOOL) clearFavorites;

-(BOOL) dbLoadSystemNofitication:(NSMutableArray*)sysnotification andMyNumber:(NSString*)mynum;
-(unsigned int) getUnreadSystemNotificationNum:(NSString*)mynum;
-(BOOL) addSystemNofitication:(NgnSystemNotification*)sysnotify;
-(BOOL) updateSystemNofitication: (long long)_id andRead:(BOOL)read;
-(BOOL) deleteSystemNofitication: (long long)_id;
-(BOOL) deleteSystemNofiticationWithMyNum: (NSString*)mynum;
-(BOOL) deleteSystemNofiticationIsNotMyNumber: (NSString*)mynum;
-(BOOL) clearSystemNofitication;

-(BOOL) dbLoadIAPRecords: (NSMutableArray*)iaprecords andMyNumber: (NSString*)mynum;
-(BOOL) addIAPRecord: (NgnIAPRecord*)record;
-(BOOL) deleteIAPRecord: (NSString*)purchasedid;
-(BOOL) deleteIAPRecordIsNotMyNumber: (NSString*)mynum;
-(BOOL) clearIAPRecords;

////////////
-(BOOL) dbLoadConfFavorites:(NSMutableArray*)conffavorites andMyNumber:(NSString *)mynumber andStatus:(ConfEditStatusDef)status;
-(BOOL) dbCheckConfFavorite:(NSString*)mynumber andName:(NSString *)name;
-(BOOL) dbCheckConfFavoriteWithUUID:(NSString*)uuid andMyNumber:(NSString*)mynumber;
-(BOOL) dbAddConfFavorite:(NgnConferenceFavorite*)favorite;
-(BOOL) dbUpdateConfFavorite:(NgnConferenceFavorite*)favorite;
-(BOOL) dbDeleteConfFavorite:(NSString *)uuid;

-(BOOL) dbLoadConfParticipants:(NSMutableArray*)participantNumber Uuid:(NSString *)uuid;
-(BOOL) dbAddConfParticipant:(NSString *)uuid andPhoneNum:(NSString*)number;
-(BOOL) dbClearConfParticipants:(NSString *)uuid;
-(BOOL) dbDeleteConfParticipant:(NSString *)uuid withPhoneNumber:(NSString *)phoneNumber;

//callfeedback
- (BOOL)dbLoadCallFeedBack:(NSMutableArray*)feedBackArray;
- (int)addCallFeedBack:(NSString *)data;
- (BOOL)updateCallFeedBack: (int)feedbackid;
- (BOOL)deleteCallFeedBack: (int)feedbackid;
- (BOOL)clearCallFeedBack;

@end