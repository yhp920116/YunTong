//
//  IMDownLoadAudioFromServerModel.m
//

#import "IMDownLoadAudioFromServerModel.h"
#import "RecorderManager.h"
#import "CloudCall2AppDelegate.h"

@implementation IMDownLoadAudioFromServerModel

SYNTHESIZE_SINGLETON_FOR_CLASS(IMDownLoadAudioFromServerModel)

- (id) init
{
    self = [super init];
    
    if (self)
    {
        downLoadDictionary = [[NSMutableDictionary alloc] init];
                
        NSURL *filePath   = [[NSBundle mainBundle] URLForResource:@"msg" withExtension:@"aif"];
        //    soundPlay = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error: nil];
        AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
    }
    
    return self;
}

// 成功
- (void) requestFinished:(ASIHTTPRequest *) aRequest
{
    [self onDownAmrSuccessful:aRequest];
}

// 失败
- (void) requestFailed:(ASIHTTPRequest *) aRequest
{
    if ([[[[aRequest error] userInfo] objectForKey:NSLocalizedDescriptionKey] isEqualToString:@"The request timed out"])
    {
        CCLog(@"请求超时");
    }
    else
    {
        CCLog(@"请求失败");
    }
}

/*
 * 下载音频(NSData)
 *@param armUrl:arm的Url路径
 */
- (void) sendDownLoadAudioRequest:(NSString *) armUrl filePath:(NSString *) filePath messgeId:(NSString *) messgeId andAudioDuration:(NSString *)duration andSenderUser:(NSString *)senderUser andDate:(NSDate *)date andPlay:(BOOL)isPlay
{
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc] init];
    [dateformat setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *timeString = [dateformat stringFromDate:[NSDate date]];
    int tag = [timeString intValue];
    [dateformat release];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:armUrl]];
    CCLog(@"download spx:%@", [[request url] absoluteString]);
    [request setAllowResumeForFileDownloads:YES ];
    [request setRequestMethod:@"GET"];
    [request setDownloadDestinationPath:filePath];
    [request setTimeOutSeconds:15];
    [request setDelegate:self];
    [request setTag:tag];
    [request startAsynchronous];
    
    // 构件fileName---->messageId字典
    [downLoadDictionary setObject:filePath forKey:[NSString stringWithFormat:@"filePath%d", tag]];
    [downLoadDictionary setObject:messgeId forKey:[NSString stringWithFormat:@"local%d", tag]];
    [downLoadDictionary setObject:duration forKey:[NSString stringWithFormat:@"duration%d", tag]];
    [downLoadDictionary setObject:senderUser forKey:[NSString stringWithFormat:@"senderUser%d", tag]];
    [downLoadDictionary setObject:date forKey:[NSString stringWithFormat:@"date%d", tag]];
    [downLoadDictionary setObject:[NSNumber numberWithBool:isPlay] forKey:[NSString stringWithFormat:@"isPlay%d", tag]];
}

- (void) onDownAmrSuccessful:(ASIHTTPRequest *) request
{
    CCLog(@"下载音频成功");
    
    // 播放消息提醒
    AudioServicesPlayAlertSound(soundID);
    
    NSDictionary *userInfo = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                [downLoadDictionary objectForKey:[NSString stringWithFormat:@"filePath%d", request.tag]], @"FilePath",
                                [downLoadDictionary objectForKey:[NSString stringWithFormat:@"local%d", request.tag]], @"messageId",
                                [downLoadDictionary objectForKey:[NSString stringWithFormat:@"duration%d", request.tag]], @"audioDuration",
                                [downLoadDictionary objectForKey:[NSString stringWithFormat:@"senderUser%d", request.tag]], @"senderUser",
                                [downLoadDictionary objectForKey:[NSString stringWithFormat:@"date%d", request.tag]], @"date",
                                [downLoadDictionary objectForKey:[NSString stringWithFormat:@"isPlay%d", request.tag]], @"isPlay", nil] autorelease];
    
    // 发送下载文件成功的消息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"wavMediaIsReadyNotification" object:nil userInfo:userInfo];
}

- (void) onDownAmrFailure:(ASIHTTPRequest *) request
{
    CCLog(@"下载音频失败");
}

@end
