
/* 2012-03-07 */

#ifndef TNET_DNS_RR_A_H
#define TNET_DNS_RR_A_H

#include "tinynet_config.h"

#include "tnet_dns_rr.h"

TNET_BEGIN_DECLS


/**DNS A Resource Record.
*/
typedef struct tnet_dns_a_s
{
	TNET_DECLARE_DNS_RR;

	/* RFC 1035 - 3.4.1. A RDATA format
	+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                    ADDRESS                    |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	*/
	char* address;
}
tnet_dns_a_t;

TINYNET_API tnet_dns_a_t* tnet_dns_a_create(const char* name, tnet_dns_qclass_t qclass, uint32_t ttl, uint16_t rdlength, const void* data, tsk_size_t offset);

TINYNET_GEXTERN const tsk_object_def_t *tnet_dns_a_def_t;

TNET_END_DECLS

#endif /* TNET_DNS_RR_A_H */

