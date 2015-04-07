
/* 2012-03-07 */

#ifndef _TSIP_HEADER_P_CHARGING_FUNCTION_ADDRESSES_H_
#define _TSIP_HEADER_P_CHARGING_FUNCTION_ADDRESSES_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'P-Charging-Function-Addresses' as per RFC 3455.
///
/// @par ABNF: P-Charging-Function-Addresses = P-Charging-Addr
/// P-Charging-Addr	= 	"P-Charging-Function-Addresses" HCOLON charge-addr-params *( SEMI charge-addr-params )
/// charge-addr-params	= 	ccf / ecf / generic-param
/// ccf	= 	"ccf" EQUAL gen-value
/// ecf	= 	"ecf" EQUAL gen-value
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_P_Charging_Function_Addresses_s
{	
	TSIP_DECLARE_HEADER;
	char* ccf;
	char* ecf;
}
tsip_header_P_Charging_Function_Addresses_t;

typedef tsk_list_t tsip_header_P_Charging_Function_Addressess_L_t;

TINYSIP_API tsip_header_P_Charging_Function_Addresses_t* tsip_header_P_Charging_Function_Addresses_create();

TINYSIP_API tsip_header_P_Charging_Function_Addressess_L_t *tsip_header_P_Charging_Function_Addresses_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_P_Charging_Function_Addresses_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_P_CHARGING_FUNCTION_ADDRESSES_H_ */

