/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import "BaloonCell.h"
#import <QuartzCore/QuartzCore.h> /* cornerRadius... */

#import "CloudCall2Constants.h"
#import "CloudCall2AppDelegate.h"
#import "WebBrowser.h"

#undef kCornerRadius
#undef kBorderWidth
#define kCornerRadius 8
#define kBorderWidth 0.8f

@interface BaloonCell(Colors)
+(CGColorRef)colorOutgoingBorder;
+(NSArray*)colorsOutgoing;
+(CGColorRef)colorIncomingBorder;
+(NSArray*)colorsIncoming;
@end

@implementation BaloonCell(Colors)

+(NSArray*) colorsOutgoing{
	static NSArray* sColorsOutgoing = nil;
	if(sColorsOutgoing == nil){
		sColorsOutgoing = [[NSArray arrayWithObjects:
						   (id)[[NgnStringUtils colorFromRGBValue: kColorBaloonOutTop] CGColor], 
						   (id)[[NgnStringUtils colorFromRGBValue: kColorBaloonOutMiddle] CGColor], 
						   (id)[[NgnStringUtils colorFromRGBValue: kColorBaloonOutBottom] CGColor],
						   nil] retain];
	}
	return sColorsOutgoing;
}

+(CGColorRef)colorOutgoingBorder{
	static CGColorRef sColorOutgoingBorder = nil;
	if(sColorOutgoingBorder == nil){
		sColorOutgoingBorder = CGColorRetain([[NgnStringUtils colorFromRGBValue: kColorBaloonOutBorder] CGColor]);
	}
	return sColorOutgoingBorder;
}

+(NSArray*)colorsIncoming{
	static NSArray* sColorsIncoming = nil;
	if(sColorsIncoming == nil){
		sColorsIncoming = [[NSArray arrayWithObjects:
							(id)[[NgnStringUtils colorFromRGBValue: kColorBaloonInTop] CGColor], 
							(id)[[NgnStringUtils colorFromRGBValue: kColorBaloonInMiddle] CGColor], 
							(id)[[NgnStringUtils colorFromRGBValue: kColorBaloonInBottom] CGColor],
							nil] retain];
	}
	return sColorsIncoming;
}

+(CGColorRef)colorIncomingBorder{
	static CGColorRef sColorIncomingBorder = nil;
	if(sColorIncomingBorder == nil){
		sColorIncomingBorder = CGColorRetain([[NgnStringUtils colorFromRGBValue: kColorBaloonInBorder] CGColor]);
	}
	return sColorIncomingBorder;
}

@end

@implementation BaloonCell

@synthesize imgViewAvatar;
@synthesize labelContent;
@synthesize labelDate;
@synthesize matches;

-(NSString *)reuseIdentifier{
	return kBaloonCellIdentifier;
}

- (id)initWithCoder:(NSCoder *)decoder{
	self = [super initWithCoder:decoder];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.clipsToBounds = YES;
        self.labelContent = [[[PPLabel alloc] initWithFrame:CGRectMake(14, 25, 235, 46)] autorelease];
        labelContent.delegate = self;
        labelContent.backgroundColor = [UIColor clearColor];
//        labelContent.layer.borderWidth =1;
//        labelContent.layer.borderColor = [[UIColor blueColor] CGColor];
        labelContent.font = [UIFont fontWithName:@"Arial" size:15];
		self.labelContent.lineBreakMode = UILineBreakModeTailTruncation;
		self.labelContent.numberOfLines = 0;
        [self addSubview:labelContent];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.clipsToBounds = YES;
		self.labelContent.lineBreakMode = UILineBreakModeWordWrap;
		self.labelContent.numberOfLines = 0;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)layoutSubviews{
    [super layoutSubviews];
    float indentPoints = self.indentationLevel * self.indentationWidth;
    self.contentView.frame = CGRectMake(indentPoints,
										self.contentView.frame.origin.y,
										self.contentView.frame.size.width - indentPoints, 
										self.contentView.frame.size.height);
}

#define kCellTopHeight		20.f
#define kCellBottomHeight	20.f
#define kCellDateHeight		20.f
#define kCellContentFontSize 17.f

+(CGFloat)getHeight:(NgnHistorySMSEvent*)event constrainedWidth:(CGFloat)width{
	if(event){
		NSString* content = event.contentAsString ? event.contentAsString : @"";
		CGSize constraintSize;
		constraintSize.width = width;
		constraintSize.height = MAXFLOAT;
		CGSize contentSize = [content sizeWithFont:[UIFont fontWithName:@"Arial" size:kCellContentFontSize] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		return kCellTopHeight + kCellBottomHeight + kCellDateHeight + contentSize.height;
	}
	return 0.0;
}

+(CGFloat)getSysNotifyHeight:(NgnSystemNotification*)notify constrainedWidth:(CGFloat)width{
	if(notify){
		NSString* content = [self addLineBreakBeforeHttp:notify.content];
		CGSize constraintSize;
		constraintSize.width = width;
		constraintSize.height = MAXFLOAT;
		CGSize contentSize = [content sizeWithFont:[UIFont fontWithName:@"Arial" size:kCellContentFontSize] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		return kCellTopHeight + kCellBottomHeight + kCellDateHeight + contentSize.height+25;
	}
	return 0.0;
}

+(CGFloat)getDefaultSysNotifyHeight:(NgnSystemNotification*)notify constrainedWidth:(CGFloat)width{
	if(notify){
		NSString* content =[BaloonCell addLineBreakBeforeHttp:notify.content];
		CGSize constraintSize;
		constraintSize.width = width;
		constraintSize.height = 167.0f;//MAXFLOAT;
		CGSize contentSize = [content sizeWithFont:[UIFont fontWithName:@"Arial" size:kCellContentFontSize] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		return kCellTopHeight + kCellBottomHeight + kCellDateHeight + contentSize.height + 150;
	}
	return 0.0;
}

#define kBaloonOutSideMargin 20.f
#define kBaloonInSideMargin 4.f
#define kContentMarginLeft 10.f
#define kContentMarginRight 10.f
#define kCellEditMargin		 20.f

-(void)setEvent:(NgnHistorySMSEvent*)event forTableView:(UITableView*)tableView{
	if(event){
		self.labelContent.text = event.contentAsString ? event.contentAsString : @"";
		
		CGSize constraintSize;
		constraintSize.width = tableView.frame.size.width - kBaloonOutSideMargin /* right */ - (kBaloonOutSideMargin * 4) /* left */;
		constraintSize.height = MAXFLOAT;
		CGSize contentSize = [self.labelContent.text sizeWithFont:self.labelContent.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		contentSize.width += kContentMarginLeft + kContentMarginRight;
		
        NSError *error = NULL;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        
        self.matches = [detector matchesInString:self.labelContent.text options:0 range:NSMakeRange(0, self.labelContent.text.length)];
        
        [self highlightLinksWithIndex:NSNotFound];
        
		UIImageView* imageView = nil;
		
		self.labelDate.text = [[NgnDateTimeUtils chatDate] stringFromDate:[NSDate dateWithTimeIntervalSince1970: event.start]];

		switch (event.status) {
			case HistoryEventStatus_Outgoing:
			case HistoryEventStatus_Failed:
			case HistoryEventStatus_Missed:
			{
				self.labelContent.frame = CGRectMake(tableView.frame.size.width - kBaloonOutSideMargin - contentSize.width - (tableView.editing ? + kCellEditMargin : 0.f), 
													 self.labelContent.frame.origin.y, 
													 contentSize.width, 
													 contentSize.height);
				imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:kImageBaloonIn] stretchableImageWithLeftCapWidth:21 topCapHeight:14]];
				break;
			}            
			
			case HistoryEventStatus_Incoming:
			default:
            {
				self.labelContent.frame = CGRectMake(kBaloonOutSideMargin + (tableView.editing ? + kCellEditMargin : 0.f), 
													 self.labelContent.frame.origin.y, 
													 contentSize.width, 
													 contentSize.height);
				imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:kImageBaloonOut] stretchableImageWithLeftCapWidth:21 topCapHeight:14]];
				break;
			}
			
		}// end switch()
		
		imageView.frame = CGRectMake(self.labelContent.frame.origin.x - kBaloonInSideMargin, 
									 self.labelContent.frame.origin.y - kBaloonInSideMargin, 
									 self.labelContent.frame.size.width + kBaloonInSideMargin, 
									 self.labelContent.frame.size.height + 3 * kBaloonInSideMargin);
		[self insertSubview:imageView atIndex:0];
		[imageView release];
	}
}

-(void)setSysNotify:(NgnSystemNotification*)notify andImage:(UIImage*)img forTableView:(UITableView*)tableView{
	if(notify){
        self.labelContent.text = [BaloonCell addLineBreakBeforeHttp:notify.content];
        
        [self.labelContent setTextAlignment:NSTextAlignmentLeft];
        
        self.imgViewAvatar.image = img;
		
		CGSize constraintSize;
		constraintSize.width = tableView.frame.size.width - kBaloonOutSideMargin /* right */ - (kBaloonOutSideMargin * 4) /* left */-30;
		constraintSize.height = MAXFLOAT;
		CGSize contentSize = [self.labelContent.text sizeWithFont:self.labelContent.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		contentSize.width += kContentMarginLeft + kContentMarginRight;
		
                
		UIImageView* imageView = nil;
        
        NSDate *receiveDate = [NSDate dateWithTimeIntervalSince1970: notify.receivetime];
        //NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setTimeZone:gmt];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        self.labelDate.text = [dateFormatter stringFromDate:receiveDate];
        [dateFormatter release];
//        float i = self.labelContent.frame.origin.y;
        self.labelContent.frame = CGRectMake(kBaloonOutSideMargin + (tableView.editing ? + kCellEditMargin : 0.f)+70,
                                             self.labelContent.frame.origin.y, 
                                             contentSize.width, 
                                             contentSize.height);
        imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:kImageBaloonOut] stretchableImageWithLeftCapWidth:21 topCapHeight:17]];
		imageView.frame = CGRectMake(self.labelContent.frame.origin.x - 3*kBaloonInSideMargin,
									 self.labelContent.frame.origin.y - kBaloonInSideMargin, 
									 self.labelContent.frame.size.width + 4*kBaloonInSideMargin,
									 self.labelContent.frame.size.height + 2 * kBaloonInSideMargin);
		[self insertSubview:imageView atIndex:0];
        
//        CGRect rect = self.imgViewAvatar.frame;        
//        CGFloat y = imageView.frame.origin.y + imageView.frame.size.height - rect.size.height - 2;
//        if (y > rect.origin.y)
//            self.imgViewAvatar.frame = CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
		[imageView release];
        
        //url蓝色高亮,可点击
        NSError *error = NULL;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        
        self.matches = [detector matchesInString:self.labelContent.text options:0 range:NSMakeRange(0, self.labelContent.text.length)];
        
        [self highlightLinksWithIndex:NSNotFound];
	}
}

+ (NSString *)addLineBreakBeforeHttp:(NSString *)str
{
    if (!str)
        return @"";
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    str = [tempStr stringByReplacingOccurrencesOfString:@"http://" withString:@"\nhttp://"];
    return str;
}

- (void)dealloc {
    [labelContent release];
    [labelDate release];
    [matches release];
    
    [super dealloc];
}

#pragma mark -

- (void)label:(PPLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex
{
    [self highlightLinksWithIndex:charIndex];
}

- (void)label:(PPLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
}

- (void)label:(PPLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:NSNotFound];
    
    for (NSTextCheckingResult *match in self.matches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            CCLog(@"charIndex=%d",charIndex);
            if ([self isIndex:charIndex inRange:matchRange]) {
                
                [self OpenWebBrowser:match.URL];
                break;
            }
        }
    }
    
}

- (void)OpenWebBrowser:(NSURL *)url
{
    WebBrowser *webBrowser = [[WebBrowser alloc] initWithUrl:url];
    webBrowser.mode = TSMiniWebBrowserModeModal;
    
    webBrowser.barStyle = UIStatusBarStyleDefault;
    webBrowser.hidesBottomBarWhenPushed = YES;
    [[CloudCall2AppDelegate sharedInstance].tabBarController presentModalViewController:webBrowser animated:YES];
    
    [webBrowser release];
}

- (void)label:(PPLabel *)label didCancelTouch:(UITouch *)touch {
    
    [self highlightLinksWithIndex:NSNotFound];
}

#pragma mark -

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    if (SystemVersion < 6)
    {
        return;
    }
    
    NSMutableAttributedString* attributedString = [self.labelContent.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.matches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    self.labelContent.attributedText = attributedString;
    [attributedString release];
}

@end
