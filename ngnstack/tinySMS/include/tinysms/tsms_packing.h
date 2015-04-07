
/* 2012-03-07 */

#ifndef TINYSMS_TSMS_PACKING_H
#define TINYSMS_TSMS_PACKING_H

#include "tinysms_config.h"

#include "tsk_buffer.h"

TSMS_BEGIN_DECLS

TINYSMS_API tsk_buffer_t* tsms_pack_to_7bit(const char* ascii);
TINYSMS_API tsk_buffer_t* tsms_pack_to_ucs2(const char* ascii);
TINYSMS_API tsk_buffer_t* tsms_pack_to_8bit(const char* ascii);

TINYSMS_API char* tsms_pack_from_7bit(const void* gsm7bit, tsk_size_t size);
TINYSMS_API char* tsms_pack_from_ucs2(const void* ucs2, tsk_size_t size);
TINYSMS_API char* tsms_pack_from_8bit(const void* gsm8bit, tsk_size_t size);

TSMS_END_DECLS

#endif /* TINYSMS_TSMS_PACKING_H */
