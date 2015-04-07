
/* Vincent, GZ, 2012-03-07 */


#ifndef TDAV_APPLE_H
#define TDAV_APPLE_H

#if TDAV_UNDER_APPLE

#include <AudioToolbox/AudioToolbox.h>

#include "tsk_debug.h"

static int tdav_apple_init()
{
	// initialize audio session
#if TARGET_OS_IPHONE
	OSStatus status;
	status = AudioSessionInitialize(NULL, NULL, NULL, NULL);
	if(status){
		TSK_DEBUG_ERROR("AudioSessionInitialize() failed with status code=%d", (int32_t)status);
		return -1;
	}
	
	// enable record/playback
	UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
	status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
	if(status){
		TSK_DEBUG_ERROR("AudioSessionSetProperty(kAudioSessionProperty_AudioCategory) failed with status code=%d", (int32_t)status);
		return -2;
	}
	
	// allow mixing
	UInt32 allowMixing = true;
	status = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
	if(status){
		TSK_DEBUG_ERROR("AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers) failed with status code=%d", (int32_t)status);
		return -3;
	}
	
	// enable audio session
	status = AudioSessionSetActive(true);
	if(status){
		TSK_DEBUG_ERROR("AudioSessionSetActive(true) failed with status code=%d", (int32_t)status);
		return -4;
	}
#endif
	return 0;
}

static int tdav_apple_deinit()
{
	// maybe other code use the session
	// OSStatus status = AudioSessionSetActive(false);
	return 0;
}

#endif /* TDAV_UNDER_APPLE */

#endif /* TDAV_APPLE_H */