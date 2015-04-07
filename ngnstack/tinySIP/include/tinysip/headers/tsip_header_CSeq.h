
/* 2012-03-07 */

#ifndef _TSIP_HEADER_CSEQ_H_
#define _TSIP_HEADER_CSEQ_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

#include "tinysip/tsip_message_common.h" /* tsip_request_type_t */

TSIP_BEGIN_DECLS

#define TSIP_HEADER_CSEQ_VA_ARGS(seq, method)		tsip_header_CSeq_def_t, (int32_t) seq, (const char*)method

#define TSIP_HEADER_CSEQ_NONE						0
#define TSIP_HEADER_CSEQ_DEFAULT					1

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'CSeq'.
///
/// @par ABNF: CSeq	= 	"CSeq" HCOLON 1*DIGIT LWS Method
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_CSeq_s
{	
	TSIP_DECLARE_HEADER;

	char *method;
	uint32_t seq;
	tsip_request_type_t type;
}
tsip_header_CSeq_t;

TINYSIP_API tsip_header_CSeq_t* tsip_header_CSeq_create(int32_t seq, const char*method);

TINYSIP_API tsip_header_CSeq_t *tsip_header_CSeq_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_CSeq_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_CSEQ_H_ */

