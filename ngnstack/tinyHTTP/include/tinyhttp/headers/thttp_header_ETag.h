
/* 2012-03-07 */

#ifndef _THTTP_HEADER_ETAG_H_
#define _THTTP_HEADER_ETAG_H_

#include "tinyhttp_config.h"
#include "tinyhttp/headers/thttp_header.h"

THTTP_BEGIN_DECLS

#define THTTP_HEADER_ETAG_VA_ARGS(value)		thttp_header_ETag_def_t, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// HTTP ETag header.
///
/// @par ABNF : ETag = "ETag" ":" entity-tag
/// 	entity-tag = [ weak ] opaque-tag
/// 	weak       = "W/"
/// 	opaque-tag = quoted-string
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct thttp_header_ETag_s
{	
	THTTP_DECLARE_HEADER;

	char *value;
	tsk_bool_t isWeak;
}
thttp_header_ETag_t;

thttp_header_ETag_t *thttp_header_ETag_parse(const char *data, tsk_size_t size);

thttp_header_ETag_t* thttp_header_etag_create(const char* value);
thttp_header_ETag_t* thttp_header_etag_create_null();

TINYHTTP_GEXTERN const tsk_object_def_t *thttp_header_ETag_def_t;

THTTP_END_DECLS

#endif /* _THTTP_HEADER_ETAG_H_ */

