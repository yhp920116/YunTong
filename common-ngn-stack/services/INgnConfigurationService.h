
#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

@protocol INgnConfigurationService <INgnBaseService>
-(NSDictionary*) getDefaults;
-(void)synchronize;
-(NSString*)getStringWithKey: (NSString*)key;
-(int)getIntWithKey: (NSString*)key;
-(float)getFloatWithKey: (NSString*)key;
-(BOOL)getBoolWithKey: (NSString*)key;
-(double)getDoubleWithKey: (NSString*)key;
-(void)setStringWithKey: (NSString*)key andValue:(NSString*)value;
-(void)setIntWithKey: (NSString*)key andValue:(int)value;
-(void)setFloatWithKey: (NSString*)key andValue:(float)value;
-(void)setBoolWithKey: (NSString*)key andValue:(BOOL)value;
-(void)setDoubleWithKey: (NSString*)key andValue:(double)value;
@end
