
/* 2012-03-07 */

#ifndef _TINYSAK_TIME_H_
#define _TINYSAK_TIME_H_

#include "tinysak_config.h"

TSK_BEGIN_DECLS

//#if defined(__SYMBIAN32__) || ANDROID /* Forward declaration */
struct timeval;
struct timezone;
struct timespec;
//#endif

/**@ingroup tsk_time_group
*/
#define TSK_TIME_S_2_MS(S) ((S)*1000)
#define TSK_TIME_MS_2_S(MS) ((MS)/1000)

TINYSAK_API int tsk_gettimeofday(struct timeval *tv, struct timezone *tz);
TINYSAK_API uint64_t tsk_time_get_ms(const struct timeval *tv);
TINYSAK_API uint64_t tsk_time_epoch();
TINYSAK_API uint64_t tsk_time_now();


TSK_END_DECLS

#endif /* _TINYSAK_TIME_H_ */

