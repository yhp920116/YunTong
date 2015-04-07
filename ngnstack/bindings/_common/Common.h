
#ifndef TINYWRAP_COMMON_H
#define TINYWRAP_COMMON_H

#if ANDROID
#	define dyn_cast	static_cast
#	define __JNIENV JNIEnv
#else
#	define dyn_cast	dynamic_cast
#	define __JNIENV void
#endif

typedef enum twrap_media_type_e
{
	// because of Java don't use OR
	twrap_media_none = 0x00,

	twrap_media_audio = 0x01,
	twrap_media_video = 0x02,
	twrap_media_audiovideo = 0x03,

	twrap_media_msrp = 0x04
}
twrap_media_type_t;

#endif /* TINYWRAP_COMMON_H */

