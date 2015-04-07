
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_GSM_H
#define TINYDAV_CODEC_GSM_H

#include "tinydav_config.h"

#if HAVE_LIBGSM

#include "tinymedia/tmedia_codec.h"

#include <gsm.h>

TDAV_BEGIN_DECLS

/** GSM codec */
typedef struct tdav_codec_gsm_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;

	gsm encoder;
	gsm decoder;
}
tdav_codec_gsm_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_gsm_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_LIBGSM */

#endif /* TINYDAV_CODEC_GSM_H */
