
/* 2012-03-07 */

#ifndef _TSIP_HEADER_MAX_FORWARDS_H_
#define _TSIP_HEADER_MAX_FORWARDS_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS


#define TSIP_HEADER_MAX_FORWARDS_VA_ARGS(max)		tsip_header_Max_Forwards_def_t, (int32_t) max

#define TSIP_HEADER_MAX_FORWARDS_NONE				-1
#define TSIP_HEADER_MAX_FORWARDS_DEFAULT			70

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Max-Forwards'.
///
/// @par ABNF: Max-Forwards = "Max-Forwards" HCOLON 1*DIGIT
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Max_Forwards_s
{	
	TSIP_DECLARE_HEADER;

	int32_t value;
}
tsip_header_Max_Forwards_t;

TINYSIP_API tsip_header_Max_Forwards_t* tsip_header_Max_Forwards_create(int32_t max);

TINYSIP_API tsip_header_Max_Forwards_t *tsip_header_Max_Forwards_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Max_Forwards_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_MAX_FORWARDS_H_ */

