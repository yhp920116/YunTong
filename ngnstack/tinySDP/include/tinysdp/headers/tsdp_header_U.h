
/* 2012-03-07 */

#ifndef _TSDP_HEADER_U_H_
#define _TSDP_HEADER_U_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_U_VA_ARGS(value)		tsdp_header_U_def_t, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "u=" header (URI).
///
/// @par ABNF : u=uri 
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_U_s
{	
	TSDP_DECLARE_HEADER;
	char* value;
}
tsdp_header_U_t;

typedef tsk_list_t tsdp_headers_U_L_t;

TINYSDP_API tsdp_header_U_t* tsdp_header_U_create(const char* value);
TINYSDP_API tsdp_header_U_t* tsdp_header_U_create_null();

TINYSDP_API tsdp_header_U_t *tsdp_header_U_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_U_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_U_H_ */

