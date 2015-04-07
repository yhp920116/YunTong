

void NgnOutputOn ();
void NgnOutputOff ();
void NgnLog(NSString* format, ...);
#define NgnNSLog(TAG, FMT, ...) NgnLog(@"%@" FMT "\n", TAG, ##__VA_ARGS__)