
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_H264_RTP_H
#define TINYDAV_CODEC_H264_RTP_H

#include "tinydav_config.h"

#include "tsk_common.h"

TDAV_BEGIN_DECLS

#if TDAV_UNDER_WINDOWS
#	define H264_RTP_PAYLOAD_SIZE	1300
#else
#	define H264_RTP_PAYLOAD_SIZE	900
#endif

#define H264_START_CODE_PREFIX_SIZE	4

struct tdav_codec_h264_common_s;

extern uint8_t H264_START_CODE_PREFIX[4];

typedef enum profile_idc_e {
	profile_idc_none = 0,

	profile_idc_baseline = 66,
	profile_idc_extended = 88,
	profile_idc_main = 77,
	profile_idc_high = 100
}
profile_idc_t;

typedef struct profile_iop_s {
	unsigned constraint_set0_flag:1; 
	unsigned constraint_set1_flag:1;
    unsigned constraint_set2_flag:1; 
	unsigned reserved_zero_5bits:5;
}
profile_iop_t;

typedef enum level_idc_e {
	level_idc_none	= 0,
	
	level_idc_1_0 = 10,
	level_idc_1_b = 14,
	level_idc_1_1 = 11,
	level_idc_1_2 = 12,
	level_idc_1_3 = 13,
	level_idc_2_0 = 20,
	level_idc_2_1 = 21,
	level_idc_2_2 = 22,
	level_idc_3_0 = 30
}
level_idc_t;


/* 5.2. Common Structure of the RTP Payload Format 
 Type   Packet    Type name                        Section
  ---------------------------------------------------------
  0      undefined                                    -
  1-23   NAL unit  Single NAL unit packet per H.264   5.6
  24     STAP-A    Single-time aggregation packet     5.7.1
  25     STAP-B    Single-time aggregation packet     5.7.1
  26     MTAP16    Multi-time aggregation packet      5.7.2
  27     MTAP24    Multi-time aggregation packet      5.7.2
  28     FU-A      Fragmentation unit                 5.8
  29     FU-B      Fragmentation unit                 5.8
  30-31  undefined                                    -
*/
typedef enum nal_unit_type_e{
    undefined_0 = 0,
    nal_unit,
    stap_a = 24,
    stap_b = 25,
    mtap16 = 26,
    mtap24 = 27, 
    fu_a = 28,	
    fu_b = 29,
	undefined_30 = 30,
	undefined_31 = 31
}
nal_unit_type_t;

int tdav_codec_h264_parse_profile(const char* profile_level_id, profile_idc_t *p_idc, profile_iop_t *p_iop, level_idc_t *l_idc);
int tdav_codec_h264_get_pay(const void* in_data, tsk_size_t in_size, const void** out_data, tsk_size_t *out_size, tsk_bool_t* append_scp);

void tdav_codec_h264_rtp_callback(struct tdav_codec_h264_common_s *self, const void *data, tsk_size_t size, tsk_bool_t marker);

TDAV_END_DECLS

#endif /* TINYDAV_CODEC_H264_RTP_H */
