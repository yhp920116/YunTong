
/* Vincent, GZ, 2012-03-07 */


#ifndef TCOMP_TYPES_H
#define TCOMP_TYPES_H

#include "tsk_list.h"

TCOMP_BEGIN_DECLS

typedef tsk_list_t tcomp_buffers_L_t; /**< List containing @ref tcomp_buffer_handle_t elements. */
typedef tsk_list_t tcomp_states_L_t; /**< List containing @ref tcomp_state_t elements. */
typedef tsk_list_t tcomp_dictionaries_L_t; /**< List containing @ref tcomp_dictionary_t elements. */
typedef tsk_list_t tcomp_compartments_L_t; /** List containing @ref tcomp_compartment_t elements. */
typedef tsk_list_t tcomp_stream_buffer_L_t; /** List containing @ref tcomp_stream_buffer_t elements. */

TCOMP_END_DECLS

#endif /* TCOMP_TYPES_H */
