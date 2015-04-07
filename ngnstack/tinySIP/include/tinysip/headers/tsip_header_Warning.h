
/* 2012-03-07 */

#ifndef _TSIP_HEADER_WARNING_H_
#define _TSIP_HEADER_WARNING_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS


////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Warning'.
///
/// @par ABNF: Warning	= 	"Warning" HCOLON warning-value *(COMMA warning-value)
/// warning-value	= 	warn-code SP warn-agent SP warn-text
/// warn-code	= 	3DIGIT
/// warn-agent	= 	hostport / pseudonym
/// warn-text	= 	quoted-string
/// pseudonym	= 	token
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Warning_s
{	
	TSIP_DECLARE_HEADER;

	int32_t code;
	char* agent;
	char* text;
}
tsip_header_Warning_t;

typedef tsk_list_t tsip_header_Warnings_L_t;

tsip_header_Warning_t* tsip_header_Warning_create();

tsip_header_Warnings_L_t *tsip_header_Warning_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Warning_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_WARNING_H_ */

