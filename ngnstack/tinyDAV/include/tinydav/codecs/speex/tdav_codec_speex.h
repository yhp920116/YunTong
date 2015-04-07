
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_SPEEX_H
#define TINYDAV_CODEC_SPEEX_H

#include "tinydav_config.h"

#if HAVE_LIB_SPEEX

#include "tinymedia/tmedia_codec.h"

#include <speex/speex.h> 

TDAV_BEGIN_DECLS

typedef enum tdav_codec_speex_type_e
{
	tdav_codec_speex_type_nb,
	tdav_codec_speex_type_wb,
	tdav_codec_speex_type_uwb,
}
tdav_codec_speex_type_t;

/** Speex codec */
typedef struct tdav_codec_speex_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;

	tdav_codec_speex_type_t type;

	struct{
		void* state;
		SpeexBits bits;
		tsk_size_t size;
	} encoder;

	struct {
		void* state;
		SpeexBits bits;
		spx_int16_t* buffer;
		tsk_size_t size;
	} decoder;
}
tdav_codec_speex_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_speex_nb_plugin_def_t;
TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_speex_wb_plugin_def_t;
TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_speex_uwb_plugin_def_t;

TDAV_END_DECLS

#endif /* TINYDAV_CODEC_SPEEX_H */

#endif /* TINYDAV_CODEC_SPEEX_H */
