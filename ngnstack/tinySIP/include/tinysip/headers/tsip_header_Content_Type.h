
/* 2012-03-07 */

#ifndef _TSIP_HEADER_CONTENT_TYPE_H_
#define _TSIP_HEADER_CONTENT_TYPE_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_CONTENT_TYPE_VA_ARGS(type)	tsip_header_Content_Type_def_t, (const char*)type

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Content-Type'.
///
/// @par ABNF= Content-Type / c
///					Content-Type	= 	( "Content-Type" / "c" ) HCOLON media-type
///					media-type	= 	m-type SLASH m-subtype *( SEMI m-parameter)
/// 				m-type	= 	discrete-type / composite-type
///					discrete-type	= 	"text" / "image" / "audio" / "video" / "application" / extension-token
/// 				composite-type	= 	"message" / "multipart" / extension-token
/// 				extension-token	= 	ietf-token / x-token
/// 				ietf-token	= 	token
/// 				x-token	= 	"x-" token
/// 				m-subtype	= 	extension-token / iana-token
/// 				iana-token	= 	token
/// 				m-parameter	= 	m-attribute EQUAL m-value
/// 				m-attribute	= 	token
/// 				m-value	= 	token / quoted-string
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Content_Type_s
{	
	TSIP_DECLARE_HEADER;

	char* type;
}
tsip_header_Content_Type_t;

TINYSIP_API tsip_header_Content_Type_t* tsip_header_Content_Type_create(const char* type);
TINYSIP_API tsip_header_Content_Type_t* tsip_header_Content_Type_create_null();

TINYSIP_API tsip_header_Content_Type_t *tsip_header_Content_Type_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Content_Type_def_t;


TSIP_END_DECLS

#endif /* _TSIP_HEADER_CONTENT_TYPE_H_ */

