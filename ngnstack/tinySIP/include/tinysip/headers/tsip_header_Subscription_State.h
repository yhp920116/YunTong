
/* 2012-03-07 */

#ifndef _TSIP_HEADER_SUBSCRIPTION_STATE_H_
#define _TSIP_HEADER_SUBSCRIPTION_STATE_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS


////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Subscription-State'.
///
/// @par ABNF: Subscription-State	= 	( "Subscription-State" / "o" ) HCOLON substate-value *( SEMI subexp-params )
/// substate-value	= 	"active" / "pending" / "terminated" / extension-substate
/// extension-substate	= 	token
/// subexp-params	= 	("reason" EQUAL event-reason-value) / ("expires" EQUAL delta-seconds) / ("retry-after" EQUAL delta-seconds) / generic-param
/// event-reason-value	= 	"deactivated" / "probation" / "rejected" / "timeout" / "giveup" / "noresource" / event-reason-extension
/// event-reason-extension 	= 	token
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Subscription_State_s
{	
	TSIP_DECLARE_HEADER;

	char* state;
	char* reason;
	int32_t expires;
	int32_t retry_after;
}
tsip_header_Subscription_State_t;

tsip_header_Subscription_State_t* tsip_header_Subscription_State_create();

tsip_header_Subscription_State_t *tsip_header_Subscription_State_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Subscription_State_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_SUBSCRIPTION_STATE_H_ */

