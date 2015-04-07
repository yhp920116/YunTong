
/* 2012-03-07 */

#ifndef TINYDAV_PRODUCER_DSOUND_H
#define TINYDAV_PRODUCER_DSOUND_H

#include "tinydav_config.h"

#if HAVE_DSOUND_H

#include "tinydav/audio/tdav_producer_audio.h"

#include <dsound.h>

TDAV_BEGIN_DECLS

#define TDAV_DSOUNS_PRODUCER_NOTIF_POS_COUNT		4

typedef struct tdav_producer_dsound_s
{
	TDAV_DECLARE_PRODUCER_AUDIO;

	tsk_bool_t started;
	tsk_bool_t mute;
	tsk_size_t bytes_per_notif;
	void* tid[1];

	LPDIRECTSOUNDCAPTURE device;
	LPDIRECTSOUNDCAPTUREBUFFER captureBuffer;
	HANDLE notifEvents[TDAV_DSOUNS_PRODUCER_NOTIF_POS_COUNT];
}
tdav_producer_dsound_t;

TINYDAV_GEXTERN const tmedia_producer_plugin_def_t *tdav_producer_dsound_plugin_def_t;


TDAV_END_DECLS

#endif /* HAVE_DSOUND_H */

#endif /* TINYDAV_PRODUCER_DSOUND_H */
