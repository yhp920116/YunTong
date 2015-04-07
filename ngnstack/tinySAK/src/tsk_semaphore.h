
/* 2012-03-07 */

#ifndef _TINYSAK_SEMAPHORE_H_
#define _TINYSAK_SEMAPHORE_H_

#include "tinysak_config.h"

TSK_BEGIN_DECLS

typedef void tsk_semaphore_handle_t;

TINYSAK_API tsk_semaphore_handle_t* tsk_semaphore_create();
TINYSAK_API tsk_semaphore_handle_t* tsk_semaphore_create_2(int initial_val);
TINYSAK_API int tsk_semaphore_increment(tsk_semaphore_handle_t* handle);
TINYSAK_API int tsk_semaphore_decrement(tsk_semaphore_handle_t* handle);
TINYSAK_API void tsk_semaphore_destroy(tsk_semaphore_handle_t** handle);

TSK_END_DECLS

#endif /* _TINYSAK_SEMAPHORE_H_ */

