
/* 2012-03-07 */

#ifndef TINYMSRP_HEADER_H
#define TINYMSRP_HEADER_H

#include "tinymsrp_config.h"

#include "tsk_ragel_state.h"
#include "tsk_list.h"

TMSRP_BEGIN_DECLS

struct tmsrp_header_s;

#define TMSRP_HEADER(self)					((tmsrp_header_t*)(self))
#define TMSRP_HEADER_VALUE_TOSTRING_F(self)	((tmsrp_header_value_tostring_f)(self))

typedef int (*tmsrp_header_value_tostring_f)(const struct tmsrp_header_s* header, tsk_buffer_t* output);

/**
 * @enum	tmsrp_header_type_e
 *
 * @brief	List of all supported headers.
**/
typedef enum tmsrp_header_type_e
{
	tmsrp_htype_Authentication_Info,
	tmsrp_htype_Authorization,
	tmsrp_htype_Byte_Range,
	tmsrp_htype_Content_Type,
	tmsrp_htype_Dummy,
	tmsrp_htype_Expires,
	tmsrp_htype_Failure_Report,
	tmsrp_htype_From_Path,
	tmsrp_htype_Max_Expires,
	tmsrp_htype_Message_ID,
	tmsrp_htype_Min_Expires,
	tmsrp_htype_Status,
	tmsrp_htype_Success_Report,
	tmsrp_htype_To_Path,
	tmsrp_htype_Use_Path,
	tmsrp_htype_WWW_Authenticate
}
tmsrp_header_type_t;

/*================================
*/
typedef struct tmsrp_header_s
{
	TSK_DECLARE_OBJECT;
	tmsrp_header_type_t type;
	tmsrp_header_value_tostring_f tostring;
}
tmsrp_header_t;

#define TMSRP_DECLARE_HEADER tmsrp_header_t __header__
typedef tsk_list_t tmsrp_headers_L_t; /**< List of @ref tmsrp_header_t elements. */
/*
================================*/

TINYMSRP_API const char* tmsrp_header_get_name(tmsrp_header_type_t type);
TINYMSRP_API const char* tmsrp_header_get_nameex(const tmsrp_header_t *self);
TINYMSRP_API int tmsrp_header_serialize(const tmsrp_header_t *self, tsk_buffer_t *output);
TINYMSRP_API char* tmsrp_header_tostring(const tmsrp_header_t *self);

TMSRP_END_DECLS

#endif /* TINYMSRP_HEADER_H */
