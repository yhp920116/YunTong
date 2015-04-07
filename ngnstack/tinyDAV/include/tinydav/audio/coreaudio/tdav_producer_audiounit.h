
/* 2012-03-07 */

#ifndef TINYDAV_PRODUCER_COREAUDIO_AUDIO_UNIT_H
#define TINYDAV_PRODUCER_COREAUDIO_AUDIO_UNIT_H

#include "tinydav_config.h"

#if HAVE_COREAUDIO_AUDIO_UNIT

#include <AudioToolbox/AudioToolbox.h>
#include <speex/speex_buffer.h>
#include "tinydav/audio/coreaudio/tdav_audiounit.h"
#include "tinydav/audio/tdav_producer_audio.h"
#include "tsk_condwait.h"
#include "tsk_mutex.h"

TDAV_BEGIN_DECLS

typedef struct tdav_producer_audiounit_s
{
	TDAV_DECLARE_PRODUCER_AUDIO;
	
	tdav_audiounit_handle_t* audioUnitHandle;
	unsigned started:1;
	unsigned paused:1;
	void* senderThreadId[1];
	tsk_condwait_handle_t* senderCondWait;
	
	struct {
		struct {
			void* buffer;
			tsk_size_t size;
		} chunck;
		SpeexBuffer* buffer;
		tsk_size_t size;
		tsk_mutex_handle_t* mutex;
	} ring;
}
tdav_producer_audiounit_t;

TINYDAV_GEXTERN const tmedia_producer_plugin_def_t *tdav_producer_audiounit_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_COREAUDIO_AUDIO_UNIT */

#endif /* TINYDAV_PRODUCER_COREAUDIO_AUDIO_UNIT_H */



