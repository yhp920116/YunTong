
/* 2012-03-07 */

#ifndef _THTTP_HEADER_TRANSFER_ENCODING_H_
#define _THTTP_HEADER_TRANSFER_ENCODING_H_

#include "tinyhttp_config.h"
#include "tinyhttp/headers/thttp_header.h"

THTTP_BEGIN_DECLS

#define THTTP_HEADER_TRANSFER_ENCODING_VA_ARGS(encoding)			thttp_header_Transfer_Encoding_def_t, (const char*)encoding

////////////////////////////////////////////////////////////////////////////////////////////////////
/// HTTP header 'Transfer-Encoding'.
///
/// @par ABNF= Transfer-Encoding       = "Transfer-Encoding" ":" transfer-coding *(COMMA transfer-coding)
///
/// 				transfer-coding     = "chunked" / transfer-extension
/// 				transfer-extension  = token *( ";" parameter )
/// 				parameter           = attribute "=" value
/// 				attribute           = token
/// 				value               = token / quoted-string
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct thttp_header_Transfer_Encoding_s
{	
	THTTP_DECLARE_HEADER;

	char* encoding;
}
thttp_header_Transfer_Encoding_t;


thttp_header_Transfer_Encoding_t *thttp_header_Transfer_Encoding_parse(const char *data, tsk_size_t size);

thttp_header_Transfer_Encoding_t* thttp_header_transfer_encoding_create(const char* encoding);
thttp_header_Transfer_Encoding_t* thttp_header_transfer_encoding_create_null();


thttp_header_Transfer_Encoding_t* thttp_header_transfer_encoding_create(const char* encoding);
thttp_header_Transfer_Encoding_t* thttp_header_transfer_encoding_create_null();

TINYHTTP_GEXTERN const tsk_object_def_t *thttp_header_Transfer_Encoding_def_t;


THTTP_END_DECLS

#endif /* _THTTP_HEADER_TRANSFER_ENCODING_H_ */

