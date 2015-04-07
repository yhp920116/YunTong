
/* Vincent, GZ, 2012-03-07 */

#import "NgnSipStack.h"
#import "NgnStringUtils.h"
#import "iOSNgnConfig.h"

#import "../model/NgnDeviceInfo2.h"

#include "tsk_debug.h"
 
#include <sys/types.h> 
#include <sys/sysctl.h>

@implementation NgnSipStack

+(NSString *) platform{
    size_t size;  
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);  
    char *machine = new char[size];  
    sysctlbyname("hw.machine", machine, &size, NULL, 0);  
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];  
    delete []machine;  
    return platform;  
}  

-(NgnSipStack*) initWithSipCallback: (const SipCallback*) callback andRealmUri: (NSString*) realmUri andIMPIUri: (NSString*) impiUri andIMPUUri: (NSString*)impuUri andDeviceToken: (NSString*)deviceToken andMaketType:(int)makettype {
	if((self = [super init])){
		_mSipStack = new SipStack(const_cast<SipCallback*>(callback), [realmUri UTF8String], [impiUri UTF8String], [impuUri UTF8String]);
		if(_mSipStack){
			// Sip headers
			_mSipStack->addHeader("Allow", "INVITE, ACK, CANCEL, BYE, MESSAGE, OPTIONS, NOTIFY, PRACK, UPDATE, REFER");
			_mSipStack->addHeader("Privacy", "none");
			_mSipStack->addHeader("P-Access-Network-Info", "ADSL;utran-cell-id-3gpp=00000000");
            
#if TARGET_OS_IPHONE            
            NSString* id = [NgnDeviceInfo2 uniqueGlobalDeviceIdentifier];
            if (!id) {
                TSK_DEBUG_ERROR("Failed to get uniqueGlobalDeviceIdentifiernew!");
            }
            NSString* usrAgent = nil;
            if (makettype == 0) {
                usrAgent = [[NSString alloc] initWithFormat:@"YunTongCall Client (%@) for IOS OS:%@ Model:%@ Mac:%@:%@",
                            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], [[UIDevice currentDevice] systemVersion],
                            [NgnSipStack platform], id ? id : @"", deviceToken];
            } else {
                usrAgent = [[NSString alloc] initWithFormat:@"YunTongCall Client (%@.%d) for IOS OS:%@ Model:%@ Mac:%@:%@",
                                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], makettype, [[UIDevice currentDevice] systemVersion],
                                  [NgnSipStack platform], id ? id : @"", deviceToken];
            }
            NgnLog(@"usrAgent: %@", usrAgent);
            _mSipStack->addHeader("User-Agent", [usrAgent UTF8String]);
            [usrAgent release];
#elif TARGET_OS_MAC
            _mSipStack->addHeader("User-Agent", "YunTong Client for Mac");
#endif
		}
		else{
			TSK_DEBUG_ERROR("Failed to create new SipStack object");
		}
	}
	return self;
}

- (void)dealloc {
	if(_mSipStack){
		delete _mSipStack;
	}
	[super dealloc];
}

-(STACK_STATE_T) getState{
	return mState;
}

-(void) setState: (STACK_STATE_T)newState{
	mState = newState;
}

-(BOOL) start{
	if(_mSipStack){
		return _mSipStack->start();
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setRealm: (NSString *)realmUri{
	if(_mSipStack){
		return _mSipStack->setRealm([realmUri UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setIMPI: (NSString *) impiUri{
	if(_mSipStack){
		return _mSipStack->setIMPI([impiUri UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setIMPU: (NSString *) impuUri{
	if(_mSipStack){
		return _mSipStack->setIMPU([impuUri UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setPassword: (NSString*) password{
	if(_mSipStack){
		return _mSipStack->setPassword([password UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setAMF: (NSString*) amf{
	if(_mSipStack){
		return _mSipStack->setAMF([amf UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setOperatorId: (NSString*) opid{
	if(_mSipStack){
		return _mSipStack->setOperatorId([opid UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setProxyCSCFWithFQDN: (NSString*) fqdn andPort: (unsigned short) port andTransport: (NSString*) transport andIPVersion: (NSString *) ipversion{
	if(_mSipStack){
		return _mSipStack->setProxyCSCF([fqdn UTF8String], port, [transport UTF8String], [ipversion UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setLocalIP: (NSString*) ip{
	if(_mSipStack){
		return _mSipStack->setLocalIP([ip UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setLocalPort: (unsigned short) port{
	if(_mSipStack){
		return _mSipStack->setLocalPort(port);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setEarlyIMS: (BOOL) enabled{
	if(_mSipStack){
		return _mSipStack->setEarlyIMS(enabled);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) addHeaderName: (NSString*) name andValue: (NSString*) value{
	if(_mSipStack){
		return _mSipStack->addHeader([name UTF8String], [value UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) removeHeader: (NSString*) name{
	if(_mSipStack){
		return _mSipStack->removeHeader([name UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) addDnsServer: (NSString*) ip{
	if(_mSipStack){
		return _mSipStack->addDnsServer([ip UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setDnsDiscovery: (BOOL) enabled{
	if(_mSipStack){
		return _mSipStack->setDnsDiscovery(enabled);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setAoRWithIP: (NSString*) ip andPort: (unsigned short) port{
	if(_mSipStack){
		return _mSipStack->setAoR([ip UTF8String], port);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}


-(BOOL) setSigCompParamsWithDMS: (unsigned) dms andSMS: (unsigned) sms andCPB: (unsigned) cpb andPresDict: (BOOL) enablePresDict{
	if(_mSipStack){
		return _mSipStack->setSigCompParams(dms, sms, cpb, enablePresDict);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(NSString*) getSigCompId{
	return mCompId;
}

-(void) setSigCompId: (NSString*)compId{
	if(mCompId != nil && mCompId != compId && _mSipStack){
		_mSipStack->removeHeader([mCompId UTF8String]);
	}
	
	[mCompId release], mCompId = [compId retain];
	if(mCompId != nil && _mSipStack){
		_mSipStack->addSigCompCompartment([mCompId UTF8String]);
	}
}

-(BOOL) setSTUNServerIP: (NSString*) ip andPort: (unsigned short) port{
	if(_mSipStack){
		return _mSipStack->setSTUNServer([ip UTF8String], port);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setSTUNCredLogin: (NSString*) login andPassword: (NSString*) password{
	if(_mSipStack){
		return _mSipStack->setSTUNCred([login UTF8String], [password UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}


-(NSString *) dnsENUMWithService: (NSString *) service andE164Num: (NSString *) e164num andDomain: (NSString*) domain{
	if(_mSipStack){
		return [NSString stringWithCString: _mSipStack->dnsENUM([service UTF8String], [e164num UTF8String], [domain UTF8String]) encoding: NSUTF8StringEncoding];
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return nil;
}

-(NSString *) dnsNaptrSrvWithDomain: (NSString *) domain andService: (NSString *) service andPort: (unsigned short*) port{
	if(_mSipStack){
		return [NSString stringWithCString: _mSipStack->dnsNaptrSrv([domain UTF8String], [service UTF8String], port) encoding: NSUTF8StringEncoding];
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return nil;
}

-(NSString *) dnsSrvWithService: (NSString *) service andPort: (unsigned short*) port{
	if(_mSipStack){
		return [NSString stringWithCString: _mSipStack->dnsSrv([service UTF8String], port) encoding: NSUTF8StringEncoding];
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return nil;
}

-(BOOL) setSSLCertificates: (NSString*)privKey andPubKey:(NSString*)pubKey andCAKey:(NSString*)caKey{
	if(_mSipStack){
		return _mSipStack->setSSLCretificates([privKey UTF8String], [pubKey UTF8String], [caKey UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(BOOL) setEncrypt: (BOOL)enabled{
	if(_mSipStack){
		return _mSipStack->setEncryptSecAgree(enabled);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(NSString*)getPreferredIdentity{
	char* _preferredIdentity = _mSipStack->getPreferredIdentity();
	NSString* preferredIdentity = [NgnStringUtils toNSString: _preferredIdentity];
	TSK_FREE(_preferredIdentity);
	return preferredIdentity;
}

-(BOOL) isValid{
	if(_mSipStack){
		return _mSipStack->isValid();
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

-(SipStack*) getStack{
	return _mSipStack;
}

-(BOOL) stop{
	if(_mSipStack){
		return _mSipStack->stop();
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return NO;
}

+(void) setCodecs:(tdav_codec_id_t) codecs{
	SipStack::setCodecs(codecs);
}


@end
