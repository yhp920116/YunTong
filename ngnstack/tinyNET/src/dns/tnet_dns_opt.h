
/* 2012-03-07 */

#ifndef TNET_DNS_RR_OPT_H
#define TNET_DNS_RR_OPT_H

#include "tinynet_config.h"

#include "tnet_dns_rr.h"


TNET_BEGIN_DECLS

/** DNS OPT Resource Record
*/
typedef struct tnet_dns_opt_s
{
	TNET_DECLARE_DNS_RR;
}
tnet_dns_opt_t;

tnet_dns_opt_t* tnet_dns_opt_create(tsk_size_t payload_size);

TINYNET_GEXTERN const tsk_object_def_t *tnet_dns_opt_def_t;


TNET_END_DECLS

#endif /* TNET_DNS_RR_OPT_H */
