
/* 2012-03-07 */

#ifndef _TINYSAK_PPFCS16_H_
#define _TINYSAK_PPFCS16_H_

#include "tinysak_config.h"

TSK_BEGIN_DECLS

#define TSK_PPPINITFCS16    0xffff  /* Initial FCS value */
#define TSK_PPPGOODFCS16    0xf0b8  /* Good final FCS value */

TINYSAK_API uint16_t tsk_pppfcs16(register uint16_t fcs, register const uint8_t* cp, register int32_t len);

TSK_END_DECLS

#endif /* _TINYSAK_PPFCS16_H_ */

