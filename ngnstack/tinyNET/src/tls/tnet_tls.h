
/* 2012-03-07 */

#ifndef TNET_TLS_H
#define TNET_TLS_H

#include "tinynet_config.h"

#include "tnet_types.h"

#include "tsk_object.h"

TNET_BEGIN_DECLS

typedef void tnet_tls_socket_handle_t;

int tnet_tls_socket_isok(const tnet_tls_socket_handle_t* self);
int tnet_tls_socket_connect(tnet_tls_socket_handle_t* self);
int tnet_tls_socket_write(tnet_tls_socket_handle_t* self, const void* data, tsk_size_t size);
#define tnet_tls_socket_send(self, data, size) tnet_tls_socket_write(self, data, size)
int tnet_tls_socket_recv(tnet_tls_socket_handle_t* self, void** data, tsk_size_t *size, int *isEncrypted);

TINYNET_API tnet_tls_socket_handle_t* tnet_tls_socket_create(tnet_fd_t fd, const char* tlsfile_ca, const char* tlsfile_pvk, const char* tlsfile_pbk, tsk_bool_t isClient);
TINYNET_API tnet_tls_socket_handle_t* tnet_tls_socket_client_create(tnet_fd_t fd, const char* tlsfile_ca, const char* tlsfile_pvk, const char* tlsfile_pbk);
TINYNET_API tnet_tls_socket_handle_t* tnet_tls_socket_server_create(tnet_fd_t fd, const char* tlsfile_ca, const char* tlsfile_pvk, const char* tlsfile_pbk);

TINYNET_GEXTERN const tsk_object_def_t *tnet_tls_socket_def_t;

TNET_END_DECLS

#endif /* TNET_TLS_H */
