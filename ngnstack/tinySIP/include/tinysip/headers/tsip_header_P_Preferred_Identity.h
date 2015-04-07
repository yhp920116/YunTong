
/* 2012-03-07 */

#ifndef _TSIP_HEADER_P_PREFERRED_IDENTITY_H_
#define _TSIP_HEADER_P_PREFERRED_IDENTITY_H_

#include "tinysip_config.h"

#include "tinysip/tsip_uri.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_P_PREFERRED_IDENTITY_VA_ARGS(uri)	tsip_header_P_Preferred_Identity_def_t, (const tsip_uri_t*)uri

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'P-Preferred-Identity' as per RFC 3325.
///
/// @par ABNF:  PPreferredID = "P-Preferred-Identity" HCOLON PPreferredID-value *(COMMA PPreferredID-value)
///       PPreferredID-value = name-addr / addr-spec
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_P_Preferred_Identity_s
{	
	TSIP_DECLARE_HEADER;

	tsip_uri_t *uri;
	char *display_name;
}
tsip_header_P_Preferred_Identity_t;

TINYSIP_API tsip_header_P_Preferred_Identity_t* tsip_header_P_Preferred_Identity_create(const tsip_uri_t* uri);
TINYSIP_API tsip_header_P_Preferred_Identity_t* tsip_header_P_Preferred_Identity_create_null();

TINYSIP_API tsip_header_P_Preferred_Identity_t *tsip_header_P_Preferred_Identity_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_P_Preferred_Identity_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_P_PREFERRED_IDENTITY_H_ */

