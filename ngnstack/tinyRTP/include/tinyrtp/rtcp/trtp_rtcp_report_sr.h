
/* 2012-03-07 */

#ifndef TINYRTP_RTCP_REPORT_SR_H
#define TINYRTP_RTCP_REPORT_SR_H

#include "tinyrtp_config.h"

#include "tinyrtp/rtcp/trtp_rtcp_packet.h"
#include "tinyrtp/rtcp/trtp_rtcp_rblock.h"

TRTP_BEGIN_DECLS

#define TRTP_RTCP_REPORT_SR(self)	((trtp_rtcp_report_sr_t*)(self))

// RFC 3550 6.4.1 SR: Sender Report RTCP Packet
typedef struct trtp_rtcp_report_sr_s
{
	TRTP_DECLARE_RTCP_PACKET;
	
	uint32_t sender_ssrc;
	struct{
		uint32_t ntp_msw; /**< NTP timestamp, most significant word */
		uint32_t ntp_lsw; /**< NTP timestamp, least significant word */
		uint32_t rtp_timestamp;/**< RTP timestamp */
		uint32_t sender_pcount; /**< sender's packet count */
		uint32_t sender_ocount; /**< sender's octet count */
	} sender_info;
	trtp_rtcp_rblocks_L_t* rblocks;
}
trtp_rtcp_report_sr_t;

TRTP_END_DECLS

TINYRTP_API trtp_rtcp_report_sr_t* trtp_rtcp_report_sr_create_null();
trtp_rtcp_report_sr_t* trtp_rtcp_report_sr_deserialize(const void* data, tsk_size_t size);
int trtp_rtcp_report_sr_deserialize_payload(trtp_rtcp_report_sr_t* self, const void* payload, tsk_size_t size);

TINYRTP_GEXTERN const tsk_object_def_t *trtp_rtcp_report_sr_def_t;

#endif /* TINYRTP_RTCP_REPORT_SR_H */
