
/* 2012-03-07 */

#ifndef _TSDP_HEADER_P_H_
#define _TSDP_HEADER_P_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_P_VA_ARGS(value)		tsdp_header_P_def_t, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "p=" header (Phone Number).
/// The "p=" line specifies contact information for the person
///   responsible for the conference.  This is not necessarily the same
///   person that created the conference announcement.
///
///
/// @par ABNF : p= phone-number
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_P_s
{	
	TSDP_DECLARE_HEADER;
	char* value;
}
tsdp_header_P_t;

typedef tsk_list_t tsdp_headers_P_L_t;

TINYSDP_API tsdp_header_P_t* tsdp_header_P_create(const char* value);
TINYSDP_API tsdp_header_P_t* tsdp_header_P_create_null();

TINYSDP_API tsdp_header_P_t *tsdp_header_P_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_P_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_P_H_ */

