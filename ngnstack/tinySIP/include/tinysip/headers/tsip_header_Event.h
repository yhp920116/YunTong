
/* 2012-03-07 */

#ifndef _TSIP_HEADER_EVENT_H_
#define _TSIP_HEADER_EVENT_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_EVENT_VA_ARGS(package)		tsip_header_Event_def_t, (const char*)package

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Event/o' .
///
/// @par ABNF: Event / o
///	Event	= 	( "Event" / "o" ) HCOLON event-type *( SEMI event-param )
///	event-type	= 	event-package *( "." event-template )
///	event-package	= 	token-nodot
///	event-template	= 	token-nodot
///	token-nodot	= 	1*( alphanum / "-" / "!" / "%" / "*" / "_" / "+" / "`" / "'" / "~" )
///	event-param	= 	generic-param / ( "id" EQUAL token ) / call-ident / from-tag / to-tag / with-sessd
///	call-ident	= 	"call-id" EQUAL ( token / DQUOTE callid DQUOTE )
///	with-sessd	= 	"include-session-description"
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Event_s
{	
	TSIP_DECLARE_HEADER;

	char *package;
}
tsip_header_Event_t;

TINYSIP_API tsip_header_Event_t* tsip_header_Event_create(const char* package);

TINYSIP_API tsip_header_Event_t *tsip_header_Event_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Event_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_EVENT_H_ */

