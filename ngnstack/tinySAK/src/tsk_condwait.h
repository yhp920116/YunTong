
/* 2012-03-07 */

#ifndef _TINYSAK_CONDWAIT_H_
#define _TINYSAK_CONDWAIT_H_

#include "tinysak_config.h"
#include "tsk_mutex.h"

TSK_BEGIN_DECLS

/**@ingroup tsk_condwait_group
*	An opaque handle to a condwait object.
*/
typedef void tsk_condwait_handle_t;

TINYSAK_API tsk_condwait_handle_t* tsk_condwait_create();
TINYSAK_API int tsk_condwait_wait(tsk_condwait_handle_t* handle);
TINYSAK_API int tsk_condwait_timedwait(tsk_condwait_handle_t* handle, uint64_t ms);
TINYSAK_API int tsk_condwait_signal(tsk_condwait_handle_t* handle);
TINYSAK_API int tsk_condwait_broadcast(tsk_condwait_handle_t* handle);
TINYSAK_API void tsk_condwait_destroy(tsk_condwait_handle_t** handle);

TSK_END_DECLS

#endif /* _TINYSAK_CONDWAIT_H_ */

