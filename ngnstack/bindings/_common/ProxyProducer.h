
/* Vincent, GZ, 2012-03-07 */


#ifndef TINYWRAP_PRODUCER_PROXY_H
#define TINYWRAP_PRODUCER_PROXY_H

#include "tinyWRAP_config.h"

#include "ProxyPluginMgr.h"

#include "tinymedia/tmedia_common.h"
#include "tinymedia/tmedia_producer.h"

/* ============ ProxyAudioProducerCallback Class ================= */
class ProxyAudioProducerCallback
{
public:
	ProxyAudioProducerCallback() { }
	virtual ~ProxyAudioProducerCallback(){ }

	virtual int prepare(int ptime, int rate, int channels) { return -1; }
	virtual int start() { return -1; }
	virtual int pause() { return -1; }
	virtual int stop() { return -1; }
};


/* ============ ProxyAudioProducer Class ================= */
class ProxyAudioProducer : public ProxyPlugin
{
public:
#if !defined(SWIG)
	ProxyAudioProducer(struct twrap_producer_proxy_audio_s* pProducer);
#endif
	virtual ~ProxyAudioProducer();

	bool setPushBuffer(const void* pPushBufferPtr, unsigned nPushBufferSize);
	int push(const void* pBuffer=tsk_null, unsigned nSize=0);
	bool setGain(unsigned nGain);
	unsigned getGain();
	void setCallback(ProxyAudioProducerCallback* pCallback) { m_pCallback = pCallback; }
#if !defined(SWIG)
	inline ProxyAudioProducerCallback* getCallback()const { return m_pCallback; }
	virtual inline bool isWrapping(tsk_object_t* pWrappedPlugin){
		return m_pWrappedPlugin == pWrappedPlugin;
	}
#endif
	virtual inline uint64_t getMediaSessionId(){
		return m_pWrappedPlugin ? TMEDIA_PRODUCER(m_pWrappedPlugin)->session_id : 0;
	}

public:
	static bool registerPlugin();

private:
	struct twrap_producer_proxy_audio_s* m_pWrappedPlugin;
	ProxyAudioProducerCallback* m_pCallback;
	struct{
		const void* pPushBufferPtr;
		unsigned nPushBufferSize;
	} m_PushBuffer;
};

/* ============ ProxyVideoProducerCallback Class ================= */
class ProxyVideoProducerCallback
{
public:
	ProxyVideoProducerCallback() { }
	virtual ~ProxyVideoProducerCallback(){ }

	virtual int prepare(int width, int height, int fps) { return -1; }
	virtual int start() { return -1; }
	virtual int pause() { return -1; }
	virtual int stop() { return -1; }
};

/* ============ ProxyVideoProducer Class ================= */
class ProxyVideoProducer : public ProxyPlugin
{
public:
#if !defined(SWIG)
	ProxyVideoProducer(tmedia_chroma_t eChroma, struct twrap_producer_proxy_video_s* pProducer);
#endif
	virtual ~ProxyVideoProducer();	

	int getRotation()const;
	bool setRotation(int nRot);
	bool setActualCameraOutputSize(unsigned nWidth, unsigned nHeight);
	int push(const void* pBuffer, unsigned nSize);
	int send(const void* pBuffer, unsigned nSize, unsigned nDuration, bool bMarker);
	void setCallback(ProxyVideoProducerCallback* pCallback) { m_pCallback = pCallback; }
#if !defined(SWIG)
	inline ProxyVideoProducerCallback* getCallback()const { return m_pCallback; }
	virtual inline bool isWrapping(tsk_object_t* wrapped_plugin){
		return m_pWrappedPlugin == wrapped_plugin;
	}
	virtual inline const tmedia_producer_t* getWrappedPlugin()const{
		return (tmedia_producer_t*)m_pWrappedPlugin;
	}
#endif
	virtual inline uint64_t getMediaSessionId(){
		return m_pWrappedPlugin ? TMEDIA_PRODUCER(m_pWrappedPlugin)->session_id : 0;
	}

public:
	static bool registerPlugin();
	static void setDefaultChroma(tmedia_chroma_t eChroma){ s_eDefaultChroma =  eChroma; }

#if !defined(SWIG)
	tmedia_chroma_t getChroma()const;
	static tmedia_chroma_t getDefaultChroma() { return s_eDefaultChroma; }
#endif

private:
	struct twrap_producer_proxy_video_s* m_pWrappedPlugin;
	ProxyVideoProducerCallback* m_pCallback;
	tmedia_chroma_t m_eChroma;
	int m_nRotation;

	static tmedia_chroma_t s_eDefaultChroma;
};

#endif /* TINYWRAP_PRODUCER_PROXY_H */
