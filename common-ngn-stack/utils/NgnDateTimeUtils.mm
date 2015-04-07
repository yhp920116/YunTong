
#import "NgnDateTimeUtils.h"


@implementation NgnDateTimeUtils


+(NSDateFormatter*) historyEventDuration{
	static NSDateFormatter* sHistoryEventDuration = nil;
	if(!sHistoryEventDuration){
		sHistoryEventDuration = [[NSDateFormatter alloc] init];
        [sHistoryEventDuration setDateFormat:@"mm:ss"];
	}
	return sHistoryEventDuration;
}

+(NSDateFormatter*) historyEventDate{
	static NSDateFormatter* sHistoryEventDate = nil;
	if(!sHistoryEventDate){
		sHistoryEventDate = [[NSDateFormatter alloc] init];
        [sHistoryEventDate setTimeStyle:NSDateFormatterNoStyle];
        [sHistoryEventDate setDateStyle:NSDateFormatterLongStyle];
	}
	return sHistoryEventDate;
}

+(NSDateFormatter*) chatDate{
	static NSDateFormatter* sChatDate = nil;
	if(!sChatDate){
		sChatDate = [[NSDateFormatter alloc] init];
        [sChatDate setDateFormat:NSLocalizedString(@"Message Date Format", @"Message Date Format")];
	}
	return sChatDate;
}

+(NSDateFormatter*) historyEventTime
{
	static NSDateFormatter* sTime = nil;
	if(!sTime){
		sTime = [[NSDateFormatter alloc] init];
        [sTime setDateFormat:@"HH:mm"];
	}
	return sTime;
}

@end
