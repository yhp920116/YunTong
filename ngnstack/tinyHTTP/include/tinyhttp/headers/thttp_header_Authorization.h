
/* 2012-03-07 */

#ifndef _THTTP_HEADER_AUTHORIZATION_H_
#define _THTTP_HEADER_AUTHORIZATION_H_

#include "tinyhttp_config.h"
#include "tinyhttp/headers/thttp_header.h"


THTTP_BEGIN_DECLS

////////////////////////////////////////////////////////////////////////////////////////////////////
/// HTTP header 'Authorization' .
///
/// @par ABNF = Authorization  = "Authorization" ":" credentials
///				credentials      = "Digest" digest-response
///				digest-response  = digest-response-value *(COMMA digest-response-value)
///				digest-response-value = ( username / realm / nonce / digest-url / auth-response / [ algorithm ] / [cnonce] / [opaque] / [message-qop] / [nonce-count]  / [auth-param] )
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct thttp_header_Authorization_s
{	
	THTTP_DECLARE_HEADER;

	char* scheme;
	char* username;
	char* realm;
	char* nonce;
	char* uri;
	char* response;
	char* algorithm;
	char* cnonce;
	char* opaque;
	char* qop;
	char* nc;
}
thttp_header_Authorization_t;
typedef thttp_header_Authorization_t thttp_header_Proxy_Authorization_t;

TINYHTTP_API  thttp_header_Authorization_t *thttp_header_Authorization_parse(const char *data, tsk_size_t size);
TINYHTTP_API thttp_header_Proxy_Authorization_t *thttp_header_Proxy_Authorization_parse(const char *data, tsk_size_t size);

thttp_header_Authorization_t* thttp_header_authorization_create();

TINYHTTP_GEXTERN const tsk_object_def_t *thttp_header_Authorization_def_t;

THTTP_END_DECLS

#endif /* _THTTP_HEADER_AUTHORIZATION_H_ */

