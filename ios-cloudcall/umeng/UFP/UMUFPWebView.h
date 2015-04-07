//
//  UMANWebView.h
//  UMAppNetwork
//
//  Created by liu yu on 1/9/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UMUFPWebView : UIWebView {
    NSString *_mAppkey;
    NSString *_mSlotId;     
    NSString *_mKeywords;
    
    BOOL _mAutoFill;
}

@property (nonatomic) BOOL  mAutoFill;
@property (nonatomic, copy) NSString *mKeywords; //keywords for the promoters data, promoter list will return according to this property, default is @""

/** 
 
 This method return a UMANWebView object
 
 @param  frame frame for the UMANWebView 
 @param  appkey appkey get from www.umeng.com, if you want use ufp service only, set this parameter empty
 @param  slotId slotId get from ufp.umeng.com
 
 @return a UMANWebView object
 */

- (id)initWithFrame:(CGRect)frame appKey:(NSString *)appkey slotId:(NSString *)slotId;

/** 
 
 This method start the releated url request load
 
 */

- (void)startLoadRequest;

@end

