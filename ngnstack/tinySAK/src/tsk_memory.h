
/* 2012-03-07 */

#ifndef _TINYSAK_MEMORY_H_
#define _TINYSAK_MEMORY_H_

#include "tinysak_config.h"

#include <stdlib.h> /* tsk_size_t */

/**@ingroup tsk_memory_group
* @def TSK_SAFE_FREE
* Safely free the memory pointed by @a ptr.
*/
/**@ingroup tsk_memory_group
* @def TSK_FREE
* Safely free the memory pointed by @a ptr.
*/

TSK_BEGIN_DECLS

#define TSK_SAFE_FREE(ptr) (void)tsk_free((void**)(&ptr));
#define TSK_FREE(ptr) TSK_SAFE_FREE(ptr)

TINYSAK_API void* tsk_malloc(tsk_size_t size);
TINYSAK_API void* tsk_realloc (void * ptr, tsk_size_t size);
TINYSAK_API void tsk_free(void** ptr);
TINYSAK_API void* tsk_calloc(tsk_size_t num, tsk_size_t size);

TSK_END_DECLS

#endif /* _TINYSAK_MEMORY_H_ */

