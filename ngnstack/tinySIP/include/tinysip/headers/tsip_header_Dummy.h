
/* 2012-03-07 */

#ifndef _TSIP_HEADER_DUMMY_H_
#define _TSIP_HEADER_DUMMY_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_DUMMY_VA_ARGS(name, value)		tsip_header_Dummy_def_t, (const char*)name, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP Dummy header.
///
/// @par ABNF : token SP* HCOLON SP*<: any*
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Dummy_s
{	
	TSIP_DECLARE_HEADER;

	char *name;
	char *value;
}
tsip_header_Dummy_t;

TINYSIP_API tsip_header_Dummy_t* tsip_header_Dummy_create(const char* name, const char* value);
TINYSIP_API tsip_header_Dummy_t* tsip_header_Dummy_create_null();

TINYSIP_API tsip_header_Dummy_t *tsip_header_Dummy_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Dummy_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_DUMMY_H_ */

