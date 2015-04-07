
/* 2012-03-07 */

#ifndef _TMSRP_HEADER_MIN_EXPIRES_H_
#define _TMSRP_HEADER_MIN_EXPIRES_H_

#include "tinymsrp_config.h"
#include "tinymsrp/headers/tmsrp_header.h"

TMSRP_BEGIN_DECLS

#define TMSRP_HEADER_MIN_EXPIRES_VA_ARGS(value)		tmsrp_header_Min_Expires_def_t, (int64_t)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	MSRP 'Min-Expires' header.
///
/// @par ABNF :  Min-Expires	=  	"Min-Expires:" SP 1*DIGIT
///
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tmsrp_header_Min_Expires_s
{	
	TMSRP_DECLARE_HEADER;
	
	int64_t value;
}
tmsrp_header_Min_Expires_t;

typedef tsk_list_t tmsrp_headers_Min_Expires_L_t;


TINYMSRP_API tmsrp_header_Min_Expires_t* tmsrp_header_Min_Expires_create(int64_t value);
TINYMSRP_API tmsrp_header_Min_Expires_t* tmsrp_header_Min_Expires_create_null();

TINYMSRP_API tmsrp_header_Min_Expires_t *tmsrp_header_Min_Expires_parse(const char *data, tsk_size_t size);

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_header_Min_Expires_def_t;

TMSRP_END_DECLS

#endif /* _TMSRP_HEADER_MIN_EXPIRES_H_ */

