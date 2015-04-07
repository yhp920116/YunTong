
/* 2012-03-07 */

#ifndef TINYHTTP_PARSER_HEADERS_H
#define TINYHTTP_PARSER_HEADERS_H

#include "tinyhttp_config.h"
#include "tinyhttp/thttp_message.h"
#include "tsk_ragel_state.h"

THTTP_BEGIN_DECLS

int thttp_header_parse(tsk_ragel_state_t *state, thttp_message_t *message);

THTTP_END_DECLS

#endif /* TINYHTTP_PARSER_HEADERS_H */

