
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYWRAP_SIPCALLBACK_H
#define TINYWRAP_SIPCALLBACK_H

class DialogEvent;
class StackEvent;

class InviteEvent;
class MessagingEvent;
class InfoEvent;
class OptionsEvent;
class PublicationEvent;
class RegistrationEvent;
class SubscriptionEvent;

class SipCallback
{
public:
	SipCallback() {  }
	virtual ~SipCallback() {}
	virtual int OnDialogEvent(const DialogEvent* e) { return -1; }
	virtual int OnStackEvent(const StackEvent* e) { return -1; }

	virtual int OnInviteEvent(const InviteEvent* e) { return -1; }
	virtual int OnMessagingEvent(const MessagingEvent* e) { return -1; }
	virtual int OnInfoEvent(const InfoEvent* e) { return -1; }
	virtual int OnOptionsEvent(const OptionsEvent* e) { return -1; }
	virtual int OnPublicationEvent(const PublicationEvent* e) { return -1; }
	virtual int OnRegistrationEvent(const RegistrationEvent* e) { return -1; }
	virtual int OnSubscriptionEvent(const SubscriptionEvent* e) { return -1; }

private:
	
};

#endif /* TINYWRAP_SIPCALLBACK_H */
