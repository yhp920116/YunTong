
#import "NgnContactService.h"
#import "model/NgnContact.h"
#import "events/NgnContactEventArgs.h"
#import "events/NgnHistoryEventArgs.h"
#import "utils/NgnNotificationCenter.h"
#import "utils/pinyin.h"

#import "NgnEngine.h"
#import "NgnStringUtils.h"
#import "NSString+Code.h"

#undef TAG
#undef kNameSpace
#define kNameSpace "net.weicall.ios.services.contacts"
#define kTAG @"NgnContactService///: "
#define TAG kTAG
#define kNotificationUploadContact @"kNotificationUploadContact"

#undef NgnCFRelease
#define NgnCFRelease(x) if(x)CFRelease(x), x=NULL;

static BOOL reload = NO;
static BOOL externalChged = NO;

#if TARGET_OS_IPHONE
void NgnAddressBookExternalChangeCallback (ABAddressBookRef _addressBook, CFDictionaryRef info, void *context){
	NgnContactService *self_ = (NgnContactService*)context;
    @synchronized(self_){
        if(!reload) {
            ABAddressBookRevert(_addressBook);
            
            reload = YES;
            externalChged = YES;
            [self_ load:YES];
        }
    }
}
#endif /* TARGET_OS_IPHONE */

@interface NgnContactService(Private)

@property(readonly, getter=isStarted) BOOL started;

-(BOOL) isStarted;
-(void) syncLoad;
@end

#if TARGET_OS_IPHONE
static void NgnAddressBookCallbackForElements(const void *value, void *context)
{
	NgnContactService* self_ = (NgnContactService*)context;
	if(!self_.started){
		return;
	}
	const ABRecordRef* record = (const ABRecordRef*)value;
	NgnContact* contact = [[NgnContact alloc] initWithABRecordRef:record];
	if(contact){
		for(NgnPhoneNumber *phoneNumber in contact.phoneNumbers){
			if(phoneNumber.number){
                //NgnLog(@"set numbers2ContactsMapper: %@", phoneNumber.number);
                //[(NSMutableDictionary*)[self_ numbers2ContactsMapper] setObject:contact forKey:phoneNumber.number];
                NSString * newNum = [phoneNumber.number phoneNumFormat];
				[(NSMutableDictionary*)[self_ numbers2ContactsMapper] setObject:contact forKey:newNum];
			}
		}
        //NgnLog(@"NgnAddressBookCallbackForElements: %@", contact.displayName);
		[(NSMutableArray*)[self_ contacts] addObject: contact];
		[contact release];
	}
}

static CFComparisonResult CompareName(ABRecordRef person1, ABRecordRef person2) {
    CFComparisonResult result = kCFCompareEqualTo;
    
    CFStringRef displayName1 = ABRecordCopyCompositeName(person1);
	CFStringRef displayName2 = ABRecordCopyCompositeName(person2);    
    NSString* str1 = (NSString*)(displayName1);
	NSString* str2 = (NSString*)(displayName2);
    //NgnLog(@"'%@' '%@'", str1, str2);

    int len1 = [str1 length];
    int len2 = [str2 length];
    int len = len1 < len2 ? len1 : len2;
    if (len == 0) {
        /*NSString* sfn1 = (NSString*)ABRecordCopyValue(person1, kABPersonFirstNameProperty);
		NSString* sln1 = (NSString*)ABRecordCopyValue(person1, kABPersonLastNameProperty);
        NSString* sfn2 = (NSString*)ABRecordCopyValue(person2, kABPersonFirstNameProperty);
		NSString* sln2 = (NSString*)ABRecordCopyValue(person2, kABPersonLastNameProperty);        
        NgnLog(@"%d, %d. '%@' '%@', 1f-'%@' 1l-'%@', 2f-'%@' 2l-'%@'", len1, len2, str1, str2, sfn1, sln1, sfn2, sln2);*/
        if (len1 == 0)
            result = kCFCompareLessThan;
        else if (len2 == 0)
            result = kCFCompareGreaterThan;
        else
            result = kCFCompareEqualTo;
    } else {
        /*NSRange range = [str2 rangeOfString: @"²âÊÔ"];
        if (range.length > 0)
        {
            NgnLog(@"%d, %d. '%@' '%@'", len1, len2, str1, str2);
        }
        else
        {
            NSRange range = [str1 rangeOfString: @"²âÊÔ"];
            if (range.length > 0)
            {
                NgnLog(@"%d, %d. '%@' '%@'", len1, len2, str1, str2);
            }
        }*/
    
        wchar_t *wstr1 = (wchar_t *)[str1 cStringUsingEncoding:NSUTF32StringEncoding];
        wchar_t *wstr2 = (wchar_t *)[str2 cStringUsingEncoding:NSUTF32StringEncoding];
        for (int i=0; i<len; i++) {
            if (IsChinese(wstr1[i]) && !IsChinese(wstr2[i])) {
                if (i > 0) {
                    result = kCFCompareGreaterThan;
                    break;
                }
            
                const char* p = GetPinyinsByUnicode(wstr1[i]);
                if (p) {
                    NSString* s1 = [[NSString alloc] initWithFormat:@"%c", p[0]];                    
                    NSString* s2 = [[NSString alloc] initWithBytes:(&wstr2[i]) length:sizeof(wstr2[i]) encoding:NSUTF32LittleEndianStringEncoding];            
                    //NgnLog(@"s2'%@'", s2);
                    switch ([s1 caseInsensitiveCompare: s2]) {
                        case NSOrderedAscending: // s1 < s2
                            result = kCFCompareLessThan;
                            break;
                        case NSOrderedDescending: // s1 > s2
                        case NSOrderedSame:
                            result = kCFCompareGreaterThan;
                            break;
                    }
                    [s1 release];
                    [s2 release];
                } else {
                    result = kCFCompareGreaterThan;
                }
                break;
            }
            else if (!IsChinese(wstr1[i]) && IsChinese(wstr2[i])) {
                if (i > 0) {
                    result = kCFCompareLessThan;
                    break;
                }
            
                NSString* s1 = [[NSString alloc] initWithBytes:(&wstr1[i]) length:sizeof(wstr1[i]) encoding:NSUTF32LittleEndianStringEncoding];            
            
                const char* p = GetPinyinsByUnicode(wstr2[i]);
                NSString* s2 = nil;
                if (p) {
                    s2 = [[NSString alloc] initWithFormat:@"%c", p[0]];
                    switch ([s1 caseInsensitiveCompare: s2]) {
                        case NSOrderedAscending: // s1 < s2
                        case NSOrderedSame:
                            result = kCFCompareLessThan;
                            break;
                        case NSOrderedDescending: // s1 > s2
                            result = kCFCompareGreaterThan;
                            break;
                    }                
                    [s2 release];                    
                } else {
                    result = kCFCompareLessThan;
                }
                [s1 release];
                break;
            }
            else if (IsChinese(wstr1[i]) && IsChinese(wstr2[i])) {
                const char* p1 = GetPinyinsByUnicode(wstr1[i]);
                const char* p2 = GetPinyinsByUnicode(wstr2[i]);
                int cmp = strcmp(p1, p2);
                if (cmp < 0) {
                    result = kCFCompareLessThan;
                    break;
                }
                else if (cmp > 0) {
                    result = kCFCompareGreaterThan;
                    break;
                } else {
                    if (wstr1[i] != wstr2[i]) {                        
                        result = wstr1[i] > wstr2[i] ? kCFCompareGreaterThan : kCFCompareLessThan;
                        break;
                    }            
                }
            }
            else if (!IsChinese(wstr1[i]) && !IsChinese(wstr2[i])) {
                NSString* s1 = [[NSString alloc] initWithBytes:(&wstr1[i]) length:sizeof(wstr1[i]) encoding:NSUTF32LittleEndianStringEncoding];            
                //NgnLog(@"s1'%@'", s1);
                NSString* s2 = [[NSString alloc] initWithBytes:(&wstr2[i]) length:sizeof(wstr2[i]) encoding:NSUTF32LittleEndianStringEncoding];            
                //NgnLog(@"s2'%@'", s2);            
                switch ([s1 caseInsensitiveCompare: s2]) {
                    case NSOrderedAscending: // s1 < s2
                        result = kCFCompareLessThan;
                        break;
                    case NSOrderedSame:
                        result = kCFCompareEqualTo;
                        break;
                    case NSOrderedDescending: // s1 > s2
                        result = kCFCompareGreaterThan;
                        break;
                }            
                [s1 release];
                [s2 release];                
                if (result != kCFCompareEqualTo) {
                    break;    
                }            
            }
        }
    }
    
	NgnCFRelease(displayName1);
	NgnCFRelease(displayName2);
    
    return result;
}

static CFComparisonResult NgnAddressBookCompareByCompositeName(ABRecordRef person1, ABRecordRef person2, ABPersonSortOrdering ordering)
{
#if 1
    CFComparisonResult result = CompareName(person1, person2);
#else
    CFStringRef displayName1 = ABRecordCopyCompositeName(person1);
	CFStringRef displayName2 = ABRecordCopyCompositeName(person2);
	CFComparisonResult result = kCFCompareEqualTo;
	switch([(NSString*)displayName1 compare: (NSString*)displayName2]){
		case NSOrderedAscending:
			result = kCFCompareLessThan;
			break;
		case NSOrderedSame:
			result = kCFCompareEqualTo;
			break;
		case NSOrderedDescending:
			result = kCFCompareGreaterThan;
			break;
	}
    NgnCFRelease(displayName1);
	NgnCFRelease(displayName2);
#endif	
	return result;
}
#endif /* TARGET_OS_IPHONE */

@implementation NgnContactService(Private)

-(BOOL) isStarted{
	return mStarted;
}

-(void)syncLoad{
	mLoading = YES;
	[mContacts removeAllObjects];
	[mNumbers2ContacstMapper removeAllObjects];
	
#if TARGET_OS_IPHONE
    if (addressBook == nil) {
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        else
            addressBook = ABAddressBookCreate();
        	        
        __block BOOL accessGranted = NO;
        if (ABAddressBookRequestAccessWithCompletion != NULL) {
            // we're on iOS 6
            NgnLog(@"on iOS 6 or later, trying to grant access permission");
            
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            dispatch_release(sema);
        }
        else { // we're on iOS 5 or older
            NgnLog(@"on iOS 5 or older, it is OK");
            accessGranted = YES;
        }
        
        if (accessGranted) {
            NgnLog(@"we got the access right");
        }
    }

	if(addressBook){
		CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
		CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
										   kCFAllocatorDefault,
										   CFArrayGetCount(people),
										   people);
		CFArraySortValues(peopleMutable,
						  CFRangeMake(0, CFArrayGetCount(peopleMutable)),
						  (CFComparatorFunction) NgnAddressBookCompareByCompositeName,
						  (void*) ABPersonGetSortOrdering());
		
		// Create NGN contacts
		CFArrayApplyFunction(peopleMutable, CFRangeMake(0, CFArrayGetCount(peopleMutable)), NgnAddressBookCallbackForElements, self);
		
		NgnCFRelease(peopleMutable);
		NgnCFRelease(people);		
	}

#elif TARGET_OS_MAC && 0
	ABAddressBook *addressBook = [ABAddressBook sharedAddressBook];
	if(addressBook){
		NSArray *peopleArray = [addressBook people];
		if(peopleArray){
			for(ABPerson *person in peopleArray){
				NgnContact* contact = [[NgnContact alloc] initWithABPerson:person];
				if(contact){
					for(NgnPhoneNumber *phoneNumber in contact.phoneNumbers){
						if(phoneNumber.number){
							[(NSMutableDictionary*)[self numbers2ContactsMapper] setObject:contact forKey:phoneNumber.number];
						}
					}
					[(NSMutableArray*)[self contacts] addObject: contact];
					[contact release];
				}
			}
		}
	}
#endif
	
    BOOL reset = isEdit || externalChged;
    
	mLoading = NO;
    isEdit = NO;
    externalChged = NO;
    reload = NO;
	
	NgnContactEventArgs *eargs = [[NgnContactEventArgs alloc] initWithType:CONTACT_RESET_ALL];
	[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnContactEventArgs_Name object:eargs];
    [eargs release];
    
    //if(reload){
    if (reset) {
        NgnHistoryEventArgs *historyEargs = [[NgnHistoryEventArgs alloc] initWithEventType: HISTORY_EVENT_RESET]; 
        [NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnHistoryEventArgs_Name object:historyEargs];
        [historyEargs release];
        
        //notification to upload contacts
        [NgnNotificationCenter postNotificationOnMainThreadWithName:kNotificationUploadContact object:nil];
    }
}

@end

@implementation NgnContactService

-(NgnContactService*)init{
	if((self = [super init])){
		mLoaderQueue = dispatch_queue_create(kNameSpace, NULL);
		mContacts = [[NgnContactMutableArray alloc] init];
		mNumbers2ContacstMapper = [[NSMutableDictionary alloc] init];
#if TARGET_OS_IPHONE
		addressBook = nil;
#elif TARGET_OS_MAC
#endif
	}
	return self;
}

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	mStarted = YES;
	
	[self load: NO];
#if TARGET_OS_IPHONE
	ABAddressBookRegisterExternalChangeCallback(addressBook, NgnAddressBookExternalChangeCallback, self);
#elif TARGET_OS_MAC
#endif /* TARGET_OS_IPHONE */
	
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	mStarted = NO;
	
	[mContacts removeAllObjects];
#if TARGET_OS_IPHONE
	ABAddressBookUnregisterExternalChangeCallback(addressBook, NgnAddressBookExternalChangeCallback, self);
#elif TARGET_OS_MAC
#endif /* TARGET_OS_IPHONE */
	
	return YES;
}

-(void)dealloc{
	[self stop];
	if(mLoaderQueue){
		dispatch_release(mLoaderQueue), mLoaderQueue = NULL;
	}
	[mContacts release];
	[mNumbers2ContacstMapper release];
	
#if TARGET_OS_IPHONE
	NgnCFRelease(addressBook);
#elif TARGETOS_MAC
#endif
	
	[super dealloc];
}



//
// INgnContactService
//

-(void) load: (BOOL) asyn{
	if(asyn){
		dispatch_async(mLoaderQueue, ^{
			[self syncLoad];
		});
	}
	else {
		[self syncLoad];
	}
}


-(void) edited:(BOOL) editing{
    isEdit=editing;
}

-(void) unload{
	[mNumbers2ContacstMapper removeAllObjects];
	[mContacts removeAllObjects];
}

-(BOOL) isLoading{
	return mLoading;
}

-(NSArray*) contacts{
	return mContacts;
}

-(NSDictionary*) numbers2ContactsMapper{
	return mNumbers2ContacstMapper;
}

-(NSArray*) contactsWithPredicate: (NSPredicate*)predicate{
	return [mContacts filteredArrayUsingPredicate: predicate];
}

-(NgnContact*) getContactByUri: (NSString*)uri{
	return nil;
}

// FIXME: should be optimized
// * Idea 1: create dictionary with the phone number as key and NgnContact as value
// * Idea 2: Idea 1 but only fill the dictionary when this function succeed. The advantage
// of this idea is that we will only store the most often searched contacts. If the contact
// doesn't exist we shoud store 'nil' to avoid query for it again and again. 
// Do not forget to clear the dictionary when the contacts are loaded again.
-(NgnContact*) getContactByPhoneNumber: (NSString*)phoneNumber{
	if(phoneNumber){
        NSString *newNum = [phoneNumber phoneNumFormat];
		return [mNumbers2ContacstMapper objectForKey:newNum];
	}
	return nil;
}

-(BOOL) dbLoadWeiCallUserContacts:(NSMutableDictionary*)users{
	BOOL ok = YES;
	static const char *sqlStatement = "SELECT id,phonenumber,mynumber FROM weicallusers";
	sqlite3_stmt *compiledStatement = nil;
	int ret;    
    
	NgnBaseService<INgnStorageService>* storageService = [[NgnEngine sharedInstance].storageService retain];
	if(![storageService database]){
		NgnNSLog(TAG, @"Invalid database");
		ok = NO;
        // release storage service
        [storageService release];        
        return ok;
	}
    
	[users removeAllObjects];
	
    unsigned long i = 0;
	if((ret = sqlite3_prepare_v2([storageService database], sqlStatement, -1, &compiledStatement, NULL)) == SQLITE_OK) {
		while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            int id = sqlite3_column_int(compiledStatement, 0);
            NSString* userNum = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 1)];
			NSString* myNum   = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 2)];            
			
            [users setObject:userNum forKey:userNum];
            
            i++;
            //NgnNSLog(TAG, @"load %@ %@ [%ld] id %d", userNum, myNum, i, id);
		}
	}
	sqlite3_finalize(compiledStatement);
	
	// release storage service
	[storageService release];    
	return ok;
}

-(BOOL) dbAddWeiCallUserContact:(NSString*)myNum PhoneNum:(NSString*)Num{
    BOOL ok = NO;
	int ret;
	NgnBaseService<INgnStorageService>* storageService = [[NgnEngine sharedInstance].storageService retain];
	if(![storageService database]){
		NgnNSLog(TAG, @"Invalid database");
		[storageService release];
        return ok;
	}

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    {
        NSString* sqlQuire = [@"SELECT id,mynumber FROM weicallusers WHERE " stringByAppendingFormat:@"phonenumber=%@", Num];
        //[@"SELECT FROM weicallusers WHERE " stringByAppendingFormat:@"phonenumber=%@", Num];
        sqlite3_stmt *quireState = nil;
        if((ret = sqlite3_prepare_v2([storageService database], [NgnStringUtils toCString:sqlQuire], -1, &quireState, NULL)) == SQLITE_OK){
            if (sqlite3_step(quireState) == SQLITE_ROW) {
                int id = sqlite3_column_int(quireState, 0);
                NSString* myNumRec = [NgnStringUtils toNSString: (char *)sqlite3_column_text(quireState, 1)];
                if (NSOrderedSame == [myNum compare:myNumRec]) {
                    sqlite3_finalize(quireState);
                    [storageService release];
                    
                    return YES;
                } else {
                    sqlite3_finalize(quireState);
                    
                    static const char* sqlUpdateStatement = "UPDATE weicallusers SET phonenumber = ?, mynumber = ? WHERE id = ?";
                    sqlite3_stmt *quireStateStatement = nil;
                    if((ret = sqlite3_prepare_v2([storageService database], sqlUpdateStatement, -1, &quireStateStatement, NULL)) == SQLITE_OK) {
                        sqlite3_bind_text(quireStateStatement, 1, [NgnStringUtils toCString: Num], -1, SQLITE_TRANSIENT);
                        sqlite3_bind_text(quireStateStatement, 2, [NgnStringUtils toCString: myNum], -1, SQLITE_TRANSIENT);
                        sqlite3_bind_int(quireStateStatement, 3, id);
                        
                        ok = ((ret = sqlite3_step(quireStateStatement))==SQLITE_DONE);
                    }
                    
                    sqlite3_finalize(quireStateStatement);
                    [storageService release];                    
                    
                    if (ok) {
                        NgnContactEventArgs *eargs = [[NgnContactEventArgs alloc] initWithType:CONTACT_SYNC_UPDATE];
                        [NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnContactEventArgs_Name object:eargs];
                        [eargs release];
                    }
                    
                    return ok;
                }
            }
        }
        
        sqlite3_finalize(quireState);
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    static const char* sqlStatement = "INSERT INTO weicallusers (phonenumber,mynumber) VALUES(?,?)";
	sqlite3_stmt *compiledStatement;
    if(sqlStatement){
		if((ret = sqlite3_prepare_v2([storageService database], sqlStatement, -1, &compiledStatement, NULL)) == SQLITE_OK) {
            sqlite3_bind_text(compiledStatement, 1, [NgnStringUtils toCString: Num], -1, SQLITE_TRANSIENT);	
			sqlite3_bind_text(compiledStatement, 2, [NgnStringUtils toCString: myNum], -1, SQLITE_TRANSIENT);
		
			ok = ((ret = sqlite3_step(compiledStatement))==SQLITE_DONE);
		}
		sqlite3_finalize(compiledStatement);
        
        if(ok){
            int id = sqlite3_last_insert_rowid([storageService database]);
            
            NgnContactEventArgs *eargs = [[NgnContactEventArgs alloc] initWithType:CONTACT_SYNC_UPDATE];
            [NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnContactEventArgs_Name object:eargs];
            [eargs release];
         }
	}
    
	[storageService release];	
    return ok;
}

-(BOOL) dbClearWeiCallUsers {
    NSString *sqlStatement = @"delete from weicallusers";
    if([[NgnEngine sharedInstance].storageService execSQL:sqlStatement]){
        NgnContactEventArgs *eargs = [[NgnContactEventArgs alloc] initWithType:CONTACT_SYNC_UPDATE];
        [NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnContactEventArgs_Name object:eargs];
        [eargs release];
        return YES;
    }

	return NO;
}

-(BOOL) dbDeleteContactsNotMine:(NSString*)myNum{
	BOOL ok = NO;
    NSString* sqlStatement = [@"DELETE FROM weicallusers WHERE " stringByAppendingFormat:@"(mynumber<>%@)", myNum];
	sqlite3_stmt *compiledStatement = nil;
	NgnBaseService<INgnStorageService>* storageService = [[NgnEngine sharedInstance].storageService retain];
	if(![storageService database]){
		NgnNSLog(TAG, @"Invalid database");
		ok = NO;
        // release storage service
        [storageService release];        
        return ok;
	}
    
    ok = [storageService execSQL:sqlStatement];
    if (ok) {
        NgnContactEventArgs *eargs = [[NgnContactEventArgs alloc] initWithType:CONTACT_SYNC_UPDATE];
        [NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnContactEventArgs_Name object:eargs];
        [eargs release];
    }
    
	// release storage service
	[storageService release];
	return ok;
}

-(BOOL) dbIsWeiCallUser:(NSString*)Num{
    BOOL ok = NO;
    int ret = -1;
    
    NSString* tmpPhoneNum = [Num phoneNumFormat];

    NSString* sqlStatement = [@"SELECT mynumber FROM weicallusers WHERE " stringByAppendingFormat:@"phonenumber='%@'", tmpPhoneNum];
	sqlite3_stmt *compiledStatement = nil;
	NgnBaseService<INgnStorageService>* storageService = [[NgnEngine sharedInstance].storageService retain];
	if(![storageService database]){
		NgnNSLog(TAG, @"Invalid database");
		ok = NO;
        // release storage service
        [storageService release];        
        return ok;
	}
    
    if((ret = sqlite3_prepare_v2([storageService database], [NgnStringUtils toCString:sqlStatement], -1, &compiledStatement, NULL)) == SQLITE_OK){
        int r = sqlite3_step(compiledStatement);
        if (r == SQLITE_ROW) {
            ok = YES;
        }
    }
    sqlite3_finalize(compiledStatement);
    
	// release storage service
	[storageService release];
    return ok;
}

@end