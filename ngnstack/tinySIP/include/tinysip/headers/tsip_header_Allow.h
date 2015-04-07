
/* 2012-03-07 */

#ifndef _TSIP_HEADER_ALLOW_H_
#define _TSIP_HEADER_ALLOW_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_ALLOW_DEFAULT	"ACK, BYE, CANCEL, INVITE, MESSAGE, NOTIFY, OPTIONS, PRACK, REFER, UPDATE"
#define TSIP_HEADER_STR				"Allow:"TSIP_HEADER_ALLOW_DEFAULT"\r\n"

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Allow'.
///
/// @par ABNF
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Allow_s
{	
	TSIP_DECLARE_HEADER;

	tsk_strings_L_t *methods;
}
tsip_header_Allow_t;

TINYSIP_API tsip_header_Allow_t* tsip_header_Allow_create();

TINYSIP_API tsip_header_Allow_t *tsip_header_Allow_parse(const char *data, tsk_size_t size);
TINYSIP_API tsk_bool_t tsip_header_Allow_allows(const tsip_header_Allow_t* self, const char* method);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Allow_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_ALLOW_H_ */

