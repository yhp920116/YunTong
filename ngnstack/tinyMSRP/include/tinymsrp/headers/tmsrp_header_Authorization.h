
/* 2012-03-07 */

#ifndef _TMSRP_HEADER_AUTHORIZATION_H_
#define _TMSRP_HEADER_AUTHORIZATION_H_

#include "tinymsrp_config.h"
#include "tinymsrp/headers/tmsrp_header.h"

TMSRP_BEGIN_DECLS

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	MSRP header 'Authorization' as per RFC 3261 subclause .
///
/// @par ABNF = Authorization	= 	"Authorization" HCOLON credentials
/// 								credentials	= 	("Digest" LWS digest-response) / other-response
/// 								digest-response	= 	dig-resp *(COMMA dig-resp)
/// 								dig-resp	= 	username / realm / nonce / digest-uri / dresponse / algorithm / cnonce / opaque / message-qop / nonce-count / auth-param / auts
/// 								username	= 	"username" EQUAL username-value
/// 								username-value	= 	quoted-string
/// 								digest-uri	= 	"uri" EQUAL LDQUOT digest-uri-value RDQUOT
/// 								digest-uri-value	= 	auth-request-uri ; equal to request-uri as specified by HTTP/1.1
/// 								message-qop	= 	"qop" EQUAL qop-value
/// 								cnonce	= 	"cnonce" EQUAL cnonce-value
/// 								cnonce-value	= 	nonce-value
/// 								nonce-count	= 	"nc" EQUAL nc-value
/// 								nc-value	= 	8LHEX
/// 								dresponse	= 	"response" EQUAL request-digest
/// 								request-digest	= 	LDQUOT 32LHEX RDQUOT
/// 								auth-request-uri = not-defined
/// 								 
/// 								auth-param	= 	auth-param-name EQUAL ( token / quoted-string )
/// 								auth-param-name	= 	token
/// 								 
/// 								other-response	= 	auth-scheme LWS auth-param *(COMMA auth-param)
/// 								auth-scheme	= 	token
/// 								auts	= 	"auts" EQUAL auts-param
/// 								auts-param	= 	LDQUOT auts-value RDQUOT
/// 								auts-value	= 	<base64 encoding of AUTS>
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tmsrp_header_Authorization_s
{	
	TMSRP_DECLARE_HEADER;

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

	tsk_params_L_t *params;
}
tmsrp_header_Authorization_t;

tmsrp_header_Authorization_t *tmsrp_header_Authorization_parse(const char *data, tsk_size_t size);

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_header_Authorization_def_t;

TMSRP_END_DECLS

#endif /* _TMSRP_HEADER_AUTHORIZATION_H_ */

