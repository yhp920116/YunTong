
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_G711_H
#define TINYDAV_CODEC_G711_H

#include "tinydav_config.h"

#include "tinymedia/tmedia_codec.h"

TDAV_BEGIN_DECLS

/** G.711u codec */
typedef struct tdav_codec_g711u_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;
}
tdav_codec_g711u_t;

/** G.711a codec */
typedef struct tdav_codec_g711a_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;
}
tdav_codec_g711a_t;


TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_g711a_plugin_def_t;
TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_g711u_plugin_def_t;

TDAV_END_DECLS

#endif /* TINYDAV_CODEC_G711_H */
