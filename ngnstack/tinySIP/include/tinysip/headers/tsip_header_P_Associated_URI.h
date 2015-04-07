
/* 2012-03-07 */

#ifndef _TSIP_HEADER_P_ASSOCIATED_URI_H_
#define _TSIP_HEADER_P_ASSOCIATED_URI_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

#include "tinysip/tsip_uri.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_P_ASSOCIATED_URI_VA_ARGS(uri)		tsip_header_P_Associated_URI_def_t, (const tsip_uri_t*)uri

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'P-Associated-URI' as per RFC 3455.
///
/// @par ABNF: P-Associated-URI	= 	"P-Associated-URI" HCOLON p-aso-uri-spec *(COMMA p-aso-uri-spec)
/// p-aso-uri-spec	= 	name-addr *( SEMI ai-param )
/// ai-param	= 	generic-param
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_P_Associated_URI_s
{	
	TSIP_DECLARE_HEADER;

	char *display_name;
	tsip_uri_t *uri;
}
tsip_header_P_Associated_URI_t;

typedef tsk_list_t tsip_header_P_Associated_URIs_L_t;

TINYSIP_API tsip_header_P_Associated_URI_t* tsip_header_P_Associated_URI_create(const tsip_uri_t* uri);
TINYSIP_API tsip_header_P_Associated_URI_t* tsip_header_P_Associated_URI_create_null();

TINYSIP_API tsip_header_P_Associated_URIs_L_t *tsip_header_P_Associated_URI_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_P_Associated_URI_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_P_ASSOCIATED_URI_H_ */

