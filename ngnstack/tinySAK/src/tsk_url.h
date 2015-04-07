
/* 2012-03-07 */

#ifndef _TINYSAK_URL_H_
#define _TINYSAK_URL_H_

#include "tinysak_config.h"

TSK_BEGIN_DECLS

TINYSAK_API char* tsk_url_encode(const char* url);
TINYSAK_API char* tsk_url_decode(const char* url);

TSK_END_DECLS

#endif /* _TINYSAK_URL_H_ */

