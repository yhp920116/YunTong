
/* 2012-03-07 */

#ifndef TINYSIP_TSIP_OPTIONS_H
#define TINYSIP_TSIP_OPTIONS_H

#include "tinysip_config.h"

#include "tinysip/tsip_event.h"

TSIP_BEGIN_DECLS

#define TSIP_OPTIONS_EVENT(self)		((tsip_options_event_t*)(self))

typedef enum tsip_options_event_type_e
{
	tsip_i_options,
	tsip_ao_options,
}
tsip_options_event_type_t;

/**< Event from SIP OPTIONS dialog */
typedef struct tsip_options_event_e
{
	TSIP_DECLARE_EVENT;
	
	//! the type of the event
	tsip_options_event_type_t type;
}
tsip_options_event_t;

int tsip_options_event_signal(tsip_options_event_type_t type, tsip_ssession_handle_t* ss, short status_code, const char *phrase, const struct tsip_message_s* sipmessage);

TINYSIP_API int tsip_api_options_send_options(const tsip_ssession_handle_t *ss, ...);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_options_event_def_t;

#if 1 // Backward Compatibility
#	define tsip_action_OPTIONS	tsip_api_options_send_options
#endif

TSIP_END_DECLS

#endif /* TINYSIP_TSIP_OPTIONS_H */
