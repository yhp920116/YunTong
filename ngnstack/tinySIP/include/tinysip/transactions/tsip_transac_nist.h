
/* 2012-03-07 */

#ifndef TINYSIP_TRANSAC_NIST_H
#define TINYSIP_TRANSAC_NIST_H

#include "tinysip_config.h"

#include "tinysip/transactions/tsip_transac.h"
#include "tinysip/tsip_message.h"

TSIP_BEGIN_DECLS

#define TSIP_TRANSAC_NIST(self)															((tsip_transac_nist_t*)(self))

typedef struct tsip_transac_nist
{
	TSIP_DECLARE_TRANSAC;

	tsip_response_t* lastResponse;
	tsip_timer_t timerJ;
}
tsip_transac_nist_t;

tsip_transac_nist_t* tsip_transac_nist_create(tsk_bool_t reliable, int32_t cseq_value, const char* cseq_method, const char* callid, tsip_dialog_t* dialog);
int tsip_transac_nist_start(tsip_transac_nist_t *self, const tsip_request_t* request);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_transac_nist_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_TRANSAC_NIST_H */

