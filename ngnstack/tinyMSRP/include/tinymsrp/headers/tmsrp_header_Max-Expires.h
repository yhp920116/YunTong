
/* 2012-03-07 */

#ifndef _TMSRP_HEADER_MAX_EXPIRES_H_
#define _TMSRP_HEADER_MAX_EXPIRES_H_

#include "tinymsrp_config.h"
#include "tinymsrp/headers/tmsrp_header.h"

TMSRP_BEGIN_DECLS

#define TMSRP_HEADER_MAX_EXPIRES_VA_ARGS(value)		tmsrp_header_Max_Expires_def_t, (int64_t)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	MSRP 'Max-Expires' header.
///
/// @par ABNF :  Max-Expires	=  	"Max-Expires:" SP 1*DIGIT
///
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tmsrp_header_Max_Expires_s
{	
	TMSRP_DECLARE_HEADER;
	
	int64_t value;
}
tmsrp_header_Max_Expires_t;

typedef tsk_list_t tmsrp_headers_Max_Expires_L_t;


TINYMSRP_API tmsrp_header_Max_Expires_t* tmsrp_header_Max_Expires_create(int64_t value);
TINYMSRP_API tmsrp_header_Max_Expires_t* tmsrp_header_Max_Expires_create_null();

TINYMSRP_API tmsrp_header_Max_Expires_t *tmsrp_header_Max_Expires_parse(const char *data, tsk_size_t size);

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_header_Max_Expires_def_t;

TMSRP_END_DECLS

#endif /* _TMSRP_HEADER_MAX_EXPIRES_H_ */

