
/* 2012-03-07 */

#ifndef _TSIP_HEADER_MIME_VERSION_H_
#define _TSIP_HEADER_MIME_VERSION_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'MIME-Version'.
///
/// @par ABNF
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_MIME_Version_s
{	
	TSIP_DECLARE_HEADER;
}
tsip_header_MIME_Version_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_MIME_VERSION_H_ */

