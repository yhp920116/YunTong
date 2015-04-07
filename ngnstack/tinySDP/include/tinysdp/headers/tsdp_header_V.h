
/* 2012-03-07 */

#ifndef _TSDP_HEADER_V_H_
#define _TSDP_HEADER_V_H_

#include "tinysdp_config.h"
#include "tinysdp/headers/tsdp_header.h"

TSDP_BEGIN_DECLS

#define TSDP_HEADER_V_VA_ARGS(version)		tsdp_header_V_def_t, (int32_t)version

#define TSDP_HEADER_V_DEFAULT				0

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	SDP "v=" header (Protocol Version).
/// The "v=" field gives the version of the Session Description Protocol.
///   This memo (RFC 4566) defines version 0.  There is no minor version number.
///
/// @par ABNF : v=1*DIGIT 
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsdp_header_V_s
{	
	TSDP_DECLARE_HEADER;
	int32_t version;
}
tsdp_header_V_t;

typedef tsk_list_t tsdp_headers_V_L_t;

TINYSDP_API tsdp_header_V_t* tsdp_header_V_create(int32_t version);
TINYSDP_API tsdp_header_V_t* tsdp_header_V_create_null();

TINYSDP_API tsdp_header_V_t *tsdp_header_V_parse(const char *data, tsk_size_t size);

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_header_V_def_t;

TSDP_END_DECLS

#endif /* _TSDP_HEADER_V_H_ */

