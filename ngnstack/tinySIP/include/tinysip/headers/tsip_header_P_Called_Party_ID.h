
/* 2012-03-07 */

#ifndef _TSIP_HEADER_P_CALLED_PARTY_ID_H_
#define _TSIP_HEADER_P_CALLED_PARTY_ID_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'P-Called-Party-ID'.
///
/// @par ABNF
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_P_Called_Party_ID_s
{	
	TSIP_DECLARE_HEADER;
}
tsip_header_P_Called_Party_ID_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_P_CALLED_PARTY_ID_H_ */