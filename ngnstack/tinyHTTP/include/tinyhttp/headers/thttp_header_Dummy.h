
/* 2012-03-07 */

#ifndef _THTTP_HEADER_DUMMY_H_
#define _THTTP_HEADER_DUMMY_H_

#include "tinyhttp_config.h"
#include "tinyhttp/headers/thttp_header.h"

THTTP_BEGIN_DECLS

#define THTTP_HEADER_DUMMY_VA_ARGS(name, value)		thttp_header_Dummy_def_t, (const char*)name, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// HTTP Dummy header.
///
/// @par ABNF : token SP* HCOLON SP*<: any*
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct thttp_header_Dummy_s
{	
	THTTP_DECLARE_HEADER;

	char *name;
	char *value;
}
thttp_header_Dummy_t;

thttp_header_Dummy_t *thttp_header_Dummy_parse(const char *data, tsk_size_t size);

TINYHTTP_GEXTERN const tsk_object_def_t *thttp_header_Dummy_def_t;

THTTP_END_DECLS

#endif /* _THTTP_HEADER_DUMMY_H_ */

