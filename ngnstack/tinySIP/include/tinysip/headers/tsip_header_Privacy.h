
/* 2012-03-07 */


#ifndef _TSIP_HEADER_PRIVACY_H_
#define _TSIP_HEADER_PRIVACY_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS


////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Privacy' as per RFC 3323.
///
/// @par ABNF: Privacy = Privacy-hdr
/// Privacy-hdr	= 	"Privacy" HCOLON priv-value *(";" priv-value)
/// priv-value	= 	"header" / "session" / "user" / "none" / "critical" / "id" / "history" / token
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Privacy_s
{	
	TSIP_DECLARE_HEADER;

	tsk_strings_L_t *values;
}
tsip_header_Privacy_t;

TINYSIP_API tsip_header_Privacy_t* tsip_header_Privacy_create();

TINYSIP_API tsip_header_Privacy_t *tsip_header_Privacy_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Privacy_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_PRIVACY_H_ */

