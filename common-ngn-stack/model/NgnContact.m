

#import "NgnContact.h"
#import "../utils/pinyin.h"
#import "../../ios-cloudcall/Services/AreaOfPhoneNumber.h"

#define NgnRelease(x) if(x){ CFRelease(x),x=NULL; }

@implementation NgnContact

@synthesize myid;
@synthesize displayName;
@synthesize firstName;
@synthesize lastName;
@synthesize phoneNumbers;
@synthesize picture;
@synthesize cIndex;
@synthesize abDisplayName;
@synthesize opaque;
@synthesize displayArea;
@synthesize displayMsg;

@synthesize displayNameRange;
@synthesize displayMsgRange;
@synthesize lettersCount;

#if TARGET_OS_IPHONE

-(NgnContact*)initWithDisplayName:(NSString*) dispname andPicture:(NSData *)_picture
{
	if ((self = [super init])){
        self->displayName = [[NSString alloc] initWithString:dispname];
        self->cIndex = [[NSString alloc] initWithString:@" "];
        self->picture = [_picture retain];
    }
    return self;
}

- (NgnContact*)initWithDisplayName:(NSString*)_displayName andFirstName:(NSString *)_firstName andLastName:(NSString *)_lastName andPhoneNumbers:(NSMutableArray *)_phoneNumbers andPicture:(NSData *)_picture  andDisplayMsg:(NSString *)_displayMsg andDisplayMsgRange:(NSRange)_displayMsgRange
{
	if ((self = [super init])){
        self->displayName = [_displayName retain];
        self->firstName = [_firstName retain];
        self->lastName = [_lastName retain];
        self->phoneNumbers = [_phoneNumbers retain];
        self->picture = [_picture retain];
        self->displayMsg = [_displayMsg retain];
        self->displayMsgRange = _displayMsgRange;
    }
    return self;
}

-(NgnContact*)initWithABRecordRef: (const ABRecordRef) record
{
	if((self = [super init]) && record){
		self->phoneNumbers = [[NSMutableArray alloc] init];
		
		self->myid = ABRecordGetRecordID(record);
		self->displayName = (NSString *)ABRecordCopyCompositeName(record);
		self->firstName = (NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
		self->lastName = (NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
		if(ABPersonHasImageData(record)){
			self->picture = (NSData*)ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail);
		}
        
        int len = [self->displayName length];
        if (len) {
            wchar_t *wstr = (wchar_t *)[self->displayName cStringUsingEncoding:NSUTF32StringEncoding];
            if (wstr) {
                //NgnLog(@"%s", wstr);
                NSMutableString *abdisp = nil;
                for (int i=0; i<len; i++) {                    
                    if (IsChinese(wstr[i])) {
                        const char* pinyins = GetPinyinsByUnicode(wstr[i]);
                        if (pinyins) {
                            if (abdisp) {
                                [abdisp appendFormat:@" %s", pinyins];
                            } else {
                                abdisp = [[NSMutableString alloc] initWithFormat:@"%s", pinyins];
                            }
                            
                            if (i == 0) {                                
                                self->cIndex = [[NSString alloc] initWithFormat:@"%c", Conver2Uppercase(pinyins[0])];
                            }
                        }
                    } else {
                        NSString* str = [[NSString alloc] initWithBytes:(&wstr[i]) length:sizeof(wstr[i]) encoding:NSUTF32LittleEndianStringEncoding];
                        
                        if (abdisp) {
                            [abdisp appendString: str?str:@""];
                        } else {
                            abdisp = [[NSMutableString alloc] initWithString: str];
                        }
                        
                        NSString* strtmp = [str uppercaseString];
                        if (i == 0) {                            
                            if (IsAlphabet(wstr[i])) {                            
                                self->cIndex = [[NSString alloc] initWithFormat:@"%@", [strtmp substringToIndex: 1]];
                            } else if (!IsChinese(wstr[i]) && !IsAlphabet(wstr[i])) {
                                self->cIndex = [[NSString alloc] initWithString:@"#"];
                            }
                        }
                        [str release];
                    }
                }
                if (abdisp) {
                    self->abDisplayName = abdisp;
                }
            }
        } else {
            self->displayName = [[NSString alloc] initWithString: NSLocalizedString(@"No Name", @"No Name")];
            self->cIndex = [[NSString alloc] initWithString:@"#"];
        }
		// kABPersonModificationDateProperty
		
		//
		//	Phone numbers
		//
		ABPropertyID properties[2] = { kABPersonPhoneProperty, kABPersonEmailProperty };
#define kABPersonPhonePropertyIndex 0
#define kABPersonEmailPropertyIndex 1
		for(int k=0; k<sizeof(properties)/sizeof(ABPropertyID); k++){
			CFStringRef phoneNumber, phoneNumberLabel, phoneNumberLabelValue;
			NgnPhoneNumber* ngnPhoneNumber;
			ABMutableMultiValueRef multi = ABRecordCopyValue(record, properties[k]);
			for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
				phoneNumberLabel = ABMultiValueCopyLabelAtIndex(multi, i);
				phoneNumberLabelValue = ABAddressBookCopyLocalizedLabel(phoneNumberLabel);
				phoneNumber      = ABMultiValueCopyValueAtIndex(multi, i);
			
				ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber:(NSString*)phoneNumber 
														 andDescription:(NSString*)phoneNumberLabelValue
														 andType:(k==kABPersonEmailPropertyIndex) ? NgnPhoneNumberType_Email : NgnPhoneNumberType_Number];
				[self->phoneNumbers addObject: ngnPhoneNumber];
                
                ////////////////////////////////////////////////////////////////////////////////
#if 0
                //NSLog(@"phoneNumberLabelValue: %@", phoneNumberLabel);
                NSString* pnLabel = (NSString*)phoneNumberLabel;
                //[pnLabel rangeOfString:@"mobile" options:NSCaseInsensitiveSearch];
                if (!(self->displayArea) &&  k==kABPersonPhonePropertyIndex
                    && pnLabel && [pnLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]
                    && ngnPhoneNumber.number && [ngnPhoneNumber.number length] >=7)
                {
                    AreaOfPhoneNumber *areaOfPhoneNumber = [[AreaOfPhoneNumber alloc] initWithPhoneNumber:ngnPhoneNumber.number];
                    self->displayArea = [areaOfPhoneNumber getAreaByPhoneNumber];
                    [areaOfPhoneNumber release];
                } 
#else
                if (self->displayArea)
                    [self->displayArea release];
#endif
                ////////////////////////////////////////////////////////////////////////////////
			
				[ngnPhoneNumber release];
				NgnRelease(phoneNumberLabelValue);
				NgnRelease(phoneNumberLabel);
				NgnRelease(phoneNumber);
			}
			NgnRelease(multi);        
		}        
	}
	return self;
}

-(void)InitDisplayAreaInfo {
    if (displayArea || [displayArea length]) 
        return;
    
    NSString *tmpDisplayArea = @"";
    CFStringRef phoneNumberLabelValue = ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel);
    for (NgnPhoneNumber*phoneNumber in phoneNumbers) {
        if (phoneNumber.number && [phoneNumber.description isEqualToString:(NSString *)phoneNumberLabelValue])
        {
            AreaOfPhoneNumber *areaOfPhoneNumber = [[AreaOfPhoneNumber alloc] initWithPhoneNumber:phoneNumber.number];
            displayArea = [[NSString alloc] initWithString:[areaOfPhoneNumber getAreaByPhoneNumber]];
            [areaOfPhoneNumber release];
            
            break;
        }
        else if(phoneNumber.number && !tmpDisplayArea)
        {
            AreaOfPhoneNumber *areaOfPhoneNumber = [[AreaOfPhoneNumber alloc] initWithPhoneNumber:phoneNumber.number];
            tmpDisplayArea = [[NSString alloc] initWithString:[areaOfPhoneNumber getAreaByPhoneNumber]];
            [areaOfPhoneNumber release];
        }
    }

    if (!displayArea) {
        displayArea = tmpDisplayArea;
    }
    
    NgnRelease(phoneNumberLabelValue);
}

#elif TARGET_OS_MAC

-(NgnContact*)initWithABPerson:(const ABPerson*)person
{
	if((self = [super init]) && person){
		self->phoneNumbers = [[NSMutableArray alloc] init];
		self->firstName = [[person valueForProperty:kABFirstNameProperty] retain];
		self->lastName = [[person valueForProperty:kABLastNameProperty] retain];
	}
	return self;
}

#endif

-(NgnPhoneNumber*)getPhoneNumberWithPredicate:(NSPredicate*)predicate
{
	@synchronized(self.phoneNumbers){
		for (NgnPhoneNumber*phoneNumber in self.phoneNumbers) {
			if([predicate evaluateWithObject: phoneNumber]){
				return phoneNumber;
			}
		}
	}
	return nil;
}

-(void)dealloc
{
#if TARGET_OS_IPHONE
	
#endif /* TARGET_OS_IPHONE */

#if TARGET_OS_MAC
	
#endif /* TARGET_OS_IPHONE */
	
    [self->displayArea release];
	[self->displayName release];
	[self->firstName release];
	[self->lastName release];
	[self->picture release];
    [self->cIndex release];
    [self->abDisplayName release];
	
	[self->phoneNumbers release];
	
	[self->opaque release];
    
    if (self->displayMsg) {
        [self->displayMsg release];
    }
    
	[super dealloc];
}

@end


