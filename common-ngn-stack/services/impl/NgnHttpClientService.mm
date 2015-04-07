
/* Vincent, GZ, 2012-03-07 */

#import "INgnHttpClientService.h"
#import "NgnHttpClientService.h"

#undef TAG
#define kTAG @"NgnHttpClientService///: "
#define TAG kTAG

#define kRequestTypeGET @"GET"
#define kRequestTypePOST @"POST"

@implementation NgnHttpClientService

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	return YES;
}


//
// INgnHttpClientService
//

-(NSData*) getSynchronously:(NSString*)uri{	
	NgnNSLog(TAG, @"getSynchronously(%@)", uri);
	
	NSError *error = nil;
	NSData *data = nil;
	NSURLResponse *response = nil;
	
	// create the HTTP GET the request
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:uri]];
	[request setHTTPMethod: kRequestTypeGET];
	
	// perform the query
	data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NgnNSLog(TAG, @"getSynchronously() returned %i", [((NSHTTPURLResponse *)response) statusCode]);
	
	return data;
}

-(NSData*) postSynchronously:(NSString*) uri withContentData:(NSData*)contentData withContentType:(NSString*)contentType{
	NgnNSLog(TAG, @"postSynchronously(uri=%@,contentType=%@)", uri, contentType);
	
	NSError *error = nil;
	NSData *data = nil;
	NSURLResponse *response = nil;
	
	// create the the POST request
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:uri]];
	[request setHTTPMethod: kRequestTypePOST];
	[request setHTTPBody:contentData];
	if(contentData){
		[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	}
	
	// perform the query
	data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NgnNSLog(TAG, @"postSynchronously() returned %i", [((NSHTTPURLResponse *)response) statusCode]);
	
	return data;
}

@end
