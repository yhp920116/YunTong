
/* 2012-03-07 */

#ifndef TINYDAV_SPEEX_RESAMPLER_H
#define TINYDAV_SPEEX_RESAMPLER_H

#include "tinydav_config.h"

#if HAVE_SPEEX_DSP && (!defined(HAVE_SPEEX_RESAMPLER) || HAVE_SPEEX_RESAMPLER)

#include "tinymedia/tmedia_resampler.h"

#include <speex/speex_resampler.h>

TDAV_BEGIN_DECLS

/** Speex resampler*/
typedef struct tdav_speex_resampler_s
{
	TMEDIA_DECLARE_RESAMPLER;

	tsk_size_t in_size;
	tsk_size_t out_size;
	int8_t channels;

	SpeexResamplerState *state;
}
tdav_speex_resampler_t;

const tmedia_resampler_plugin_def_t *tdav_speex_resampler_plugin_def_t;

TDAV_END_DECLS

#endif /* #if HAVE_SPEEX_DSP */

#endif /* TINYDAV_SPEEX_RESAMPLER_H */
