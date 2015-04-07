
/* 2012-03-07 */

#ifndef _TMSRP_HEADER_STATUS_H_
#define _TMSRP_HEADER_STATUS_H_

#include "tinymsrp_config.h"
#include "tinymsrp/headers/tmsrp_header.h"

TMSRP_BEGIN_DECLS

#define TMSRP_HEADER_STATUS_VA_ARGS(namespace, code, reason)		tmsrp_header_Status_def_t, (short)namespace, (short)code, (const char*)reason

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	MSRP 'Status' header.
///
/// @par ABNF :  Status	=  	 "Status:" SP namespace  SP status-code  [SP text-reason]
/// namespace	= 	3(DIGIT) ; "000" for all codes defined in RFC 4975
/// text-reason	= 	utf8text 
///
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tmsrp_header_Status_s
{	
	TMSRP_DECLARE_HEADER;

	short _namespace;
	short code;
	char* reason;
}
tmsrp_header_Status_t;

typedef tsk_list_t tmsrp_headers_Status_L_t;

TINYMSRP_API tmsrp_header_Status_t* tmsrp_header_Status_create(short _namespace, short code, const char* reason);
TINYMSRP_API tmsrp_header_Status_t* tmsrp_header_Status_create_null();

TINYMSRP_API tmsrp_header_Status_t *tmsrp_header_Status_parse(const char *data, tsk_size_t size);

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_header_Status_def_t;

TMSRP_END_DECLS

#endif /* _TMSRP_HEADER_STATUS_H_ */

