
/* 2012-03-07 */

#ifndef TINYMSRP_PARSER_MESSAGE_H
#define TINYMSRP_PARSER_MESSAGE_H

#include "tinymsrp_config.h"
#include "tinymsrp/tmsrp_message.h"
#include "tsk_ragel_state.h"

TMSRP_BEGIN_DECLS

TINYMSRP_API tmsrp_message_t* tmsrp_message_parse_2(const void *input, tsk_size_t size, tsk_size_t* msg_size);
TINYMSRP_API tmsrp_message_t* tmsrp_message_parse(const void *input, tsk_size_t size);

TMSRP_END_DECLS

#endif /* TINYMSRP_PARSER_MESSAGE_H */

