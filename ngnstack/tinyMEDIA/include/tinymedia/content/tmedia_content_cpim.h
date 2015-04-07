
/* 2012-03-07 */

#ifndef TINYMEDIA_CONTENT_CPIM_H
#define TINYMEDIA_CONTENT_CPIM_H

#include "tinymedia_config.h"

#include "tmedia_content.h"

TMEDIA_BEGIN_DECLS

#define TMEDIA_CONTENT_CPIM_TYPE "message/CPIM"

/** message/CPIM content */
typedef struct tmedia_content_cpim_s
{
	TMEDIA_DECLARE_CONTENT;

	tmedia_content_headers_L_t* m_headers; /**< MIME headers for the overall message */
	tmedia_content_headers_L_t* h_headers; /**< message headers */
	tsk_buffer_t* e; /**< encapsulated MIME object containing the message content */
	tsk_buffer_t* x; /**< MIME security multipart message wrapper */
}
tmedia_content_cpim_t;

#define TMEDIA_CONTENT_CPIM(self) ((tmedia_content_cpim_t*)(self))
#define TMEDIA_CONTENT_IS_CPIM(self) ( (self) && (TMEDIA_CONTENT((self))->plugin==tmedia_content_cpim_plugin_def_t) )

TINYMEDIA_GEXTERN const tmedia_content_plugin_def_t *tmedia_content_cpim_plugin_def_t;

TMEDIA_END_DECLS

#endif /* TINYMEDIA_CONTENT_CPIM_H */
