
/* 2012-03-07 */

#ifndef TINYRTP_RTCP_PACKET_H
#define TINYRTP_RTCP_PACKET_H

#include "tinyrtp_config.h"

#include "tsk_list.h"

TRTP_BEGIN_DECLS

#define TRTP_RTCP_PACKET(self)	((trtp_rtcp_packet_t*)(self))

// RFC 3550 12.1 RTCP Packet Types
typedef enum trtp_rtcp_packet_type_e
{
	trtp_rtcp_packet_type_sr = 200,
	trtp_rtcp_packet_type_rr = 201,
	trtp_rtcp_packet_type_sdes = 202,
	trtp_rtcp_packet_type_bye = 203,
	trtp_rtcp_packet_type_app = 204,
}
trtp_rtcp_packet_type_t;

typedef struct trtp_rtcp_packet_s
{
	TSK_DECLARE_OBJECT;

	struct trtp_rtcp_header_s *header;
}
trtp_rtcp_packet_t;

#define TRTP_DECLARE_RTCP_PACKET trtp_rtcp_packet_t __packet__
typedef tsk_list_t trtp_rtcp_packets_L_t; /**< List of @ref trtp_rtcp_packet_t elements */

TINYRTP_API int trtp_rtcp_packet_init(trtp_rtcp_packet_t* self, uint8_t version, uint8_t padding, uint8_t rc, trtp_rtcp_packet_type_t type, uint16_t length);
int trtp_rtcp_packet_init_header(trtp_rtcp_packet_t* self, const void* data, tsk_size_t size);
TINYRTP_API trtp_rtcp_packet_t* trtp_rtcp_packet_deserialize(const void* data, tsk_size_t size);
TINYRTP_API int trtp_rtcp_packet_set_length(trtp_rtcp_packet_t* self, uint16_t length);
tsk_size_t trtp_rtcp_packet_get_size(trtp_rtcp_packet_t* self);
TINYRTP_API int trtp_rtcp_packet_deinit(trtp_rtcp_packet_t* self);

TRTP_END_DECLS

#endif /* TINYRTP_RTCP_PACKET_H */
