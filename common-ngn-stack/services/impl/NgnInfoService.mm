//
//  NgnInfoService.m
//  ios-ngn-stack
//
//  Created by Dan on 14-1-10.
//  Copyright (c) 2014年 SkyBroad. All rights reserved.
//

#import "NgnInfoService.h"
#import "NgnConfigurationEntry.h"
#import <CoreData/CoreData.h>
#import "NSString+Code.h"

#undef TAG
#define KTAG @"NgnInformationService///: "
#define TAG KTAG


@implementation NgnInfoService

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize info = __info;


- (NgnInfoService *)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (BOOL)start
{
    NgnNSLog(TAG, @"Start()");
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_ACCOUNT_CEARTDATA]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_ACCOUNT_CEARTDATA];
        //Information initial
        Information *info = [NSEntityDescription insertNewObjectForEntityForName:@"Information" inManagedObjectContext:context];
        info.identity_display_name = DEFAULT_IDENTITY_DISPLAY_NAME;
        info.identity_impi = [DEFAULT_IDENTITY_IMPI tripleDESWithKey:YunTong3DesKey];
        info.identity_impu = [DEFAULT_IDENTITY_IMPU tripleDESWithKey:YunTong3DesKey];
        info.identity_password = [DEFAULT_IDENTITY_PASSWORD tripleDESWithKey:YunTong3DesKey];
        info.account_name = DEFAULT_ACCOUNT_NAME;
        info.account_nickname = DEFAULT_ACCOUNT_NICKNAME;
        info.account_localnum = @"";
        info.account_gender = DEFAULT_ACCOUNT_GENDER;
        info.account_birthdate = DEFAULT_ACCOUNT_BIRTHDATE;
        info.account_email = DEFAULT_ACCOUNT_EMAIL;
        info.account_referee = DEFAULT_ACCOUNT_REFEREE;
        info.account_qq = DEFAULT_ACCOUNT_QQ;
        info.account_sinaweibo = DEFAULT_ACCOUNT_SINAWEIBO;
        info.account_level = [NSNumber numberWithInt:0];
        info.account_thumbnail = DEFAULT_ACCOUNT_THUMBNAIL;
        
        //insert into context and save
        [self saveContext];
    }
    
    return YES;
}

- (BOOL)stop
{
    NgnNSLog(TAG, @"Stop()");
    return YES;
}

- (void)dealloc
{
    [self stop];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [__info release];
    [super dealloc];
}

- (Information *)info
{
    if (__info != nil) {
        return __info;
    }
    
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Information" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    __info = [(Information *)[fetchObjects lastObject] retain];
    
    
    [fetchRequest release];
    return __info;
}

- (Information *)getInfo
{
    return [self info];
}

#pragma mark - Protocal optional

- (void)setInfoValue:(id)value forKey:(NSString *)key
{
    if (__info == nil) {
        [self info];
    }
    if (value)
    {
        [__info setValue:value forKey:key];
        [self saveContext];
    }
}

- (id)getInfoValueForkey:(NSString *)key
{
    if (__info == nil) {
        [self info];
    }
    [self info];
//    NSLog(@"infovalue = %@",[__info valueForKey:key]);
    return [__info valueForKey:key];
}

//with 3des encrypt
- (void)setInfoValueWithEncrypt:(NSString *)value forKey:(NSString *)key
{
    if (__info == nil) {
        [self info];
    }
    NSString *enresult = [value tripleDESWithKey:YunTong3DesKey];
    [__info setValue:enresult forKey:key];
    [self saveContext];
    
}

- (NSString *)getInfoValueForkeyWithDecrypt:(NSString *)key
{
    if (__info == nil) {
        [self info];
    }
    [self info];
    
    NSString *value = (NSString *)[__info valueForKey:key];
    NSString *deresult = [value decodeTripleDESWithKey:YunTong3DesKey];
//    NSLog(@"infovalue = %@",deresult);
    return deresult;
}

#pragma mark - Protocal required

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        else
            NSLog( @"CoreData数据成功插入");
    }
}

#pragma mark - applicationDocument

- (NSURL *)applicationDocumentsDirectory
{
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modeURL = [[NSBundle mainBundle] URLForResource:@"InfoService" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modeURL];
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"InfoService.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return __persistentStoreCoordinator;
    
    
}


@end
