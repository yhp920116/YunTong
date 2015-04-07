
/* Vincent, GZ, 2012-03-07 */

#ifndef TCOMP_MESSAGE_H
#define TCOMP_MESSAGE_H

#include "tinysigcomp_config.h"
#include "tcomp_buffer.h"
#include "tcomp_nackinfo.h"
#include "tsk_object.h"

TCOMP_BEGIN_DECLS


/**
* SigComp Message Format as per RFC 3320 subclause 7.
*/
typedef struct tcomp_message_s
{
	TSK_DECLARE_OBJECT;

	uint8_t headerSigComp; /**< SigComp header */

	unsigned isOK:1; /**< Message validity. */
	unsigned isNack:1; /**< If it's a NACK message. */
	unsigned stream_based:1; /**< If it's stream message (e.g. TCP) */
	const uint8_t* startPtr; /**< Message pointer. */
	tsk_size_t totalSize; /**< The total message size. */
	tsk_size_t header_size;	/**< The size of the message header */
	
	tcomp_buffer_handle_t* stateId; /**< */
	
	uint16_t bytecodes_destination; /**< */
	tcomp_buffer_handle_t* remaining_sigcomp_buffer; /**< */
	tcomp_buffer_handle_t* uploaded_UDVM_buffer; /**< */
	tcomp_buffer_handle_t* ret_feedback_buffer; /**< */
	
	tcomp_nackinfo_t* nack_info; /**< */
}
tcomp_message_t;

tcomp_message_t* tcomp_message_create(const void* input_ptr, tsk_size_t input_size, tsk_bool_t stream);

TINYSIGCOMP_GEXTERN const tsk_object_def_t *tcomp_message_def_t;

TCOMP_END_DECLS

#endif /* TCOMP_MESSAGE_H */
