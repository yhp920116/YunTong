
/* 2012-03-07 */

#ifndef _TSDP_HEADER_Z_H_
#define _TSDP_HEADER_Z_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_Z_VA_ARGS(time, shifted_back, typed_time)		tsdp_header_Z_def_t, (uint64_t)time, (tsk_bool_t)shifted_back, (const char*)typed_time

typedef struct tsdp_zone_s
{
	TSK_DECLARE_OBJECT;

	uint64_t time;
	tsk_bool_t shifted_back;
	char* typed_time;
}
tsdp_zone_t;
typedef tsk_list_t tsdp_zones_L_t;

TINYSDP_API tsdp_zone_t* tsdp_zone_create(uint64_t time, tsk_bool_t shifted_back, const char* typed_time) ;
TINYSDP_API tsdp_zone_t* tsdp_zone_create_null();

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "z=" header (Time Zones).
///
/// @par ABNF :  z=time  SP ["-"] typed-time
/// *(SP time SP ["-"] typed-time)
/// time	=  	POS-DIGIT 9*DIGIT
/// typed-time	=  	1*DIGIT [fixed-len-time-unit]
/// fixed-len-time-unit	= 	"d" / "h" / "m" / "s" 
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_Z_s
{	
	TSDP_DECLARE_HEADER;

	tsdp_zones_L_t* zones;
}
tsdp_header_Z_t;

typedef tsk_list_t tsdp_headers_Z_L_t;

TINYSDP_API tsdp_header_Z_t* tsdp_header_Z_create(uint64_t time, tsk_bool_t shifted_back, const char* typed_time);
TINYSDP_API tsdp_header_Z_t* tsdp_header_Z_create_null();

TINYSDP_API tsdp_header_Z_t *tsdp_header_Z_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_Z_def_t;
TINYSDP_GEXTERN const tsk_object_def_t *tsdp_zone_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_Z_H_ */

