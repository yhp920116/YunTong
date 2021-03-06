
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_H264_H
#define TINYDAV_CODEC_H264_H

#include "tinydav_config.h"

#if HAVE_FFMPEG && (!defined(HAVE_H264) || HAVE_H264)

#include "tinydav/codecs/h264/tdav_codec_h264_common.h"

#include <libavcodec/avcodec.h>

TDAV_BEGIN_DECLS

typedef struct tdav_codec_h264_s
{
	TDAV_DECLARE_CODEC_H264_COMMON;

	// Encoder
	struct{
		AVCodec* codec;
		AVCodecContext* context;
		AVFrame* picture;
		void* buffer;
		int64_t frame_count;
	} encoder;
	
	// decoder
	struct{
		AVCodec* codec;
		AVCodecContext* context;
		AVFrame* picture;

		void* accumulator;
		tsk_size_t accumulator_pos;
		tsk_size_t accumulator_size;
		uint16_t last_seq;
	} decoder;
}
tdav_codec_h264_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_h264_bp10_plugin_def_t;
TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_h264_bp20_plugin_def_t;
TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_h264_bp30_plugin_def_t;

static inline tsk_bool_t tdav_codec_h264_is_ffmpeg_plugin(const tmedia_codec_plugin_def_t *plugin)
{
	if(plugin && (plugin == tdav_codec_h264_bp10_plugin_def_t || plugin == tdav_codec_h264_bp20_plugin_def_t || plugin == tdav_codec_h264_bp30_plugin_def_t)){
		return tsk_true;
	}
	return tsk_false;
}

TDAV_END_DECLS

#endif /* HAVE_FFMPEG */

#endif /* TINYDAV_CODEC_H264_H */