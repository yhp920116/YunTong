
/* 2012-03-07 */

#ifndef TINYDAV_CONSUMER_MSRP_H
#define TINYDAV_CONSUMER_MSRP_H

#include "tinydav_config.h"

TDAV_BEGIN_DECLS


#define TDAV_CONSUMER_MSRP(self)		((tdav_consumer_msrp_t*)(self))


typedef struct tdav_consumer_msrp_s
{
	TMEDIA_DECLARE_CONSUMER;
}
tdav_consumer_msrp_t;


TDAV_END_DECLS

#endif /* TINYDAV_CONSUMER_MSRP_H */
