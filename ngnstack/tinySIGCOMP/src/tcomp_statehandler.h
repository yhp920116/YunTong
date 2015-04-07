
/* Vincent, GZ, 2012-03-07 */

#ifndef TCOMP_STATE_HANDLER_H
#define TCOMP_STATE_HANDLER_H

#include "tinysigcomp_config.h"

#include "tcomp_types.h"
#include "tcomp_params.h"
#include "tcomp_nackinfo.h"
#include "tcomp_result.h"
#include "tcomp_buffer.h"
#include "tcomp_compartment.h"
#include "tcomp_state.h"

#include "tsk_safeobj.h"
#include "tsk_object.h"

TCOMP_BEGIN_DECLS

/**State handler.
*/
typedef struct tcomp_statehandler_s
{
	TSK_DECLARE_OBJECT;
	
	tcomp_compartments_L_t *compartments;
	tcomp_params_t *sigcomp_parameters;
	
	tcomp_dictionaries_L_t *dictionaries;
	int hasSipSdpDictionary;
	int hasPresenceDictionary;

	TSK_DECLARE_SAFEOBJ;
}
tcomp_statehandler_t;

tcomp_statehandler_t* tcomp_statehandler_create();

tcomp_compartment_t *tcomp_statehandler_getCompartment(const tcomp_statehandler_t *statehandler, uint64_t id);
void tcomp_statehandler_deleteCompartment(tcomp_statehandler_t *statehandler, uint64_t id);
tsk_bool_t tcomp_statehandler_compartmentExist(tcomp_statehandler_t *statehandler, uint64_t id);
uint16_t tcomp_statehandler_findState(tcomp_statehandler_t *statehandler, const tcomp_buffer_handle_t *partial_identifier, tcomp_state_t** lpState);

void tcomp_statehandler_handleResult(tcomp_statehandler_t *statehandler, tcomp_result_t **lpResult);
tsk_bool_t tcomp_statehandler_handleNack(tcomp_statehandler_t *statehandler, const tcomp_nackinfo_t *);

int tcomp_statehandler_addSipSdpDictionary(tcomp_statehandler_t *statehandler);
int tcomp_statehandler_addPresenceDictionary(tcomp_statehandler_t *statehandler);

TINYSIGCOMP_GEXTERN const tsk_object_def_t *tcomp_statehandler_def_t;

TCOMP_END_DECLS

#endif /* TCOMP_STATE_HANDLER_H */
