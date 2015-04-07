
/* 2012-03-07 */

#ifndef TINYDAV_SESSION_VIDEO_H
#define TINYDAV_SESSION_VIDEO_H

#include "tinydav_config.h"

#include "tinydav/video/tdav_converter_video.h"

#include "tinymedia/tmedia_session.h"

#include "tsk_safeobj.h"

TDAV_BEGIN_DECLS

// Forward declaration
struct trtp_manager_s;
struct tdav_consumer_video_s;
struct tdav_converter_video_s;

typedef struct tdav_session_video_s
{
	TMEDIA_DECLARE_SESSION_VIDEO;

	tsk_bool_t useIPv6;

	char* local_ip;

	char* remote_ip;
	uint16_t remote_port;
	
	/* NAT Traversal context */
	tnet_nat_context_handle_t* natt_ctx;

	tsk_bool_t rtcp_enabled;

	struct trtp_manager_s* rtp_manager;

	struct{
		void* buffer;
		tsk_size_t buffer_size;

		void* conv_buffer;
		tsk_size_t conv_buffer_size;
	} encoder;

	struct{
		void* buffer;
		tsk_size_t buffer_size;

		void* conv_buffer;
		tsk_size_t conv_buffer_size;
	} decoder;

	struct tmedia_consumer_s* consumer;
	struct tmedia_producer_s* producer;
	struct {
		tsk_size_t consumerLastWidth;
		tsk_size_t consumerLastHeight;
		struct tdav_converter_video_s* fromYUV420;
		
		tsk_size_t producerWidth;
		tsk_size_t producerHeight;
		tsk_size_t xProducerSize;
		struct tdav_converter_video_s* toYUV420;
	} conv;

	TSK_DECLARE_SAFEOBJ;
}
tdav_session_video_t;

#define TDAV_SESSION_VIDEO(self) ((tdav_session_video_t*)(self))

TINYDAV_GEXTERN const tmedia_session_plugin_def_t *tdav_session_video_plugin_def_t;

TDAV_END_DECLS

#endif /* TINYDAV_SESSION_VIDEO_H */
