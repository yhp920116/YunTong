
/* 2012-03-07 */

#ifndef TINYSIP_PARSER_URI_H
#define TINYSIP_PARSER_URI_H

#include "tinysip_config.h"
#include "tinysip/tsip_uri.h"

#include "tsk_ragel_state.h"

TSIP_BEGIN_DECLS

TINYSIP_API tsip_uri_t *tsip_uri_parse(const char *data, tsk_size_t size);

TSIP_END_DECLS

#endif /* TINYSIP_PARSER_URI_H */

