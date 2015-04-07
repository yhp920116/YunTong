//
//  IMDownLoadAudioFromServerModel.h
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "SynthesizeSingleton.h"
#import <AVFoundation/AVFoundation.h>

@interface IMDownLoadAudioFromServerModel : NSObject <ASIHTTPRequestDelegate>
{
    
    NSMutableDictionary *downLoadDictionary;
    
    // 声音播放
    SystemSoundID soundID;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(IMDownLoadAudioFromServerModel);

// 下载音频(NSData)
- (void) sendDownLoadAudioRequest:(NSString *) armUrl filePath:(NSString *) filePath messgeId:(NSString *) messgeId andAudioDuration:(NSString *)duration andSenderUser:(NSString *)senderUser andDate:(NSDate *)date andPlay:(BOOL)isPlay;

@end
