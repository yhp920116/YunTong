
/* 2012-03-07 */

#ifndef _TSDP_HEADER_B_H_
#define _TSDP_HEADER_B_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS


#define TSDP_HEADER_B_VA_ARGS(bwtype, bandwidth)		tsdp_header_B_def_t, (const char*)bwtype, (uint32_t)bandwidth

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "b=" header (Bandwidth).
///
/// @par ABNF :  b=<bwtype> HCOLON <bandwidth>
/// bwtype	=  	token 
/// bandwidth	=  	1*DIGIT
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_B_s
{	
	TSDP_DECLARE_HEADER;

	char* bwtype;
	uint32_t bandwidth;
}
tsdp_header_B_t;

typedef tsk_list_t tsdp_headers_B_L_t;

TINYSDP_API tsdp_header_B_t* tsdp_header_B_create(const char* bwtype, uint32_t bandwidth);
TINYSDP_API tsdp_header_B_t* tsdp_header_b_create_null();

TINYSDP_API tsdp_header_B_t *tsdp_header_B_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_B_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_B_H_ */

