
/* 2012-03-07 */

#ifndef TINYHTTP_PARSER_URL_H
#define TINYHTTP_PARSER_URL_H

#include "tinyhttp_config.h"
#include "tinyhttp/thttp_url.h"

#include "tsk_ragel_state.h"

THTTP_BEGIN_DECLS

TINYHTTP_API thttp_url_t *thttp_url_parse(const char *data, tsk_size_t size);

THTTP_END_DECLS

#endif /* TINYHTTP_PARSER_URL_H */

