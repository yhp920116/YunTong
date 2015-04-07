
/* 2012-03-07 */

#ifndef _THTTP_HEADER_CONTENT_TYPE_H_
#define _THTTP_HEADER_CONTENT_TYPE_H_

#include "tinyhttp_config.h"
#include "tinyhttp/headers/thttp_header.h"

THTTP_BEGIN_DECLS

#define THTTP_HEADER_CONTENT_TYPE_VA_ARGS(type)			thttp_header_Content_Type_def_t, (const char*)type

////////////////////////////////////////////////////////////////////////////////////////////////////
/// HTTP header 'Content-Type'.
///
/// @par ABNF= Content-Type
///					Content-Type	= 	( "Content-Type" ) HCOLON media-type
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
typedef struct thttp_header_Content_Type_s
{	
	THTTP_DECLARE_HEADER;

	char* type;
}
thttp_header_Content_Type_t;


thttp_header_Content_Type_t *thttp_header_Content_Type_parse(const char *data, tsk_size_t size);

TINYHTTP_GEXTERN const tsk_object_def_t *thttp_header_Content_Type_def_t;


THTTP_END_DECLS

#endif /* _THTTP_HEADER_CONTENT_TYPE_H_ */

