
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYDAV_CODEC_AMR_H
#define TINYDAV_CODEC_AMR_H

#include "tinydav_config.h"

#if HAVE_OPENCORE_AMR

#include "tinymedia/tmedia_codec.h"

#include <opencore-amrnb/interf_dec.h>
#include <opencore-amrnb/interf_enc.h>

TDAV_BEGIN_DECLS

#define TDAV_CODEC_AMR(self)	((tdav_codec_amr_t*)(self))

typedef enum tdav_codec_amr_type_e
{
	tdav_codec_amr_type_nb,
	tdav_codec_amr_type_wb,
}
tdav_codec_amr_type_t;

typedef enum tdav_codec_amr_mode_e
{
	tdav_codec_amr_mode_oa,
	tdav_codec_amr_mode_be,
}
tdav_codec_amr_mode_t;

/** Base class for all AMR codecs */
typedef struct tdav_codec_amr_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;

	tdav_codec_amr_type_t type;
	tdav_codec_amr_mode_t mode;

	enum Mode encoder_mode;
	void* encoder;
	void* decoder;

	unsigned modes:16; /**< 0..7 for NB and 0..8 for WB plus SID, SPEECH_LOST, NO_DATA etc etc */
	unsigned mcp:2; /**< mode-change-periode (1 or 2) */
	unsigned mcc:2; /**< mode-change-capability (1 or 2) */
	unsigned mcn:1; /**< mode-change-neighnor (0 or 1) */
	unsigned crc:1; /**< 0 or 1 */
	unsigned robust_sorting:1; /**< robust-sorting (0 or 1) */
}
tdav_codec_amr_t;

#define TDAV_DECLARE_CODEC_AMR tdav_codec_amr_t __codec_amr__


TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_amrnb_oa_plugin_def_t;
TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_amrnb_be_plugin_def_t;

TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_amrwb_oa_plugin_def_t;
TINYDAV_GEXTERN const tmedia_codec_plugin_def_t *tdav_codec_amrwb_be_plugin_def_t;

TDAV_END_DECLS

#endif /* HAVE_OPENCORE_AMR */

#endif /* TINYDAV_CODEC_AMR_H */
