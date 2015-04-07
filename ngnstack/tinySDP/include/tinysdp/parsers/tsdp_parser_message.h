
/* 2012-03-07 */

#ifndef TINYSDP_PARSER_MESSAGE_H
#define TINYSDP_PARSER_MESSAGE_H

#include "tinysdp_config.h"
#include "tinysdp/tsdp_message.h"
#include "tsk_ragel_state.h"

TSDP_BEGIN_DECLS

TINYSDP_API tsdp_message_t* tsdp_message_parse(const void *input, tsk_size_t size);

TSDP_END_DECLS

#endif /* TINYSDP_PARSER_MESSAGE_H */

