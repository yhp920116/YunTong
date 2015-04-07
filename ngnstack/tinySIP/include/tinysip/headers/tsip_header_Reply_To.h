
/* 2012-03-07 */

#ifndef _TSIP_HEADER_REPLY_TO_H_
#define _TSIP_HEADER_REPLY_TO_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @brief	SIP header 'Reply_To'.
///
/// @par ABNF
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Reply_To_s
{	
	TSIP_DECLARE_HEADER;
}
tsip_header_Reply_To_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_REPLY_TO_H_ */

