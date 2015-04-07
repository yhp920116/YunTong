
/* 2012-03-07 */

#ifndef TINYSIP_DIALOG_REGISTER_H
#define TINYSIP_DIALOG_REGISTER_H

#include "tinysip_config.h"
#include "tinysip/dialogs/tsip_dialog.h"

TSIP_BEGIN_DECLS

#define TSIP_DIALOG_REGISTER(self)							((tsip_dialog_register_t*)(self))

/**< SIP REGISTER dialog */
typedef struct tsip_dialog_register
{
	TSIP_DECLARE_DIALOG;

	tsip_timer_t timerrefresh;
	tsip_timer_t timershutdown;

	tsip_request_t* last_iRegister;

	tsk_bool_t unregistering;
	tsk_bool_t is_server;
}
tsip_dialog_register_t;

tsip_dialog_register_t* tsip_dialog_register_create(const tsip_ssession_handle_t* ss, const char* call_id);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_dialog_register_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_DIALOG_REGISTER_H */

