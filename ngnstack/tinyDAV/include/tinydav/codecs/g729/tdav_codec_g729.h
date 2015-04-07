
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_G729_H
#define TINYDAV_CODEC_G729_H

#include "tinydav_config.h"

#if HAVE_G729

#include "tinymedia/tmedia_codec.h"

#include "g729b/typedef.h"
#include "g729b/ld8a.h"


TDAV_BEGIN_DECLS

/** G.729abb codec */
typedef struct tdav_codec_g729ab_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;

	struct{
		Word16 prm[PRM_SIZE+1];        /* Analysis parameters + frame type      */
		Word16 serial[SERIAL_SIZE];    /* Output bitstream buffer               */

		Word16 frame;                  /* frame counter */

		/* For G.729B */
		Word16 vad_enable;
	} encoder;

	struct{
		Word16  serial[SERIAL_SIZE];          /* Serial stream               */
		Word16  synth_buf[L_FRAME+M], *synth; /* Synthesis                   */
		Word16  parm[PRM_SIZE+2];             /* Synthesis parameters        */
		Word16  Az_dec[MP1*2];                /* Decoded Az for post-filter  */
		Word16  T2[2];                        /* Pitch lag for 2 subframes   */

		/* For G.729B */
		Word16  Vad;
	} decoder;
}
tdav_codec_g729ab_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_g729ab_plugin_def_t;

TDAV_END_DECLS

#endif /* TINYDAV_CODEC_G729_H */

#endif
