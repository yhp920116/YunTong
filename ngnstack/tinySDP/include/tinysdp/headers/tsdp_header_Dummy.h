
/* 2012-03-07 */

#ifndef _TSDP_HEADER_DUMMY_H_
#define _TSDP_HEADER_DUMMY_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_DUMMY_VA_ARGS(name, value)		tsdp_header_Dummy_def_t, (char)name, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP Dummy header.
///
/// @par ABNF : alpha SP* "=" SP*<: any*
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_Dummy_s
{	
	TSDP_DECLARE_HEADER;
	char name;
	char *value;
}
tsdp_header_Dummy_t;

typedef tsk_list_t tsdp_headers_Dummy_L_t;

TINYSDP_API tsdp_header_Dummy_t* tsdp_header_dummy_create(char name, const char* value);
TINYSDP_API tsdp_header_Dummy_t* tsdp_header_dummy_create_null();

TINYSDP_API tsdp_header_Dummy_t *tsdp_header_Dummy_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_Dummy_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_DUMMY_H_ */

