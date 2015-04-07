
/* 2012-03-07 */

#ifndef _TINYSAK_TIMER_H_
#define _TINYSAK_TIMER_H_

#include "tinysak_config.h"

#include "tsk_object.h"

TSK_BEGIN_DECLS


/**@ingroup tsk_timer_group
* @def TSK_TIMER_CALLBACK
*/
#define TSK_TIMER_CALLBACK_F(callback)				((tsk_timer_callback_f)callback)

/**@ingroup tsk_timer_group
* @def TSK_INVALID_TIMER_ID
*/
/**@ingroup tsk_timer_group
* @def TSK_TIMER_ID_IS_VALID
*/
#define TSK_INVALID_TIMER_ID						0
#define TSK_TIMER_ID_IS_VALID(id)					((id) != TSK_INVALID_TIMER_ID)

/**@ingroup tsk_timer_group
* @def tsk_timer_manager_handle_t
*/
/**@ingroup tsk_timer_group
* @def tsk_timer_id_t
*/
/**@ingroup tsk_timer_group
* @def tsk_timer_callback
*/
typedef void tsk_timer_manager_handle_t;
typedef uint64_t tsk_timer_id_t;
typedef int (*tsk_timer_callback_f)(const void* arg, tsk_timer_id_t timer_id);

TINYSAK_API tsk_timer_manager_handle_t* tsk_timer_manager_create();

TINYSAK_API int tsk_timer_manager_start(tsk_timer_manager_handle_t *self);
TINYSAK_API int tsk_timer_manager_stop(tsk_timer_manager_handle_t *self);
#if defined(DEBUG) || defined(_DEBUG)
TINYSAK_API void tsk_timer_manager_debug(tsk_timer_manager_handle_t *self);
#endif

TINYSAK_API tsk_timer_id_t tsk_timer_manager_schedule(tsk_timer_manager_handle_t *self, uint64_t timeout, tsk_timer_callback_f callback, const void *arg);
TINYSAK_API int tsk_timer_manager_cancel(tsk_timer_manager_handle_t *self, tsk_timer_id_t id);
TINYSAK_API int tsk_timer_manager_destroy(tsk_timer_manager_handle_t **self);


// Global Timer manager
TINYSAK_API int tsk_timer_mgr_global_ref();
TINYSAK_API int tsk_timer_mgr_global_start();
TINYSAK_API tsk_timer_id_t tsk_timer_mgr_global_schedule(uint64_t timeout, tsk_timer_callback_f callback, const void *arg);
TINYSAK_API int tsk_timer_mgr_global_cancel(tsk_timer_id_t id);
TINYSAK_API int tsk_timer_mgr_global_stop();
TINYSAK_API int tsk_timer_mgr_global_unref();


TINYSAK_GEXTERN const tsk_object_def_t *tsk_timer_def_t;
TINYSAK_GEXTERN const tsk_object_def_t *tsk_timer_manager_def_t;

TSK_END_DECLS

#endif /* _TINYSAK_TIMER_H_ */

