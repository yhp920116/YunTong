
/* Vincent, GZ, 2012-03-07 */

#ifndef TCOMP_STATE_H
#define TCOMP_STATE_H

#include "tinysigcomp_config.h"

#include "tcomp_buffer.h"
#include "tsk_safeobj.h"
#include "tsk_object.h"

TCOMP_BEGIN_DECLS

#define TCOMP_PARTIAL_ID_LEN_CODE		0x01
#define TCOMP_PARTIAL_ID_LEN_VALUE		0x06

/**For the purpose of calculation, each state item is considered to cost (state_length + 64) bytes.
*/
#define TCOMP_GET_STATE_SIZE(state) ( (state) ? ((state)->length + 64) : 0 )

/**SigComp state.
*/
typedef struct tcomp_state_s
{
	TSK_DECLARE_OBJECT;

	tcomp_buffer_handle_t *value;		/**< State's value. */
	tcomp_buffer_handle_t *identifier;	/**< State's identifier. */
	
	uint16_t length;					/**< State's length. */
	uint16_t address;					/**< State's address. */
	uint16_t instruction;				/**< State's instruction. */
	uint16_t minimum_access_length;		/**< State's minimum access length. */
	uint16_t retention_priority;		/**< State's retention priority. */

	TSK_DECLARE_SAFEOBJ;
}
tcomp_state_t;

typedef tcomp_state_t tcomp_dictionary_t; /**< Ad dictionary is  a @ref tcomp_state_t. */

tcomp_state_t* tcomp_state_create(uint16_t length, uint16_t address, uint16_t instruction, uint16_t minimum_access_length, uint16_t retention_priority);

int tcomp_state_equals(const tcomp_state_t *state1, const tcomp_state_t *state2);
void tcomp_state_makeValid(tcomp_state_t*);

TINYSIGCOMP_GEXTERN const tsk_object_def_t *tcomp_state_def_t;

TCOMP_END_DECLS

#endif /* TCOMP_STATE_H */
