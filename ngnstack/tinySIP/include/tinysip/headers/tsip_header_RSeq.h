
/* 2012-03-07 */

#ifndef _TSIP_HEADER_RSEQ_H_
#define _TSIP_HEADER_RSEQ_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_RSEQ_VA_ARGS(seq)		tsip_header_RSeq_def_t, (int32_t) seq

#define TSIP_HEADER_RSEQ_NONE						0
#define TSIP_HEADER_RSEQ_DEFAULT					1

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'RSeq' as per RFC 3262.
///
/// @par ABNF: "RSeq" HCOLON response-num
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_RSeq_s
{	
	TSIP_DECLARE_HEADER;
	uint32_t seq;
}
tsip_header_RSeq_t;


TINYSIP_API tsip_header_RSeq_t* tsip_header_RSeq_create(uint32_t seq);
TINYSIP_API tsip_header_RSeq_t* tsip_header_RSeq_create_null();

TINYSIP_API tsip_header_RSeq_t *tsip_header_RSeq_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_RSeq_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_RSEQ_H_ */

