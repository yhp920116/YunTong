
/* 2012-03-07 */

#ifndef TINYSIP_PARSER_HEADERS_H
#define TINYSIP_PARSER_HEADERS_H

#include "tinysip_config.h"
#include "tinysip/tsip_message.h"
#include "tsk_ragel_state.h"

TSIP_BEGIN_DECLS

tsk_bool_t tsip_header_parse(tsk_ragel_state_t *state, tsip_message_t *message);

TSIP_END_DECLS

#endif /* TINYSIP_PARSER_HEADERS_H */

