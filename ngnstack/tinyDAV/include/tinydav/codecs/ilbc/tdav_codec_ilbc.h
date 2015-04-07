
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_ILBC_H
#define TINYDAV_CODEC_ILBC_H

#include "tinydav_config.h"

#if HAVE_ILBC

#include "tinymedia/tmedia_codec.h"

#include <ilbc/iLBC_define.h>
#include <ilbc/iLBC_encode.h>
#include <ilbc/iLBC_decode.h>

TDAV_BEGIN_DECLS

/** iLBC codec */
typedef struct tdav_codec_ilbc_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;

	iLBC_Enc_Inst_t encoder;
	iLBC_Dec_Inst_t decoder;

	float encblock[BLOCKL_MAX];
	float decblock[BLOCKL_MAX];
}
tdav_codec_ilbc_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_ilbc_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_ILBC */

#endif /* TINYDAV_CODEC_ILBC_H */
