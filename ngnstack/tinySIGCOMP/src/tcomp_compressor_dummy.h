
/* Vincent, GZ, 2012-03-07 */

#ifndef TCOMP_COMPRESSOR_DUMMY_H
#define TCOMP_COMPRESSOR_DUMMY_H

#include "tinysigcomp_config.h"
#include "tcomp_compartment.h"

TCOMP_BEGIN_DECLS

tsk_bool_t tcomp_compressor_dummy_compress(tcomp_compartment_t *lpCompartment, const void *input_ptr, tsk_size_t input_size, void *output_ptr, tsk_size_t *output_size, tsk_bool_t stream);

TCOMP_END_DECLS

#endif /* TCOMP_COMPRESSOR_DUMMY_H */

