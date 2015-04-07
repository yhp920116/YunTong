
/* 2012-03-07 */

#ifndef _TINYSAK_COMMON_H_
#define _TINYSAK_COMMON_H_

typedef int tsk_boolean_t;
#define tsk_bool_t tsk_boolean_t

/**@def tsk_true
* True (1).
*/
/**@def tsk_false
* False (0).
*/
#define tsk_true	1
#define tsk_false	0

#define TSK_MIN(a,b)					(((a) < (b)) ? (a) : (b))
#define TSK_MAX(a,b)					(((a) > (b)) ? (a) : (b))
#define TSK_ABS(a)						(((a)< 0) ? -(a) : (a))
#define TSK_CLAMP(nMin, nVal, nMax)		((nVal) > (nMax)) ? (nMax) : (((nVal) < (nMin)) ? (nMin) : (nVal))

// used to avoid doing *((uint32_t*)ptr) which don't respect memory alignment on
// some embedded (ARM,?...) platforms
#define TSK_TO_UINT32(u8_ptr) (((uint32_t)(u8_ptr)[0]) | ((uint32_t)(u8_ptr)[1])<<8 | ((uint32_t)(u8_ptr)[2])<<16 | ((uint32_t)(u8_ptr)[3])<<24)
#define TSK_TO_INT32(u8_ptr) (((int32_t)(u8_ptr)[0]) | ((int32_t)(u8_ptr)[1])<<8 | ((int32_t)(u8_ptr)[2])<<16 | ((int32_t)(u8_ptr)[3])<<24)
#define TSK_TO_UINT16(u8_ptr) (((uint16_t)(u8_ptr)[0]) | ((uint16_t)(u8_ptr)[1])<<8)

typedef int tsk_ssize_t; /**< Signed size */
typedef unsigned int tsk_size_t; /**< Unsigned size */


#if defined(va_copy)
#	define tsk_va_copy(D, S)       va_copy((D), (S))
#elif defined(__va_copy)
#	define tsk_va_copy(D, S)       __va_copy((D), (S))
#else
#	define tsk_va_copy(D, S)       ((D) = (S))
#endif


#ifdef NULL
#define tsk_null    NULL /**< Null pointer */
#else
#define tsk_null    0  /**< Null pointer */
#endif

#endif /* _TINYSAK_COMMON_H_ */
