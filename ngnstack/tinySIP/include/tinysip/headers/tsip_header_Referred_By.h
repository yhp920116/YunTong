
/* 2012-03-07 */

#ifndef _TSIP_HEADER_REFERRED_BY_H_
#define _TSIP_HEADER_REFERRED_BY_H_

#include "tinysip_config.h"

#include "tinysip/tsip_uri.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_REFERRED_BY_VA_ARGS(uri, cid)	tsip_header_Referred_By_def_t, (const tsip_uri_t*)uri, (const char*)cid

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Referred-By'.
///
/// @par ABNF: Referred-By	= 	( "Referred-By" / "b" ) HCOLON referrer-uri *( SEMI (referredby-id-param / generic-param) )
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Referred_By_s
{	
	TSIP_DECLARE_HEADER;

	char *display_name;
	tsip_uri_t *uri;

	char* cid;
}
tsip_header_Referred_By_t;

TINYSIP_API tsip_header_Referred_By_t* tsip_header_Referred_By_create(const tsip_uri_t* uri, const char* cid);
TINYSIP_API tsip_header_Referred_By_t* tsip_header_Referred_By_create_null();

TINYSIP_API tsip_header_Referred_By_t *tsip_header_Referred_By_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Referred_By_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_REFERRED_BY_H_ */

