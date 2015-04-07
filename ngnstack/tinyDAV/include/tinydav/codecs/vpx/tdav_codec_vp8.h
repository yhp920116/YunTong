
#ifndef TINYDAV_CODEC_VP8_H
#define TINYDAV_CODEC_VP8_H

#include "tinydav_config.h"

#if HAVE_LIBVPX

#include "tinymedia/tmedia_codec.h"

#define VPX_CODEC_DISABLE_COMPAT 1 /* strict compliance with the latest SDK by disabling some backwards compatibility  */
#include <vpx/vpx_encoder.h>
#include <vpx/vpx_decoder.h>
#include <vpx/vp8cx.h>
#include <vpx/vp8dx.h>

TDAV_BEGIN_DECLS

/* VP8 codec */
typedef struct tdav_codec_vp8_s
{
	TMEDIA_DECLARE_CODEC_VIDEO;

	// Encoder
	struct{
		unsigned initialized:1;
		vpx_codec_pts_t pts;
		vpx_codec_ctx_t context;
		uint16_t pic_id;
		uint16_t gop_size;
		uint64_t frame_count;

		struct{
			uint8_t* ptr;
			tsk_size_t size;
		} rtp;
	} encoder;

	// decoder
	struct{
		unsigned initialized:1;
		vpx_codec_ctx_t context;
		void* accumulator;
		tsk_size_t accumulator_pos;
		tsk_size_t accumulator_size;
		uint16_t last_seq;
		unsigned last_PartID:4;
		unsigned last_S:1;
		unsigned last_N:1;
		unsigned frame_corrupted;
	} decoder;
}
tdav_codec_vp8_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_vp8_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_LIBVPX */


#endif /* TINYDAV_CODEC_VP8_H */