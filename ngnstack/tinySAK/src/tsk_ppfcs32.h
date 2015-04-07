
/* 2012-03-07 */

#ifndef _TINYSAK_PPFCS32_H_
#define _TINYSAK_PPFCS32_H_

#include "tinysak_config.h"

TSK_BEGIN_DECLS

#define TSK_PPPINITFCS32  0xffffffff   /* Initial FCS value */
#define TSK_PPPGOODFCS32  0xdebb20e3   /* Good final FCS value */

TINYSAK_API uint32_t tsk_pppfcs32(register uint32_t fcs, register const uint8_t* cp, register int32_t len);

TSK_END_DECLS

#endif /* _TINYSAK_PPFCS32_H_ */

