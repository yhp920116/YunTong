
/* 2012-03-07 */

#ifndef TINYDAV_PRODUCER_COREAUDIO_AUDIO_QUEUE_H
#define TINYDAV_PRODUCER_COREAUDIO_AUDIO_QUEUE_H

#include "tinydav_config.h"

#if HAVE_COREAUDIO_AUDIO_QUEUE

#include <AudioToolbox/AudioToolbox.h>
#include "tinydav/audio/tdav_producer_audio.h"

TDAV_BEGIN_DECLS

#define CoreAudioRecordBuffers 3

typedef struct tdav_producer_audioqueue_s
{
	TDAV_DECLARE_PRODUCER_AUDIO;
	
	tsk_bool_t started;
	
    AudioStreamBasicDescription description;
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[CoreAudioRecordBuffers];
    
    tsk_size_t buffer_size;
}
tdav_producer_audioqueue_t;

TINYDAV_GEXTERN const tmedia_producer_plugin_def_t *tdav_producer_audioqueue_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_COREAUDIO_AUDIO_QUEUE */

#endif /* TINYDAV_PRODUCER_COREAUDIO_AUDIO_QUEUE_H */
