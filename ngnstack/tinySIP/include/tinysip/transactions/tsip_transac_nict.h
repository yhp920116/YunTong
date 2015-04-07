
/* 2012-03-07 */

#ifndef TINYSIP_TRANSAC_NICT_H
#define TINYSIP_TRANSAC_NICT_H

#include "tinysip_config.h"

#include "tinysip/transactions/tsip_transac.h"
#include "tinysip/tsip_message.h"

TSIP_BEGIN_DECLS

#define TSIP_TRANSAC_NICT(self)															((tsip_transac_nict_t*)(self))

typedef struct tsip_transac_nict
{
	TSIP_DECLARE_TRANSAC;

	tsip_request_t* request;
	tsip_timer_t timerE;
	tsip_timer_t timerF;
	tsip_timer_t timerK;
}
tsip_transac_nict_t;

tsip_transac_nict_t* tsip_transac_nict_create(tsk_bool_t reliable, int32_t cseq_value, const char* cseq_method, const char* callid, tsip_dialog_t* dialog);
int tsip_transac_nict_start(tsip_transac_nict_t *self, const tsip_request_t* request);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_transac_nict_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_TRANSAC_NICT_H */

