//
//  UMUFPManager.h
//  UFP
//
//  Created by liu yu on 2/16/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMUFPHandleViewDelegate;

typedef enum {
    ContentTypeApp = 0, //app list
    ContentTypeWap,     //wap
    ContentTypeDefault = ContentTypeApp,
} ContentType;

typedef enum {
    OrientationTypePortrait  = 0, 
    OrientationTypeLandscape,     
    OrientationTypeAll,
    OrientationTypeDefault = OrientationTypeAll,
} OrientationType;

@class UMImageView;

@interface UMUFPHandleView : UIView {
    
@private
	UMImageView* _mImageView;
    NSString *_mAppkey;
    NSString *_mSlotId;
    NSString *_mKeywords;
    NSString *_mSessionId;
    NSArray  *_mPromoterDatas;
    
    BOOL _mAutoFill;
    ContentType _mContentType;

    UIViewController *_mCurrentViewController;
    id<UMUFPHandleViewDelegate> _delegate;
}

@property (nonatomic) BOOL  mAutoFill;
@property (nonatomic, copy) NSString *mKeywords; 
@property (nonatomic) ContentType mContentType;
@property (nonatomic) OrientationType mOrientationType;
@property (nonatomic, assign) id<UMUFPHandleViewDelegate> delegate; //delegate for banner view

/** 
 
 This method create and return a UMUFPHandleView object
 
 @param  frame frame for the UMUFPHandleView 
 @param  appkey appkey get from www.umeng.com
 @param  slotId slotId get from ufp.umeng.com
 @param  controller view controller releated to the view that the handle view added into
 
 @return a UMUFPHandleView object
 
*/

- (id)initWithFrame:(CGRect)frame appKey:(NSString *)appkey slotId:(NSString *)slotId currentViewController:(UIViewController *)controller;

/** 
 
 This method start the promoter data load in background, promoter data will be load until this method called
 
 */

- (void)requestPromoterDataInBackground;

@end

@protocol UMUFPHandleViewDelegate <NSObject>

@optional

- (void)UMUFPHandleView:(UMUFPHandleView *)handleView didLoadDataFinish:(NSInteger)promotersAmount; 
- (void)UMUFPHandleView:(UMUFPHandleView *)handleView didLoadDataFailWithError:(NSError *)error; 
- (void)UMUFPHandleView:(UMUFPHandleView *)handleView didClickPromoterForUrl:(NSURL *)url; 

@end
