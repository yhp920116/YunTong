
/* 2012-03-07 */

#ifndef TINYSIP_TSIP_INFO_H
#define TINYSIP_TSIP_INFO_H

#include "tinysip_config.h"

#include "tinysip/tsip_event.h"

TSIP_BEGIN_DECLS

#define TSIP_INFO_EVENT(self)		((tsip_info_event_t*)(self))

typedef enum tsip_info_event_type_e
{
	tsip_i_info,
	tsip_ao_info,
}
tsip_info_event_type_t;

typedef struct tsip_info_event_e
{
	TSIP_DECLARE_EVENT;

	tsip_info_event_type_t type;
}
tsip_info_event_t;

int tsip_info_event_signal(tsip_info_event_type_t type, tsip_ssession_handle_t* ss, short status_code, const char *phrase, const struct tsip_message_s* sipmessage);

TINYSIP_API int tsip_api_info_send_info(const tsip_ssession_handle_t *ss, ...);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_info_event_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_TSIP_INFO_H */
