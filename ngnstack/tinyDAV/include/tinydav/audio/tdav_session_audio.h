
/* 2012-03-07 */

#ifndef TINYDAV_SESSION_AUDIO_H
#define TINYDAV_SESSION_AUDIO_H

#include "tinydav_config.h"

#include "tinymedia/tmedia_session.h"

#include "tsk_safeobj.h"

TDAV_BEGIN_DECLS

// Forward declaration
struct trtp_manager_s;
struct tdav_consumer_audio_s;

typedef tsk_list_t tdav_session_audio_dtmfe_L_t;

typedef struct tdav_session_audio_s
{
	TMEDIA_DECLARE_SESSION_AUDIO;

	tsk_bool_t useIPv6;

	struct {
		unsigned created;
		unsigned started:1;
	} timer;

	struct {
		tmedia_codec_t* codec;
		void* buffer;
		tsk_size_t buffer_size;
	} encoder;

	struct {
		void* buffer;
		tsk_size_t buffer_size;
		struct {
			void* buffer;
			tsk_size_t buffer_size;
			struct tmedia_resampler_s* instance;
		} resampler;
	} decoder;

	char* local_ip;
	//uint16_t local_port;

	/* NAT Traversal context */
	tnet_nat_context_handle_t* natt_ctx;

	char* remote_ip;
	uint16_t remote_port;
	
	tsk_bool_t rtcp_enabled;

	struct trtp_manager_s* rtp_manager;
	
	struct tmedia_consumer_s* consumer;
	struct tmedia_producer_s* producer;
	struct tmedia_denoise_s* denoise;

	tdav_session_audio_dtmfe_L_t* dtmf_events;

	TSK_DECLARE_SAFEOBJ;
}
tdav_session_audio_t;

#define TDAV_SESSION_AUDIO(self) ((tdav_session_audio_t*)(self))

TINYDAV_GEXTERN const tmedia_session_plugin_def_t *tdav_session_audio_plugin_def_t;

TDAV_END_DECLS

#endif /* TINYDAV_SESSION_AUDIO_H */
