
/* 2012-03-07 */

#ifndef TNET_DNS_RESOLVCONF_H
#define TNET_DNS_RESOLVCONF_H

#include "tinynet_config.h"

#include "tnet_types.h"

TNET_BEGIN_DECLS

TINYNET_API tnet_addresses_L_t * tnet_dns_resolvconf_parse(const char* path);

TNET_END_DECLS

#endif /* TNET_DNS_RESOLVCONF_H */

