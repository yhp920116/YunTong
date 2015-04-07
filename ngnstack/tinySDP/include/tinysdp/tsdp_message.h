
/* 2012-03-07 */

#ifndef TINYSDP_MESSAGE_H
#define TINYSDP_MESSAGE_H

#include "tinysdp_config.h"

#include "tinysdp/headers/tsdp_header.h"

#include "tinysdp/headers/tsdp_header_M.h"

TSDP_BEGIN_DECLS

typedef struct tsdp_message_s
{
	TSK_DECLARE_OBJECT;

	//! List of @ref tsdp_header_t elements. 
	tsdp_headers_L_t* headers;
}
tsdp_message_t;

typedef tsdp_message_t tsdp_offer_t;
typedef tsdp_message_t tsdp_answer_t;
typedef tsdp_message_t tsdp_caps_t;

TINYSDP_API int tsdp_message_add_header(tsdp_message_t *self, const tsdp_header_t *hdr);
TINYSDP_API int tsdp_message_add_headers(tsdp_message_t *self, ...);

#if defined(__SYMBIAN32__) && 0
static void TSDP_MESSAGE_ADD_HEADER(tsdp_message_t *self, ...)
	{
		va_list ap;
		tsdp_header_t *header;
		const tsk_object_def_t *objdef;
		
		va_start(ap, self);
		objdef = va_arg(ap, const tsk_object_def_t*);
		header = (tsdp_header_t *)tsk_object_new_2(objdef, &ap);
		va_end(ap);

		tsdp_message_add_header(self, header);
		tsk_object_unref(header);
	}
#else
#define TSDP_MESSAGE_ADD_HEADER(self, objdef, ...)						\
	{																	\
		tsdp_header_t *header = (tsdp_header_t *)tsk_object_new(objdef, ##__VA_ARGS__);	\
		tsdp_message_add_header(self, header);							\
		tsk_object_unref(header);										\
	}
#endif

TINYSDP_API const tsdp_header_t *tsdp_message_get_headerAt(const tsdp_message_t *self, tsdp_header_type_t type, tsk_size_t index);
TINYSDP_API const tsdp_header_t *tsdp_message_get_header(const tsdp_message_t *self, tsdp_header_type_t type);
TINYSDP_API const tsdp_header_t *tsdp_message_get_headerByName(const tsdp_message_t *self, char name);

TINYSDP_API int tsdp_message_serialize(const tsdp_message_t *self, tsk_buffer_t *output);
TINYSDP_API char* tsdp_message_tostring(const tsdp_message_t *self);

TINYSDP_API tsdp_message_t* tsdp_message_create_empty(const char* addr, tsk_bool_t ipv6, uint32_t version);
TINYSDP_API tsdp_message_t* tsdp_message_clone(const tsdp_message_t *self);
TINYSDP_API int tsdp_message_add_media(tsdp_message_t *self, const char* media, uint32_t port, const char* proto, ...);
TINYSDP_API int tsdp_message_add_media_2(tsdp_message_t *self, const char* media, uint32_t port, const char* proto, va_list *ap);
TINYSDP_API int tsdp_message_remove_media(tsdp_message_t *self, const char* media);


// 3GPP TS 24.610 Communication HOLD
TINYSDP_API int tsdp_message_hold(tsdp_message_t* self, const char* media);
TINYSDP_API int tsdp_message_resume(tsdp_message_t* self, const char* media);

TINYSDP_API tsdp_message_t* tsdp_message_create();

TINYSDP_GEXTERN const tsk_object_def_t *tsdp_message_def_t;

TSDP_END_DECLS

#endif /* TINYSDP_MESSAGE_H */
