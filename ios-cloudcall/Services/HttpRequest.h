//

#import <UIKit/UIKit.h>
#import "UrlHeader.h"
#import "JSONKit.h"
#import "ASIFormDataRequest.h"

@interface httpEncrptRequest : ASIFormDataRequest <ASIHTTPRequestDelegate>

@property (nonatomic, assign) SEL successSelector;
@property (nonatomic, assign) SEL failureSelector;
@property (nonatomic, assign) NSObject *completionDelegate;

@end


@interface HttpRequest : NSObject {
    int activeRequestsCount;
    int concurrentRequestsLimit;
    // NSValue * with NSURLConnection * -> AsyncNetRequest *
    NSMutableDictionary *requests;
    NSMutableArray *queue; // NSURLConnection *
    
}

@property (nonatomic, assign) int concurrentRequestsLimit;
@property (nonatomic, retain) NSMutableArray *requestArrs;

+ (HttpRequest *)instance;

- (id)init;
- (void)startRequest:(NSURLConnection *)con;
- (void)stopRequest:(NSURLConnection *)con;
- (void)queueRequest:(NSURLConnection *)con;
- (NSURLConnection *)dequeueRequest;
- (void)connectionEnded;
- (NSMutableArray *)getRequestHeader;
- (NSMutableDictionary *)getRequestHeaderWithEncrypt;
- (void)clearDelegatesAndCancel;

#pragma mark Public
- (NSData *)sendRequestSync:(NSString *)url andMethod:(NSString *)method andHeaderFields:(NSMutableArray *)headerFields andContent:(NSData*)content andTimeout:(int)seconds;

- (NSURLConnection *)addRequest:(NSString *)url andMethod:(NSString*)method andHeaderFields:(NSMutableArray*)headerFields andContent:(NSData*)content andTimeout:(int)seconds
                  successTarget:(id)successTarget successAction:(SEL)successAction
                  failureTarget:(id)failureTarget failureAction:(SEL)failureAction
                       userInfo:(NSDictionary *)userInfo;

- (NSData *)sendRequestSyncWithEncrypt:(NSString *)url andMethod:(NSString *)method andContent:(NSMutableDictionary*)content andTimeout:(int)seconds andTarget:(id)target andSuccessSelector:(SEL)successSel andFailureSelector:(SEL)failureSel;;

- (void)addRequestWithEncrypt:(NSString *)url andMethod:(NSString*)method andContent:(NSMutableDictionary*)content andTimeout:(int)seconds
                     delegate:(id)_delegate successAction:(SEL)successAction failureAction:(SEL)failureAction
                     userInfo:(NSDictionary *)userInfo;

- (void)cancelRequest:(NSURLConnection *)con;
- (void)cancelAllRequests;
@end