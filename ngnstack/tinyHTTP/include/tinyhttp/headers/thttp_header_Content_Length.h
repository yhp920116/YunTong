
/* 2012-03-07 */

#ifndef _THTTP_HEADER_CONTENT_LENGTH_H_
#define _THTTP_HEADER_CONTENT_LENGTH_H_

#include "tinyhttp_config.h"
#include "tinyhttp/headers/thttp_header.h"

THTTP_BEGIN_DECLS

#define THTTP_HEADER_CONTENT_LENGTH_VA_ARGS(length)	thttp_header_Content_Length_def_t, (uint32_t)length

////////////////////////////////////////////////////////////////////////////////////////////////////
/// HTTP header 'Content-Length'.
///
/// @par ABNF: Content-Length / l
/// Content-Length	= 	"Content-Length" HCOLON 1*DIGIT
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct thttp_header_Content_Length_s
{	
	THTTP_DECLARE_HEADER;

	uint32_t length;
}
thttp_header_Content_Length_t;

thttp_header_Content_Length_t *thttp_header_Content_Length_parse(const char *data, tsk_size_t size);

TINYHTTP_GEXTERN const tsk_object_def_t *thttp_header_Content_Length_def_t;

THTTP_END_DECLS

#endif /* _THTTP_HEADER_CONTENT_LENGTH_H_ */

