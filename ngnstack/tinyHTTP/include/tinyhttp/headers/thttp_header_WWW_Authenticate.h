
/* 2012-03-07 */

#ifndef _THTTP_HEADER_WWW_Authenticate_H_
#define _THTTP_HEADER_WWW_Authenticate_H_

#include "tinyhttp_config.h"
#include "tinyhttp/headers/thttp_header.h"

THTTP_BEGIN_DECLS


////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// HTTP header 'WWW-Authenticate'.
///
/// @par ABNF = WWW-Authenticate	= 	"WWW-Authenticate" HCOLON challenge
///				challenge	= 	("Digest" LWS digest-cln *(COMMA digest-cln)) / other-challenge
///				other-challenge	= 	auth-scheme / auth-param *(COMMA auth-param)
///				digest-cln	= 	realm / domain / nonce / opaque / stale / algorithm / qop-options / auth-param
///				realm	= 	"realm" EQUAL realm-value
///				realm-value	= 	quoted-string
///				domain	= 	"domain" EQUAL LDQUOT URI *( 1*SP URI ) RDQUOT
///				URI	= 	absoluteURI / abs-path
///				opaque	= 	"opaque" EQUAL quoted-string
///				stale	= 	"stale" EQUAL ( "true" / "false" )
///				qop-options	= 	"qop" EQUAL LDQUOT qop-value *("," qop-value) RDQUOT
///				qop-value	= 	"auth" / "auth-int" / token
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct thttp_header_WWW_Authenticate_s
{	
	THTTP_DECLARE_HEADER;

	char* scheme;
	char* realm;
	char* domain;
	char* nonce;
	char* opaque;
	tsk_bool_t stale;
	char* algorithm;
	char* qop;
}
thttp_header_WWW_Authenticate_t;

typedef thttp_header_WWW_Authenticate_t thttp_header_Proxy_Authenticate_t;

TINYHTTP_API thttp_header_WWW_Authenticate_t *thttp_header_WWW_Authenticate_parse(const char *data, tsk_size_t size);
TINYHTTP_API thttp_header_Proxy_Authenticate_t *thttp_header_Proxy_Authenticate_parse(const char *data, tsk_size_t size);

TINYHTTP_GEXTERN const tsk_object_def_t *thttp_header_WWW_Authenticate_def_t;

THTTP_END_DECLS

#endif /* _THTTP_HEADER_WWW_Authenticate_H_ */

