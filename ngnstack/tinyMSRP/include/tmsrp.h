
/* 2012-03-07 */

#ifndef TINYMSRP_TMSRP_H
#define TINYMSRP_TMSRP_H

#include "tinymsrp_config.h"

#include "tinymsrp/tmsrp_message.h"

TMSRP_BEGIN_DECLS

TINYMSRP_API tmsrp_request_t* tmsrp_create_bodiless(const tmsrp_uri_t* To, const tmsrp_uri_t* From);
TINYMSRP_API tmsrp_response_t* tmsrp_create_response(const tmsrp_request_t* request, short status, const char* comment);
TINYMSRP_API tmsrp_request_t* tmsrp_create_report(const tmsrp_request_t* SEND, short status, const char* reason);
TINYMSRP_API tsk_bool_t tmsrp_isReportRequired(const tmsrp_request_t* request, tsk_bool_t failed);

TMSRP_END_DECLS

#endif /* TINYMSRP_TMSRP_H */
