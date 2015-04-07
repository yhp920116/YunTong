
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_G722_H
#define TINYDAV_CODEC_G722_H

#include "tinydav_config.h"

#include "tinydav/codecs/g722/g722_enc_dec.h"

#include "tinymedia/tmedia_codec.h"

TDAV_BEGIN_DECLS

typedef struct tdav_codec_g722_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;

	g722_encode_state_t *enc_state;
	g722_decode_state_t *dec_state;
}
tdav_codec_g722_t;
TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_g722_plugin_def_t;

TDAV_END_DECLS

#endif /* TINYDAV_CODEC_G722_H */
