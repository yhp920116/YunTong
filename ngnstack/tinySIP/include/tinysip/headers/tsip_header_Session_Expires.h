
/* 2012-03-07 */

#ifndef _TSIP_HEADER_SESSION_EXPIRES_H_
#define _TSIP_HEADER_SESSION_EXPIRES_H_

#include "tinysip_config.h"
#include "tinysip/headers/tsip_header.h"

TSIP_BEGIN_DECLS

#define TSIP_HEADER_SESSION_EXPIRES_VA_ARGS(delta_seconds, refresher_uas)		tsip_header_Session_Expires_def_t, (int64_t)delta_seconds, (tsk_bool_t)refresher_uas

#define TSIP_SESSION_EXPIRES_DEFAULT_VALUE					1800

////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// @brief	SIP header 'Session-Expires'.
///
/// @par ABNF: Session-Expires	=  	 ( "Session-Expires" / "x" ) HCOLON delta-seconds *( SEMI (se-params )
/// se-params	= 	refresher-param / generic-param
/// refresher-param	= 	"refresher" EQUAL ("uas" / "uac") 
/// 	
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tsip_header_Session_Expires_s
{	
	TSIP_DECLARE_HEADER;

	int64_t delta_seconds;
	tsk_bool_t refresher_uas;
}
tsip_header_Session_Expires_t;

TINYSIP_API tsip_header_Session_Expires_t* tsip_header_Session_Expires_create(int64_t delta_seconds, tsk_bool_t refresher_uas);

TINYSIP_API tsip_header_Session_Expires_t *tsip_header_Session_Expires_parse(const char *data, tsk_size_t size);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_header_Session_Expires_def_t;

TSIP_END_DECLS

#endif /* _TSIP_HEADER_SESSION_EXPIRES_H_ */

