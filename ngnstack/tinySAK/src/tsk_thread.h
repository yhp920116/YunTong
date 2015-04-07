
/* 2012-03-07 */

#ifndef _TINYSAK_THREAD_H_
#define _TINYSAK_THREAD_H_

#include "tinysak_config.h"

TSK_BEGIN_DECLS

TINYSAK_API void tsk_thread_sleep(uint64_t ms);
TINYSAK_API int tsk_thread_create(void** tid, void *(*start) (void *), void *arg);
TINYSAK_API int tsk_thread_set_priority(void* tid, int32_t priority);
TINYSAK_API int tsk_thread_set_priority_2(int32_t priority);
TINYSAK_API int tsk_thread_join(void** tid);

TSK_END_DECLS

#endif


