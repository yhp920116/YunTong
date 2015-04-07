
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYWRAP_SIPSTACK_H
#define TINYWRAP_SIPSTACK_H

#include "SipCallback.h"
#include "SafeObject.h"

#include "tinydav/tdav.h"
#include "tinysip.h"

class SipStack: public SafeObject
{
public: /* ctor() and dtor() */
	SipStack(SipCallback* pCallback, const char* realm_uri, const char* impi_uri, const char* impu_uri);
    ~SipStack();

public: /* API functions */
	bool start();
	bool setRealm(const char* realm_uri);
	bool setIMPI(const char* impi);
	bool setIMPU(const char* impu_uri);
	bool setPassword(const char* password);
	bool setAMF(const char* amf);
	bool setOperatorId(const char* opid);
	bool setProxyCSCF(const char* fqdn, unsigned short port, const char* transport, const char* ipversion);
	bool setLocalIP(const char* ip);
	bool setLocalPort(unsigned short port);
	bool setEarlyIMS(bool enabled);
	bool addHeader(const char* name, const char* value);
	bool removeHeader(const char* name);
	bool addDnsServer(const char* ip);
	bool setDnsDiscovery(bool enabled);
	bool setAoR(const char* ip, int port);
#if !defined(SWIG)
	bool setModeServer();
#endif

	bool setSigCompParams(unsigned dms, unsigned sms, unsigned cpb, bool enablePresDict);
	bool addSigCompCompartment(const char* compId);
	bool removeSigCompCompartment(const char* compId);
	
	bool setSTUNServer(const char* ip, unsigned short port);
	bool setSTUNCred(const char* login, const char* password);

	bool setTLSSecAgree(bool enabled);
	bool setSSLCretificates(const char* privKey, const char* pubKey, const char* caKey);
	bool setIPSecSecAgree(bool enabled);
	bool setIPSecParameters(const char* algo, const char* ealgo, const char* mode, const char* proto);    
    bool setEncryptSecAgree(bool enabled);
	
	char* dnsENUM(const char* service, const char* e164num, const char* domain);
	char* dnsNaptrSrv(const char* domain, const char* service, unsigned short *OUTPUT);
	char* dnsSrv(const char* service, unsigned short* OUTPUT);

	char* getLocalIPnPort(const char* protocol, unsigned short* OUTPUT);

	char* getPreferredIdentity();

	bool isValid();
	bool stop();
	
	static bool initialize();
	static bool deInitialize();
	static void setCodecs(tdav_codec_id_t codecs);
	static void setCodecs_2(int codecs); // For stupid languages
	static bool setCodecPriority(tdav_codec_id_t codec_id, int priority);
    static int getCodecPriority(tdav_codec_id_t* codec_id);
	static bool setCodecPriority_2(int codec, int priority);// For stupid languages
	static bool isCodecSupported(tdav_codec_id_t codec_id);
    
    static const char* getCodecName(tdav_codec_id_t codec_id);

public: /* Public helper function */
#if !defined(SWIG)
	inline tsip_stack_handle_t* getHandle()const{
		return m_pHandle;
	}
	inline SipCallback* getCallback()const{
		return m_pCallback;
	}
#endif

private:
	SipCallback* m_pCallback;
	tsip_stack_handle_t* m_pHandle;

	static bool g_bInitialized;
};

#endif /* TINYWRAP_SIPSTACK_H */
