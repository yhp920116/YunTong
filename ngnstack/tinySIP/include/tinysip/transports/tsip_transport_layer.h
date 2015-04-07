
/* 2012-03-07 */

#ifndef TINYSIP_TRANSPORT_LAYER_H
#define TINYSIP_TRANSPORT_LAYER_H

#include "tinysip_config.h"

#include "tinysip/transports/tsip_transport.h"
#include "tinysip/tsip_message.h"
#include "tsip.h"

#include "tipsec.h"

TSIP_BEGIN_DECLS

typedef struct tsip_transport_layer_s
{
	TSK_DECLARE_OBJECT;

	const tsip_stack_t *stack;

	tsk_bool_t running;
	tsip_transports_L_t *transports;
}
tsip_transport_layer_t;

tsip_transport_layer_t* tsip_transport_layer_create(tsip_stack_t *stack);

int tsip_transport_layer_add(tsip_transport_layer_t* self, const char* local_host, tnet_port_t local_port, tnet_socket_type_t type, const char* description);
int tsip_transport_layer_remove(tsip_transport_layer_t* self, const char* description);

int tsip_transport_layer_send(const tsip_transport_layer_t* self, const char *branch, const tsip_message_t *msg);

int tsip_transport_createTempSAs(const tsip_transport_layer_t *self);
int tsip_transport_ensureTempSAs(const tsip_transport_layer_t *self, const tsip_response_t *r401_407, int64_t expires);
int tsip_transport_startSAs(const tsip_transport_layer_t* self, const void* ik, const void* ck);
int tsip_transport_cleanupSAs(const tsip_transport_layer_t *self);

int tsip_transport_layer_start(tsip_transport_layer_t* self);
int tsip_transport_layer_shutdown(tsip_transport_layer_t* self);

TINYSIP_GEXTERN const tsk_object_def_t *tsip_transport_layer_def_t;

TSIP_END_DECLS

#endif /* TINYSIP_TRANSPORT_LAYER_H */

