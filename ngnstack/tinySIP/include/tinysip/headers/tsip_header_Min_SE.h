
/* 2012-03-07 */

#ifndef _TSIP_HEADER_MIN_SE_H_
#define _TSIP_HEADER_MIN_SE_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_MIN_SE_VA_ARGS(delta_seconds)		tsip_header_Min_SE_def_t, (int64_t)delta_seconds

#define TSIP_SESSION_EXPIRES_MIN_VALUE					90

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Min-SE'.
///
/// @par ABNF : Min-SE	= 	"Min-SE" HCOLON delta-seconds *(SEMI generic-param)
/// 
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Min_SE_s
{	
	TSIP_DECLARE_HEADER;

	int64_t delta_seconds;
}
tsip_header_Min_SE_t;

TINYSIP_API tsip_header_Min_SE_t* tsip_header_Min_SE_create(int64_t delta_seconds);

TINYSIP_API tsip_header_Min_SE_t *tsip_header_Min_SE_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Min_SE_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_MIN_SE_H_ */

