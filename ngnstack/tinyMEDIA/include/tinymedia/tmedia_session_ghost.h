
/* 2012-03-07 */

#ifndef TINYMEDIA_SESSION_GHOST_H
#define TINYMEDIA_SESSION_GHOST_H

#include "tinymedia_config.h"

#include "tmedia_session.h"

#include "tsk_object.h"

TMEDIA_BEGIN_DECLS

/** Ghost session */
typedef struct tmedia_session_ghost_s
{
	TMEDIA_DECLARE_SESSION;
	char* media;
}
tmedia_session_ghost_t;

TINYMEDIA_GEXTERN const tmedia_session_plugin_def_t *tmedia_session_ghost_plugin_def_t;

TMEDIA_END_DECLS

#endif /* TINYMEDIA_SESSION_GHOST_H */
