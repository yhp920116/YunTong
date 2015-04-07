
/* Vincent, GZ, 2012-03-07 */


#ifndef TCOMP_COMPRESSOR_H
#define TCOMP_COMPRESSOR_H

#include "tinysigcomp_config.h"
#include "tcomp_compartment.h"

TCOMP_BEGIN_DECLS

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @typedef	int (*tcomp_compressor_compress_f)(tcomp_compartment_t *lpCompartment,
/// 			const void *input_ptr, tsk_size_t input_size, void *output_ptr, tsk_size_t *output_size,
/// 			int stream)
///
/// @brief	Function pointer definition for compression method.
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef tsk_bool_t (*tcomp_compressor_compress_f)(tcomp_compartment_t *lpCompartment, const void *input_ptr, tsk_size_t input_size, void *output_ptr, tsk_size_t *output_size, tsk_bool_t stream);

#define TCOMP_COMPRESSOR_COMPRESS_F(self) ((tcomp_compressor_compress_f)(self))

TCOMP_END_DECLS

#endif /* TCOMP_COMPRESSOR_H */
