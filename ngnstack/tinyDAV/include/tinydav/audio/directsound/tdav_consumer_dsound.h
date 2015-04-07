
/* 2012-03-07 */

#ifndef TINYDAV_CONSUMER_DSOUND_H
#define TINYDAV_CONSUMER_DSOUND_H

#include "tinydav_config.h"

#if HAVE_DSOUND_H

#include "tinydav/audio/tdav_consumer_audio.h"

#include <dsound.h>

TDAV_BEGIN_DECLS

#define TDAV_DSOUNS_CONSUMER_NOTIF_POS_COUNT		4

typedef struct tdav_consumer_dsound_s
{
	TDAV_DECLARE_CONSUMER_AUDIO;

	tsk_bool_t started;
	tsk_size_t bytes_per_notif;
	void* tid[1];

	LPDIRECTSOUND device;
	LPDIRECTSOUNDBUFFER primaryBuffer;
	LPDIRECTSOUNDBUFFER secondaryBuffer;
	HANDLE notifEvents[TDAV_DSOUNS_CONSUMER_NOTIF_POS_COUNT];
}
tdav_consumer_dsound_t;

TINYDAV_GEXTERN const tmedia_consumer_plugin_def_t *tdav_consumer_dsound_plugin_def_t;


TDAV_END_DECLS

#endif /* HAVE_DSOUND_H */

#endif /* TINYDAV_CONSUMER_DSOUND_H */
