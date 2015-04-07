
/* 2012-03-07 */

#ifndef TINYSIP_PARSER_MESSAGE_H
#define TINYSIP_PARSER_MESSAGE_H

#include "tinysip_config.h"
#include "tinysip/tsip_message.h"
#include "tsk_ragel_state.h"

TSIP_BEGIN_DECLS

TINYSIP_API tsk_bool_t tsip_message_parse(tsk_ragel_state_t *state, tsip_message_t **result, tsk_bool_t extract_content);

TSIP_END_DECLS

#endif /* TINYSIP_PARSER_MESSAGE_H */

