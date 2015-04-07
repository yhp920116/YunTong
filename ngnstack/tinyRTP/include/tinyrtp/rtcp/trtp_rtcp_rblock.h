
/* 2012-03-07 */

#ifndef TINYRTP_RTCP_REPORT_RB_H
#define TINYRTP_RTCP_REPORT_RB_H

#include "tinyrtp_config.h"

#include "tsk_list.h"

TRTP_BEGIN_DECLS

// RFC 3550 6.4.1 SR: Sender Report RTCP Packet => Report block part
typedef struct trtp_rtcp_rblock_s
{
	TSK_DECLARE_OBJECT;

	uint32_t ssrc;				/* data source being reported */
	unsigned int fraction:8;	/* fraction lost since last SR/RR */
	int cumulative_no_lost:24;  /* cumul. no. pkts lost (signed!) */
	uint32_t last_seq;			/* extended last seq. no. received */
	uint32_t jitter;			/* interarrival jitter */
	uint32_t lsr;				/* last SR packet from this source */
	uint32_t dlsr;				/* delay since last SR packet */
}
trtp_rtcp_rblock_t;
#define TRTP_RTCP_RBLOCK(self) ((trtp_rtcp_rblock_t*)(self))
TINYRTP_GEXTERN const tsk_object_def_t *trtp_rtcp_rblock_def_t;
typedef tsk_list_t trtp_rtcp_rblocks_L_t; /**< List of @ref trtp_rtcp_rblock_t elements */

trtp_rtcp_rblock_t* trtp_rtcp_rblock_create_null();
trtp_rtcp_rblock_t* trtp_rtcp_rblock_deserialize(const void* data, tsk_size_t size);
int trtp_rtcp_rblock_deserialize_payload(trtp_rtcp_rblock_t* self, const void* payload, tsk_size_t size);
tsk_size_t trtp_rtcp_rblock_get_size(trtp_rtcp_rblock_t* self);

TRTP_END_DECLS

#endif /* TINYRTP_RTCP_REPORT_RB_H */
