
/* 2012-03-07 */

#ifndef _TSIP_HEADER_RECORD_ROUTE_H_
#define _TSIP_HEADER_RECORD_ROUTE_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

#include "tinysip/tsip_uri.h"

TSIP_BEGIN_DECLS


#define TSIP_HEADER_RECORD_ROUTE_VA_ARGS(uri)	tsip_header_Record_Route_def_t, (const tsip_uri_t*)uri

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Record-Route'.
///
/// @par ABNF : Record-Route	= 	"Record-Route" HCOLON rec-route *(COMMA rec-route)
///				rec-route	= 	name-addr *( SEMI rr-param )
///				rr-param	= 	generic-param
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Record_Route_s
{	
	TSIP_DECLARE_HEADER;
	
	char* display_name;
	tsip_uri_t *uri;
}
tsip_header_Record_Route_t;

typedef tsk_list_t tsip_header_Record_Routes_L_t;

TINYSIP_API tsip_header_Record_Route_t* tsip_header_Record_Route_create(const tsip_uri_t* uri);
TINYSIP_API tsip_header_Record_Route_t* tsip_header_Record_Route_create_null();

TINYSIP_API tsip_header_Record_Routes_L_t *tsip_header_Record_Route_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Record_Route_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_RECORD_ROUTE_H_ */

