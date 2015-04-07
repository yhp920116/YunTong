
/* 2012-03-07 */

#ifndef TNET_DNS_RR_TXT_H
#define TNET_DNS_RR_TXT_H

#include "tinynet_config.h"

#include "tnet_dns_rr.h"


TNET_BEGIN_DECLS

/** DNS TXT Resource Record
*/
typedef struct tnet_dns_txt_s
{
	TNET_DECLARE_DNS_RR;

	/* RFC 1035 - 3.3.14. TXT RDATA format
	+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    /                   TXT-DATA                    /
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	*/
	char* txt_data;
}
tnet_dns_txt_t;

tnet_dns_txt_t* tnet_dns_txt_create(const char* name, tnet_dns_qclass_t qclass, uint32_t ttl, uint16_t rdlength, const void* data, tsk_size_t offset);

TINYNET_GEXTERN const tsk_object_def_t *tnet_dns_txt_def_t;

TNET_END_DECLS

#endif /* TNET_DNS_RR_TXT_H */

