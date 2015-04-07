#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#	import "iOSNgnConfig.h"
#elif TARGET_OS_MAC
#	import "OSXNgnConfig.h"
#endif

#import <UIKit/UIKit.h>
#import "services/impl/NgnBaseService.h"
#import "services/INgnInfoService.h"
#import "services/impl/InfoService/Information.h"

@interface NgnInfoService : NgnBaseService<INgnInfoService>

@property (nonatomic, retain) Information *info;
@property (readonly, retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, retain, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, retain, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
