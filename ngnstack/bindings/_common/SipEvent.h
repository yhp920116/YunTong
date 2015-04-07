
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYWRAP_SIPEVENT_H
#define TINYWRAP_SIPEVENT_H

#include "tinysip.h"
#include "Common.h"

class SipStack;

class SipSession;
class InviteSession;
class CallSession;
class MsrpSession;
class MessagingSession;
class InfoSession;
class OptionsSession;
class PublicationSession;
class RegistrationSession;
class SubscriptionSession;

class SipMessage;


/* ======================== SipEvent ========================*/
class SipEvent
{
public:
#if !defined(SWIG)
	SipEvent(const tsip_event_t *sipevent);
#endif
	virtual ~SipEvent();

public:
	short getCode() const;
	const char* getPhrase() const;
	const SipSession* getBaseSession() const;
	const SipMessage* getSipMessage() const;

protected:
#if !defined(SWIG)
	SipStack* getStack()const;
#endif

protected:
	const tsip_event_t *sipevent;
	SipMessage* sipmessage;
};


/* ======================== DialogEvent ========================*/
class DialogEvent: public SipEvent
{
public:
#if !defined(SWIG)
	DialogEvent(const tsip_event_t *sipevent);
#endif
	virtual ~DialogEvent();

public: /* Public API functions */
};

/* ======================== StackEvent ========================*/
class StackEvent: public SipEvent
{
public:
#if !defined(SWIG)
	StackEvent(const tsip_event_t *sipevent);
#endif
	virtual ~StackEvent();

public: /* Public API functions */
};



/* ======================== InviteEvent ========================*/
class InviteEvent: public SipEvent
{
public:
#if !defined(SWIG)
	InviteEvent(const tsip_event_t *sipevent);
#endif
	virtual ~InviteEvent();

public: /* Public API functions */
	tsip_invite_event_type_t getType() const;
	twrap_media_type_t getMediaType() const;
	const InviteSession* getSession() const;
	CallSession* takeCallSessionOwnership() const;
	MsrpSession* takeMsrpSessionOwnership() const;
};



/* ======================== MessagingEvent ========================*/
class MessagingEvent: public SipEvent
{
public:
#if !defined(SWIG)
	MessagingEvent(const tsip_event_t *sipevent);
#endif
	virtual ~MessagingEvent();

public: /* Public API functions */
	tsip_message_event_type_t getType() const;
	const MessagingSession* getSession() const;
	MessagingSession* takeSessionOwnership() const;
};

/* ======================== InfoEvent ========================*/
class InfoEvent: public SipEvent
{
public:
#if !defined(SWIG)
	InfoEvent(const tsip_event_t *sipevent);
#endif
	virtual ~InfoEvent();

public: /* Public API functions */
	tsip_info_event_type_t getType() const;
	const InfoSession* getSession() const;
	InfoSession* takeSessionOwnership() const;
};



/* ======================== OptionsEvent ========================*/
class OptionsEvent: public SipEvent
{
public:
#if !defined(SWIG)
	OptionsEvent(const tsip_event_t *sipevent);
#endif
	virtual ~OptionsEvent();

public: /* Public API functions */
	tsip_options_event_type_t getType() const;
	const OptionsSession* getSession() const;
	OptionsSession* takeSessionOwnership() const;
};



/* ======================== PublicationEvent ========================*/
class PublicationEvent: public SipEvent
{
public:
#if !defined(SWIG)
	PublicationEvent(const tsip_event_t *sipevent);
#endif
	virtual ~PublicationEvent();

public: /* Public API functions */
	tsip_publish_event_type_t getType() const;
	const PublicationSession* getSession() const;
};



/* ======================== RegistrationEvent ========================*/
class RegistrationEvent: public SipEvent
{
public:
#if !defined(SWIG)
	RegistrationEvent(const tsip_event_t *sipevent);
#endif
	virtual ~RegistrationEvent();

public: /* Public API functions */
	tsip_register_event_type_t getType() const;
	const RegistrationSession* getSession() const;
	RegistrationSession* takeSessionOwnership() const;
	
};


/* ======================== SubscriptionEvent ========================*/
class SubscriptionEvent: public SipEvent
{
public:
#if !defined(SWIG)
	SubscriptionEvent(const tsip_event_t *sipevent);
#endif
	virtual ~SubscriptionEvent();

public: /* Public API functions */
	tsip_subscribe_event_type_t getType() const;
	const SubscriptionSession* getSession() const;
};

#endif /* TINYWRAP_SIPEVENT_H */
