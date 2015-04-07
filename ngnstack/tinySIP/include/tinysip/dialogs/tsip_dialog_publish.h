
/* 2012-03-07 */

#ifndef TINYSIP_DIALOG_PUBLISH_H
#define TINYSIP_DIALOG_PUBLISH_H

#include "tinysip_config.h"
#include "tinysip/dialogs/tsip_dialog.h"

TSIP_BEGIN_DECLS

#define TSIP_DIALOG_PUBLISH(self)							((tsip_dialog_publish_t*)(self))

typedef struct tsip_dialog_publish
{
	TSIP_DECLARE_DIALOG;
		
	tsip_timer_t timerrefresh;
	tsip_timer_t timershutdown;

	tsk_bool_t unpublishing;
	char* etag;
}
tsip_dialog_publish_t;

tsip_dialog_publish_t* tsip_dialog_publish_create(const tsip_ssession_handle_t* ss);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_dialog_publish_def_t;


TSIP_END_DECLS


#endif /* TINYSIP_DIALOG_PUBLISH_H */
