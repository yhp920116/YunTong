
/* 2012-03-07 */

#ifndef _TSIP_HEADER_P_ACCESS_NETWORK_INFO_H_
#define _TSIP_HEADER_P_ACCESS_NETWORK_INFO_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_P_ACCESS_NETWORK_INFO_VA_ARGS(value)	tsip_header_P_Access_Network_Info_def_t, (const char*)value

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'P-Access-Network-Info' as per RFC 3455.
///
/// @par ABNF: P-Access-Network-Info  	= 	"P-Access-Network-Info" HCOLON access-net-spec
/// access-net-spec	= 	access-type *( SEMI access-info )
/// access-type	= 	"IEEE-802.11a" / "IEEE-802.11b" / "3GPP-GERAN" / "3GPP-UTRAN-FDD" / "3GPP-UTRAN-TDD" / "3GPP-CDMA2000" / token
/// access-info	= 	cgi-3gpp / utran-cell-id-3gpp / extension-access-info
/// extension-access-info	= 	gen-value
/// cgi-3gpp	= 	"cgi-3gpp" EQUAL (token / quoted-string)
/// utran-cell-id-3gpp	= 	"utran-cell-id-3gpp" EQUAL (token / quoted-string)
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_P_Access_Network_Info_s
{	
	TSIP_DECLARE_HEADER;

	char *value;
}
tsip_header_P_Access_Network_Info_t;

TINYSIP_API tsip_header_P_Access_Network_Info_t* tsip_header_P_Access_Network_Info_create(const char* value);
TINYSIP_API tsip_header_P_Access_Network_Info_t* tsip_header_P_Access_Network_Info_create_null();

TINYSIP_API tsip_header_P_Access_Network_Info_t *tsip_header_P_Access_Network_Info_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_P_Access_Network_Info_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_P_ACCESS_NETWORK_INFO_H_ */

