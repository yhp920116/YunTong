
/* 2012-03-07 */

#ifndef TINYMEDIA_CODEC_DUMMY_H
#define TINYMEDIA_CODEC_DUMMY_H

#include "tinymedia_config.h"

#include "tmedia_codec.h"

#include "tsk_object.h"

TMEDIA_BEGIN_DECLS

/** Dummy PCMU codec */
typedef struct tmedia_codec_dpcmu_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;
}
tmedia_codec_dpcmu_t;

/** Dummy PCMA codec */
typedef struct tmedia_codec_dpcma_s
{
	TMEDIA_DECLARE_CODEC_AUDIO;
}
tmedia_codec_dpcma_t;

/** Dummy H.263 codec */
typedef struct tmedia_codec_dh263_s
{
	TMEDIA_DECLARE_CODEC_VIDEO;
}
tmedia_codec_dh263_t;

/** Dummy H.264 codec */
typedef struct tmedia_codec_dh264_s
{
	TMEDIA_DECLARE_CODEC_VIDEO;
}
tmedia_codec_dh264_t;


TINYMEDIA_GEXTERN const tmedia_codec_plugin_def_t *tmedia_codec_dpcma_plugin_def_t;
TINYMEDIA_GEXTERN const tmedia_codec_plugin_def_t *tmedia_codec_dpcmu_plugin_def_t;

TINYMEDIA_GEXTERN const tmedia_codec_plugin_def_t *tmedia_codec_dh263_plugin_def_t;
TINYMEDIA_GEXTERN const tmedia_codec_plugin_def_t *tmedia_codec_dh264_plugin_def_t;

TMEDIA_END_DECLS

#endif /* TINYMEDIA_CODEC_DUMMY_H */
