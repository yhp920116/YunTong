
/* 2012-03-07 */

#ifndef TINYSIP_TSIP_EVENT_H
#define TINYSIP_TSIP_EVENT_H

#include "tinysip_config.h"

#include "tinysip/tsip_ssession.h"

TSIP_BEGIN_DECLS

#define TSIP_EVENT(self)		((tsip_event_t*)(self))

typedef enum tsip_event_type_e
{	
	tsip_event_invite,
	tsip_event_message,
	tsip_event_info,
	tsip_event_options,
	tsip_event_publish,
	tsip_event_register,
	tsip_event_subscribe,
	
	tsip_event_dialog,
	tsip_event_stack,
}
tsip_event_type_t;

/* SIP codes associated to an internal event */
// 100-699 are reserved codes

// 7xx ==> errors
#define tsip_event_code_dialog_transport_error		702
#define tsip_event_code_dialog_global_error			703
#define tsip_event_code_dialog_message_error		704

// 8xx ==> success
#define tsip_event_code_dialog_request_incoming		800
#define tsip_event_code_dialog_request_outgoing		802
#define tsip_event_code_dialog_request_cancelled	803
#define tsip_event_code_dialog_request_sent			804

// 9xx ==> Informational
#define tsip_event_code_dialog_connecting			900
#define tsip_event_code_dialog_connected			901
#define tsip_event_code_dialog_terminating			902
#define tsip_event_code_dialog_terminated			903
#define tsip_event_code_stack_started				950
#define tsip_event_code_stack_stopped				951
#define tsip_event_code_stack_failed_to_start		952
#define tsip_event_code_stack_failed_to_stop		953


typedef struct tsip_event_s
{
	TSK_DECLARE_OBJECT;

	tsip_ssession_handle_t* ss;

	short code;
	char *phrase;

	tsip_event_type_t type;
	struct tsip_message_s *sipmessage;

	//! copy of stack user data (needed by sessionless events)
	const void* userdata;
}
tsip_event_t;
#define TSIP_DECLARE_EVENT	tsip_event_t __sipevent__

TINYSIP_GEXTERN const tsk_object_def_t *tsip_event_def_t;

int tsip_event_init(tsip_event_t* self, tsip_ssession_t* ss, short code, const char *phrase, const struct tsip_message_s* sipmessage, tsip_event_type_t type);
int tsip_event_signal(tsip_event_type_t type, tsip_ssession_t* ss, short code, const char *phrase);
int tsip_event_signal_2(tsip_event_type_t type, tsip_ssession_t* ss, short code, const char *phrase, const struct tsip_message_s* sipmessage);
int tsip_event_deinit(tsip_event_t* self);

typedef int (*tsip_stack_callback_f)(const tsip_event_t *sipevent);

TSIP_END_DECLS

#endif /* TINYSIP_TSIP_EVENT_H */
