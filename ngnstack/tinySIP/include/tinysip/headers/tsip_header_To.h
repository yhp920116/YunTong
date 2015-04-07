
/* 2012-03-07 */

#ifndef _TSIP_HEADER_TO_H_
#define _TSIP_HEADER_TO_H_

#include "tinysip_config.h"
#include "tinysip/tsip_uri.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS


#define TSIP_HEADER_TO_VA_ARGS(display_name, uri, tag)			tsip_header_To_def_t, (const char*)display_name, (const tsip_uri_t*)uri, (const char*)tag

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'To' .
///
/// @par ABNF: To	= 	To	= 	( "To" / "t" ) HCOLON ( name-addr / addr-spec ) *( SEMI to-param )
/// to-param	= 	tag-param / generic-param
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_To_s
{	
	TSIP_DECLARE_HEADER;
	
	char *display_name;
	tsip_uri_t *uri;
	char *tag;
}
tsip_header_To_t;

TINYSIP_API tsip_header_To_t* tsip_header_To_create(const char* display_name, const tsip_uri_t* uri, const char* tag);
TINYSIP_API tsip_header_To_t* tsip_header_To_create_null();

TINYSIP_API tsip_header_To_t *tsip_header_To_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_To_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_TO_H_ */

