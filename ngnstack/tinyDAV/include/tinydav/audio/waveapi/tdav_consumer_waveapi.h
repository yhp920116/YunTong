
/* 2012-03-07 */

#ifndef TINYDAV_CONSUMER_WAVEAPI_H
#define TINYDAV_CONSUMER_WAVEAPI_H

#include "tinydav_config.h"

#if HAVE_WAVE_API

#include "tinydav/audio/tdav_consumer_audio.h"

#include <windows.h>

TDAV_BEGIN_DECLS

#define TDAV_WAVEAPI_CONSUMER_NOTIF_POS_COUNT		4

typedef struct tdav_consumer_waveapi_s
{
	TDAV_DECLARE_CONSUMER_AUDIO;

	tsk_bool_t started;

	WAVEFORMATEX wfx;
	HWAVEOUT hWaveOut;
	LPWAVEHDR hWaveHeaders[TDAV_WAVEAPI_CONSUMER_NOTIF_POS_COUNT];
	tsk_size_t bytes_per_notif;

	void* tid[1];
	HANDLE events[2];
	CRITICAL_SECTION cs;
}
tdav_consumer_waveapi_t;

TINYDAV_GEXTERN const tmedia_consumer_plugin_def_t *tdav_consumer_waveapi_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_WAVE_API */

#endif /* TINYDAV_CONSUMER_WAVEAPI_H */
