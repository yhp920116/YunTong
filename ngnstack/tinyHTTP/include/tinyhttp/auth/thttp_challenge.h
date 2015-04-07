
/* 2012-03-07 */

#ifndef TINYHTTP_AUTHENTICATION_CHALLENGE_H
#define TINYHTTP_AUTHENTICATION_CHALLENGE_H

#include "tinyhttp_config.h"

#include "tinyhttp/thttp_message.h"
#include "tinyhttp/headers/thttp_header.h"

#include "tinyhttp/auth/thttp_auth.h"

#include "tsk_object.h"
#include "tsk_list.h"
#include "tsk_md5.h"

THTTP_BEGIN_DECLS

typedef struct thttp_challenge_s
{
	TSK_DECLARE_OBJECT;

	tsk_bool_t isproxy;

	char* scheme;
	char* realm;
	char* nonce;
	char* opaque;
	char* algorithm;
	const char* qop;

	tsk_md5string_t cnonce;
	unsigned nc;
}
thttp_challenge_t;

typedef tsk_list_t thttp_challenges_L_t;

int thttp_challenge_update(thttp_challenge_t *self, const char* scheme, const char* realm, const char* nonce, const char* opaque, const char* algorithm, const char* qop);
thttp_header_t *thttp_challenge_create_header_authorization(thttp_challenge_t *self, const char* username, const char* password, const thttp_request_t *request);

thttp_challenge_t* thttp_challenge_create(tsk_bool_t isproxy,const char* scheme, const char* realm, const char* nonce, const char* opaque, const char* algorithm, const char* qop);

TINYHTTP_GEXTERN const tsk_object_def_t *thttp_challenge_def_t;

THTTP_END_DECLS

#endif /* TINYHTTP_AUTHENTICATION_CHALLENGE_H */

