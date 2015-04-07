
/* 2012-03-07 */

#ifndef _TINYSAK_SAFEOBJ_H_
#define _TINYSAK_SAFEOBJ_H_

#include "tinysak_config.h"
#include "tsk_mutex.h"

TSK_BEGIN_DECLS

//#define TSK_DECLARE_SAFEOBJ\
//	union{ \
//		tsk_mutex_handle_t *mutex; \
//	}

/**@ingroup tsk_safeobj_group
* Macro helper to declare an object as thread-safe.
*/
#define TSK_DECLARE_SAFEOBJ		tsk_mutex_handle_t *mutex

#define TSK_SAFEOBJ_MUTEX(safeobj) ((safeobj)->mutex)

/**@ingroup tsk_safeobj_group
* @def tsk_safeobj_init
* You MUST call this method before using @ref tsk_safeobj_lock or @ref tsk_safeobj_unlock to initilize the internal mutex.
* Before freeing your safeobject you MUST call @ref tsk_safeobj_deinit to deinitialize the internal mutex.
* @param safeobj The thread-safe object to initialize.
* @sa @ref tsk_safeobj_deinit.
*/
/**@ingroup tsk_safeobj_group
*@def tsk_safeobj_lock
* Locks a previously initialized safeobject.
* @param safeobj The thread-safe object to lock.
*/
/**@ingroup tsk_safeobj_group
*@def tsk_safeobj_unlock
* Unlocks a previously locked safeobject.
* @param safeobj The thread-safe object to unlock.
*/
/**@ingroup tsk_safeobj_group
*@def tsk_safeobj_deinit
* Deinitialize a previously initialize safeobject.
* @param safeobj The thread-safe object to deinitialize.
* @sa @ref tsk_safeobj_init.
*/
#define tsk_safeobj_init(safeobj)	TSK_SAFEOBJ_MUTEX(safeobj) = (TSK_SAFEOBJ_MUTEX(safeobj) ? TSK_SAFEOBJ_MUTEX(safeobj) : tsk_mutex_create())
#define tsk_safeobj_lock(safeobj)	tsk_mutex_lock(TSK_SAFEOBJ_MUTEX(safeobj))
#define tsk_safeobj_unlock(safeobj) tsk_mutex_unlock(TSK_SAFEOBJ_MUTEX(safeobj))
#define tsk_safeobj_deinit(safeobj)	tsk_mutex_destroy(&TSK_SAFEOBJ_MUTEX(safeobj))

TSK_END_DECLS

#endif /* _TINYSAK_SAFEOBJ_H_ */

