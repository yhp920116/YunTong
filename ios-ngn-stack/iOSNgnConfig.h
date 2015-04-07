
#ifndef IOS_NGN_CONFIG_H
#define IOS_NGN_CONFIG_H

#include "iOSNgnLog.h"

// FIXME: to be renamed to "NGN_HAS_VIDEO_CAPTURE" in both NgnStack and WeiCall
#define NGN_PRODUCER_HAS_VIDEO_CAPTURE (__IPHONE_OS_VERSION_MIN_REQUIRED >= 40000 && TARGET_OS_EMBEDDED)

// Gary for supporting video, current release does not support video
#undef CLIENT_SUPPORT_VIDEO

#endif /* IOS_NGN_CONFIG_H */

