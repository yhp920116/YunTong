
/* 2012-03-07 */

#ifndef _TMSRP_HEADER_USE_PATH_H_
#define _TMSRP_HEADER_USE_PATH_H_

#include "tinymsrp_config.h"
#include "tinymsrp/headers/tmsrp_header.h"

#include "tinymsrp/parsers/tmsrp_parser_uri.h"

TMSRP_BEGIN_DECLS

#define TMSRP_HEADER_USE_PATH_VA_ARGS(uri)		tmsrp_header_Use_Path_def_t, (const tmsrp_uri_t*)uri

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	MSRP 'Use-Path' header.
///
/// @par ABNF :  "Use-Path:" SP MSRP-URI  *( SP MSRP-URI )
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tmsrp_header_Use_Path_s
{	
	TMSRP_DECLARE_HEADER;

	tmsrp_uri_t *uri;
	tmsrp_uris_L_t *otherURIs;
}
tmsrp_header_Use_Path_t;

typedef tsk_list_t tmsrp_headers_Use_Path_L_t;

TINYMSRP_API tmsrp_header_Use_Path_t* tmsrp_header_Use_Path_create(const tmsrp_uri_t* uri);
TINYMSRP_API tmsrp_header_Use_Path_t* tmsrp_header_Use_Path_create_null();

TINYMSRP_API tmsrp_header_Use_Path_t *tmsrp_header_Use_Path_parse(const char *data, tsk_size_t size);

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_header_Use_Path_def_t;

TMSRP_END_DECLS

#endif /* _TMSRP_HEADER_USE_PATH_H_ */

