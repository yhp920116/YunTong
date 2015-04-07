
/* 2012-03-07 */

#ifndef TNET_ENDIANNESS_H
#define TNET_ENDIANNESS_H

#include "tinynet_config.h"

#include "tsk_common.h" /* tsk_bool_t */

TNET_BEGIN_DECLS

TINYNET_API TNET_INLINE unsigned short tnet_htons(unsigned short x);
TINYNET_API TNET_INLINE unsigned short tnet_htons_2(const void* px);
TINYNET_API TNET_INLINE unsigned long tnet_htonl(unsigned long x);
TINYNET_API TNET_INLINE unsigned long tnet_htonl_2(const void* px);
TINYNET_API TNET_INLINE tsk_bool_t tnet_is_BE();

#define tnet_ntohs(x) tnet_htons(x)
#define tnet_ntohs_2(px) tnet_htons_2(px)
#define tnet_ntohl(x) tnet_htonl(x)
#define tnet_ntohl_2(px) tnet_htonl_2(px)

TNET_BEGIN_DECLS

#endif /*TNET_ENDIANNESS_H*/

