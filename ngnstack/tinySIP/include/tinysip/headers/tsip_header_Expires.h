
/* 2012-03-07 */

#ifndef _TSIP_HEADER_EXPIRES_H_
#define _TSIP_HEADER_EXPIRES_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_EXPIRES_VA_ARGS(delta_seconds)		tsip_header_Expires_def_t, (int64_t)delta_seconds

#define TSIP_HEADER_EXPIRES_NONE						-1
#define TSIP_HEADER_EXPIRES_DEFAULT						600000

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Expires'.
///
/// @par ABNF: Expires	= 	"Expires" HCOLON delta-seconds
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Expires_s
{	
	TSIP_DECLARE_HEADER;

	int64_t delta_seconds;
}
tsip_header_Expires_t;

TINYSIP_API tsip_header_Expires_t* tsip_header_Expires_create(int64_t delta_seconds);

TINYSIP_API tsip_header_Expires_t *tsip_header_Expires_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Expires_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_EXPIRES_H_ */

