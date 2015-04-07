
/* 2012-03-07 */

#ifndef _TSDP_HEADER_S_H_
#define _TSDP_HEADER_S_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_S_VA_ARGS(value)		tsdp_header_S_def_t, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "s=" header (Session Name).
///
/// @par ABNF : s=text 
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_S_s
{	
	TSDP_DECLARE_HEADER;
	char* value;
}
tsdp_header_S_t;

TINYSDP_API tsdp_header_S_t* tsdp_header_S_create(const char* value);
TINYSDP_API tsdp_header_S_t* tsdp_header_S_create_null();

TINYSDP_API tsdp_header_S_t *tsdp_header_S_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_S_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_S_H_ */

