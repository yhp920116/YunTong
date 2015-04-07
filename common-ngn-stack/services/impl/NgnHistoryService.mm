
/* Vincent, GZ, 2012-03-07 */


#import "NgnHistoryService.h"
#import "NgnHistoryEventArgs.h"
#import "NgnNotificationCenter.h"
#import "NgnStringUtils.h"
#import "NgnHistorySMSEvent.h"

#undef TAG
#undef kHistoryTableName
#define kTAG @"NgnHistoryService///: "
#define TAG kTAG
#define kHistoryTableName "hist_event"

// NgnHistoryService (DataBase)
@interface NgnHistoryService (DataBase)
-(BOOL) databaseLoad;
-(BOOL) databaseAddEvent: (NgnHistoryEvent*)event;
@end

// NgnHistoryService (DataBase)
@implementation NgnHistoryService (DataBase)

-(BOOL) databaseLoad{
	BOOL ok = YES;
	static const char *sqlStatement = "SELECT id,seen,status,mediaType,remoteParty,start,end,content,CallMode FROM hist_event ORDER BY start DESC";
	sqlite3_stmt *compiledStatement = nil;
	NgnHistoryEvent* event = nil;
	int ret;
	
	NgnBaseService<INgnStorageService>* storageService = [[NgnEngine sharedInstance].storageService retain];
	if(![storageService database]){
		NgnNSLog(TAG, @"Invalid database");
		ok = NO;
		goto done;
	}
	
	[mEvents removeAllObjects];
	
	if((ret = sqlite3_prepare_v2([storageService database], sqlStatement, -1, &compiledStatement, NULL)) == SQLITE_OK) {
		while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
			int _id = sqlite3_column_int(compiledStatement, 0);
			BOOL seen = sqlite3_column_int(compiledStatement, 1);
			HistoryEventStatus_t status = (HistoryEventStatus_t)sqlite3_column_int(compiledStatement, 2);
			NgnMediaType_t mediaType = (NgnMediaType_t)sqlite3_column_int(compiledStatement, 3);
			NSString *remoteParty = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 4)];
			double start = sqlite3_column_double(compiledStatement, 5);
			double end = sqlite3_column_double(compiledStatement, 6);
			const void* content = sqlite3_column_blob(compiledStatement, 7);
			NSUInteger contentLength = sqlite3_column_bytes(compiledStatement, 7);
            int callmode = sqlite3_column_int(compiledStatement, 8);
            
            CALL_OUT_MODE calloutmode = CALL_OUT_MODE_NONE;
            switch (callmode) {
                case 0:
                    calloutmode = CALL_OUT_MODE_INNER;
                    break;
                case 1:
                    calloutmode = CALL_OUT_MODE_LNAD;
                    break;
                case 2:
                    calloutmode = CALL_OUT_MODE_CALL_BACK;
                    break;
                default:
                    calloutmode = CALL_OUT_MODE_NONE;
                    break;
            }
			
			switch (mediaType) {
				case MediaType_Audio:
				case MediaType_Video:
				case MediaType_AudioVideo:
					event = [(NgnHistoryEvent*)[NgnHistoryEvent createAudioVideoEventWithRemoteParty: remoteParty andVideo: isVideoType(mediaType) andCalloutMode:calloutmode] retain];
					break;
				case MediaType_SMS:
					event = [(NgnHistoryEvent*)[NgnHistoryEvent createSMSEventWithStatus: status andRemoteParty: remoteParty andContent: [NSData dataWithBytes: content length: contentLength]] retain]; 
					break;
				case MediaType_Chat:
				case MediaType_FileTransfer:
				case MediaType_Msrp:
				default:
					break;
			}
			
			// add events
			if(event){
				event.id = _id;
				event.seen = seen;
				event.status = status;
				event.start = start;
				event.end = end;
			
				[mEvents setObject: event forKey: [NSNumber numberWithLongLong: event.id]];
				[event release];
			}
		}
	}
	sqlite3_finalize(compiledStatement);
	
done:
	// release storage service
	[storageService release];
	
	// alert listeners
	NgnHistoryEventArgs *eargs = [[NgnHistoryEventArgs alloc] initWithEventType: HISTORY_EVENT_RESET]; 
	[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnHistoryEventArgs_Name object:eargs];
	[eargs release];
	
	return ok;
}

-(BOOL) databaseAddEvent: (NgnHistoryEvent*)event{
	BOOL ok = YES;
	static const char* sqlStatement = "INSERT INTO hist_event(seen,status,mediaType,remoteParty,start,end,content,CallMode) VALUES(?,?,?,?,?,?,?,?)";
	sqlite3_stmt *compiledStatement;
	int ret;
	NgnBaseService<INgnStorageService>* storageService = [[NgnEngine sharedInstance].storageService retain];
	if(![storageService database]){
		NgnNSLog(TAG, @"Invalid database");
		ok = NO;
		goto done;
	}

	if(sqlStatement){
		if((ret = sqlite3_prepare_v2([storageService database], sqlStatement, -1, &compiledStatement, NULL)) == SQLITE_OK) {
			sqlite3_bind_int(compiledStatement, 1, event.seen ? 1 : 0);
			sqlite3_bind_int(compiledStatement, 2, (int)event.status);
			sqlite3_bind_int(compiledStatement, 3, (int)event.mediaType);
			sqlite3_bind_text(compiledStatement, 4, [NgnStringUtils toCString: event.remoteParty], -1, SQLITE_TRANSIENT);
			sqlite3_bind_double(compiledStatement, 5, event.start);
			sqlite3_bind_double(compiledStatement, 6, event.end);
			if([event isKindOfClass: [NgnHistorySMSEvent class]]){
				sqlite3_bind_blob(compiledStatement, 7, [((NgnHistorySMSEvent*)event).content bytes], [((NgnHistorySMSEvent*)event).content length], SQLITE_STATIC);
			}
			else {
				sqlite3_bind_null(compiledStatement, 7);
			}
            int callmode = 3;
            
            switch (event.calloutmode) {
                case CALL_OUT_MODE_INNER:
                    callmode = 0;
                    break;
                case CALL_OUT_MODE_LNAD:
                    callmode = 1;
                    break;
                case CALL_OUT_MODE_CALL_BACK:
                    callmode = 2;
                    break;
                default:
                    callmode = 3;
                    break;
            }
            sqlite3_bind_int(compiledStatement, 8, callmode);
			ok = ((ret = sqlite3_step(compiledStatement))==SQLITE_DONE);
		}
		sqlite3_finalize(compiledStatement);
	
		if(ok){
			// update event id
			event.id = sqlite3_last_insert_rowid([storageService database]);
			[mEvents setObject: event forKey: [NSNumber numberWithLongLong: event.id]];
			
			// alert listeners
			NgnHistoryEventArgs *eargs = [[NgnHistoryEventArgs alloc] initWithEventId: event.id andEventType: HISTORY_EVENT_ITEM_ADDED];
			eargs.mediaType = event.mediaType;
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnHistoryEventArgs_Name object:eargs];
			[eargs release];
		}
	}
	else {
		ok = NO;
	}
	
done:
	[storageService release];
	return ok;
}


@end


//
// NgnHistoryService
//
@implementation NgnHistoryService

-(id)init{
	if((self = [super init])){
		mEvents = [[NgnHistoryEventMutableDictionary alloc] init];
	}
	return self;
}

-(void)dealloc{
	[mEvents release];
	
	[super dealloc];
}

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	if(![self load]){
		NgnNSLog(TAG, @"Failed to load database events");
		return NO;
	}
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	return YES;
}

//
// INgnHistoryService
//

-(BOOL) load{
	BOOL ret;
	@synchronized(self){
		ret = [self databaseLoad];
	}
	return ret;
}

-(BOOL) isLoading{
	return NO;
}

-(BOOL) addEvent: (NgnHistoryEvent*) event{
	if(!event){
		NgnNSLog(TAG,@"Null event object");
		return NO;
	}
	BOOL ret;
	@synchronized(self){
		ret = [self databaseAddEvent: event];
	}
	return ret;
}

-(BOOL) updateEvent: (NgnHistoryEvent*) event{
	BOOL ok = YES;
	static const char* sqlStatement = "UPDATE hist_event SET seen = ?, status = ?, mediaType = ?, remoteParty = ?, start = ?, end = ?, content = ? WHERE id = ?";
	sqlite3_stmt *compiledStatement;
	int ret;
	NgnBaseService<INgnStorageService>* storageService = [[NgnEngine sharedInstance].storageService retain];
	if(![storageService database]){
		NgnNSLog(TAG, @"Invalid database");
		ok = NO;
		goto done;
	}
	
	if(sqlStatement){
		if((ret = sqlite3_prepare_v2([storageService database], sqlStatement, -1, &compiledStatement, NULL)) == SQLITE_OK) {
			sqlite3_bind_int(compiledStatement, 1, event.seen ? 1 : 0);
			sqlite3_bind_int(compiledStatement, 2, (int)event.status);
			sqlite3_bind_int(compiledStatement, 3, (int)event.mediaType);
			sqlite3_bind_text(compiledStatement, 4, [NgnStringUtils toCString: event.remoteParty], -1, SQLITE_TRANSIENT);
			sqlite3_bind_double(compiledStatement, 5, event.start);
			sqlite3_bind_double(compiledStatement, 6, event.end);
			if([event isKindOfClass: [NgnHistorySMSEvent class]]){
				sqlite3_bind_blob(compiledStatement, 7, [((NgnHistorySMSEvent*)event).content bytes], [((NgnHistorySMSEvent*)event).content length], SQLITE_STATIC);
			}
			else {
				sqlite3_bind_null(compiledStatement, 7);
			}
			sqlite3_bind_int(compiledStatement, 8, event.id);
			
			ok = ((ret = sqlite3_step(compiledStatement))==SQLITE_DONE);
		}
		sqlite3_finalize(compiledStatement);
		
		if(ok){
			// alert listeners
			NgnHistoryEventArgs *eargs = [[NgnHistoryEventArgs alloc] initWithEventId: event.id andEventType: HISTORY_EVENT_ITEM_UPDATED];
			eargs.mediaType = event.mediaType;
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnHistoryEventArgs_Name object:eargs];
			[eargs release];
		}
	}
	else {
		ok = NO;
	}
	
done:
	[storageService release];
	return ok;
}

-(BOOL) deleteEvent: (NgnHistoryEvent*) event{
	if(event){
		return [self deleteEventWithId:event.id];
	}
	return NO;
}

-(BOOL) deleteEventAtIndex: (int) index{
	@synchronized(self){
		if([mEvents count] > index){
			NgnHistoryEvent* event = [[mEvents allValues] objectAtIndex:index];
			if(event){
				return [self deleteEvent:event];
			}
		}
	}
	return NO;
}

-(BOOL) deleteEventWithId: (long long) eventId{
	@synchronized(self){
		NSString* sqlStatement =  [@"delete from hist_event where " stringByAppendingFormat:@"id=%lld", eventId];
		NgnHistoryEvent* event = [mEvents objectForKey: [NSNumber numberWithLongLong: eventId]];
		if(event && [[NgnEngine sharedInstance].storageService execSQL:sqlStatement]){
			NgnHistoryEventArgs *eargs = [[NgnHistoryEventArgs alloc] initWithEventId: event.id andEventType: HISTORY_EVENT_ITEM_REMOVED];
			eargs.mediaType = event.mediaType;
			
			// clear events
			[mEvents removeObjectForKey: [NSNumber numberWithLongLong: event.id]];
			
			// alert listeners
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnHistoryEventArgs_Name object:eargs];
			[eargs release];
			
			return YES;
		}
	}
	return NO;
}

-(BOOL) deleteEvents: (NgnMediaType_t) mediaType{
	BOOL ret;
	@synchronized(self){
		ret = [self deleteEvents:mediaType withRemoteParty:nil];
	}
	return ret;
}

-(BOOL) deleteEvents: (NgnMediaType_t) mediaType withRemoteParty: (NSString*)remoteParty{
	NSString* sqlStatement =  @"delete from hist_event";
	BOOL whereAdded = NO;
	static NgnMediaType_t mediaTypes[] = {
		MediaType_Audio,
		MediaType_Video,
		MediaType_AudioVideo,
		MediaType_SMS,
		MediaType_Chat,
		MediaType_FileTransfer,
		MediaType_Msrp,
	};
	
	// Complete the request
	for(int i=0; i<sizeof(mediaTypes)/sizeof(NgnMediaType_t); i++){
		if((mediaType & mediaTypes[i])){
			if(!whereAdded){
				sqlStatement = [sqlStatement stringByAppendingFormat:@" where (mediaType=%d", (int)mediaTypes[i]];
			}
			else {
				sqlStatement = [sqlStatement stringByAppendingFormat:@" or mediaType=%d", (int)mediaTypes[i]];
			}
			whereAdded = YES;
		}
	}
	if (whereAdded) {
		sqlStatement = [sqlStatement stringByAppendingString:@")"];
	}
	
	if(remoteParty){
		sqlStatement = [sqlStatement stringByAppendingFormat:whereAdded ? @" and remoteParty='%@'" : @" where remoteParty=%@", remoteParty];
	}
	
	BOOL ok = [[NgnEngine sharedInstance].storageService execSQL:sqlStatement];
	
	if(ok){
		// remove events
		NSArray* values = [mEvents allValues];
		NSMutableArray* keysToRemove = [NSMutableArray array];
		for (NgnHistoryEvent* event in values) {
			if((event.mediaType & mediaType) && (!remoteParty || ([event.remoteParty isEqualToString:remoteParty]))){
				[keysToRemove addObject:[NSNumber numberWithLongLong: event.id]];
			}
		}
		
		// remove and alert listeners
		if([keysToRemove count] > 0){
			[mEvents removeObjectsForKeys: keysToRemove];
			
			NgnHistoryEventArgs *eargs = [[NgnHistoryEventArgs alloc] initWithEventType: HISTORY_EVENT_RESET];
			eargs.mediaType = mediaType;
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnHistoryEventArgs_Name object:eargs];
			[eargs release];
		}
	}
	
	return ok;
}

-(BOOL) deleteEventsArray: (NSArray*) events{
	NSString* sqlStatement =  @"delete from hist_event";
	BOOL whereAdded = NO;
	
	for (NgnHistoryEvent *event in events) {
		if(!whereAdded){
			sqlStatement = [sqlStatement stringByAppendingFormat:@" where id=%lld", event.id];
		}
		else {
			sqlStatement = [sqlStatement stringByAppendingFormat:@" or id=%lld", event.id];
		}
		whereAdded = YES;
	}
	
	if([[NgnEngine sharedInstance].storageService execSQL:sqlStatement]){
		NgnMediaType_t mediaType = MediaType_None;
		NSMutableArray* keysToRemove = [NSMutableArray array];
		for (NgnHistoryEvent *event in events) {
			[keysToRemove addObject:[NSNumber numberWithLongLong:event.id]];
			mediaType = (NgnMediaType_t)(mediaType | event.mediaType);
		}
		
		// remove and alert listeners
		if([keysToRemove count] > 0){
			[mEvents removeObjectsForKeys: keysToRemove];
			
			NgnHistoryEventArgs *eargs = [[NgnHistoryEventArgs alloc] initWithEventType:HISTORY_EVENT_RESET];
			eargs.mediaType = mediaType;
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnHistoryEventArgs_Name object:eargs];
			[eargs release];
		}
		return YES;
	}
	return NO;
}

-(BOOL) clear{
	@synchronized(self){
		NSString *sqlStatement = @"delete from hist_event";
		if([[NgnEngine sharedInstance].storageService execSQL:sqlStatement]){
			[mEvents removeAllObjects];
			NgnHistoryEventArgs *eargs = [[NgnHistoryEventArgs alloc] initWithEventType:HISTORY_EVENT_RESET];
			eargs.mediaType = MediaType_All;
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnHistoryEventArgs_Name object:eargs];
			[eargs release];
			return YES;
		}
	}
	return NO;
}

-(NgnHistoryEventDictionary*) events{
	return mEvents;
}

@end

