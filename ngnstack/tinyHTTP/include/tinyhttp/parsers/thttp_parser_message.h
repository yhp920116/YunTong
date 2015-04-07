
/* 2012-03-07 */

#ifndef TINYHTTP_PARSER_MESSAGE_H
#define TINYHTTP_PARSER_MESSAGE_H

#include "tinyhttp_config.h"
#include "tinyhttp/thttp_message.h"
#include "tsk_ragel_state.h"

THTTP_BEGIN_DECLS

TINYHTTP_API int thttp_message_parse(tsk_ragel_state_t *state, thttp_message_t **result, tsk_bool_t extract_content);

THTTP_END_DECLS

#endif /* TINYHTTP_PARSER_MESSAGE_H */

