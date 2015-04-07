
/* Vincent, GZ, 2012-03-07 */

#ifndef TCOMP_DECOMPRESSORDISP_H
#define TCOMP_DECOMPRESSORDISP_H

#include "tinysigcomp_config.h"
#include "tcomp_statehandler.h"
#include "tcomp_buffer.h"
#include "tcomp_types.h"
#include "tcomp_result.h"


#include "tsk_object.h"
#include "tsk_safeobj.h"

TCOMP_BEGIN_DECLS

typedef struct tcomp_stream_buffer_s
{
	TSK_DECLARE_OBJECT;

	uint64_t	id;						/**< Buffer identifier */
	tcomp_buffer_handle_t *buffer;		/**< Buffer handle */

	TSK_DECLARE_SAFEOBJ;
}
tcomp_stream_buffer_t;

typedef struct tcomp_decompressordisp_s
{
	TSK_DECLARE_OBJECT;

	const tcomp_statehandler_t* stateHandler;
	tcomp_stream_buffer_L_t *streamBuffers;

	TSK_DECLARE_SAFEOBJ;
}
tcomp_decompressordisp_t;

tcomp_decompressordisp_t* tcomp_decompressordisp_create(const tcomp_statehandler_t* statehandler);

tsk_bool_t tcomp_decompressordisp_decompress(tcomp_decompressordisp_t *dispatcher, const void* input_ptr, tsk_size_t input_size, tcomp_result_t *lpResult);
tsk_bool_t tcomp_decompressordisp_getNextMessage(tcomp_decompressordisp_t *dispatcher, tcomp_result_t *lpResult);

tsk_bool_t tcomp_decompressordisp_internalDecompress(tcomp_decompressordisp_t *dispatcher, const void* input_ptr, const tsk_size_t input_size, tcomp_result_t **lpResult);
tsk_bool_t tcomp_decompressordisp_appendStream(tcomp_decompressordisp_t *dispatcher, const void* input_ptr, tsk_size_t input_size, uint64_t streamId);
tsk_bool_t tcomp_decompressordisp_getNextStreamMsg(tcomp_decompressordisp_t *dispatcher, uint64_t streamId, uint16_t *discard_count, tsk_size_t *size);

TINYSIGCOMP_GEXTERN const tsk_object_def_t *tcomp_stream_buffer_def_t;
TINYSIGCOMP_GEXTERN const tsk_object_def_t *tcomp_decompressordisp_def_t;

TCOMP_END_DECLS

#endif /*TCOMP_DECOMPRESSORDISP_H*/
