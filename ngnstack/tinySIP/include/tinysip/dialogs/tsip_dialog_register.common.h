
/* 2012-03-07 */

#ifndef TINYSIP_DIALOG_REGISTER_COMMON_H
#define TINYSIP_DIALOG_REGISTER_COMMON_H

#include "tinysip/api/tsip_api_register.h"

#define DEBUG_STATE_MACHINE											0
#define TSIP_DIALOG_REGISTER_TIMER_SCHEDULE(TX)						TSIP_DIALOG_TIMER_SCHEDULE(register, TX)
#define TSIP_DIALOG_REGISTER_SIGNAL(self, type, code, phrase, message)	\
	tsip_register_event_signal(type, TSIP_DIALOG(self)->ss, code, phrase, message)


/* ======================== actions ======================== */
typedef enum _fsm_action_e
{
	_fsm_action_accept = tsip_atype_accept,
	_fsm_action_reject = tsip_atype_hangup,
	_fsm_action_hangup = tsip_atype_hangup,
	_fsm_action_oREGISTER = tsip_atype_register,
	_fsm_action_cancel = tsip_atype_cancel,
	_fsm_action_shutdown = tsip_atype_shutdown,

	_fsm_action_1xx = 0xFF,
	_fsm_action_2xx,
	_fsm_action_401_407_421_494,
	_fsm_action_423,
	_fsm_action_300_to_699,

	_fsm_action_iREGISTER,

	_fsm_action_shutdown_timedout, /* Any -> Terminated */
	_fsm_action_transporterror,
	_fsm_action_error,
}
_fsm_action_t;

/* ======================== states ======================== */
typedef enum _fsm_state_e
{
	_fsm_state_Started,
	_fsm_state_InProgress, // Outgoing (Client)
	_fsm_state_Incoming, // Incoming (Server)
	_fsm_state_Connected,
	_fsm_state_Terminated
}
_fsm_state_t;


#define _fsm_cond_silent_shutdown _fsm_cond_silent_hangup
#define _fsm_cond_not_silent_shutdown _fsm_cond_not_silent_hangup

#else
#error "This file must only be included in a source(.c or .cxx)"

#endif /* TINYSIP_DIALOG_REGISTER_COMMON_H */
