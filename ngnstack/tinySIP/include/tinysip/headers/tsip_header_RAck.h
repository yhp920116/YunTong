
/* 2012-03-07 */

#ifndef _TSIP_HEADER_RACK_H_
#define _TSIP_HEADER_RACK_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_RACK_VA_ARGS(seq, cseq, method)		tsip_header_RAck_def_t, (uint32_t)seq, (uint32_t)cseq, (const char*)method

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'RAck' as per RFC 3262.
///
/// @par ABNF : "RAck" HCOLON response-num  LWS  CSeq-num  LWS  Method
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_RAck_s
{	
	TSIP_DECLARE_HEADER;

	uint32_t seq;
	uint32_t cseq;
	char* method;
}
tsip_header_RAck_t;


TINYSIP_API tsip_header_RAck_t* tsip_header_RAck_create(uint32_t seq, uint32_t cseq, const char* method);
TINYSIP_API tsip_header_RAck_t* tsip_header_RAck_create_null();

TINYSIP_API tsip_header_RAck_t *tsip_header_RAck_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_RAck_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_RACK_H_ */

