
/* 2012-03-07 */

#ifndef TINYDAV_SPEAKUP_JITTER_BUFFER_H
#define TINYDAV_SPEAKUP_JITTER_BUFFER_H

#include "tinydav_config.h"

#include "tinymedia/tmedia_jitterbuffer.h"

#include "tinydav/audio/tdav_jitterbuffer.h"

TDAV_BEGIN_DECLS

/** Speakuo JitterBufferr*/
typedef struct tdav_speakup_jitterBuffer_s
{
	TMEDIA_DECLARE_JITTER_BUFFER;

	jitterbuffer *jbuffer;
	uint8_t jcodec;
	uint64_t ref_timestamp;
	uint32_t frame_duration;
	uint32_t rate;
	uint32_t _10ms_size_bytes;
}
tdav_speakup_jitterbuffer_t;

const tmedia_jitterbuffer_plugin_def_t *tdav_speakup_jitterbuffer_plugin_def_t;

TDAV_END_DECLS

#endif /* TINYDAV_SPEAKUP_JITTER_BUFFER_H */
