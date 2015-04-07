
/* 2012-03-07 */

#ifndef TSIP_SIGCOMP_H
#define TSIP_SIGCOMP_H

#include "tinysip_config.h"

#include "tsk_object.h"

TSIP_BEGIN_DECLS

#define TSIP_IS_SIGCOMP_DATA(data)	((data) && (*((uint8_t*)data) & 0xF8) == 0xF8)

#define TSIP_SIGCOMP_DMS			8192
#define TSIP_SIGCOMP_SMS			8192
#define TSIP_SIGCOMP_CPB			64
#define TSIP_SIGCOMP_PRES_DICT		tsk_false
#define TSIP_SIGCOMP_SIP_DICT		tsk_true
#define TSIP_SIGCOMP_MAX_BUFF_SIZE	0x2710

typedef void tsip_sigcomp_handle_t;

tsip_sigcomp_handle_t* tsip_sigcomp_handler_create(uint8_t cpb, uint32_t dms, uint32_t sms);
int tsip_sigcomp_handler_set_dicts(tsip_sigcomp_handle_t* self, tsk_bool_t sip_n_sdp, tsk_bool_t pres);
int tsip_sigcomp_handler_add_compartment(tsip_sigcomp_handle_t* self, const char* comp_id);
int tsip_sigcomp_handler_remove_compartment(tsip_sigcomp_handle_t* self, const char* comp_id);
const char* tsip_sigcomp_handler_fixme_getcompid(const tsip_sigcomp_handle_t* self);
int tsip_sigcomp_close_all(tsip_sigcomp_handle_t* self);
tsk_size_t tsip_sigcomp_handler_compress(tsip_sigcomp_handle_t* self, const char* comp_id, tsk_bool_t is_stream, const void* in_data, tsk_size_t in_size, void* out_data, tsk_size_t out_maxsize);
tsk_size_t tsip_sigcomp_handler_uncompress(tsip_sigcomp_handle_t* self, const char* comp_id, tsk_bool_t is_stream, const void* in_data, tsk_size_t in_size, void* out_data, tsk_size_t out_maxsize, tsk_bool_t* is_nack);
tsk_size_t tsip_sigcomp_handler_uncompress_next(tsip_sigcomp_handle_t* self, const char* comp_id, void** nack_data, tsk_bool_t* is_nack);


#define tsip_sigcomp_handler_compressUDP(self, comp_id, in_data, in_size, out_data, out_maxsize)	tsip_sigcomp_handler_compress(self, comp_id, tsk_false, in_data, in_size, out_data, out_maxsize)
#define tsip_sigcomp_handler_compressTCP(self, comp_id, in_data, in_size, out_data, out_maxsize)	tsip_sigcomp_handler_compress(self, comp_id, tsk_true, in_data, in_size, out_data, out_maxsize)
#define tsip_sigcomp_handler_uncompressUDP(self, comp_id, in_data, in_size, out_data, out_maxsize, is_nack) tsip_sigcomp_handler_uncompress(self, comp_id, tsk_false, in_data, in_size, out_data, out_maxsize, is_nack)
#define tsip_sigcomp_handler_uncompressTCP(self, comp_id, in_data, in_size, out_data, out_maxsize, is_nack) tsip_sigcomp_handler_uncompress(self, comp_id, tsk_true, in_data, in_size, out_data, out_maxsize, is_nack)

TSIP_END_DECLS

#endif /* TSIP_SIGCOMP_H */

