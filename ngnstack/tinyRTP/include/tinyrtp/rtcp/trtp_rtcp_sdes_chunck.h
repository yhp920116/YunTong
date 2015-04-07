
/* 2012-03-07 */

#ifndef TINYRTP_RTCP_SDES_CHUNCK_H
#define TINYRTP_RTCP_SDES_CHUNCK_H

#include "tinyrtp_config.h"

#include "tinyrtp/rtcp/trtp_rtcp_sdes_item.h"

#define TRTP_RTCP_SDES_CHUNCK_MIN_SIZE			4
#define TRTP_RTCP_SDES_CHUNCK_SSRC_OR_CSRC_SIZE 4

TRTP_BEGIN_DECLS

typedef struct trtp_rtcp_sdes_chunck_s
{
	TSK_DECLARE_OBJECT;

	uint32_t ssrc_or_csrc;
	trtp_rtcp_sdes_items_L_t* items;
}
trtp_rtcp_sdes_chunck_t;
#define TRTP_RTCP_SDES_CHUNCK(self) ((trtp_rtcp_sdes_chunck_t*)(self))
TINYRTP_GEXTERN const tsk_object_def_t *trtp_rtcp_sdes_chunck_def_t;
typedef tsk_list_t trtp_rtcp_sdes_chuncks_L_t; /**< List of @ref trtp_rtcp_sdes_item_t elements */

trtp_rtcp_sdes_chunck_t* trtp_rtcp_sdes_chunck_create_null();
trtp_rtcp_sdes_chunck_t* trtp_rtcp_sdes_chunck_create(uint32_t ssrc_or_csrc);
trtp_rtcp_sdes_chunck_t* trtp_rtcp_sdes_chunck_deserialize(const void* data, tsk_size_t size);
tsk_size_t trtp_rtcp_sdes_chunck_get_size(trtp_rtcp_sdes_chunck_t* self);

TRTP_END_DECLS

#endif /*TINYRTP_RTCP_SDES_CHUNCK_H*/
