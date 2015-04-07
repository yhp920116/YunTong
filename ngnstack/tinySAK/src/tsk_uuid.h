
/* 2012-03-07 */

#ifndef _TINYSAK_UUID_H_
#define _TINYSAK_UUID_H_

#include "tinysak_config.h"

TSK_BEGIN_DECLS

#define TSK_UUID_DIGEST_SIZE			16
#define TSK_UUID_STRING_SIZE			((TSK_UUID_DIGEST_SIZE*2)+4/*-*/)

typedef char tsk_uuidstring_t[TSK_UUID_STRING_SIZE+1]; /**< Hexadecimal UUID digest string. */
typedef char tsk_uuiddigest_t[TSK_UUID_DIGEST_SIZE]; /**< UUID digest bytes. */

TINYSAK_API int tsk_uuidgenerate(tsk_uuidstring_t *result);

TSK_END_DECLS

#endif /* _TINYSAK_UUID_H_ */
