
/* 2012-03-07 */

#ifndef TNET_DNS_RR_PTR_H
#define TNET_DNS_RR_PTR_H

#include "tinynet_config.h"

#include "tnet_dns_rr.h"

TNET_BEGIN_DECLS


/** DNS PTR Resource Record
*/
typedef struct tnet_dns_ptr_s
{
	TNET_DECLARE_DNS_RR;

	/* RFC 1035 - 3.3.12. PTR RDATA format
	+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /                   PTRDNAME                    /
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	*/
	char* ptrdname;
}
tnet_dns_ptr_t;

tnet_dns_ptr_t* tnet_dns_ptr_create(const char* name, tnet_dns_qclass_t qclass, uint32_t ttl, uint16_t rdlength, const void*data, tsk_size_t offset);

TINYNET_GEXTERN const tsk_object_def_t *tnet_dns_ptr_def_t;

TNET_END_DECLS

#endif /* TNET_DNS_RR_PTR_H */

