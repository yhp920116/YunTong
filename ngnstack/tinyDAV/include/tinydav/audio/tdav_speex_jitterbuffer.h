
/* 2012-03-07 */

#ifndef TINYDAV_SPEEX_JITTER_BUFFER_H
#define TINYDAV_SPEEX_JITTER_BUFFER_H

#include "tinydav_config.h"

#if HAVE_SPEEX_DSP && HAVE_SPEEX_JB

#include "tinymedia/tmedia_jitterbuffer.h"

#include <speex/speex_jitter.h>

TDAV_BEGIN_DECLS

/** Speex JitterBuffer*/
typedef struct tdav_speex_jitterBuffer_s
{
	TMEDIA_DECLARE_JITTER_BUFFER;

	JitterBuffer* state;
	uint32_t rate;
	uint32_t frame_duration;
}
tdav_speex_jitterbuffer_t;

const tmedia_jitterbuffer_plugin_def_t *tdav_speex_jitterbuffer_plugin_def_t;

TDAV_END_DECLS

#endif /* #if HAVE_SPEEX_DSP */

#endif /* TINYDAV_SPEEX_JITTER_BUFFER_H */
