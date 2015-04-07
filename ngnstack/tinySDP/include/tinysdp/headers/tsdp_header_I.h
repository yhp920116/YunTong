
/* 2012-03-07 */

#ifndef _TSDP_HEADER_I_H_
#define _TSDP_HEADER_I_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_I_VA_ARGS(value)		tsdp_header_I_def_t, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "i=" header (Session Information).
///
/// @par ABNF : i=text 
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_I_s
{	
	TSDP_DECLARE_HEADER;
	char* value;
}
tsdp_header_I_t;

typedef tsk_list_t tsdp_headers_I_L_t;

TINYSDP_API tsdp_header_I_t* tsdp_header_I_create(const char* value);
TINYSDP_API tsdp_header_I_t* tsdp_header_I_create_null();

TINYSDP_API tsdp_header_I_t *tsdp_header_I_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_I_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_I_H_ */

