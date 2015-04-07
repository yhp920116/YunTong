
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYWRAP_SIPMESSAGE_H
#define TINYWRAP_SIPMESSAGE_H

#include "tinysip.h"

class SdpMessage
{
public:
	SdpMessage();
#if !defined(SWIG)
	SdpMessage(tsdp_message_t *sdpmessage);
#endif
	virtual ~SdpMessage();

	char* getSdpHeaderValue(const char* media, char name, unsigned index = 0);
	char* getSdpHeaderAValue(const char* media, const char* attributeName);

private:
	tsdp_message_t *m_pSdpMessage;
};

class SipMessage
{
public:
	SipMessage();
#if !defined(SWIG)
	SipMessage(tsip_message_t *sipmessage);
#endif
	virtual ~SipMessage();
	
	bool isResponse();
	tsip_request_type_t getRequestType();
	short getResponseCode();
	char* getSipHeaderValue(const char* name, unsigned index = 0);
	char* getSipHeaderParamValue(const char* name, const char* param, unsigned index = 0);
	unsigned getSipContentLength();
	unsigned getSipContent(void* output, unsigned maxsize);
#if !defined(SWIG)
	const void* getSipContentPtr();
#endif
	const SdpMessage* getSdpMessage();

private:
	const tsip_header_t* getSipHeader(const char* name, unsigned index = 0);

private:
	tsip_message_t *m_pSipMessage;
	SdpMessage *m_pSdpMessage;
};

#endif /* TINYWRAP_SIPMESSAGE_H */
