
/* 2012-03-07 */


#ifndef tnet_dhcp_option_sip_H
#define tnet_dhcp_option_sip_H

#include "tinynet_config.h"

#include "tnet_dhcp_option.h"

#include "tsk_string.h"

TNET_BEGIN_DECLS

typedef struct tnet_dhcp_option_sip_s
{
	TNET_DECLARE_DHCP_OPTION;

	/* RFC 3361 subclause 3.1
	Code  Len   enc   DNS name of SIP server
	+-----+-----+-----+-----+-----+-----+-----+-----+--
	| 120 |  n  |  0  |  s1 |  s2 |  s3 |  s4 | s5  |  ...
	+-----+-----+-----+-----+-----+-----+-----+-----+--
	*/
	tsk_strings_L_t *servers;
}
tnet_dhcp_option_sip_t;

TINYNET_API tnet_dhcp_option_sip_t* tnet_dhcp_option_sip_create(const void* payload, tsk_size_t payload_size);

TINYNET_GEXTERN const tsk_object_def_t *tnet_dhcp_option_sip_def_t;

TNET_END_DECLS

#endif /* #define tnet_dhcp_option_sip_H */
