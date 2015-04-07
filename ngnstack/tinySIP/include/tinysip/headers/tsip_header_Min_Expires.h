
/* 2012-03-07 */

#ifndef _TSIP_HEADER_MIN_EXPIRES_H_
#define _TSIP_HEADER_MIN_EXPIRES_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_MIN_EXPIRES_VA_ARGS(value)		tsip_header_Min_Expires_def_t, (int32_t) value

#define TSIP_HEADER_MIN_EXPIRES_NONE				-1
#define TSIP_HEADER_MIN_EXPIRES_DEFAULT				30

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Min-Expires' as per RFC 3261.
///
/// @par ABNF: Min-Expires = "Min-Expires" HCOLON delta-seconds
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Min_Expires_s
{	
	TSIP_DECLARE_HEADER;

	int32_t value;
}
tsip_header_Min_Expires_t;

TINYSIP_API tsip_header_Min_Expires_t* tsip_header_Min_Expires_create(int32_t value);
TINYSIP_API tsip_header_Min_Expires_t* tsip_header_Min_Expires_create_null();

TINYSIP_API tsip_header_Min_Expires_t *tsip_header_Min_Expires_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Min_Expires_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_MIN_EXPIRES_H_ */

