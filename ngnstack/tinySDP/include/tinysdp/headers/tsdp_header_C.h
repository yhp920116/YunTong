
/* 2012-03-07 */

#ifndef _TSDP_HEADER_C_H_
#define _TSDP_HEADER_C_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_C_VA_ARGS(nettype, addrtype, addr)		tsdp_header_C_def_t, (const char*)(nettype), (const char*)(addrtype), (const char*)(addr)

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "c=" header	(Connection Data).
/// A session description MUST contain either at least one "c=" field in
///    each media description or a single "c=" field at the session level.
///    It MAY contain a single session-level "c=" field and additional "c="
///    field(s) per media description, in which case the per-media values
///    override the session-level settings for the respective media.
/// 
///
///
/// @par ABNF : c= nettype SP addrtype SP connection-address
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_C_s
{	
	TSDP_DECLARE_HEADER;
	char* nettype;
	char* addrtype;
	char* addr;
}
tsdp_header_C_t;

typedef tsk_list_t tsdp_headers_C_L_t;

TINYSDP_API tsdp_header_C_t* tsdp_header_c_create(const char* nettype, const char* addrtype, const char* addr);
TINYSDP_API tsdp_header_C_t* tsdp_header_c_create_null();

TINYSDP_API tsdp_header_C_t *tsdp_header_C_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_C_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_C_H_ */

