
/* 2012-03-07 */

#ifndef TINYHTTP_EVENT_H
#define TINYHTTP_EVENT_H

#include "tinyhttp_config.h"

#include "tinyhttp/thttp_session.h"

#include "tsk_object.h"

THTTP_BEGIN_DECLS

#define THTTP_EVENT(self)		((thttp_event_t*)(self))

typedef enum thttp_event_type_e
{
	thttp_event_dialog_started,
	thttp_event_message,
	thttp_event_auth_failed,
	thttp_event_closed,
	thttp_event_transport_error,
	thttp_event_dialog_terminated
}
thttp_event_type_t;

typedef struct thttp_event_s
{
	TSK_DECLARE_OBJECT;
	
	thttp_event_type_t type;
	const thttp_session_handle_t* session;
	
	char* description;
	
	struct thttp_message_s *message;
}
thttp_event_t;

typedef int (*thttp_stack_callback_f)(const thttp_event_t *httpevent);

thttp_event_t* thttp_event_create(thttp_event_type_t type, const thttp_session_handle_t* session, const char* description, const thttp_message_t* message);

TINYHTTP_GEXTERN const void *thttp_event_def_t;

THTTP_END_DECLS

#endif /* TINYHTTP_EVENT_H */
