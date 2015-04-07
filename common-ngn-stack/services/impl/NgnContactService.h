
#	import <AddressBook/AddressBook.h>

#if TARGET_OS_IPHONE
#	import <Foundation/Foundation.h>
#	import "iOSNgnConfig.h"
#elif TARGET_OS_MAC
#	import "OSXNgnConfig.h"
#endif

#import "services/impl/NgnBaseService.h"
#import "services/INgnContactService.h"
#import "services/INgnHistoryService.h"

@class NgnContact;

@interface NgnContactService : NgnBaseService <INgnContactService>{	
	dispatch_queue_t mLoaderQueue;
	BOOL mLoading;
	BOOL mStarted;
	NgnContactMutableArray* mContacts;
	NSMutableDictionary *mNumbers2ContacstMapper;
#if TARGET_OS_IPHONE
	ABAddressBookRef addressBook;
#elif TARGET_OS_MAC
#endif
    BOOL isEdit;
}

@end