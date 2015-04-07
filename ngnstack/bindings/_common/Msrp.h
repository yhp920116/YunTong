
#ifndef TINYWRAP_MSRP_H
#define TINYWRAP_MSRP_H

#include "tinymsrp.h"

class MsrpSession;

class MsrpMessage
{
public:
	MsrpMessage();
#if !defined(SWIG)
	MsrpMessage(tmsrp_message_t *message);
#endif
	virtual ~MsrpMessage();

	bool isRequest();
	short getCode();
	const char* getPhrase();
	tmsrp_request_type_t getRequestType();
#if defined(SWIG)
	void getByteRange(int64_t* OUTPUT, int64_t* OUTPUT, int64_t* OUTPUT);
#else
	void getByteRange(int64_t* start, int64_t* end, int64_t* total);
#endif
	bool isLastChunck();
	bool isFirstChunck();
	bool isSuccessReport();
	char* getMsrpHeaderValue(const char* name);
	char* getMsrpHeaderParamValue(const char* name, const char* param);
	unsigned getMsrpContentLength();
	unsigned getMsrpContent(void* output, unsigned maxsize);

private:
	const tmsrp_header_t* getMsrpHeader(const char* name, unsigned index = 0);

private:
	tmsrp_message_t *m_pMessage;
};

class MsrpEvent
{
public:
#if !defined(SWIG)
	MsrpEvent(const tmsrp_event_t *_event);
#endif
	virtual ~MsrpEvent();

	tmsrp_event_type_t getType();
	const MsrpSession* getSipSession();
	const MsrpMessage* getMessage() const;

protected:
	const tmsrp_event_t *_event;
	MsrpMessage* m_pMessage;
};

class MsrpCallback
{
public:
	MsrpCallback() {  }
	virtual ~MsrpCallback() {}
	virtual int OnEvent(const MsrpEvent* e) { return -1; }
};


#if !defined(SWIG)
int twrap_msrp_cb(const tmsrp_event_t* _event);
#endif

#endif /* TINYWRAP_MSRP_H */
