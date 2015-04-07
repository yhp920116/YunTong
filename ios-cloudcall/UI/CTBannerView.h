//

#import <UIKit/UIKit.h>
#import "AdResourceManager.h"

@interface CTBannerView : UIView<AdResourceManagerDelegate> {
    UIImageView* imgView;
    UIButton* buttonAd;
//    UILabel* labelCT;
    
    NSMutableArray* adsArray;
    int currAdIndex;
    
    NSTimer *refreshTimer;
    BOOL show;
    
    NSString* imgAdUrl;
    
    int adid;
    int actionType;
}

@property (nonatomic, retain) NSMutableArray* adsArray;

-(CTBannerView*)initWithFrame:(CGRect)frame;
-(void)bannerViewShow;
-(void)bannerViewHide;

@end
