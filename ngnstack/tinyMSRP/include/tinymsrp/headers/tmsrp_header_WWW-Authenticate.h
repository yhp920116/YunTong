
/* 2012-03-07 */

#ifndef _TMSRP_HEADER_WWW_Authenticate_H_
#define _TMSRP_HEADER_WWW_Authenticate_H_

#include "tinymsrp_config.h"
#include "tinymsrp/headers/tmsrp_header.h"

TMSRP_BEGIN_DECLS


////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	MSRP header 'WWW-Authenticate'.
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
typedef struct tmsrp_header_WWW_Authenticate_s
{	
	TMSRP_DECLARE_HEADER;

	char* scheme;
	char* realm;
	char* domain;
	char* nonce;
	char* opaque;
	unsigned stale:1;
	char* algorithm;
	char* qop;

	tsk_params_L_t* params;
}
tmsrp_header_WWW_Authenticate_t;

tmsrp_header_WWW_Authenticate_t *tmsrp_header_WWW_Authenticate_parse(const char *data, tsk_size_t size);

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_header_WWW_Authenticate_def_t;

TMSRP_END_DECLS

#endif /* _TMSRP_HEADER_WWW_Authenticate_H_ */

