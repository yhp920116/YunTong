
/* 2012-03-07 */

#ifndef TNET_DNS_RR_SOA_H
#define TNET_DNS_RR_SOA_H

#include "tinynet_config.h"

#include "tnet_dns_rr.h"

TNET_BEGIN_DECLS

typedef struct tnet_dns_soa_s
{
	TNET_DECLARE_DNS_RR;

	/* RFC 1035 - 3.3.13. SOA RDATA format
	+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /                     MNAME                     /
    /                                               /
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /                     RNAME                     /
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                    SERIAL                     |
    |                                               |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                    REFRESH                    |
    |                                               |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                     RETRY                     |
    |                                               |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                    EXPIRE                     |
    |                                               |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                    MINIMUM                    |
    |                                               |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	*/
	char* mname;
	char* rname;
	uint32_t serial;
	uint32_t refresh;
	uint32_t retry;
	uint32_t expire;
	uint32_t minimum;
}
tnet_dns_soa_t;

tnet_dns_soa_t* tnet_dns_soa_create(const char* name, tnet_dns_qclass_t qclass, uint32_t ttl, uint16_t rdlength, const void* data, tsk_size_t offset);

TINYNET_GEXTERN const tsk_object_def_t *tnet_dns_soa_def_t;

TNET_END_DECLS

#endif /* TNET_DNS_RR_SOA_H */

