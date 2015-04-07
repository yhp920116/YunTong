
/* 2012-03-07 */


#ifndef _TSIP_HEADER_CONTENT_LENGTH_H_
#define _TSIP_HEADER_CONTENT_LENGTH_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_CONTENT_LENGTH_VA_ARGS(length)	tsip_header_Content_Length_def_t, (uint32_t)length

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Content-Length'.
///
/// @par ABNF: Content-Length / l
/// Content-Length	= 	( "Content-Length" / "l" ) HCOLON 1*DIGIT
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Content_Length_s
{	
	TSIP_DECLARE_HEADER;

	uint32_t length;
}
tsip_header_Content_Length_t;

TINYSIP_API tsip_header_Content_Length_t* tsip_header_Content_Length_create(uint32_t length);
TINYSIP_API tsip_header_Content_Length_t* tsip_header_Content_Length_create_null();

TINYSIP_API tsip_header_Content_Length_t *tsip_header_Content_Length_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Content_Length_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_CONTENT_LENGTH_H_ */

