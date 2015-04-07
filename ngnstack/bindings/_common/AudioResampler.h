

#ifndef TINYWRAP_AUDIO_RESAMPLER_H
#define TINYWRAP_AUDIO_RESAMPLER_H

#include "tinyWRAP_config.h"
#include "tsk_common.h"

class AudioResampler
{
public:
	AudioResampler(uint32_t nInFreq, uint32_t nOutFreq, uint32_t nFrameDuration, uint32_t nChannels, uint32_t nQuality);
	~AudioResampler();

public:
	inline bool isValid(){ return (m_pWrappedResampler != tsk_null); }
	inline uint32_t getOutputRequiredSizeInShort(){ return (m_nOutFreq * m_nFrameDuration)/1000; }
	inline uint32_t getInputRequiredSizeInShort(){ return (m_nInFreq * m_nFrameDuration)/1000; }
	uint32_t process(const void* pInData, uint32_t nInSizeInBytes, void* pOutData, uint32_t nOutSizeInBytes);

private:
	struct tmedia_resampler_s* m_pWrappedResampler;
	uint32_t m_nOutFreq;
	uint32_t m_nInFreq;
	uint32_t m_nFrameDuration;
	uint32_t m_nChannels;
	uint32_t m_nQuality;
};


#endif /* TINYWRAP_AUDIO_RESAMPLER_H */
