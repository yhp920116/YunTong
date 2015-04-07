/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "RecentDetailCell.h"

@implementation RecentDetailCell
@synthesize labelDisplayNumber;
@synthesize labelDuration;
@synthesize labelDate;
@synthesize imgViewType;
@synthesize callType;

-(NSString *)reuseIdentifier{
	return kRecentDetailCellIdentifier;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

-(void)setEvent: (NgnHistoryEvent*)event{
	if(event){
        labelDisplayNumber.text = event.remoteParty;
        
		// status
		switch (event.status) {
			case HistoryEventStatus_Missed:
 			{
                [imgViewType setImage:[UIImage imageNamed:@"recent_missed.png"]];
                self.callType.textColor = [UIColor redColor];
                self.callType.text = NSLocalizedString(@"MissedR", @"MissedR");
				break;
			}
			case HistoryEventStatus_Failed:
			{
                [imgViewType setImage:[UIImage imageNamed:@"recent_missed.png"]];
                self.callType.textColor = [UIColor redColor];
                self.callType.text = NSLocalizedString(@"MissedR", @"MissedR");
				break;
			}
			case HistoryEventStatus_Outgoing:
			{
                [imgViewType setImage:[UIImage imageNamed:@"recent_callout.png"]];
                self.callType.textColor = [UIColor colorWithRed:55.0/255.0 green:161.0/255.0 blue:21.0/255.0 alpha:1.0];
                self.callType.text = NSLocalizedString(@"Call Out", @"Call Out");
                break;
			}
			case HistoryEventStatus_Incoming:
			{
                [imgViewType setImage:[UIImage imageNamed:@"recent_callin.png"]];
                self.callType.textColor = [UIColor colorWithRed:46.0/255.0 green:179.0/255.0 blue:253.0/255.0 alpha:1.0];
                self.callType.text = NSLocalizedString(@"Incoming", @"Incoming");
				break;
			}
			default:
				break;
		}
		
		// date[@"Add " stringByAppendingFormat:@"%@ to Favorites as:",self.pickedNumber.number]
        //		labelDate.text =  [[[NgnDateTimeUtils historyEventDate] stringFromDate:
        //						  [NSDate dateWithTimeIntervalSince1970: event.start]]
        //                          stringByAppendingFormat:@" %@", [[NgnDateTimeUtils historyEventTime] stringFromDate:[NSDate dateWithTimeIntervalSince1970: event.start]]];
        //显示日期
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyyMMdd"];
        
        NSDate *dialDate = [NSDate dateWithTimeIntervalSince1970: event.start];
        NSDate *today = [NSDate date];
        NSDate *yesterday = [NSDate dateWithTimeInterval:- 24 * 60 * 60 sinceDate:today];
        
        NSString *strDialDate = [dateformatter stringFromDate:dialDate];
        NSString *strToday = [dateformatter stringFromDate:today];
        NSString *strYestesday = [dateformatter stringFromDate:yesterday];
        
        NSString *displayDate = nil;
        if ([strDialDate isEqualToString:strToday])
            displayDate = NSLocalizedString(@"Today", @"Today");
        else if([strDialDate isEqualToString:strYestesday])
            displayDate = NSLocalizedString(@"Yesterday", @"Yesterday");
        else
        {
            NSString *tmp = [[NgnDateTimeUtils historyEventDate] stringFromDate:[NSDate dateWithTimeIntervalSince1970: event.start]];
            
            displayDate = [tmp substringFromIndex:5];
        }
        
        NSString *dialTime = [[NgnDateTimeUtils historyEventTime] stringFromDate:[NSDate dateWithTimeIntervalSince1970: event.start]];
        labelDate.text = [NSString stringWithFormat:@"%@ %@", displayDate, dialTime];
        
        [dateformatter release];
        
        NSInteger duration = event.end - event.start;
        NSString* str;
        if (duration > 0) {
            if ((duration > 3600)) {
                str = [NSString stringWithFormat:@"%d%@%d%@%d%@", duration/3600, NSLocalizedString(@"Hour(s)", @"Hour(s)"), (duration%3600)/60, NSLocalizedString(@"Minute(s)", @"Minute(s)"), duration%60, NSLocalizedString(@"Sec(s)", @"Sec(s)")];
            } else if(duration > 60){
                str = [NSString stringWithFormat:@"%d%@%d%@", (duration%3600)/60, NSLocalizedString(@"Minute(s)", @"Minute(s)"), duration%60, NSLocalizedString(@"Sec(s)", @"Sec(s)")];
            } else {
                str = [NSString stringWithFormat:@"%d%@",duration, NSLocalizedString(@"Sec(s)", @"Sec(s)")];
            }
            labelDuration.font = [UIFont systemFontOfSize:15.0f];
        }
        else{
            if (event.calloutmode == CALL_OUT_MODE_CALL_BACK)
                str = NSLocalizedString(@"YunTong Callback", @"YunTong Callback");
            else
                str = NSLocalizedString(@"Access Failure", @"Access Failure");
            labelDuration.font = [UIFont systemFontOfSize:14.0f];
        }
        labelDuration.text = str;
	}
}

- (void)dealloc
{
    [labelDisplayNumber release];
    [labelDuration release];
    [labelDate release];
    [imgViewType release];
    [callType release];
    
    [super dealloc];
}

@end
