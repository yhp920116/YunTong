
/* Vincent, GZ, 2012-03-07 */


#import "NgnLogService.h"
#import "LogMgr.h"

#import "../../utils/lzma/7z/LzmaUtil.h"


#undef TAG
#define kTAG @"NgnLogService///: "
#define TAG kTAG

#undef kLogFileName
#define kLogFileName @"Logs"

#define MAX_ENT_SIZE 2056

#define kLogFileVersion 100

@implementation NgnLogService

static LogMgr* logmgr = nil;

static NSString* LogFileDir() {
    NSString* LogDir = nil;
#if TARGET_OS_IPHONE
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    LogDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"Logs"];
#elif TARGET_OS_MAC
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    LogDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"WeiCall/Logs"];
#endif
    return LogDir;
}

-(NgnLogService*) init {
	if((self = [super init])){
		//
	}
	return self;
}

-(void) dealloc {
	[self stop];
	
	[super dealloc];
}

//
// INgnBaseService
//

-(BOOL) start {
	NgnNSLog(TAG, @"Start()");
	BOOL ok = NO;
    if (!logmgr) {
        NSString* logdir = LogFileDir();
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:logdir];        
        if (!fileExists) {            
            [fileManager createDirectoryAtPath:logdir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString* LogFilePath = [logdir stringByAppendingPathComponent:kLogFileName];        
        logmgr = new LogMgr([LogFilePath UTF8String], MAX_ENT_SIZE);
    }
    if (logmgr && logmgr->OK()) {
        ok = YES;
        NSString* str = @"LogService Start";
        logmgr->log(false, LogMgr::TText, str, [str length]);
    } 
	return ok;
}

-(BOOL) stop {
	NgnNSLog(TAG, @"Stop()");
	BOOL ok = YES;
    if (logmgr) {
        delete logmgr;
        logmgr = nil;
    }
	return ok;
}

//
// INgnLogService
//

/*-(int) logfileVersion{
	return kLogFileVersion;
}*/

-(BOOL) addLog:(NSString*)log {
    BOOL OK = NO;
    if (logmgr) {        
        logmgr->log(LogMgr::TText, [log UTF8String], [log length]);
        OK = YES;
    }
    return OK;
}

- (void) Log:(NSString *)format, ... {
    if (!logmgr || !format) return;

    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];     
    [self addLog: str];
    [str release];
    va_end(args);
}

-(NSString*) getCompressdLogFile {
    NSString* filepath = nil;
    if (logmgr) {
        logmgr->Suspend();

        // compress log file.
#if TARGET_OS_IPHONE
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
#elif TARGET_OS_MAC
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
#endif
        NSString* sdestfile = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"logs"];
        
        // Delete the old file before compress a new one.
        NSFileManager* fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:sdestfile]==YES) {
            if ([fm removeItemAtPath:sdestfile error:nil] == YES) {
                NgnLog(@"remove old file successful!");
            }
        }
        
#if 1
        NSString* LogFilePath = [LogFileDir() stringByAppendingPathComponent:kLogFileName]; 
#else
        
#if TARGET_OS_IPHONE
        NSString* LogFileDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"Logs"];
#elif TARGET_OS_MAC
        NSString* LogFileDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"WeiCall/Logs"];
#endif       
        NSString* LogFilePath = [LogFileDir stringByAppendingPathComponent:kLogFileName];
        
        if (LogFilePath && [LogFilePath length])
            NgnLog(@"%s\n", [LogFilePath UTF8String]);
        NgnLog(@"%s\n", [sdestfile UTF8String]);
#endif
        
        if ([fm fileExistsAtPath:LogFilePath]==NO) {
            NgnLog(@"no log file '%@'", LogFilePath);
        } else {
            LzmaUtil('e', [LogFilePath UTF8String], [sdestfile UTF8String]);
            
            if ([fm fileExistsAtPath:sdestfile]==NO) {  
                NgnLog(@"file not exist!");
            } else {
                filepath = sdestfile;
            }
        }
        
        logmgr->Resume();        
      
    }    
    return filepath;
}

@end
