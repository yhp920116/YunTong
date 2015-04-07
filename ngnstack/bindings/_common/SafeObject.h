
/* Vincent, GZ, 2012-03-07 */

#ifndef TINYWRAP_SAFEOBJECT_H
#define TINYWRAP_SAFEOBJECT_H

#include "tsk_mutex.h"

class SafeObject
{
public:
	SafeObject();
	virtual ~SafeObject();

/* protected: */
	int Lock()const;
	int UnLock()const;

private:
	tsk_mutex_handle_t *mutex;
};

#endif /* TINYWRAP_SAFEOBJECT_H */
