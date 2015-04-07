
/* 2012-03-07 */

#ifndef TINYSIP_TSIP_REGISTER_H
#define TINYSIP_TSIP_REGISTER_H

#include "tinysip_config.h"

#include "tinysip/tsip_event.h"

TSIP_BEGIN_DECLS

#define TSIP_REGISTER_EVENT(self)		((tsip_register_event_t*)(self))

typedef enum tsip_register_event_type_e
{
	tsip_i_newreg,

	tsip_i_register, // refresh
	tsip_ao_register,

	tsip_i_unregister,
	tsip_ao_unregister,
}
tsip_register_event_type_t;

typedef struct tsip_register_event_e
{
	TSIP_DECLARE_EVENT;

	tsip_register_event_type_t type;
}
tsip_register_event_t;

int tsip_register_event_signal(tsip_register_event_type_t type, tsip_ssession_t* ss, short status_code, const char *phrase, const struct tsip_message_s* sipmessage);

TINYSIP_API int tsip_api_register_send_register(const tsip_ssession_handle_t *ss, ...);
TINYSIP_API int tsip_api_register_send_unregister(const tsip_ssession_handle_t *ss, ...);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_register_event_def_t;

#if 1 // Backward Compatibility
#	define tsip_action_REGISTER	tsip_api_register_send_register
#	define tsip_action_UNREGISTER	tsip_api_register_send_unregister
#endif

TSIP_END_DECLS

#endif /* TINYSIP_TSIP_REGISTER_H */
