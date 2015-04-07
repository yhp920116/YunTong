
/* 2012-03-07 */

#ifndef TINYSIP_TRANSAC_IST_H
#define TINYSIP_TRANSAC_IST_H

#include "tinysip_config.h"
#include "tinysip/transactions/tsip_transac.h"

TSIP_BEGIN_DECLS

#define TSIP_TRANSAC_IST(self)												((tsip_transac_ist_t*)(self))


typedef struct tsip_transac_ist
{
	TSIP_DECLARE_TRANSAC;

	tsip_response_t* lastResponse;

	tsip_timer_t timerH;
	tsip_timer_t timerI;
	tsip_timer_t timerG;
	tsip_timer_t timerL;
}
tsip_transac_ist_t;

tsip_transac_ist_t* tsip_transac_ist_create(tsk_bool_t reliable, int32_t cseq_value, const char* callid, tsip_dialog_t* dialog);
int tsip_transac_ist_start(tsip_transac_ist_t *self, const tsip_request_t* request);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_transac_ist_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_TRANSAC_IST_H */

