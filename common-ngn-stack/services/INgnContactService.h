
#import <Foundation/Foundation.h>

#import "INgnBaseService.h"
#import "model/NgnContact.h"

@protocol INgnContactService <INgnBaseService>
-(void) load:(BOOL) asyn;
-(void) edited:(BOOL) editing;
-(void) unload;
-(BOOL) isLoading;
-(NSArray*) contacts;
-(NSDictionary*) numbers2ContactsMapper;
-(NSArray*) contactsWithPredicate:(NSPredicate*)predicate;
-(NgnContact*) getContactByUri:(NSString*)uri;
-(NgnContact*) getContactByPhoneNumber:(NSString*)phoneNumber;
-(BOOL) dbLoadWeiCallUserContacts:(NSMutableDictionary*)users;
-(BOOL) dbAddWeiCallUserContact:(NSString*)myNum PhoneNum:(NSString*)Num;
-(BOOL) dbClearWeiCallUsers;
-(BOOL) dbDeleteContactsNotMine:(NSString*)myNum;
-(BOOL) dbIsWeiCallUser:(NSString*)Num;
@end

