
/* 2012-03-07 */

#ifndef TINYSIP_DIALOG_INVITE_H
#define TINYSIP_DIALOG_INVITE_H

#include "tinysip_config.h"
#include "tinysip/dialogs/tsip_dialog.h"

#include "tinymedia/tmedia_session.h"


TSIP_BEGIN_DECLS

#define TSIP_DIALOG_INVITE(self)							((tsip_dialog_invite_t*)(self))

typedef struct tsip_dialog_invite
{
	TSIP_DECLARE_DIALOG;
	
	tsk_bool_t support_update; /**< Indicates whether the remote party support UPDATE */
	tsk_bool_t is_client;
	tsk_bool_t is_transf;
	tsk_bool_t refersub;
	uint32_t rseq;
	
	tsip_timer_t timershutdown;
	tsip_timer_t timer100rel;

	tsip_response_t* last_o1xxrel;
	tsip_request_t* last_iInvite;
	tsip_request_t* last_oInvite;
	tsip_request_t* last_iRefer;
	tmedia_session_mgr_t* msession_mgr; /**< Media session Manager. */
	struct tsip_ssession_s* ss_transf;
	
	/* Session Timers */
	struct{
		tsip_timer_t timer;
		char* refresher;
		uint64_t minse;
	} stimers;
	/* QoS (Preconditions) */
	struct{
		tsip_timer_t timer;
		enum tmedia_qos_stype_e type;
		enum tmedia_qos_strength_e strength;
	} qos;
	/* Hold/Resume */
	struct{
		unsigned remote:1;
		unsigned local:1;
	} hold;

	struct{
		unsigned _100rel:1;
		unsigned precondition:1;
		unsigned timer:1;
		unsigned norefersub:1;
	} supported;

	struct{
		unsigned _100rel:1;
		unsigned precondition:1;
		unsigned timer:1;
		unsigned norefersub;
	} require;
}
tsip_dialog_invite_t;

tsip_dialog_invite_t* tsip_dialog_invite_create(const tsip_ssession_handle_t* ss, const char* call_id);

int tsip_dialog_invite_start(tsip_dialog_invite_t *self);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_dialog_invite_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_DIALOG_INVITE_H */
