
#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

@protocol INgnLogService <INgnBaseService>

-(BOOL) addLog:(NSString*)log;
-(void) Log:(NSString *)format, ...;
-(NSString*) getCompressdLogFile;

@end