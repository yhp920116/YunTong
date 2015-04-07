
/* 2012-03-07 */

#ifndef _TMSRP_HEADER_MESSAGE_ID_H_
#define _TMSRP_HEADER_MESSAGE_ID_H_

#include "tinymsrp_config.h"
#include "tinymsrp/headers/tmsrp_header.h"

TMSRP_BEGIN_DECLS

#define TMSRP_HEADER_MESSAGE_ID_VA_ARGS(value)		tmsrp_header_Message_ID_def_t, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	MSRP 'Message-Id' header.
///
/// @par ABNF :  Message-ID	=  	 "Message-ID:" SP ident
/// ident	=  	ALPHANUM 3*31ident-char
/// ident-char	= 	ALPHANUM / "." / "-" / "+" / "%" / "="
///
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tmsrp_header_Message_ID_s
{	
	TMSRP_DECLARE_HEADER;
	
	char *value;
}
tmsrp_header_Message_ID_t;

typedef tsk_list_t tmsrp_headers_Message_Id_L_t;

TINYMSRP_API tmsrp_header_Message_ID_t* tmsrp_header_Message_ID_create(const char* value);
TINYMSRP_API tmsrp_header_Message_ID_t* tmsrp_header_Message_ID_create_null();

TINYMSRP_API tmsrp_header_Message_ID_t *tmsrp_header_Message_ID_parse(const char *data, tsk_size_t size);

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_header_Message_ID_def_t;

TMSRP_END_DECLS

#endif /* _TMSRP_HEADER_MESSAGE_ID_H_ */

