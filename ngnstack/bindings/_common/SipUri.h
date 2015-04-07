
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYWRAP_SIPURI_H
#define TINYWRAP_SIPURI_H

#include "tinysip.h"

class SipUri
{
public:
	SipUri(const char* uriString, const char* displayName=tsk_null);
	~SipUri();

public:
	static bool isValid(const char*);

	bool isValid();
	const char* getScheme();
	const char* getHost();
	unsigned short getPort();
	const char* getUserName();
	const char* getPassword();
	const char* getDisplayName();
	const char* getParamValue(const char* pname);
	void setDisplayName(const char* displayName);
#if !defined(SWIG)
	inline const tsip_uri_t* getWrappedUri()const{
		return m_pUri;
	}
#endif

private:
	tsip_uri_t* m_pUri;
};

#endif /* TINYWRAP_SIPURI_H */
