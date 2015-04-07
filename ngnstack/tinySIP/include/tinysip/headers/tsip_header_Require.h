
/* 2012-03-07 */

#ifndef _TSIP_HEADER_REQUIRE_H_
#define _TSIP_HEADER_REQUIRE_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS


#define TSIP_HEADER_REQUIRE_VA_ARGS(option)	tsip_header_Require_def_t, (const char*)option

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Require'.
///
/// @par ABNF: Require	= 	"Require" HCOLON option-tag *(COMMA option-tag)
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Require_s
{	
	TSIP_DECLARE_HEADER;

	tsk_strings_L_t *options;
}
tsip_header_Require_t;

TINYSIP_API tsip_header_Require_t* tsip_header_Require_create(const char* option);
TINYSIP_API tsip_header_Require_t* tsip_header_Require_create_null();

TINYSIP_API tsip_header_Require_t *tsip_header_Require_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Require_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_REQUIRE_H_ */

