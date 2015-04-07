
/* 2012-03-07 */

#ifndef _TSIP_HEADER_REFER_SUB_H_
#define _TSIP_HEADER_REFER_SUB_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_REFER_SUB_VA_ARGS(sub)		tsip_header_Refer_Sub_def_t, (tsk_bool_t)sub

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Refer-Sub'.
///
/// @par ABNF : Refer-Sub	= 	"Refer-Sub" HCOLON refer-sub-value *(SEMI exten)
/// refer-sub-value	= 	"true" / "false"
/// exten	= 	generic-param
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Refer_Sub_s
{	
	TSIP_DECLARE_HEADER;

	tsk_bool_t sub;
}
tsip_header_Refer_Sub_t;

TINYSIP_API tsip_header_Refer_Sub_t* tsip_header_Refer_Sub_create(tsk_bool_t sub);
TINYSIP_API tsip_header_Refer_Sub_t* tsip_header_Refer_Sub_create_null();

TINYSIP_API tsip_header_Refer_Sub_t *tsip_header_Refer_Sub_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Refer_Sub_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_REFER_SUB_H_ */

