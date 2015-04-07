
/* 2012-03-07 */

#ifndef TINYSIP_TSIP_MESSAGE_H
#define TINYSIP_TSIP_MESSAGE_H

#include "tinysip_config.h"

#include "tinysip/tsip_event.h"

TSIP_BEGIN_DECLS

#define TSIP_MESSAGE_EVENT(self)		((tsip_message_event_t*)(self))

typedef enum tsip_message_event_type_e
{
	tsip_i_message,
	tsip_ao_message,
}
tsip_message_event_type_t;

typedef struct tsip_message_event_e
{
	TSIP_DECLARE_EVENT;

	tsip_message_event_type_t type;
}
tsip_message_event_t;

int tsip_message_event_signal(tsip_message_event_type_t type, tsip_ssession_handle_t* ss, short status_code, const char *phrase, const struct tsip_message_s* sipmessage);

TINYSIP_API int tsip_api_message_send_message(const tsip_ssession_handle_t *ss, ...);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_message_event_def_t;

#if 1 // Backward Compatibility
#	define tsip_action_MESSAGE	tsip_api_message_send_message
#endif

TSIP_END_DECLS

#endif /* TINYSIP_TSIP_MESSAGE_H */
