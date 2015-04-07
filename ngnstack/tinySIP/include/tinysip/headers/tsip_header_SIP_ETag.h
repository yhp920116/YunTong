
/* 2012-03-07 */

#ifndef _TSIP_HEADER_SIP_ETAG_H_
#define _TSIP_HEADER_SIP_ETAG_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS


#define TSIP_HEADER_SIP_ETAG_VA_ARGS(etag)		tsip_header_SIP_ETag_def_t, (const char*)etag

/**
 * @struct	tsip_header_SIP_ETag_s
 *
 * 	SIP header 'SIP-ETag' as per RFC 3903.
 * 	@par ABNF 
 *	SIP-ETag	= 	"SIP-ETag" HCOLON entity-tag
 *	entity-tag = token 
**/
typedef struct tsip_header_SIP_ETag_s
{	
	TSIP_DECLARE_HEADER;
	char *value;
}
tsip_header_SIP_ETag_t;

TINYSIP_API tsip_header_SIP_ETag_t* tsip_header_SIP_ETag_create(const char* etag);
TINYSIP_API tsip_header_SIP_ETag_t* tsip_header_SIP_ETag_create_null();

TINYSIP_API tsip_header_SIP_ETag_t *tsip_header_SIP_ETag_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_SIP_ETag_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_SIP_ETAG_H_ */

