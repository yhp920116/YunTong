
/* 2012-03-07 */

#ifndef TINYRTP_RTP_PACKET_H
#define TINYRTP_RTP_PACKET_H

#include "tinyrtp_config.h"

#include "tinyrtp/rtp/trtp_rtp_header.h"

#include "tsk_object.h"

TRTP_BEGIN_DECLS


typedef struct trtp_rtp_packet_s
{
	TSK_DECLARE_OBJECT;

	trtp_rtp_header_t* header;

	struct{
		void* data;
		const void* data_const;
		tsk_size_t size;
	} payload;
	
	/* extension header as per RFC 3550 section 5.3.1 */
	struct{
		void* data;
		tsk_size_t size; /* contains the first two 16-bit fields */
	} extension;
}
trtp_rtp_packet_t;

TINYRTP_API trtp_rtp_packet_t* trtp_rtp_packet_create_null();
TINYRTP_API trtp_rtp_packet_t* trtp_rtp_packet_create(uint32_t ssrc, uint16_t seq_num, uint32_t timestamp, uint8_t payload_type, tsk_bool_t marker);
TINYRTP_API tsk_buffer_t* trtp_rtp_packet_serialize(const trtp_rtp_packet_t *self);
TINYRTP_API trtp_rtp_packet_t* trtp_rtp_packet_deserialize(const void *data, tsk_size_t size);


TINYRTP_GEXTERN const tsk_object_def_t *trtp_rtp_packet_def_t;

TRTP_END_DECLS

#endif /* TINYRTP_RTP_PACKET_H */
