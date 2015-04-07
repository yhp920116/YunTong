
/* 2012-03-07 */

#ifndef TINYMSRP_PARSER_URI_H
#define TINYMSRP_PARSER_URI_H

#include "tinymsrp_config.h"
#include "tinymsrp/tmsrp_uri.h"

#include "tsk_ragel_state.h"

TMSRP_BEGIN_DECLS

TINYMSRP_API tmsrp_uri_t *tmsrp_uri_parse(const char *data, tsk_size_t size);

TMSRP_END_DECLS

#endif /* TINYMSRP_PARSER_URI_H */

