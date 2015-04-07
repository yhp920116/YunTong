
/* 2012-03-07 */

#ifndef TINYHTTP_HEADER_H
#define TINYHTTP_HEADER_H

#include "tinyhttp_config.h"

#include "tsk_ragel_state.h"

#include "tsk_params.h"
#include "tsk_object.h"
#include "tsk_safeobj.h"
#include "tsk_memory.h"
#include "tsk_string.h"
#include "tsk_list.h"
#include "tsk_buffer.h"

THTTP_BEGIN_DECLS

#define THTTP_HEADER(self)			((thttp_header_t*)(self))
#define THTTP_HEADER_PARAMS(self)	(THTTP_HEADER(self)->params)

// FD
struct thttp_header_s;

typedef int (*thttp_header_value_tostring_f)(const struct thttp_header_s* header, tsk_buffer_t* output);
#define THTTP_HEADER_VALUE_TOSTRING_F(self) ((thttp_header_value_tostring_f)(self))

/**
 * @enum	thttp_header_type_e
 *
 * @brief	List of all supported headers.
**/
typedef enum thttp_header_type_e
{
	thttp_htype_Authorization,
	thttp_htype_Content_Length,
	thttp_htype_Content_Type,
	thttp_htype_Dummy,
	thttp_htype_ETag,
	thttp_htype_Proxy_Authenticate,
	thttp_htype_Proxy_Authorization,
	thttp_htype_Transfer_Encoding,
	thttp_htype_WWW_Authenticate,
}
thttp_header_type_t;

/*================================
*/
typedef struct thttp_header_s
{
	TSK_DECLARE_OBJECT;
	thttp_header_type_t type;
	thttp_header_value_tostring_f tostring;
	tsk_params_L_t *params;
}
thttp_header_t;

#define THTTP_DECLARE_HEADER thttp_header_t header
typedef tsk_list_t thttp_headers_L_t; /**< List of @ref thttp_header_t elements. */
/*
================================*/

TINYHTTP_API const char *thttp_header_get_name(thttp_header_type_t type);
TINYHTTP_API const char *thttp_header_get_nameex(const thttp_header_t *self);
TINYHTTP_API char thttp_header_get_param_separator(const thttp_header_t *self);
TINYHTTP_API int thttp_header_serialize(const thttp_header_t *self, tsk_buffer_t *output);
TINYHTTP_API char* thttp_header_tostring(const thttp_header_t *self);
TINYHTTP_API char* thttp_header_value_tostring(const thttp_header_t *self);

THTTP_END_DECLS

#endif /* TINYHTTP_HEADERS_H */

