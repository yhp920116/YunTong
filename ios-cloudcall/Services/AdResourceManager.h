//

#import <UIKit/UIKit.h>
#import "FMDB/FMDatabase.h"
#import "WebBrowser.h"

#define kTotalShowToSubmit          100
#define kTotalClickToSubmit         5

#define kADsInfoTable               @"adsinfo"
#define kADsInfoColId               @"id"
#define kADsInfoColEndtime          @"endtime"
#define kADsInfoColUpdateTime       @"updatetime"
#define kADsInfoColType             @"type"
#define kADsInfoColMyindex          @"myindex"
#define kADsInfoColImage            @"image"
#define kADsInfoColRing             @"ring"
#define kADsInfoColVideo            @"video"
#define kADsInfoColAdtxt            @"adtxt"
#define kADsInfoColClickAction      @"clickAction"
#define kADsInfoColClickUrl         @"clickurl"
#define kADsInfoColNeedUpdate       @"needupdate"
#define kADsInfoColDaySegments      @"daySegments"

#define kADStatisticsTable          @"adstatistics"
#define kADStatisticsColId          @"id"
#define kADStatisticsColADId        @"adid"
#define kADStatisticsColShow        @"show"
#define kADStatisticsColClick       @"click"
#define kADStatisticsColIsSubmit    @"issubmit"
#define kADStatisticsColTimeByHour  @"timebyhour"

#define kNotificationUpdateAdsInfo  @"kNotificationUpdateAdsInfo"

enum ADStatisticsSubmitState
{
    ADStatisticsUnSubmit = 0,   //未提交
    ADStatisticsSubmiting,      //提交中
    ADStatisticsSubmited        //已提交
};

enum ADStatisticsUpdateType
{
    ADStatisticsUpdateTypeShow = 0,   //展示
    ADStatisticsUpdateTypeClick,      //点击
};

enum ADSType                //广告类型
{
    ADSTypeImage = 0,       //0：图片
    ADSTypeImageWithRing,   //1：图片加铃声；
    ADSTypeRing,            //2：铃声；
    ADSTypeText,            //3：文字；
    ADSTypeVideo            //4：视频
};

enum ADSMyindex             //广告位
{
    ADSMyindexBanner = 0,   //0：首页banner；
    ADSMyindexAlertView,    //1：音质反馈；
    ADSMyindexSlotMachine,  //2：老虎机图片
    ADSMyindexSignin,       //3：签到；
    ADSMyindexScreen,       //4：大屏广告
};

enum ADActionType
{
    ADActionTypeOpenInnerBrowser = 0,
    ADActionTypeOpenOuterBrowser,
    ADActionTypeGoToAppStore,
    ADActionTypeShowFullScreen,
    ADActionTypeDownloadApp,
};

@protocol AdResourceManagerDelegate <NSObject>

-(void) shouldContinueAfterGetAdDataFromNet;

@end

@interface CCAdData : NSObject {
    NSString *name;
    NSString *imageUrl;
    NSString *audioUrl;
    NSString *adUrl;
    NSString *adText;
    NSString *updateDate;
    NSString *type;
    int adid;
    BOOL need2Update;
}

@property(readonly, retain)  NSString *name;
@property(readonly, retain)  NSString *imageUrl;
@property(readonly, retain)  NSString *audioUrl;
@property(readonly, retain)  NSString *adUrl;
@property(readonly, retain)  NSString *adText;
@property(readonly, retain)  NSString *updateDate;
@property(readonly, retain)  NSString *type;
@property(readonly)          int adid;
@property(readwrite) BOOL need2Update;

-(CCAdData*) initWithName:(NSString*)name andImageUrl:(NSString*)imageUrl andAudioUrl:(NSString*)audioUrl andAdUrl:(NSString*)adUrl andAdText:(NSString*)adText andAdID:(int)adID andType:(NSString*)type andUpdateDate:(NSString*)updateDate andNeed2Update:(BOOL)need2update;
@end

@interface CCAdsData : NSObject {
    int adid;
    NSString *endtime;
    NSString *updatetime;
    int type;
    int myindex;
    NSString *image;
    NSString *ring;
    NSString *video;
    NSString *adtxt;
    int clickAction;
    NSString *clickurl;
    BOOL need2Update;
    NSString *daySegments;
}

@property (nonatomic, assign) int adid;
@property (nonatomic, retain) NSString *endtime;
@property (nonatomic, retain) NSString *updatetime;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int myindex;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *ring;
@property (nonatomic, retain) NSString *video;
@property (nonatomic, retain) NSString *adtxt;
@property (nonatomic, assign) int clickAction;
@property (nonatomic, copy) NSString *clickurl;
@property (nonatomic, assign) BOOL need2Update;
@property (nonatomic, retain) NSString *daySegments;

- (CCAdsData *)initWithAdID:(int)_adid andEndtime:(NSString *)_endtime andUpdateTime:(NSString *)_updatetime andType:(int)_type andMyindex:(int)_myindex andImage:(NSString *)_image andRing:(NSString *)_ring andVideo:(NSString *)_video andAdtext:(NSString *)_adtext andClickAction:(int)_clickAction andClickUrl:(NSString *)_clickurl andNeed2Update:(BOOL)_need2Update andDaySegments:(NSString *)_daySegments;
@end

@interface CCAdStatisticsData : NSObject {
    int _id;
    int adid;
    int show;
    int click;
    int issubmit;
    NSString *timebyhour;
}

@property (nonatomic, assign) int _id;
@property (nonatomic, assign) int adid;
@property (nonatomic, assign) int show;
@property (nonatomic, assign) int click;
@property (nonatomic, assign) int issubmit;
@property (nonatomic, copy) NSString *timebyhour;

-(CCAdStatisticsData *) initWithid:(int)_id andAdID:(int)adid andShow:(int)show andClick:(int)click andIsSubmit:(int)issubmit andTime:(NSString *)_timebyhour;
@end


@interface AdResourceManager : NSObject {
    NSString* directory;
    NSString* filename;
    
    int totalShow;
    int totalClick;
    
    BOOL notAllowToSubmitAdStat;
    
    NSMutableArray *submittingArray;
    NSMutableArray *adsDataArray;
}

@property(nonatomic, assign) id<AdResourceManagerDelegate> delegate;
@property(nonatomic, retain) NSMutableArray *submittingArray;
@property(nonatomic, retain) NSMutableArray *adsDataArray;

- (void)adClickAction:(NSString *)actionUrl andActionType:(int)actionType andNavigation:(UINavigationController *)_navigationController;

-(AdResourceManager*) initWithDirectory:(NSString*)_directory andListFileName:(NSString*)filename;

+(NSMutableArray*)LoadAdsDataFromFile:(NSString*)filepath;
+(void)SaveAdsDataToFile:(NSString*)filepath andAdArray:(NSMutableArray*)adData;

#pragma mark HttpRequest
- (void)getAdsListFromServer:(NSString*)jsonString;

- (void)sendAdsRequest:(NSData *)jsonData andUserInfo:(NSMutableDictionary *)userInfo;
- (void)sendAdsResponse:(NSData *)data andUserInfo:(NSMutableDictionary *)userInfo;
- (void)sendAdsResponseError:(NSData *)data andUserInfo:(NSMutableDictionary *)userInfo;

#pragma mark table Adsinfo
- (void)checkAdsDatabaseAndCreateTable;
- (void)dbLoadAdsData:(NSMutableArray *)adsArray andMyIndex:(ADSMyindex)myindex;
- (void)dbUpdateADsUpdateStateByAdid:(int)adid;

#pragma mark table AdStatistics
- (void)dbLoadAdStatisticsData:(NSMutableArray *)adStatisticsArray andTimeByHour:(NSString *)timeByHour;
- (void)dbLoadAdStatisticsData:(CCAdStatisticsData *)adStatisticsData byAdid:(int)_adid;
- (int)dbCountAdStatisticsDataByAdid:(int)_adid andTimeByHour:(NSString *)timeByHour;
- (void)dbCountAdStatisticsShowandClick;
- (void)dbAddAdStatisticsData:(CCAdStatisticsData *)adStatisticsData;
- (void)dbUpdateADStatisticsData:(NSString *)column andValue:(int)value andAdid:(int)adid  andTimeByHour:(NSString *)timeByHour;
- (void)dbUpdateADStatisticsDataStateSubmiting:(ADStatisticsSubmitState)submitState;
- (void)dbUpdateADStatisticsDataStateSubmitFail:(ADStatisticsSubmitState)submitState;

#pragma mark public method
- (void)updateData:(int)adid andType:(ADStatisticsUpdateType)type;
- (NSString *)getTimeByhour;
- (void)submitADStatisticsData;
@end
