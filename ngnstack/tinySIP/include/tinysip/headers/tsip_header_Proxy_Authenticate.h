
/* 2012-03-07 */

#ifndef _TSIP_HEADER_PROXY_AUTHENTICATE_H_
#define _TSIP_HEADER_PROXY_AUTHENTICATE_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Proxy-Authenticate'.
///
/// @par ABNF = Proxy-Authenticate	= 	"Proxy-Authenticate" HCOLON challenge
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
typedef struct tsip_header_Proxy_Authenticate_s
{	
	TSIP_DECLARE_HEADER;
	
	char* scheme;
	char* realm;
	char* domain;
	char* nonce;
	char* opaque;
	tsk_bool_t stale;
	char* algorithm;
	char* qop;
}
tsip_header_Proxy_Authenticate_t;

tsip_header_Proxy_Authenticate_t *tsip_header_Proxy_Authenticate_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Proxy_Authenticate_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_PROXY_AUTHENTICATE_H_ */
