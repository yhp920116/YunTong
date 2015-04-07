
/* 2012-03-07 */

#ifndef TINYDAV_RUNNABLE_VIDEO_H
#define TINYDAV_RUNNABLE_VIDEO_H

#include "tinydav_config.h"

#include "tsk_runnable.h"

TDAV_BEGIN_DECLS

typedef struct tdav_runnable_video_s
{
	TSK_DECLARE_RUNNABLE;

	const void* userdata;
}
tdav_runnable_video_t;

tdav_runnable_video_t* tdav_runnable_video_create(tsk_runnable_func_run run_f, const void* userdata);
int tdav_runnable_video_start(tdav_runnable_video_t* self);
int tdav_runnable_video_stop(tdav_runnable_video_t* self);

TINYDAV_GEXTERN const tsk_object_def_t *tdav_runnable_video_def_t;

TDAV_END_DECLS

#endif /* TINYDAV_RUNNABLE_VIDEO_H */
