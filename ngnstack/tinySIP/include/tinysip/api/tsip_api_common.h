
/* 2012-03-07 */

#ifndef TINYSIP_TSIP_COMMON_H
#define TINYSIP_TSIP_COMMON_H

#include "tinysip_config.h"

#include "tinysip/tsip_ssession.h"

TSIP_BEGIN_DECLS

TINYSIP_API int tsip_api_common_reject(const tsip_ssession_handle_t *ss, ...);
TINYSIP_API int tsip_api_common_hangup(const tsip_ssession_handle_t *ss, ...);
TINYSIP_API int tsip_api_common_accept(const tsip_ssession_handle_t *ss, ...);


#if 1 // Backward Compatibility
#	define tsip_action_REJECT	tsip_api_common_reject
#	define tsip_action_HANGUP	tsip_api_common_hangup
#	define tsip_action_ACCEPT	tsip_api_common_accept
#endif

TSIP_END_DECLS

#endif /* TINYSIP_TSIP_COMMON_H */
