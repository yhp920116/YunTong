
/* 2012-03-07 */

#ifndef _TSIP_HEADER_REFER_TO_H_
#define _TSIP_HEADER_REFER_TO_H_

#include "tinysip_config.h"

#include "tinysip/tsip_uri.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_REFER_TO_VA_ARGS(uri)	tsip_header_Refer_To_def_t, (const tsip_uri_t*)uri

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Refer-To' .
///
/// @par ABNF: Refer-To	= 	( "Refer-To" / "r" ) HCOLON ( name-addr / addr-spec ) *(SEMI refer-param)
/// refer-param	= 	generic-param / feature-param
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Refer_To_s
{	
	TSIP_DECLARE_HEADER;

	char *display_name;
	tsip_uri_t *uri;
}
tsip_header_Refer_To_t;

TSIP_END_DECLS

TINYSIP_API tsip_header_Refer_To_t* tsip_header_Refer_To_create(const tsip_uri_t* uri);
TINYSIP_API tsip_header_Refer_To_t* tsip_header_Refer_To_create_null();

TINYSIP_API tsip_header_Refer_To_t *tsip_header_Refer_To_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Refer_To_def_t;

#endif /* _TSIP_HEADER_REFER_TO_H_ */

