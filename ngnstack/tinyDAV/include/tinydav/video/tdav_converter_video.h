
/* 2012-03-07 */

#ifndef TINYDAV_CONVERTER_VIDEO_H
#define TINYDAV_CONVERTER_VIDEO_H

#include "tinydav_config.h"


#include "tinymedia/tmedia_common.h"

#if HAVE_FFMPEG || HAVE_SWSSCALE
#include <libswscale/swscale.h>
#include <libavcodec/avcodec.h>
#endif

#include "tsk_object.h"

TDAV_BEGIN_DECLS

typedef struct tdav_converter_video_s
{
	TSK_DECLARE_OBJECT;
	
#if HAVE_FFMPEG || HAVE_SWSSCALE
	struct SwsContext *context;

	enum PixelFormat srcFormat;
	enum PixelFormat dstFormat;

	AVFrame* srcFrame;
	AVFrame* dstFrame;

	struct {
		struct SwsContext *context;
		AVFrame* frame;
		uint8_t* buffer;
	} rot;

#endif

	tsk_size_t srcWidth;
	tsk_size_t srcHeight;

	tsk_size_t dstWidth;
	tsk_size_t dstHeight;

	// one shot parameters
	int rotation;
	tsk_bool_t flip;
}
tdav_converter_video_t;

tdav_converter_video_t* tdav_converter_video_create(tsk_size_t srcWidth, tsk_size_t srcHeight, tmedia_chroma_t srcChroma, tsk_size_t dstWidth, tsk_size_t dstHeight, tmedia_chroma_t dstChroma);
tsk_size_t tdav_converter_video_convert(tdav_converter_video_t* self, const void* buffer, void** output, tsk_size_t* output_max_size);

#define tdav_converter_video_init(self, _rotation, _flip/*...To be completed with other parameters*/) \
	if((self)){ \
		(self)->rotation  = (_rotation); \
		(self)->flip  = (_flip); \
	}

#define tdav_converter_video_flip(frame, height) \
    frame->data[0] += frame->linesize[0] * (height -1); \
    frame->data[1] += frame->linesize[1] * ((height -1)/2); \
    frame->data[2] += frame->linesize[2] * ((height -1)/2); \
    \
    frame->linesize[0] *= -1; \
    frame->linesize[1] *= -1; \
    frame->linesize[2] *= -1;

TINYDAV_GEXTERN const tsk_object_def_t *tdav_converter_video_def_t;

TDAV_END_DECLS


#endif /* TINYDAV_CONVERTER_VIDEO_H */
