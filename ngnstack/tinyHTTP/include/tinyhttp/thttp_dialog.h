
/* 2012-03-07 */

#ifndef THTTP_DIALOG_H
#define THTTP_DIALOG_H

#include "tinyhttp_config.h"

#include "tsk_fsm.h"
#include "tsk_list.h"
#include "tsk_buffer.h"

THTTP_BEGIN_DECLS

struct thttp_message_s;

typedef uint64_t thttp_dialog_id_t;

typedef struct thttp_dialog_s
{
	TSK_DECLARE_OBJECT;
	
	thttp_dialog_id_t id;
	uint64_t timestamp;
	
	tsk_fsm_t* fsm;
	
	tsk_buffer_t* buf;
	
	struct thttp_session_s* session;
	struct thttp_action_s* action;
	tsk_bool_t answered;
}
thttp_dialog_t;

typedef tsk_list_t thttp_dialogs_L_t;

TINYHTTP_API int thttp_dialog_fsm_act(thttp_dialog_t* self, tsk_fsm_action_id , const struct thttp_message_s* , const struct thttp_action_s*);
TINYHTTP_API thttp_dialog_t* thttp_dialog_new(struct thttp_session_s* session);
thttp_dialog_t* thttp_dialog_get_oldest(thttp_dialogs_L_t* dialogs);

TINYHTTP_GEXTERN const tsk_object_def_t *thttp_dialog_def_t;

THTTP_END_DECLS

#endif /* THTTP_DIALOG_H */

