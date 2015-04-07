
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_H261_H
#define TINYDAV_CODEC_H261_H

#include "tinydav_config.h"

#if HAVE_FFMPEG

#include "tinymedia/tmedia_codec.h"

#include <libavcodec/avcodec.h>

TDAV_BEGIN_DECLS

#define TDAV_CODEC_H261(self) ((tdav_codec_h261_t*)(self))

/** H.2261 codec */
typedef struct tdav_codec_h261_s
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
	} encoder;
	
	// decoder
	struct{
		AVCodec* codec;
		AVCodecContext* context;
		AVFrame* picture;

		void* accumulator;
		uint8_t ebit;
		tsk_size_t accumulator_pos;
		uint16_t last_seq;
	} decoder;
}
tdav_codec_h261_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_h261_plugin_def_t;
TDAV_END_DECLS


#endif /* HAVE_FFMPEG */

#endif /* TINYDAV_CODEC_H261_H */
