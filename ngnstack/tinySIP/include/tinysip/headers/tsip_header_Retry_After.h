
/* 2012-03-07 */

#ifndef _TSIP_HEADER_RETRY_AFTER_H_
#define _TSIP_HEADER_RETRY_AFTER_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Retry-After'.
///
/// @par ABNF
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Retry_After_s
{	
	TSIP_DECLARE_HEADER;
}
tsip_header_Retry_After_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_RETRY_AFTER_H_ */

