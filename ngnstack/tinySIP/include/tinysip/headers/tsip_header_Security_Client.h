
/* 2012-03-07 */

#ifndef _TSIP_HEADER_SECURITY_CLIENT_H_
#define _TSIP_HEADER_SECURITY_CLIENT_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

#include "tnet_types.h"

TSIP_BEGIN_DECLS


#define TSIP_HEADER_SECURITY_CLIENT_VA_ARGS(mech, alg, prot, mod, ealg, port_c, port_s, spi_c, spi_s)		tsip_header_Security_Client_def_t, (const char*)mech, (const char*)alg, (const char*)prot, (const char*)mod, (const char*)ealg, (tnet_port_t)port_c, (tnet_port_t)port_s, (uint32_t)spi_c, (uint32_t)spi_s

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Security-Client' as per RFC 3329.
///
/// @par ABNF : Security-Client	= 	"Security-Client" HCOLON sec-mechanism *(COMMA sec-mechanism)
/// sec-mechanism	= 	mechanism-name *( SEMI mech-parameters )
/// mechanism-name	= 	( "digest" / "tls" / "ipsec-ike" / "ipsec-man" / token )
/// mech-parameters	= 	( preference / digest-algorithm / digest-qop / digest-verify / mech-extension )
/// preference	= 	"q" EQUAL qvalue
/// digest-algorithm	= 	"d-alg" EQUAL token
/// digest-qop	= 	"d-qop" EQUAL token
/// digest-verify	= 	"d-ver" EQUAL LDQUOT 32LHEX RDQUOT
/// mech-extension	= 	generic-param
///
/// mechanism-name   = ( "ipsec-3gpp" )
/// mech-parameters    = ( algorithm / protocol /mode /
///                              encrypt-algorithm / spi /
///                              port1 / port2 )
/// algorithm          = "alg" EQUAL ( "hmac-md5-96" /
///                                          "hmac-sha-1-96" )
/// protocol           = "prot" EQUAL ( "ah" / "esp" )
/// mode               = "mod" EQUAL ( "trans" / "tun" )
/// encrypt-algorithm  = "ealg" EQUAL ( "des-ede3-cbc" / "null" )
/// spi                = "spi" EQUAL spivalue
/// spivalue           = 10DIGIT; 0 to 4294967295
/// port1              = "port1" EQUAL port
/// port2              = "port2" EQUAL port
/// port               = 1*DIGIT
/// 
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Security_Client_s
{	
	TSIP_DECLARE_HEADER;

	//! sec-mechanism (e.g. "digest" / "tls" / "ipsec-3gpp")
	char* mech;
	//! algorithm (e.g. "hmac-md5-96" / "hmac-sha-1-96")
	char* alg;
	//! protocol (e.g. "ah" / "esp")
	char* prot;
	//! mode (e.g. "trans" / "tun")
	char* mod;
	//! encrypt-algorithm (e.g. "des-ede3-cbc" / "null")
	char* ealg;
	//! client port
	tnet_port_t port_c;
	//! server port
	tnet_port_t port_s;
	//! client spi
	uint32_t spi_c;
	//! server spi
	uint32_t spi_s;
	//! preference
	double q;
}
tsip_header_Security_Client_t;

typedef tsk_list_t tsip_header_Security_Clients_L_t;

TINYSIP_API tsip_header_Security_Client_t* tsip_header_Security_Client_create(const char* mech, const char* alg, const char* prot, const char* mod, const char* ealg, tnet_port_t port_c, tnet_port_t port_s, uint32_t spi_c, uint32_t spi_s);
TINYSIP_API tsip_header_Security_Client_t* tsip_header_Security_Client_create_null();

TINYSIP_API tsip_header_Security_Clients_L_t *tsip_header_Security_Client_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Security_Client_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_SECURITY_CLIENT_H_ */

