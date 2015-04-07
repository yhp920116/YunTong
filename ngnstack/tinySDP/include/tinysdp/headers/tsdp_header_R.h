
/* 2012-03-07 */

#ifndef _TSDP_HEADER_R_H_
#define _TSDP_HEADER_R_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

#include "tsk_string.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_R_VA_ARGS()		tsdp_header_R_def_t

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "r=" header (Repeat Times).
///
/// The "e=" line "r=" fields specify repeat times for a session.
///
/// @par ABNF : r= repeat-interval SP  typed-time  1*(SP typed-time)
/// repeat-interval = POS-DIGIT *DIGIT [fixed-len-time-unit]
/// typed-time	=  	1*DIGIT [fixed-len-time-unit] 
/// 1*DIGIT [fixed-len-time-unit] 
/// fixed-len-time-unit	=  	"d" / "h" / "m" / "s"
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_R_s
{	
	TSDP_DECLARE_HEADER;
	char* repeat_interval;
	char* typed_time;
	tsk_strings_L_t* typed_times;
}
tsdp_header_R_t;

typedef tsk_list_t tsdp_headers_R_L_t;

TINYSDP_API tsdp_header_R_t* tsdp_header_R_create();
TINYSDP_API tsdp_header_R_t* tsdp_header_R_create_null();

TINYSDP_API tsdp_header_R_t *tsdp_header_R_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_R_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_R_H_ */

