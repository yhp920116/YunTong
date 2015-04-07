
/* 2012-03-07 */

#ifndef _TINYSAK_MD5_H_
#define _TINYSAK_MD5_H_

#include "tinysak_config.h"

TSK_BEGIN_DECLS

/**@ingroup tsk_md5_group
* @def TSK_MD5_DIGEST_SIZE
*/
/**@ingroup tsk_md5_group
* @def TSK_MD5_BLOCK_SIZE
*/
/**@ingroup tsk_md5_group
* @def TSK_MD5_EMPTY
*/
/**@ingroup tsk_md5_group
* @def TSK_MD5_STRING_SIZE
*/
/**@ingroup tsk_md5_group
* @def tsk_md5string_t
*/
/**@ingroup tsk_md5_group
* @def tsk_md5digest_t
*/
/**@ingroup TSK_MD5_DIGEST_CALC
* @def tsk_md5digest_t
*/


#define TSK_MD5_DIGEST_SIZE		16
#define TSK_MD5_BLOCK_SIZE		64

#define TSK_MD5_EMPTY			"d41d8cd98f00b204e9800998ecf8427e"

#define TSK_MD5_STRING_SIZE		(TSK_MD5_DIGEST_SIZE*2)
typedef char tsk_md5string_t[TSK_MD5_STRING_SIZE+1]; /**< Hexadecimal MD5 string. */
typedef uint8_t tsk_md5digest_t[TSK_MD5_DIGEST_SIZE]; /**< MD5 digest bytes. */

#define TSK_MD5_DIGEST_CALC(input, input_size, digest)		\
	{														\
		tsk_md5context_t ctx;								\
		tsk_md5init(&ctx);									\
		tsk_md5update(&ctx, (const uint8_t*)(input), (input_size));			\
		tsk_md5final((digest), &ctx);						\
	}

typedef struct tsk_md5context_s
{
	uint32_t buf[4];
	uint32_t bytes[2];
	uint32_t in[16];
}
tsk_md5context_t;

TINYSAK_API void tsk_md5init(tsk_md5context_t *context);
TINYSAK_API void tsk_md5update(tsk_md5context_t *context, uint8_t const *buf, tsk_size_t len);
TINYSAK_API void tsk_md5final(tsk_md5digest_t digest, tsk_md5context_t *context);
TINYSAK_API void tsk_md5transform(uint32_t buf[4], uint32_t const in[TSK_MD5_DIGEST_SIZE]);
TINYSAK_API int tsk_md5compute(const char* input, tsk_size_t size, tsk_md5string_t *result);

TSK_END_DECLS

#endif /* _TINYSAK_MD5_H_ */

