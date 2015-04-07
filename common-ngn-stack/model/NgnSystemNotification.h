
#if TARGET_OS_IPHONE
#	import <Foundation/Foundation.h>
#elif TARGET_OS_MAC
#endif

#import "media/NgnMediaType.h"
#import "model/NgnContact.h"

@interface NgnSystemNotification : NSObject {
	long long myid;
    NSString* mynumber;
	NSString *content;
	NSTimeInterval receivetime;
    BOOL read;
    
@private
	// to be used for any purpose (e.g. category)
	id opaque;
}

-(NgnSystemNotification*) initWithId: (long long)id andMyNumber:(NSString*)mynumber andContent: (NSString*)content andReceiveTime: (double)receivetime andRead: (BOOL)read;
-(NgnSystemNotification*) initWithContent: (NSString*)content andMyNumber:(NSString*)mynumber andReceiveTime: (double)receivetime andRead: (BOOL)read;
-(NSComparisonResult) compareSysNotificationByReceiveTime: (NgnSystemNotification *)otherNotify;

@property(readonly) long long myid;
@property(readonly) NSString *mynumber;
@property(readonly) NSString *content;
@property(readonly) double receivetime;
@property(readwrite) BOOL read;

@property(readwrite, retain, nonatomic) id opaque;

@end