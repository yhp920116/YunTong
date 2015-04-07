
#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

@protocol INgnHttpClientService <INgnBaseService>

-(NSData*) getSynchronously:(NSString*)uri;
-(NSData*) postSynchronously:(NSString*) uri withContentData:(NSData*)contentData withContentType:(NSString*)contentType;

@end