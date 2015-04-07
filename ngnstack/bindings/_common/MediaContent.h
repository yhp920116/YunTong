
#ifndef TINYWRAP_MEDIA_CONTENT_H
#define TINYWRAP_MEDIA_CONTENT_H

#include "tinymedia.h"
#include "Common.h"

class MediaContentCPIM;

class MediaContent
{
public:
#if !defined(SWIG)
	MediaContent(tmedia_content_t* content);
#endif
	virtual ~MediaContent();

public:
	const char* getType();
	virtual unsigned getDataLength();
	virtual unsigned getData(void* pOutput, unsigned nMaxsize);
	
	// SWIG %newobject()
	static MediaContent* parse(const void* pData, unsigned nSize, const char* pType);
	static MediaContentCPIM* parse(const void* pData, unsigned nSize);

	virtual unsigned getPayloadLength() = 0;
	virtual unsigned getPayload(void* pOutput, unsigned nMaxsize) = 0;

protected:
	tmedia_content_t* m_pContent;

private:
	tsk_buffer_t* m_pData;
};


/* ============ message/CPIM ================= */
class MediaContentCPIM : public MediaContent
{
public:
#if !defined(SWIG)
	MediaContentCPIM(tmedia_content_t* pContent);
#endif
	virtual ~MediaContentCPIM();

public:
	virtual unsigned getPayloadLength();
	virtual unsigned getPayload(void* pOutput, unsigned nMaxsize);
#if !defined(SWIG)
	const void* getPayloadPtr();
#endif
	const char* getHeaderValue(const char* pName);
};

#endif /*TINYWRAP_MEDIA_CONTENT_H*/
