
/* 2012-03-07 */

#ifndef TINYDAV_PRODUCER_WAVEAPI_H
#define TINYDAV_PRODUCER_WAVEAPI_H

#include "tinydav_config.h"

#if HAVE_WAVE_API

#include "tinydav/audio/tdav_producer_audio.h"

#include <windows.h>

TDAV_BEGIN_DECLS

#define TDAV_WAVEAPI_PRODUCER_NOTIF_POS_COUNT		4

typedef struct tdav_producer_waveapi_s
{
	TDAV_DECLARE_PRODUCER_AUDIO;
	
	tsk_bool_t started;
	
	WAVEFORMATEX wfx;
	HWAVEIN hWaveIn;
	LPWAVEHDR hWaveHeaders[TDAV_WAVEAPI_PRODUCER_NOTIF_POS_COUNT];
	tsk_size_t bytes_per_notif;
	
	void* tid[1];
	HANDLE events[2];
	CRITICAL_SECTION cs;
}
tdav_producer_waveapi_t;

TINYDAV_GEXTERN const tmedia_producer_plugin_def_t *tdav_producer_waveapi_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_WAVE_API */

#endif /* TINYDAV_PRODUCER_WAVEAPI_H */
