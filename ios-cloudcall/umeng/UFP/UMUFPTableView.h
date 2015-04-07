//
//  UMANTableView.h
//  UMAppNetwork
//
//  Created by liu yu on 12/17/11.
//  Copyright (c) 2011 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMUFPTableViewDataLoadDelegate;

@interface UMUFPTableView : UITableView {
    
    id<UMUFPTableViewDataLoadDelegate> _dataLoadDelegate;
    NSString *_mKeywords;
    NSString *_mSessionId;
    NSString *_mAppkey;
    NSString *_mSlotId;
    BOOL      _mAutoFill;
    
    UIViewController *_mCurrentViewController;
}

@property (nonatomic, copy) NSString *mKeywords;        //keywords for the promoters data, promoter list will return according to this property, default is @""
@property (nonatomic) BOOL  mAutoFill;
@property (nonatomic, assign) id<UMUFPTableViewDataLoadDelegate> dataLoadDelegate; //dataLoadDelegate for tableview

/** 
 
 This method start the promoter data load in background, promoter data will be load until this method called
 
 */

- (void)requestPromoterDataInBackground;

/** 
 
 This method return a UMANTableView object
 
 @param  frame frame for the UMANTableView 
 @param  style tableview style, UITableViewStylePlain or UITableViewStyleGrouped 
 @param  appkey appkey get from www.umeng.com, if you want use ufp service only, set this parameter empty
 @param  slotId slotId get from ufp.umeng.com
 @param  controller view controller releated to the view that the table view added into

 @return a UMANTableView object
 */

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style appkey:(NSString *)appkey slotId:(NSString *)slotId currentViewController:(UIViewController *)controller;

/** 
 
 This method called when promoter clicked
 
 @param  promoter info of the clicked promoter 
 @param  index index of the clicked promoter in the promoter array
 
 */

- (void)didClickPromoterAtIndex:(NSDictionary *)promoter index:(NSInteger)index;

@end

@protocol UMUFPTableViewDataLoadDelegate <NSObject>

@optional

- (void)UMUFPTableViewDidLoadDataFinish:(UMUFPTableView *)tableview promoters:(NSArray *)promoters; //called when promoter list loaded
- (void)UMUFPTableView:(UMUFPTableView *)tableview didLoadDataFailWithError:(NSError *)error; //called when promoter list loaded failed for some reason
- (void)UMUFPTableView:(UMUFPTableView *)tableview didClickPromoterForUrl:(NSURL *)url; //implement this method if you want to handle promoter click event for the case that should open an url in webview  
- (void)UMUFPTableView:(UMUFPTableView *)tableview didClickedPromoterAtIndex:(NSInteger)promoterIndex; //called when table cell clicked, current action is go to app store

@end

