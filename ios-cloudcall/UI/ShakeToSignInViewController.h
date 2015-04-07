//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
//#import <CoreLocation/CoreLocation.h>
#import "HttpRequest.h"

#import "AdResourceManager.h"
#import <ShareSDK/ShareSDK.h>

@interface ShakeToSignInViewController : UIViewController
{
    UIImageView *imgUp;
    UIImageView *imgDown;
    
    UIView *resultView;
    UIImageView *adView;
    UIButton *adButton;
    UIButton *shareButton;
    
    UIImageView *resultBg;    
	UIActivityIndicatorView *activityIndicator;
    UILabel *labelResult;
    
//    CLLocationManager *lm;
    NSString *shareString;
    
    float longitude;
    float latitude;
    
    int adid;
    BOOL isSignInRemind;
@private    
    
    NSString* imgAdUrl;
    int actionType;
    
    BOOL signinDone;
    
    BOOL isCN;
    
    NSMutableArray *strShareWeibo;
    
    BOOL animating;
    BOOL signining;
    NSTimer* signinTimer;
    
    AVAudioPlayer* player;
}

@property (nonatomic, assign) BOOL isSignInRemind;
@property (nonatomic, retain) NSString *shareString;

@property(nonatomic, retain) IBOutlet UIImageView *imgUp;
@property(nonatomic, retain) IBOutlet UIImageView *imgDown;

@property(nonatomic, retain) IBOutlet UIView *resultView;
@property(nonatomic, retain) IBOutlet UIImageView *adView;
@property(nonatomic, retain) IBOutlet UIButton *adButton;
@property(nonatomic, retain) IBOutlet UIButton *shareButton;
@property(nonatomic, retain) IBOutlet UIImageView *resultBg;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) IBOutlet UILabel *labelResult;

@property (nonatomic, retain) IBOutlet UIView *tipsView;
@property (nonatomic, retain) IBOutlet UILabel *tipsLabel;
@property (nonatomic, retain) IBOutlet UIButton *btnCloseTips;
@property (nonatomic, assign) int adid;

- (IBAction)onButtonClick: (id)sender;
- (void)playAudioWithUrl:(NSString *)urlString;
@end
