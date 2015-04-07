
/* 2012-03-07 */

#ifndef _TSIP_HEADER_SERVER_H_
#define _TSIP_HEADER_SERVER_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS


#define TSIP_HEADER_SERVER_VA_ARGS(server)		tsip_header_Server_def_t, (const char*)server


////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Server'.
///
/// @par ABNF: Server	= 	"Server" HCOLON server-val *(LWS server-val)
/// server-val	= 	product / comment
/// product	= 	token [SLASH product-version]
/// product-version	= 	token
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Server_s
{	
	TSIP_DECLARE_HEADER;
	char* value;
}
tsip_header_Server_t;

TINYSIP_API tsip_header_Server_t* tsip_header_server_create(const char* server);
TINYSIP_API tsip_header_Server_t* tsip_header_server_create_null();

TINYSIP_API tsip_header_Server_t *tsip_header_Server_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Server_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_SERVER_H_ */

