
/* 2012-03-07 */

#ifndef TINYSIP_HEADER_VIA_H
#define TINYSIP_HEADER_VIA_H

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

#include "tsk_object.h"

TSIP_BEGIN_DECLS


#define TSIP_HEADER_VIA_VA_ARGS(proto_name, proto_version, transport, host, port)		tsip_header_Via_def_t, (const char*)proto_name, (const char*)proto_version, (const char*)transport, (const char*)host, (uint16_t)port


#define TSIP_HEADER_VIA_HAS_RPORT(self)			((self)->rport!=0)
#define TSIP_HEADER_VIA_HAS_TTL(self)			((self)->ttl!=0)
#define TSIP_HEADER_VIA_UNRELIABLE_TRANS(self)	(tsk_striequals("UDP", (self)->transport))
#define TSIP_HEADER_VIA_RELIABLE_TRANS(self)	!(TSIP_HEADER_VIA_UNRELIABLE_TRANS(self))
#define TSIP_HEADER_VIA_PROTO_NAME_DEFAULT		"SIP"
#define TSIP_HEADER_VIA_PROTO_VERSION_DEFAULT	"2.0"

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP Via/v header as per RFC 3261 subclause 20.42.
/// ABNF:	Via	= 	( "Via" / "v" ) HCOLON via-parm *(COMMA via-parm)
///			via-parm	= 	sent-protocol LWS sent-by *( SEMI via-params )
/// 		via-params	= 	via-ttl / via-maddr / via-received / via-branch / via-compression / response-port / via-extension
/// 		via-ttl	= 	"ttl" EQUAL ttl
/// 		via-maddr	= 	"maddr" EQUAL host
/// 		via-received	= 	"received" EQUAL (IPv4address / IPv6address)
///			via-branch	= 	"branch" EQUAL token
/// 		via-compression	= 	"comp" EQUAL ("sigcomp" / other-compression)
/// 		other-compression	= 	token
/// 		response-port	= 	"rport" [EQUAL 1*DIGIT]
/// 		via-extension	= 	generic-param
/// 		sent-protocol	= 	protocol-name SLASH protocol-version SLASH transport
/// 		protocol-name	= 	"SIP" / token
/// 		protocol-version	= 	token
/// 		transport	= 	"UDP" / "TCP" / "TLS" / "SCTP" / "TLS-SCTP" / other-transport
/// 		sent-by	= 	host [ COLON port ]
/// 		ttl	= 	1*3DIGIT
///
/// @date	12/5/2009
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Via_s
{
	TSIP_DECLARE_HEADER;

	char *branch;
	char *host;
	uint16_t port;
	char *comp;
	char *sigcomp_id;
	char *received;
	char *maddr;
	char *proto_name;
	char *proto_version;
	char *transport;
	
	int32_t rport;
	int32_t ttl;
}
tsip_header_Via_t;

typedef tsk_list_t tsip_header_Vias_L_t;

TINYSIP_API tsip_header_Via_t* tsip_header_Via_create(const char* proto_name, const char* proto_version, const char* transport, const char* host, uint16_t port);
TINYSIP_API tsip_header_Via_t* tsip_header_Via_create_null();

TINYSIP_API tsip_header_Vias_L_t *tsip_header_Via_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Via_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_HEADER_VIA_H */

