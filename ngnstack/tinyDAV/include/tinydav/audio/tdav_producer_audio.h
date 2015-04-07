
/* 2012-03-07 */

#ifndef TINYDAV_PRODUCER_AUDIO_H
#define TINYDAV_PRODUCER_AUDIO_H

#include "tinydav_config.h"

#include "tinymedia/tmedia_producer.h"

TDAV_BEGIN_DECLS

#define TDAV_BITS_PER_SAMPLE_DEFAULT 16

#define TDAV_PRODUCER_AUDIO(self)  ((tdav_producer_audio_t*)(self))

typedef struct tdav_producer_audio_s
{
	TMEDIA_DECLARE_PRODUCER;
}
tdav_producer_audio_t;

TINYDAV_API int tdav_producer_audio_init(tdav_producer_audio_t* self);
TINYDAV_API int tdav_producer_audio_cmp(const tsk_object_t* producer1, const tsk_object_t* producer2);
#define tdav_producer_audio_prepare(self, codec) tmedia_producer_prepare(TMEDIA_PRODUCER(self), codec)
#define tmedia_producer_audio_set_callback(self, callback, callback_data) tmedia_producer_set_callback(TMEDIA_PRODUCER(self), callback, callback_data)
#define tdav_producer_audio_start(self)	tdav_producer_start(TMEDIA_PRODUCER(self))
#define tdav_producer_audio_pause(self)	tdav_producer_pause(TMEDIA_PRODUCER(self))
#define tdav_producer_audio_stop(self) tdav_producer_stop(TMEDIA_PRODUCER(self))
TINYDAV_API int tdav_producer_audio_set(tdav_producer_audio_t* self, const tmedia_param_t* param);
TINYDAV_API int tdav_producer_audio_deinit(tdav_producer_audio_t* self);

#define TDAV_DECLARE_PRODUCER_AUDIO tdav_producer_audio_t __producer_audio__

TDAV_END_DECLS

#endif /* TINYDAV_PRODUCER_AUDIO_H */

