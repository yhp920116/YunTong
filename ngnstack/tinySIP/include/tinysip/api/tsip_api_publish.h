
/* 2012-03-07 */

#ifndef TINYSIP_TSIP_PUBLISH_H
#define TINYSIP_TSIP_PUBLISH_H

#include "tinysip_config.h"

#include "tinysip/tsip_event.h"

TSIP_BEGIN_DECLS

#define TSIP_PUBLISH_EVENT(self)		((tsip_publish_event_t*)(self))

typedef enum tsip_publish_event_type_e
{
	tsip_i_publish,
	tsip_ao_publish,
	
	tsip_i_unpublish,
	tsip_ao_unpublish
}
tsip_publish_event_type_t;

typedef struct tsip_publish_event_e
{
	TSIP_DECLARE_EVENT;

	tsip_publish_event_type_t type;
}
tsip_publish_event_t;

int tsip_publish_event_signal(tsip_publish_event_type_t type, tsip_ssession_handle_t* ss, short status_code, const char *phrase, const struct tsip_message_s* sipmessage);

TINYSIP_API int tsip_api_publish_send_publish(const tsip_ssession_handle_t *ss, ...);
TINYSIP_API int tsip_api_publish_send_unpublish(const tsip_ssession_handle_t *ss, ...);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_publish_event_def_t;

#if 1 // Backward Compatibility
#	define tsip_action_PUBLISH	tsip_api_publish_send_publish
#	define tsip_action_UNPUBLISH	tsip_api_publish_send_unpublish
#endif

TSIP_END_DECLS

#endif /* TINYSIP_TSIP_PUBLISH_H */
