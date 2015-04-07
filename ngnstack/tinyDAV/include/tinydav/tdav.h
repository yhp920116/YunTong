
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYMEDIA_TDAV_H
#define TINYMEDIA_TDAV_H

#include "tinydav_config.h"

#include "tsk_common.h" /* tsk_bool_t */

TDAV_BEGIN_DECLS

typedef enum tdav_codec_id_e
{
	tdav_codec_id_none = 0x00000000,
	
	tdav_codec_id_amr_nb_oa = 0x00000001<<0,
	tdav_codec_id_amr_nb_be = 0x00000001<<1,
	tdav_codec_id_amr_wb_oa = 0x00000001<<2,
	tdav_codec_id_amr_wb_be = 0x00000001<<3,
	tdav_codec_id_gsm = 0x00000001<<4,
	tdav_codec_id_pcma = 0x00000001<<5,
	tdav_codec_id_pcmu = 0x00000001<<6,
	tdav_codec_id_ilbc = 0x00000001<<7,
	tdav_codec_id_speex_nb = 0x00000001<<8,
	tdav_codec_id_speex_wb = 0x00000001<<9,
	tdav_codec_id_speex_uwb = 0x00000001<<10,
	tdav_codec_id_bv16 = 0x00000001<<11,
	tdav_codec_id_bv32 = 0x00000001<<12,
	tdav_codec_id_evrc = 0x00000001<<13,
	tdav_codec_id_g729ab = 0x00000001<<14,
	tdav_codec_id_g722 = 0x00000001<<15,
	
	/* room for new Audio codecs */
	
	tdav_codec_id_h261 = 0x00010000<<0,
	tdav_codec_id_h263 = 0x00010000<<1,
	tdav_codec_id_h263p = 0x00010000<<2,
	tdav_codec_id_h263pp = 0x00010000<<3,
	tdav_codec_id_h264_bp10 = 0x00010000<<4,
	tdav_codec_id_h264_bp20 = 0x00010000<<5,
	tdav_codec_id_h264_bp30 = 0x00010000<<6,
	tdav_codec_id_h264_svc = 0x00010000<<7,
	tdav_codec_id_theora = 0x00010000<<8,
	tdav_codec_id_mp4ves_es = 0x00010000<<9,
	tdav_codec_id_vp8 = 0x00010000<<10,
}
tdav_codec_id_t;

TINYDAV_API int tdav_init();
TINYDAV_API int tdav_codec_set_priority(tdav_codec_id_t codec_id, int priority);
TINYDAV_API int tdav_codec_get_priority(tdav_codec_id_t* codec_id);
TINYDAV_API void tdav_set_codecs(tdav_codec_id_t codecs);
TINYDAV_API tsk_bool_t tdav_codec_is_supported(tdav_codec_id_t codec);
TINYDAV_API int tdav_deinit();

TINYDAV_API const char* tdav_codec_get_codec_name(tdav_codec_id_t codec);

TDAV_END_DECLS

#endif /* TINYMEDIA_TDAV_H */
