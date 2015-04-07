
/* 2012-03-07 */

#ifndef _TSIP_HEADER_USER_AGENT_H_
#define _TSIP_HEADER_USER_AGENT_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_USER_AGENT_VA_ARGS(ua)		tsip_header_User_Agent_def_t, (const char*)ua

#define TSIP_HEADER_USER_AGENT_DEFAULT			"IM-client/OMA1.0 weicall/v1.0.0"
////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'User-Agent'.
///
/// @par ABNF : User-Agent	= 	"User-Agent" HCOLON server-val *(LWS server-val)
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_User_Agent_s
{	
	TSIP_DECLARE_HEADER;
	char *value;
}
tsip_header_User_Agent_t;

TINYSIP_API tsip_header_User_Agent_t* tsip_header_User_Agent_create(const char* ua);
TINYSIP_API tsip_header_User_Agent_t* tsip_header_User_Agent_create_null();

TINYSIP_API tsip_header_User_Agent_t *tsip_header_User_Agent_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_User_Agent_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_USER_AGENT_H_ */

