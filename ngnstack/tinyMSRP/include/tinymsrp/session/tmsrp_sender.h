
/* 2012-03-07 */

#ifndef TINYMSRP_SENDER_H
#define TINYMSRP_SENDER_H

#include "tinymsrp_config.h"

#include "tinymsrp/session/tmsrp_data.h"
#include "tinymsrp/session/tmsrp_config.h"

#include "tnet_types.h"

#include "tsk_runnable.h"

TMSRP_BEGIN_DECLS

typedef struct tmsrp_sender_s
{
	TSK_DECLARE_RUNNABLE;

	tmsrp_datas_L_t* outgoingList;
	tmsrp_config_t* config;
	tnet_fd_t fd;
	uint64_t chunck_duration;
}
tmsrp_sender_t;

TINYMSRP_API tmsrp_sender_t* tmsrp_sender_create(tmsrp_config_t* config, tnet_fd_t fd);

TINYMSRP_API int tmsrp_sender_set_fd(tmsrp_sender_t* self, tnet_fd_t fd);
TINYMSRP_API int tmsrp_sender_start(tmsrp_sender_t* self);
TINYMSRP_API int tsmrp_sender_send_data(tmsrp_sender_t* self, const void* data, tsk_size_t size, const char* ctype, const char* wctype);
TINYMSRP_API int tsmrp_sender_send_file(tmsrp_sender_t* self, const char* filepath);
TINYMSRP_API int tmsrp_sender_stop(tmsrp_sender_t* self);

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_sender_def_t;

TMSRP_END_DECLS

#endif /* TINYMSRP_SENDER_H */
