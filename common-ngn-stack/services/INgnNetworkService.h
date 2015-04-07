
#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

typedef enum NgnNetworkType_e
{
	NetworkType_None = 0x00,
	
	NetworkType_WLAN = 0x01 << 0, // WiFi
	NetworkType_2G = 0x01 << 1,
	NetworkType_EDGE = 0x01 << 2,
	NetworkType_3G = 0x01 << 3,
	NetworkType_4G = 0x01 << 4,
	
	NetworkType_WWAN = (NetworkType_2G | NetworkType_EDGE | NetworkType_3G | NetworkType_4G),
}
NgnNetworkType_t;

typedef enum NgnNetworkReachability_e
{
	NetworkReachability_None = 0x00,
	
	NetworkReachability_TransientConnection = 0x01 << 0,
	NetworkReachability_Reachable = 0x01 << 1,
	NetworkReachability_ConnectionRequired = 0x01 << 2,
	NetworkReachability_ConnectionAutomatic = 0x01 << 3,
	NetworkReachability_InterventionRequired = 0x01 << 4,
	NetworkReachability_IsLocalAddress = 0x01 << 5,
	NetworkReachability_IsDirect = 0x01 << 6,
}
NgnNetworkReachability_t;

@protocol INgnNetworkService <INgnBaseService>

-(NSString*)getReachabilityHostName;
-(void)setReachabilityHostName:(NSString*)hostName;
-(NgnNetworkType_t) getNetworkType;
-(NSString*) getNetworkTypeName:(NgnNetworkType_t)type;
-(NgnNetworkReachability_t) getReachability;
-(BOOL) isReachable;

@property(readwrite, retain, getter=getReachabilityHostName, setter=setReachabilityHostName:) NSString* reachabilityHostName;
@property(readonly, getter=getNetworkType) NgnNetworkType_t networkType;
@property(readonly, getter=getReachability) NgnNetworkReachability_t reachability;
@property(readonly, getter=isReachable) BOOL reachable;

@end