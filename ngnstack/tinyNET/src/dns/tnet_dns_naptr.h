
/* 2012-03-07 */

#ifndef TNET_DNS_RR_NAPTR_H
#define TNET_DNS_RR_NAPTR_H

#include "tinynet_config.h"

#include "tnet_dns_rr.h"

TNET_BEGIN_DECLS

/** DNS NAPTR Resource Record
*/
typedef struct tnet_dns_naptr_s
{
	TNET_DECLARE_DNS_RR;

	/*	RFC 3403 - 4.1 Packet Format

		The packet format for the NAPTR record is as follows
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                     ORDER                     |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                   PREFERENCE                  |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                     FLAGS                     /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                   SERVICES                    /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                    REGEXP                     /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                  REPLACEMENT                  /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
		<character-string> and <domain-name> as used here are defined in RFC 1035.
	*/
	uint16_t order;
	uint16_t preference;
	char* flags;
	char* services;
	char* regexp;
	char* replacement;
}
tnet_dns_naptr_t;

TINYNET_API tnet_dns_naptr_t* tnet_dns_naptr_create(const char* name, tnet_dns_qclass_t qclass, uint32_t ttl, uint16_t rdlength, const void* data, tsk_size_t offset);

TINYNET_GEXTERN const tsk_object_def_t *tnet_dns_naptr_def_t;

TNET_END_DECLS

#endif /* TNET_DNS_RR_NAPTR_H */

