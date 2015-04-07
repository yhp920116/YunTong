//
//  RecorderManager.h
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AQRecorder.h"
#import "Encapsulator.h"

@protocol RecordingDelegate <NSObject>

- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval;
- (void)recordingTimeout;
- (void)recordingStopped;  //录音机停止采集声音
- (void)recordingFailed:(NSString *)failureInfoString;

@optional
- (void)levelMeterChanged:(float)levelMeter;

@end


//默认最大录音时间
#define kDefaultMaxRecordTime               60

#define kCancelOriginY          ([[UIScreen mainScreen]bounds].size.height-70)

@interface RecorderManager : NSObject <EncapsulatingDelegate> {
    
    Encapsulator *encapsulator;
    NSString *filename;
    NSDate *dateStartRecording;
    NSDate *dateStopRecording;
    NSTimer *timerLevelMeter;
    NSTimer *timerTimeout;
    
@protected
    
    //最大录音时间
    NSInteger               maxRecordTime;
    //录音文件名
    NSString                *recordFileName;
    //录音文件路径
    NSString                *recordFilePath;
}

@property (nonatomic, weak)  id<RecordingDelegate> delegate;
@property (nonatomic, strong) Encapsulator *encapsulator;
@property (nonatomic, strong) NSDate *dateStartRecording, *dateStopRecording;
@property (nonatomic, strong) NSTimer *timerLevelMeter;
@property (nonatomic, strong) NSTimer *timerTimeout;

@property (assign, nonatomic)           NSInteger maxRecordTime;


/**
 判断文件是否存在
 @param _path 文件路径
 @returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path;

/**
 删除文件
 @param _path 文件路径
 @returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path;


#pragma mark -

/**
 生成文件路径
 @param _fileName 文件名
 @param _type 文件类型
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName;
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type;


+ (RecorderManager *)sharedManager;

- (void)startRecording:(NSString *)filePath;

- (void)stopRecording;

- (void)cancelRecording;

- (NSTimeInterval)recordedTimeInterval;

@end
