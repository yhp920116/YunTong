//
//  AFKReviewTroller.h
//  AFKReviewTroller
//
//  Created by Marco Tabini on 11-02-06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequest.h"
#import "CloudCall2AppDelegate.h"

#define kCloudCallRunCount @"CloudCallRunCount"
#define kCloudCallAppID @"CloudCallAppID"
#define kCloudCallAppriseLastDate @"CloudCallAppriseLastDate"
#define kCloudCallVersion @"kCloudCallVersion"

@interface AFKReviewTroller : NSObject <UIAlertViewDelegate> {
    
    int numberOfExecutions;
    
}


+ (int) numberOfExecutions;
+ (void)sendPraiseDataToServer;
+ (void)postAwardPraiseDataToServer:(NSString*)strUrl andData:(NSData *)jsonData;
+ (NSMutableArray *)getRequestHeader;
+ (void)postAwardPraiseDataToServerSucceeded:(NSData *)data userInfo:(NSDictionary *)userInfo;
+ (void)postAwardPraiseDataToServerFailed:(NSError *)error userInfo:(NSDictionary *)userInfo;
- (id) initWithNumberOfExecutions:(int) executionCount;


@end
