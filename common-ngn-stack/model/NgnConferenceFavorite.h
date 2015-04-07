
#if TARGET_OS_IPHONE
#import <Foundation/Foundation.h>
#elif TARGET_OS_MAC
#endif

typedef enum {
    Conf_Type_Private,
    Conf_Type_Public
}ConfTypeDef;

typedef enum {
    Conf_Edit_Status_Default,
    Conf_Edit_Status_Delete,
    Conf_Edit_Status_Add
}ConfEditStatusDef;

@interface NgnConferenceFavorite : NSObject {
	long long myid;
    NSString *mynumber;
	NSString *name;
	NSString *uuid; // group id
    ConfTypeDef type;
    NSTimeInterval updatetime; // since EPOCH (00:00:00 UTC on 1 January 1970)
    ConfEditStatusDef status;
    
@private
	// to be used for any purpose (e.g. category)
	id opaque;
}

-(NgnConferenceFavorite*) initWithId: (long long)id andMyNumber:(NSString *)mynumber andName:(NSString*)name andUuid:(NSString *)uuid
                                    andType:(ConfTypeDef)type andUpdateTime:(NSTimeInterval)time andStatus:(ConfEditStatusDef)status;
-(NgnConferenceFavorite*) initWithMynumber:(NSString *)mynumber andName: (NSString*)name andUuid: (NSString *)uuid
                                   andType:(ConfTypeDef)type andUpdateTime:(NSTimeInterval)time andStatus:(ConfEditStatusDef)status;
//-(NSComparisonResult) compareFavoriteByCreateTime: (NgnConferenceFavorite *)otherFavorite;

@property(readwrite) long long myid;
@property(readonly) NSString *mynumber;
@property(nonatomic, retain) NSString *name;
@property(readonly) NSString *uuid;
@property(readwrite) ConfTypeDef type;
@property(readwrite) NSTimeInterval updatetime;
@property(readwrite) ConfEditStatusDef status;

@property(readwrite, retain, nonatomic) id opaque;

@end