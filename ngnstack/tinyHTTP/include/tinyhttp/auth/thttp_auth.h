
/* 2012-03-07 */

#ifndef TINYHTTP_THTTP_AUTH_H
#define TINYHTTP_THTTP_AUTH_H

#include "tinyhttp_config.h"

#include "tsk_md5.h"
#include "tsk_buffer.h"

THTTP_BEGIN_DECLS

typedef char nonce_count_t[9];
#define THTTP_NCOUNT_2_STRING(nc_int32, nc_string)							\
	{																		\
		tsk_size_t i = 7;														\
		do{																	\
			nc_string[7-i]= "0123456789abcdef"[(nc_int32 >> i*4) & 0xF];	\
		}																	\
		while(i--);															\
		nc_string[8] = '\0';												\
	}

TINYHTTP_API tsk_size_t thttp_auth_basic_response(const char* userid, const char* password, char** response);

TINYHTTP_API int thttp_auth_digest_HA1(const char* username, const char* realm, const char* password, tsk_md5string_t* ha1);
TINYHTTP_API int thttp_auth_digest_HA1sess(const char* username, const char* realm, const char* password, const char* nonce, const char* cnonce, tsk_md5string_t* ha1sess);

TINYHTTP_API int thttp_auth_digest_HA2(const char* method, const char* url, const tsk_buffer_t* entity_body, const char* qop, tsk_md5string_t* ha2);

TINYHTTP_API int thttp_auth_digest_response(const tsk_md5string_t *ha1, const char* nonce, const nonce_count_t noncecount, const char* cnonce, 
											const char* qop, const tsk_md5string_t* ha2, tsk_md5string_t* response);

THTTP_END_DECLS

#endif /* TINYHTTP_THTTP_H */
