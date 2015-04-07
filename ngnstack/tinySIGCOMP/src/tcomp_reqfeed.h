
/* Vincent, GZ, 2012-03-07 */

#ifndef TCOMP_REQ_FEEDBACK_H
#define TCOMP_REQ_FEEDBACK_H

#include "tinysigcomp_config.h"
#include "tcomp_buffer.h"
#include "tsk_object.h"

TCOMP_BEGIN_DECLS

/*
0   1   2   3   4   5   6   7
+---+---+---+---+---+---+---+---+
|     reserved      | Q | S | I |  requested_feedback_location
+---+---+---+---+---+---+---+---+
|                               |
:    requested feedback item    :  if Q = 1
|                               |
+---+---+---+---+---+---+---+---+
*/

/** SigComp Requested feedback item as per RFC 3320 subclause 9.4.9.
*/
typedef struct tcomp_reqfeed_s
{
	TSK_DECLARE_OBJECT;

	unsigned Q:1; /**< The Q-bit indicates whether a requested feedback item is present or not.*/
	unsigned S:1; /**< The compressor sets the S-bit to 1 if it does not wish (or no longer
	wishes) to save state information at the receiving endpoint and also
	does not wish to access state information that it has previously saved.*/
	unsigned I:1; /**< Similarly the compressor sets the I-bit to 1 if it does not wish (or
	no longer wishes) to access any of the locally available state items
	offered by the receiving endpoint.*/
	tcomp_buffer_handle_t *item; /**< The requested item feedback data */
}
tcomp_reqfeed_t;

tcomp_reqfeed_t* tcomp_reqfeed_create();

void tcomp_reqfeed_reset(tcomp_reqfeed_t*);

TINYSIGCOMP_GEXTERN const tsk_object_def_t *tcomp_reqfeed_def_t;

TCOMP_END_DECLS

#endif /* TCOMP_REQ_FEEDBACK_H */
