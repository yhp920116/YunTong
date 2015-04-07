
/* 2012-03-07 */

#ifndef TINYDAV_SPEEX_DENOISE_H
#define TINYDAV_SPEEX_DENOISE_H

#include "tinydav_config.h"

#if HAVE_SPEEX_DSP && (!defined(HAVE_SPEEX_DENOISE) || HAVE_SPEEX_DENOISE)

#include "tinymedia/tmedia_denoise.h"

#include <speex/speex_preprocess.h>
#include <speex/speex_echo.h>

TDAV_BEGIN_DECLS

/** Speex denoiser*/
typedef struct tdav_speex_denoise_s
{
	TMEDIA_DECLARE_DENOISE;

	SpeexPreprocessState *preprocess_state_record; 
	SpeexPreprocessState *preprocess_state_playback;
	SpeexEchoState *echo_state;

	spx_int16_t* echo_output_frame;
	uint32_t frame_size;
}
tdav_speex_denoise_t;

const tmedia_denoise_plugin_def_t *tdav_speex_denoise_plugin_def_t;

TDAV_END_DECLS

#endif /* #if HAVE_SPEEX_DSP */

#endif /* TINYDAV_SPEEX_DENOISE_H */
