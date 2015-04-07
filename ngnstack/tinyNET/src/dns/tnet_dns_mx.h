
/* 2012-03-07 */

#ifndef TNET_DNS_RR_MX_H
#define TNET_DNS_RR_MX_H

#include "tinynet_config.h"

#include "tnet_dns_rr.h"


TNET_BEGIN_DECLS


/** DNS MX Resource Record
*/
typedef struct tnet_dns_mx_s
{
	TNET_DECLARE_DNS_RR;

	/* RFC 1035 - 3.3.9. MX RDATA format
	+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                  PREFERENCE                   |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /                   EXCHANGE                    /
    /                                               /
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	*/
	uint16_t preference;
	char* exchange;
}
tnet_dns_mx_t;

tnet_dns_mx_t* tnet_dns_mx_create(const char* name, tnet_dns_qclass_t qclass, uint32_t ttl, uint16_t rdlength, const void* data, tsk_size_t offset);

TINYNET_GEXTERN const tsk_object_def_t *tnet_dns_mx_def_t;

TNET_END_DECLS

#endif /* TNET_DNS_RR_MX_H */

