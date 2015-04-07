
#ifndef TINYWRAP_ACTIONCONFIG_H
#define TINYWRAP_ACTIONCONFIG_H

#include "tinysip.h"
#include "Common.h"

class ActionConfig
{
public:
	ActionConfig();
	virtual ~ActionConfig();
	
	bool addHeader(const char* name, const char* value);
	bool addPayload(const void* payload, unsigned len);
	
	ActionConfig* setResponseLine(short code, const char* phrase);
	ActionConfig* setMediaString(twrap_media_type_t type, const char* key, const char* value);
	ActionConfig* setMediaInt(twrap_media_type_t type, const char* key, int value);
	
private:
	tsip_action_handle_t* m_pHandle;

#if !defined(SWIG)
public:
	const inline tsip_action_handle_t* getHandle()const{
		return m_pHandle;
	}
#endif
};


#endif /* TINYWRAP_ACTIONCONFIG_H */
