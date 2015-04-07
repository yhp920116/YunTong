/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "RecentCell.h"
#import "AreaOfPhoneNumber.h"

@implementation RecentCell

@synthesize labelDisplayName;
@synthesize labelDisplayNumber;
@synthesize labelDuration;
@synthesize labelDate;
@synthesize imgViewType;

-(NSString *)reuseIdentifier{
	return kRecentCellIdentifier;
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
		labelDisplayName.text = event.remotePartyDisplayName;
        
        AreaOfPhoneNumber *areaOfPhoneNumber = [[AreaOfPhoneNumber alloc] initWithPhoneNumber:event.remoteParty];
        NSString *areaOfNumber = [areaOfPhoneNumber getAreaByPhoneNumber];
        [areaOfPhoneNumber release];
        
        if ([NgnStringUtils isNullOrEmpty:areaOfNumber])
        {
            areaOfNumber = NSLocalizedString(@"Unknown", @"Unknown");
        }
        
        //显示名称不等于号码或空
        if (![labelDisplayName.text isEqualToString:event.remoteParty])
        {
            labelDisplayNumber.text = [NSString stringWithFormat:@"%@   %@",event.remoteParty,areaOfNumber];
        }
        else
        {
            labelDisplayNumber.text = [NSString stringWithFormat:@"%@",areaOfNumber];
        }

		// status
		switch (event.status) {
			case HistoryEventStatus_Missed:
 			{
				labelDisplayName.textColor = [UIColor redColor];
                [imgViewType setImage:[UIImage imageNamed:@"recent_missed.png"]];
				break;
			}
               
			case HistoryEventStatus_Failed:
			{
				labelDisplayName.textColor = [UIColor redColor];
                [imgViewType setImage:[UIImage imageNamed:@"recent_missed.png"]];
				break;
			}
			case HistoryEventStatus_Outgoing:
			{
				labelDisplayName.textColor = [UIColor blackColor];
                [imgViewType setImage:[UIImage imageNamed:@"recent_callout.png"]];
				break;
			}
			case HistoryEventStatus_Incoming:
			{
				labelDisplayName.textColor = [UIColor blackColor];
                [imgViewType setImage:[UIImage imageNamed:@"recent_callin.png"]];
				break;
			}
			default:
			{
				labelDisplayName.textColor = [UIColor blackColor];
				break;
			}
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
        }
        else{
            if (event.calloutmode == CALL_OUT_MODE_CALL_BACK)
                str = NSLocalizedString(@"YunTong Callback", @"YunTong Callback");
            else
                str = NSLocalizedString(@"Access Failure", @"Access Failure");
            
        }
        labelDuration.text = str;
	}
}

- (void)dealloc {
	
    [labelDisplayName release];
    [labelDisplayNumber release];
    [labelDuration release];
    [labelDate release];
    [imgViewType release];
    
    [super dealloc];
}


@end
