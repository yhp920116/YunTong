
#import "NgnDeviceInfo2.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <CommonCrypto/CommonDigest.h>

NSString* stringMD5(NSString *src) {
    if (src == nil || [src length] == 0)
        return nil;
    
    const char *value = [src UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString autorelease];
}

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
NSString* macaddress(NSString* separator){
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        return nil;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return nil;
    }
    
    if ((buf = (char*)malloc(len)) == NULL) {
        return nil;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        return nil;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);

    NSString *outstring = nil;
    if (separator && [separator length]) {
        outstring = [NSString stringWithFormat:@"%02X%@%02X%@%02X%@%02X%@%02X%@%02X", 
                           *ptr, separator, *(ptr+1), separator, *(ptr+2), separator, *(ptr+3), separator, *(ptr+4), separator, *(ptr+5)];
    } else {
        outstring = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X", 
         *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    }
    free(buf);
    
    return outstring;
}

@implementation NgnDeviceInfo2

+ (NSString *) uniqueDeviceIdentifier{
    NSString *macaddr = macaddress(nil);
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@", macaddr, bundleIdentifier];
    NSString *uniqueId = stringMD5(stringToHash);
    
    return uniqueId;
}

+ (NSString *) uniqueGlobalDeviceIdentifier{
    NSString *macaddr = macaddress(nil);
#if 1
    return macaddr;
#else
    NSString *uniqueId = stringMD5(macaddr);
    return uniqueId;
#endif
}

@end
