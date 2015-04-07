
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_THEORA_H
#define TINYDAV_CODEC_THEORA_H

#include "tinydav_config.h"

#if HAVE_FFMPEG && (!defined(HAVE_THEORA) || HAVE_THEORA)

#include "tinymedia/tmedia_codec.h"

#include "tsk_buffer.h"

#include <libavcodec/avcodec.h>

TDAV_BEGIN_DECLS

typedef struct tdav_codec_theora_s
{
	TMEDIA_DECLARE_CODEC_VIDEO;

	struct{
		uint8_t* ptr;
		tsk_size_t size;
	} rtp;

	// Encoder
	struct{
		AVCodec* codec;
		AVCodecContext* context;
		AVFrame* picture;
		void* buffer;

		uint64_t conf_last;
		int conf_count;
	} encoder;
	
	// decoder
	struct{
		AVCodec* codec;
		AVCodecContext* context;
		AVFrame* picture;

		tsk_bool_t opened;
		uint8_t conf_ident[3];
		tsk_buffer_t* conf_pkt;
		
		void* accumulator;
		uint8_t ebit;
		tsk_size_t accumulator_pos;
		uint16_t last_seq;
	} decoder;
}
tdav_codec_theora_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_theora_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_FFMPEG */

#endif /* TINYDAV_CODEC_THEORA_H */