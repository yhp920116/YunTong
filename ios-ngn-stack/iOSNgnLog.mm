
#import "iOSNgnLog.h"

#ifdef DEBUG
static int g_NgnOutputOn = 1;
#else
static int g_NgnOutputOn = 0;
#endif

void NgnOutputOn () {
    g_NgnOutputOn = 1;
}

void NgnOutputOff () {
    g_NgnOutputOn = 0;
}

void NgnLog(NSString* format, ...) {
    if (!format || !g_NgnOutputOn)
        return;
    
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"%@", str);
    [str release];
    va_end(args);
}
