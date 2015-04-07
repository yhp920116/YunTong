
/* 2012-03-07 */

#ifndef TINYSIP_DIALOG_INFO_H
#define TINYSIP_DIALOG_INFO_H

#include "tinysip_config.h"
#include "tinysip/dialogs/tsip_dialog.h"

TSIP_BEGIN_DECLS

/* Forward declaration */
struct tsip_message_s;

#define TSIP_DIALOG_INFO(self)							((tsip_dialog_info_t*)(self))

typedef struct tsip_dialog_info
{
	TSIP_DECLARE_DIALOG;
	/**< Last incoming message. */
	struct tsip_message_s* last_iMessage;
}
tsip_dialog_info_t;

tsip_dialog_info_t* tsip_dialog_info_create(const tsip_ssession_handle_t* ss);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_dialog_info_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_DIALOG_INFO_H */
