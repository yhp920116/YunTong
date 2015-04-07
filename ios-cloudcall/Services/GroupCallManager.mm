//

#import "GroupCallManager.h"
#import "HttpRequest.h"
#import "CloudCall2AppDelegate.h"
#import "JSONKit.h"

@implementation GroupCallResponseStatusNotificationArgs

@synthesize success;
@synthesize errorcode;
@synthesize type;
@synthesize text;
@synthesize records;

-(GroupCallResponseStatusNotificationArgs*) initWithStatus:(BOOL)_success andErrorCode:(int)_errorcode andType:(GroupCallRequsetType)_type andText:(NSString*)_text andRecords:(NSMutableArray*)_records {
    if ((self = [super init])) {
        self->success   = _success;
        self->errorcode = _errorcode;
        self->type      = _type;
        self->text      = [_text retain];
        self->records   = [_records retain];
	}
	return self;
}

-(void)dealloc {
    [text release];
    [records release];
    
    [super dealloc];
}
@end

@implementation GroupCallMember

@synthesize name;
@synthesize number;

-(GroupCallMember*) initWithName:(NSString*)_name andNumber:(NSString*)_number {
    if ((self = [super init])) {
        self->name   = [_name retain];
        self->number = [_number retain];
	}
	return self;
}

-(void)dealloc {
    [name release];
    [number release];
    
    [super dealloc];
}

@end

@implementation GroupCallRecord

@synthesize usernumber;
@synthesize name;
@synthesize groupid;
@synthesize type;
@synthesize updatetime;
@synthesize members;

-(GroupCallRecord*) initWithUserNumber:(NSString*)_usernumber andName:(NSString*)_name andGroupId:(NSString*)_groupid andType:(ConfTypeDef)_type andUpdateTime:(NSTimeInterval)_updatetime andMembers:(NSMutableArray*)_members {
    if ((self = [super init])) {
        self->usernumber = [_usernumber retain];
        self->name = [_name retain];
        self->groupid = [_groupid retain];
        self->type = _type;
        self->updatetime = _updatetime;
        self->members = [_members retain];
	}
	return self;
}

-(void)dealloc {
    [usernumber release];
    [name release];
    [groupid release];
    [members release];
    
    [super dealloc];
}

@end

#define request_type_add    @"add"
#define request_type_update @"update"
#define request_type_delete @"delete"
#define request_type_get    @"get"

@implementation GroupCallManager

#pragma mark -
#pragma mark HttpRequest API

- (void)responseWithSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo {
	if (data == nil)
        return;

    NSString* reqType = [userInfo objectForKey:@"type"];
    if (!reqType)
        return;
    
    CCLog(@"GroupCallManager responseWithSucceeded: reqType='%@', data len=%d", reqType, [data length]);
    
    NSMutableDictionary *root = [data mutableObjectFromJSONData];
    
    if ([reqType isEqualToString:request_type_add]) {
        NSString* result   = [root objectForKey:@"result"];
        NSString* text     = [root objectForKey:@"text"];
        CCLog(@"GroupCallManager responseWithSucceeded result='%@', text='%@'", result, text);
        
        BOOL succ = [result caseInsensitiveCompare:@"success"] == NSOrderedSame;
        NSMutableArray* records = [[NSMutableArray alloc] init];
        NSString* groupid = [userInfo objectForKey:@"groupid"];
        if (groupid) {
            [records addObject:groupid];
        }
        GroupCallResponseStatusNotificationArgs* gcrsna = [[[GroupCallResponseStatusNotificationArgs alloc] initWithStatus:succ andErrorCode:0 andType:GroupCallRequsetType_Add andText:text andRecords:records] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCallResponseStatusNotification object:gcrsna];
    } else if ([reqType isEqualToString:request_type_update]) {
        NSString* result   = [root objectForKey:@"result"];
        NSString* text     = [root objectForKey:@"text"];
        CCLog(@"GroupCallManager responseWithSucceeded result='%@', text='%@'", result, text);
        
        BOOL succ = [result caseInsensitiveCompare:@"success"] == NSOrderedSame;
        GroupCallResponseStatusNotificationArgs* gcrsna = [[[GroupCallResponseStatusNotificationArgs alloc] initWithStatus:succ andErrorCode:0 andType:GroupCallRequsetType_Update andText:text andRecords:nil] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCallResponseStatusNotification object:gcrsna];
    }  else if ([reqType isEqualToString:request_type_delete]) {
        NSString* result   = [root objectForKey:@"result"];
        NSString* text     = [root objectForKey:@"text"];
        CCLog(@"GroupCallManager responseWithSucceeded result='%@', text='%@'", result, text);
        
        NSMutableArray* records = [[NSMutableArray alloc] init];
        NSString* groupid = [userInfo objectForKey:@"groupid"];
        if (groupid) {
            [records addObject:groupid];
        }        
        BOOL succ = [result caseInsensitiveCompare:@"success"] == NSOrderedSame;
        GroupCallResponseStatusNotificationArgs* gcrsna = [[[GroupCallResponseStatusNotificationArgs alloc] initWithStatus:succ andErrorCode:0 andType:GroupCallRequsetType_Delete andText:text andRecords:records] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCallResponseStatusNotification object:gcrsna];
        [records release];
    } else if ([reqType isEqualToString:request_type_get]) {        
        NSMutableArray* grouplist = [root objectForKey:@"group_list"];
        
        NSMutableArray* records = [[NSMutableArray alloc] init];
        for (NSMutableDictionary* d in grouplist) {
            NSString* usernumber    = [d objectForKey:@"user_number"];
            NSString* name          = [d objectForKey:@"group_name"];
            NSString* groupid       = [d objectForKey:@"group_id"];
            NSString* strtype       = [d objectForKey:@"group_type"];
            NSString* updatetime    = [d objectForKey:@"update_time"];
            NSMutableArray* members = [d objectForKey:@"member"];
            CCLog(@"group='%@', '%@', '%@', '%@', '%@'", usernumber, name, groupid, strtype, updatetime);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            NSDate *date = [dateFormatter dateFromString:updatetime];
            NSTimeInterval time = [date timeIntervalSince1970];
            CCLog(@"time=%f", time);
            [dateFormatter release];            
            
            ConfTypeDef type = (NSOrderedSame == [strtype caseInsensitiveCompare:@"public"]) ? Conf_Type_Public: Conf_Type_Private;
            
            NSMutableArray* marray = [[NSMutableArray alloc] init];
            for (NSMutableDictionary* r in members) {
                NSString* number   = [r objectForKey:@"phone"];
                NSString* name     = [r objectForKey:@"name"];
                CCLog(@"member='%@', '%@''", name, number);
                GroupCallMember* m = [[GroupCallMember alloc] initWithName:name andNumber:number];
                [marray addObject:m];
                [m release];
            }
            GroupCallRecord* r = [[GroupCallRecord alloc] initWithUserNumber:usernumber andName:name andGroupId:groupid andType:type andUpdateTime:time andMembers:marray];
            [records addObject:r];
            [r release];
            
            [marray release];
        }
        
        GroupCallResponseStatusNotificationArgs* gcrsna = [[[GroupCallResponseStatusNotificationArgs alloc] initWithStatus:YES andErrorCode:0 andType:GroupCallRequsetType_Get andText:@"" andRecords:records] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCallResponseStatusNotification object:gcrsna];
        
        [records release];
    }
}

- (void)responseWithFailed:(NSError *)error userInfo:(NSDictionary *)userInfo {
    NSString* reqType = [userInfo objectForKey:@"type"];
    if (!reqType)
        return;
    
    if ([reqType isEqualToString:request_type_add]) {        
        GroupCallResponseStatusNotificationArgs* gcrsna = [[[GroupCallResponseStatusNotificationArgs alloc] initWithStatus:NO andErrorCode:[error code] andType:GroupCallRequsetType_Add andText:[error localizedDescription] andRecords:nil] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCallResponseStatusNotification object:gcrsna];
    } else if ([reqType isEqualToString:request_type_update]) {        
        GroupCallResponseStatusNotificationArgs* gcrsna = [[[GroupCallResponseStatusNotificationArgs alloc] initWithStatus:NO andErrorCode:[error code] andType:GroupCallRequsetType_Update andText:[error localizedDescription] andRecords:nil] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCallResponseStatusNotification object:gcrsna];        
    }  else if ([reqType isEqualToString:request_type_delete]) {        
        GroupCallResponseStatusNotificationArgs* gcrsna = [[[GroupCallResponseStatusNotificationArgs alloc] initWithStatus:NO andErrorCode:[error code] andType:GroupCallRequsetType_Delete andText:[error localizedDescription] andRecords:nil] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCallResponseStatusNotification object:gcrsna];
    } else if ([reqType isEqualToString:request_type_get]) {
        GroupCallResponseStatusNotificationArgs* gcrsna = [[[GroupCallResponseStatusNotificationArgs alloc] initWithStatus:NO andErrorCode:[error code] andType:GroupCallRequsetType_Get andText:[error localizedDescription] andRecords:nil] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCallResponseStatusNotification object:gcrsna];
    }
}

- (void)sendRequest2Server:(NSData*)jsonData andUserInfo:(NSMutableDictionary*)userInfo{   
    [[HttpRequest instance] addRequest:kGroupCallGroupUrl andMethod:@"POST" andHeaderFields:[[HttpRequest instance] getRequestHeader] andContent:jsonData andTimeout:10
                         successTarget:self successAction:@selector(responseWithSucceeded:userInfo:)
                         failureTarget:self failureAction:@selector(responseWithFailed:userInfo:) userInfo:userInfo];
}

///////////////////////////////////////////////////////////////////
-(void)AddGroupRecords:(NSArray*)records {
    if ([records count] == 0)
        return;
    
    NSMutableArray* groupids = [[NSMutableArray alloc] init];
    NSMutableArray* context = [[NSMutableArray alloc] init];
    for (GroupCallRecord* r in records) {
        NSMutableArray* memarry = [[NSMutableArray alloc] init];        
        if (r.members) {
            for (GroupCallMember* m in r.members) {
                NSMutableDictionary* member = [NSMutableDictionary dictionaryWithObjectsAndKeys: m.name, @"name", m.number, @"phone", nil];
                [memarry addObject:member];                
            }
        }
        
        NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
        NSString* strType = (r.type == Conf_Type_Private) ? @"private" : @"public";
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:r.updatetime];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
        NSString *strCallTime = [dateFormatter stringFromDate:date];
        [dateFormatter release];        
        
        NSDictionary *condic = [NSDictionary dictionaryWithObjectsAndKeys: mynum, @"user_number", r.name, @"group_name", r.groupid, @"group_id", strType, @"group_type",
                                 strCallTime, @"update_time", memarry, @"member", nil];
        [context addObject:condic];
        
        [groupids addObject:r.groupid];
        
        [memarry release];
    }
    NSData *jsonData = nil;
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @"add", @"oper_type", context, @"context", nil];
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            NSError *error;
            jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
        }
    } else {
        jsonData = [body JSONData];
    }

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    CCLog(@"AddGroupRecord: body json data:%@", jsonString);
    [jsonString release];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:request_type_add forKey:@"type"];
    [userInfo setObject:groupids forKey:@"groupid"];
    [self sendRequest2Server:jsonData andUserInfo:userInfo];    
    [groupids release];
    [userInfo release];

    [context release];
}

-(void)UpdateGroupRecords:(NSArray*)records {
    if ([records count] == 0)
        return;
    
    NSMutableArray* context = [[NSMutableArray alloc] init];
    for (GroupCallRecord* r in records) {
        NSMutableArray *members = [[NSMutableArray alloc] init];
        for (GroupCallMember* m in r.members) {
            [members addObject:[NSDictionary dictionaryWithObjectsAndKeys:m.name,@"name",m.number,@"phone", nil]];
//            [members setObject:m.name forKey:@"name"];
//            [members setObject:m.number forKey:@"phone"];
        }
        
        NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
        NSString* strType = (r.type == Conf_Type_Private) ? @"private" : @"public";
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:r.updatetime];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
        NSString *strCallTime = [dateFormatter stringFromDate:date];
        [dateFormatter release];
        
        NSDictionary *condic = [NSDictionary dictionaryWithObjectsAndKeys:
                                mynum, @"user_number",
                                r.name, @"group_name",
                                r.groupid, @"group_id",
                                strType, @"group_type",
                                strCallTime, @"update_time",
                                members, @"member", nil];
        
        [context addObject:condic];
        
        [members release];
    }
    NSData *jsonData = nil;
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @"update", @"oper_type", context, @"context", nil];
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            NSError *error;
            jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
        }
    } else {
        jsonData = [body JSONData];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    CCLog(@"UpdateGroupRecord: body json data:%@", jsonString);
    [jsonString release];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:request_type_update forKey:@"type"];
    [self sendRequest2Server:jsonData andUserInfo:userInfo];
    [userInfo release];
    
    [context release];
}

-(void)DeleteGroupRecords:(NSArray*)records {
    if ([records count] == 0)
        return;
    
    for (GroupCallRecord* r in records) {
        [self DeleteGroupRecord:r.groupid];
    }
}

-(void)DeleteGroupRecord:(NSString*)groupid {
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSDictionary *numdic = [NSDictionary dictionaryWithObjectsAndKeys: mynum, @"user_number", groupid, @"group_id", nil];
    NSArray* context = [NSArray arrayWithObject:numdic];
    NSData *jsonData = nil;
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @"delete", @"oper_type", context, @"context", nil];
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            NSError *error;
            jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
        }
    } else {
        jsonData = [body JSONData];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    CCLog(@"DeleteGroupRecord: body json data:%@", jsonString);
    [jsonString release];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:request_type_delete forKey:@"type"];
    [userInfo setObject:groupid forKey:@"groupid"];
    [self sendRequest2Server:jsonData andUserInfo:userInfo];
    [userInfo release];
}

-(void)GetGroupRecords {    
    NSString *mynum = [[CloudCall2AppDelegate sharedInstance] getUserName];
    NSDictionary *numdic = [NSDictionary dictionaryWithObjectsAndKeys: mynum, @"user_number", nil];
    NSArray* context = [NSArray arrayWithObject:numdic];    
    NSData *jsonData = nil;
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @"query", @"oper_type", context, @"context", nil];
    if (SystemVersion >= 5.0) {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            NSError *error;
            jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
        }
    } else {
        jsonData = [body JSONData];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    CCLog(@"GetGroupRecords: body json data:%@", jsonString);
    [jsonString release];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:request_type_get forKey:@"type"];
    [self sendRequest2Server:jsonData andUserInfo:userInfo];
    [userInfo release];
}

@end
