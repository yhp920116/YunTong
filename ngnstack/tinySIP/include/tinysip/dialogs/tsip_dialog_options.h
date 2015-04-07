
/* 2012-03-07 */

#ifndef TINYSIP_DIALOG_OPTIONS_H
#define TINYSIP_DIALOG_OPTIONS_H

#include "tinysip_config.h"
#include "tinysip/dialogs/tsip_dialog.h"

TSIP_BEGIN_DECLS

#define TSIP_DIALOG_OPTIONS(self)							((tsip_dialog_options_t*)(self))

typedef struct tsip_dialog_options
{
	TSIP_DECLARE_DIALOG;
	/**< Last incoming message. */
	struct tsip_message_s* last_iMessage;
}
tsip_dialog_options_t;

tsip_dialog_options_t* tsip_dialog_options_create(const tsip_ssession_handle_t* ss);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_dialog_options_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_DIALOG_OPTIONS_H */
