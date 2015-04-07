
/* 2012-03-07 */

#ifndef _TINYSAK_HMAC_H_
#define _TINYSAK_HMAC_H_

#include "tinysak_config.h"

#include "tsk_sha1.h"
#include "tsk_md5.h"

TSK_BEGIN_DECLS

TINYSAK_API int hmac_md5_compute(const uint8_t* input, tsk_size_t input_size, const char* key, tsk_size_t key_size, tsk_md5string_t *result);
TINYSAK_API int hmac_md5digest_compute(const uint8_t* input, tsk_size_t input_size, const char* key, tsk_size_t key_size, tsk_md5digest_t result);

TINYSAK_API int hmac_sha1_compute(const uint8_t* input, tsk_size_t input_size, const char* key, tsk_size_t key_size, tsk_sha1string_t *result);
TINYSAK_API int hmac_sha1digest_compute(const uint8_t* input, tsk_size_t input_size, const char* key, tsk_size_t key_size, tsk_sha1digest_t result);

TSK_END_DECLS

#endif /* _TINYSAK_HMAC_H_ */
