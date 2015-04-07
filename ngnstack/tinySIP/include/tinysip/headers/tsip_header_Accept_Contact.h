
/* 2012-03-07 */

#ifndef _TSIP_HEADER_ACCEPT_CONTACT_H_
#define _TSIP_HEADER_ACCEPT_CONTACT_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Accept-Contact' as per RFC 3261 subclause .
/// @date	12/3/2009
///
/// @par ABNF
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Accept_Contact_s
{	
	TSIP_DECLARE_HEADER;
}
tsip_header_Accept_Contact_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_ACCEPT_CONTACT_H_ */

