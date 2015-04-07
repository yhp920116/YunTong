
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#import "utils/NgnPredicate.h"
#import "NgnPhoneNumber.h"


typedef NSMutableArray NgnContactMutableArray;
typedef NSArray NgnContactArray;

@class NgnPhoneNumber;

@interface NgnContact : NSObject {
@protected
	int32_t myid;
	NSString* displayName;
	NSString* firstName;
	NSString* lastName;
	NSMutableArray* phoneNumbers;
	NSData* picture;
    NSString* cIndex;
    NSString* abDisplayName;
    NSString* displayArea;
    NSString* displayMsg;   //显示内容,拨号盘使用
    int lettersCount;       //变色字母个数
    
    NSRange displayNameRange;   //变色姓名序列
    NSRange displayMsgRange;    //变色内容序列

@private
	// to be used for any purpose (e.g. category)
	id opaque;
}

#if TARGET_OS_IPHONE
-(NgnContact*)initWithDisplayName:(NSString*) dispname andPicture:(NSData *)picture;
- (NgnContact*)initWithDisplayName:(NSString*)_displayName andFirstName:(NSString *)_firstName andLastName:(NSString *)_lastName andPhoneNumbers:(NSMutableArray *)_phoneNumbers andPicture:(NSData *)_picture  andDisplayMsg:(NSString *)_displayMsg andDisplayMsgRange:(NSRange)_displayMsgRange;
-(NgnContact*)initWithABRecordRef:(const ABRecordRef)record;
#elif TARGET_OS_MAC
-(NgnContact*)initWithABPerson:(const ABPerson*)person;
#endif /* TARGET_OS_IPHONE */
-(NgnPhoneNumber*)getPhoneNumberWithPredicate:(NSPredicate*)predicate;

-(void)InitDisplayAreaInfo;

@property(readonly) int32_t myid;
@property(readonly) NSString* displayName;
@property(readonly) NSString* firstName;
@property(readonly) NSString* lastName;
@property(readonly) NSMutableArray* phoneNumbers;
@property(readonly) NSData* picture;
@property(readonly) NSString* cIndex;
@property(readonly) NSString* abDisplayName;
@property(readwrite, retain, nonatomic) id opaque;
@property(retain, nonatomic) NSString* displayArea;
@property(retain, nonatomic) NSString* displayMsg;

@property (nonatomic,assign) NSRange displayNameRange;
@property (nonatomic,assign) NSRange displayMsgRange;
@property (nonatomic,assign) int lettersCount;

@end
