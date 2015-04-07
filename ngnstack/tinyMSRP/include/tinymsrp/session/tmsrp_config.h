
/* 2012-03-07 */

#ifndef TINYMSRP_CONFIG_H
#define TINYMSRP_CONFIG_H

#include "tinymsrp_config.h"

#include "tinymsrp/headers/tmsrp_header_From-Path.h"
#include "tinymsrp/headers/tmsrp_header_To-Path.h"

#include "tsk_object.h"

TMSRP_BEGIN_DECLS

#ifndef TMSRP_MAX_CHUNK_SIZE
#	define TMSRP_MAX_CHUNK_SIZE				2048
#endif

typedef struct tmsrp_config_s
{
	TSK_DECLARE_OBJECT;

	tmsrp_header_To_Path_t* To_Path;
	tmsrp_header_From_Path_t* From_Path;

	tsk_bool_t Failure_Report;
	tsk_bool_t Success_Report;
	tsk_bool_t OMA_Final_Report;
}
tmsrp_config_t;

TINYMSRP_API tmsrp_config_t* tmsrp_config_create();

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_config_def_t;

TMSRP_END_DECLS

#endif /* TINYMSRP_CONFIG_H */
