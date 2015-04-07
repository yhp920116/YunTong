
/* 2012-03-07 */

#ifndef _TSIP_HEADER_ALLOW_EVENTS_H_
#define _TSIP_HEADER_ALLOW_EVENTS_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS


////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Allow-Events'.
///
/// @par ABNF : Allow-Events	=  	 ( "Allow-Events" / "u" ) HCOLON event-type *(COMMA event-type)
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Allow_Events_s
{	
	TSIP_DECLARE_HEADER;

	tsk_strings_L_t *events;
}
tsip_header_Allow_Events_t;

TINYSIP_API tsip_header_Allow_Events_t* tsip_header_Allow_Events_create();

TINYSIP_API tsip_header_Allow_Events_t *tsip_header_Allow_Events_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Allow_Events_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_ALLOW_EVENTS_H_ */

