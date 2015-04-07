
/* 2012-03-07 */

#ifndef TINYRTP_RTCP_REPORT_SDES_H
#define TINYRTP_RTCP_REPORT_SDES_H

#include "tinyrtp_config.h"

#include "tinyrtp/rtcp/trtp_rtcp_packet.h"
#include "tinyrtp/rtcp/trtp_rtcp_sdes_chunck.h"

TRTP_BEGIN_DECLS

/* RFC 3550 6.5 SDES: Source Description RTCP Packet */
typedef struct trtp_rtcp_report_sdes_s
{
	TRTP_DECLARE_RTCP_PACKET;
	trtp_rtcp_sdes_chuncks_L_t* chuncks;
}
trtp_rtcp_report_sdes_t;
#define TRTP_RTCP_REPORT_SDES(self) ((trtp_rtcp_report_sdes_t*)(self))
TINYRTP_GEXTERN const tsk_object_def_t *trtp_rtcp_report_sdes_def_t;
typedef tsk_list_t trtp_rtcp_report_sdess_L_t; /**< List of @ref trtp_rtcp_report_sdes_t elements */

trtp_rtcp_report_sdes_t* trtp_rtcp_report_sdes_create_null();
trtp_rtcp_report_sdes_t* trtp_rtcp_report_sdes_deserialize(const void* data, tsk_size_t size);
int trtp_rtcp_report_sdes_deserialize_payload(trtp_rtcp_report_sdes_t* self, const void* payload, tsk_size_t size);

TRTP_END_DECLS

#endif /* TINYRTP_RTCP_REPORT_SDES_H */
