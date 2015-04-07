
/* 2012-03-07 */

#ifndef TINYMSRP_EVENT_H
#define TINYMSRP_EVENT_H

#include "tinymsrp_config.h"

#include "tinymsrp/tmsrp_message.h"

#include "tsk_params.h"
#include "tsk_buffer.h"

TMSRP_BEGIN_DECLS

typedef enum tmsrp_event_type_e
{
	tmsrp_event_type_none,
	tmsrp_event_type_connected,
	tmsrp_event_type_disconnected,
	tmsrp_event_type_message,
}
tmsrp_event_type_t;

typedef struct tmsrp_event_s
{
	TSK_DECLARE_OBJECT;

	const void* callback_data;
	unsigned outgoing:1;


	tmsrp_event_type_t type;
	tmsrp_message_t* message;
}
tmsrp_event_t;

typedef int (*tmsrp_event_cb_f)(tmsrp_event_t* _event);

TINYMSRP_API tmsrp_event_t* tmsrp_event_create(const void* callback_data, tsk_bool_t outgoing, tmsrp_event_type_t type, tmsrp_message_t* message);

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_event_def_t;

TMSRP_END_DECLS

#endif /* TINYMSRP_EVENT_H */
