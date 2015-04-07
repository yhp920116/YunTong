
/* 2012-03-07 */

#ifndef _TSIP_HEADER_ACCEPT_H_
#define _TSIP_HEADER_ACCEPT_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

// The ' in the media-range field is used for doxygen (escape) and is not part of the abnf.
////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Accept' as per RFC 3261 subclause 20.1.
///
/// @par ABNF = Accept = "Accept" HCOLON [ accept-range *(COMMA accept-range) ] ; example: ;
/// 	Accept: application/dialog-info+xml 
///		accept-range = media-range *(SEMI accept-param)
/// 	media-range = ( "*'/*" / ( m-type SLASH "*" ) / ( m-type SLASH m-subtype ) )  *( SEMI m-parameter ) 
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Accept_s
{	
	TSIP_DECLARE_HEADER;
}
tsip_header_Accept_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_ACCEPT_H_ */

