
/* 2012-03-07 */

#ifndef _TSDP_HEADER_E_H_
#define _TSDP_HEADER_E_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_E_VA_ARGS(value)		tsdp_header_E_def_t, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "e=" header (Email Address).
///
/// The "e=" line specifies contact information for the person
///   responsible for the conference.  This is not necessarily the same
///   person that created the conference announcement.
///
/// @par ABNF : e= email-address 
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_E_s
{	
	TSDP_DECLARE_HEADER;
	char* value;
}
tsdp_header_E_t;

typedef tsk_list_t tsdp_headers_E_L_t;

TINYSDP_API tsdp_header_E_t* tsdp_header_E_create(const char* value);
TINYSDP_API tsdp_header_E_t* tsdp_header_E_create_null();

TINYSDP_API tsdp_header_E_t *tsdp_header_E_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_E_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_E_H_ */

