
#import <Foundation/Foundation.h>

#import "services/INgnBaseService.h"
#import "sip/NgnSipSession.h"
#import "sip/NgnSipStack.h"

@protocol INgnSipService <INgnBaseService>
-(NSString*)getDefaultIdentity;
-(void)setDefaultIdentity: (NSString*)identity;
-(NgnSipStack*)getSipStack;
-(BOOL)isRegistered;
-(ConnectionState_t)getRegistrationState;
-(int)getCodecs;
-(void)setCodecs: (int)codecs;
-(BOOL)stopStackAsynchronously;
-(BOOL)stopStackSynchronously;
-(BOOL)registerIdentity;
-(BOOL)unRegisterIdentity;
-(NSString*)getCurrentAccount;

@property(readwrite, retain, getter=getDefaultIdentity, setter=setDefaultIdentity:) NSString* defaultIdentity;
@property(readonly, getter=getSipStack) NgnSipStack* stack;
@property(readonly, getter=isRegistered) BOOL registered;
@property(readonly, getter=getRegistrationState) ConnectionState_t registrationState;
@property(readwrite, getter=getCodecs, setter=setCodecs:) int codecs;

@end