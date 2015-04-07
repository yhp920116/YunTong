
#ifndef TINYDAV_CODEC_G711_IMPLEMENTATION_H
#define TINYDAV_CODEC_G711_IMPLEMENTATION_H

#include "tinydav_config.h"

TDAV_BEGIN_DECLS

unsigned char linear2alaw(short	pcm_val);
short alaw2linear(unsigned char	a_val);
unsigned char linear2ulaw(short	pcm_val);
short ulaw2linear(unsigned char	u_val);

TDAV_END_DECLS

#endif /* TINYDAV_CODEC_G711_IMPLEMENTATION_H */
