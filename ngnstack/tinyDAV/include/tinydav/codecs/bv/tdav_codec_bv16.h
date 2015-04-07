
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_BV16_H
#define TINYDAV_CODEC_BV16_H

#include "tinydav_config.h"

#if HAVE_BV16

#include "tinymedia/tmedia_codec.h"


TDAV_BEGIN_DECLS

/** BV16 codec */
typedef struct tdav_codec_bv16_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;

	struct {
		void *state;
		void *bs;
		void *x;
	} encoder;

	struct {
		void *state;
		void *bs;
		void *x;
	} decoder;
}
tdav_codec_bv16_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_bv16_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_BV16 */

#endif /* TINYDAV_CODEC_BV16_H */
