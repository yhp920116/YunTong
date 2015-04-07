
/* 2012-03-07 */

#ifndef TINYMEDIA_SESSION_DUMMY_H
#define TINYMEDIA_SESSION_DUMMY_H

#include "tinymedia_config.h"

#include "tmedia_session.h"

#include "tsk_object.h"

TMEDIA_BEGIN_DECLS

/** Dummy Audio session */
typedef struct tmedia_session_daudio_s
{
	TMEDIA_DECLARE_SESSION_AUDIO;
	uint16_t local_port;
	uint16_t remote_port;
}
tmedia_session_daudio_t;

/** Dummy Video session */
typedef struct tmedia_session_dvideo_s
{
	TMEDIA_DECLARE_SESSION_VIDEO;
	uint16_t local_port;
	uint16_t remote_port;
}
tmedia_session_dvideo_t;

/** Dummy Msrp session */
typedef struct tmedia_session_dmsrp_s
{
	TMEDIA_DECLARE_SESSION_MSRP;
	uint16_t local_port;
	uint16_t remote_port;
}
tmedia_session_dmsrp_t;


TINYMEDIA_GEXTERN const tmedia_session_plugin_def_t *tmedia_session_daudio_plugin_def_t;
TINYMEDIA_GEXTERN const tmedia_session_plugin_def_t *tmedia_session_dvideo_plugin_def_t;
TINYMEDIA_GEXTERN const tmedia_session_plugin_def_t *tmedia_session_dmsrp_plugin_def_t;

TMEDIA_END_DECLS

#endif /* TINYMEDIA_SESSION_DUMMY_H */

