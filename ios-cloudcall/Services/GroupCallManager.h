//

#import <UIKit/UIKit.h>
#import "NgnEngine.h"

#define kGroupCallResponseStatusNotification  @"GroupCallResponseStatus"

typedef enum {
    GroupCallRequsetType_Add,
    GroupCallRequsetType_Update,
    GroupCallRequsetType_Delete,
    GroupCallRequsetType_Get
}GroupCallRequsetType;
@interface GroupCallResponseStatusNotificationArgs : NSObject {
    BOOL success;
    int errorcode;    
    GroupCallRequsetType type;
    NSString* text;
    NSMutableArray* records;
}

@property(readonly) BOOL success;
@property(readonly) int errorcode;
@property(readonly) GroupCallRequsetType type;
@property(readonly) NSString* text;
@property(readonly) NSMutableArray* records;

-(GroupCallResponseStatusNotificationArgs*) initWithStatus:(BOOL)success andErrorCode:(int)errorcode andType:(GroupCallRequsetType)type andText:(NSString*)text andRecords:(NSMutableArray*)records;

@end


@interface GroupCallMember : NSObject {
    NSString* name;
    NSString* number;
}
@property(nonatomic, retain)  NSString *name;
@property(nonatomic, retain)  NSString *number;

-(GroupCallMember*) initWithName:(NSString*)name andNumber:(NSString*)number;
@end

@interface GroupCallRecord : NSObject {
    NSString* usernumber;
    NSString* name;
    NSString* groupid;
    ConfTypeDef type;
    NSTimeInterval updatetime;
    NSMutableArray* members;
}
@property(nonatomic, retain)  NSString*       usernumber;
@property(nonatomic, retain)  NSString*       name;
@property(nonatomic, retain)  NSString*       groupid;
@property(readwrite)          ConfTypeDef     type;
@property(readwrite)          NSTimeInterval  updatetime;
@property(nonatomic, retain)  NSMutableArray* members;

-(GroupCallRecord*) initWithUserNumber:(NSString*)usernumber andName:(NSString*)name andGroupId:(NSString*)groupid andType:(ConfTypeDef)type andUpdateTime:(NSTimeInterval)updatetime andMembers:(NSMutableArray*)members;
@end

@interface GroupCallManager : NSObject {
}

-(void)sendRequest2Server:(NSData*)jsonData andUserInfo:(NSMutableDictionary*)userInfo;

-(void)AddGroupRecords:(NSArray*)records;
-(void)UpdateGroupRecords:(NSArray*)records;
-(void)DeleteGroupRecords:(NSArray*)records;
-(void)DeleteGroupRecord:(NSString*)groupid;
-(void)GetGroupRecords;
@end
