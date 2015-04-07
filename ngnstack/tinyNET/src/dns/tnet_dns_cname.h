
/* 2012-03-07 */

#ifndef TNET_DNS_RR_CNAME_H
#define TNET_DNS_RR_CNAME_H

#include "tinynet_config.h"

#include "tnet_dns_rr.h"


TNET_BEGIN_DECLS


/** DNS CNAME Resource Record
*/
typedef struct tnet_dns_cname_s
{
	TNET_DECLARE_DNS_RR;

	/* 3.3.1. CNAME RDATA format
	+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /                     CNAME                     /
    /                                               /
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	*/
	char* cname;
}
tnet_dns_cname_t;

tnet_dns_cname_t* tnet_dns_cname_create(const char* name, tnet_dns_qclass_t qclass, uint32_t ttl, uint16_t rdlength, const void* data, tsk_size_t offset);

TINYNET_GEXTERN const tsk_object_def_t *tnet_dns_cname_def_t;

TNET_END_DECLS

#endif /* TNET_DNS_RR_CNAME_H */

