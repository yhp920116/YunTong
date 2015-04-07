
/* 2012-03-07 */

#ifndef _TSDP_HEADER_A_H_
#define _TSDP_HEADER_A_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_A_VA_ARGS(field, value)		tsdp_header_A_def_t, (const char*)(field), (const char*)(value)

#define TSDP_HEADER_A(self)		((tsdp_header_A_t*)(self))

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "a=" header (Attributes).
///
/// @par ABNF :  a=attribute
/// attribute	=  	(att-field  ":" att-value) / att-field
/// att-field	= 	token
/// att-value	= 	byte-string 
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_A_s
{	
	TSDP_DECLARE_HEADER;

	char* field;
	char* value;
}
tsdp_header_A_t;

typedef tsk_list_t tsdp_headers_A_L_t;

TINYSDP_API tsdp_header_A_t* tsdp_header_A_create(const char* field, const char* value);
TINYSDP_API tsdp_header_A_t* tsdp_header_A_create_null();

TINYSDP_API tsdp_header_A_t *tsdp_header_A_parse(const char *data, tsk_size_t size);
TINYSDP_API int tsdp_header_A_removeAll_by_field(tsdp_headers_A_L_t *attributes, const char* field);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_A_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_A_H_ */

