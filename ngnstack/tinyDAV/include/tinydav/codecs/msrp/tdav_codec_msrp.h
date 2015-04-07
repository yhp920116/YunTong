
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_MSRP_H
#define TINYDAV_CODEC_MSRP_H

#include "tinydav_config.h"

#include "tinymedia/tmedia_codec.h"

TDAV_BEGIN_DECLS

/** MSRP codec */
typedef struct tdav_codec_msrp_s
{
	TMEDIA_DECLARE_CODEC_MSRP;
}
tdav_codec_msrp_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_msrp_plugin_def_t;

TDAV_END_DECLS

#endif /* TINYDAV_CODEC_MSRP_H */
