
/* 2012-03-07 */

#ifndef TINYDAV_CONSUMER_COREAUDIO_AUDIO_QUEUE_H
#define TINYDAV_CONSUMER_COREAUDIO_AUDIO_QUEUE_H

#include "tinydav_config.h"

#if HAVE_COREAUDIO_AUDIO_QUEUE

#include <AudioToolbox/AudioToolbox.h>
#include "tinydav/audio/tdav_consumer_audio.h"

TDAV_BEGIN_DECLS

#ifndef CoreAudioPlayBuffers
#	define CoreAudioPlayBuffers 3
#endif

typedef struct tdav_consumer_audioqueue_s
{
	TDAV_DECLARE_CONSUMER_AUDIO;
    
	tsk_bool_t started;
    
    AudioStreamBasicDescription description;
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[CoreAudioPlayBuffers];
    
    tsk_size_t buffer_size;
}
tdav_consumer_audioqueue_t;

TINYDAV_GEXTERN const tmedia_consumer_plugin_def_t *tdav_consumer_audioqueue_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_COREAUDIO_AUDIO_QUEUE */

#endif /* TINYDAV_CONSUMER_COREAUDIO_AUDIO_QUEUE_H */
