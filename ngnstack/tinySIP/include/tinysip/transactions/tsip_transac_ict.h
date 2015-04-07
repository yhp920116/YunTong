
/* 2012-03-07 */

#ifndef TINYSIP_TRANSAC_ICT_H
#define TINYSIP_TRANSAC_ICT_H

#include "tinysip_config.h"

#include "tinysip/transactions/tsip_transac.h"
#include "tinysip/tsip_message.h"

TSIP_BEGIN_DECLS

#define TSIP_TRANSAC_ICT(self)															((tsip_transac_ict_t*)(self))

typedef struct tsip_transac_ict
{
	TSIP_DECLARE_TRANSAC;
	
	tsip_request_t* request;

	tsip_timer_t timerA;
	tsip_timer_t timerB;
	tsip_timer_t timerD;
	tsip_timer_t timerM;
}
tsip_transac_ict_t;

tsip_transac_ict_t* tsip_transac_ict_create(tsk_bool_t reliable, int32_t cseq_value, const char* callid, tsip_dialog_t* dialog);
int tsip_transac_ict_start(tsip_transac_ict_t *self, const tsip_request_t* request);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_transac_ict_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_TRANSAC_ICT_H */

