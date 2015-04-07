
/* Vincent, GZ, 2012-03-07 */

#ifndef TCOMP_PARAMS_H
#define TCOMP_PARAMS_H

#include "tinysigcomp_config.h"
#include "tcomp_types.h"
#include "tsk_object.h"

/**@typedef tcomp_params_t
* SIGCOMP parameters as per rfc 3320 subclause 3.3.
*/

TCOMP_BEGIN_DECLS


typedef struct tcomp_params_s
{
	TSK_DECLARE_OBJECT;

	uint8_t cpbCode; /**< 'Cycles Per Bit' binary code. You MUST use @ref tcomp_params_setCpbCode to set this value. */
	uint8_t dmsCode; /**< 'Decompression Memory' Size binary code. You MUST use @ref tcomp_params_setDmsCode to set this value. */
	uint8_t smsCode; /**< 'State Memory Size' binary code. You MUST use @ref tcomp_params_setSmsCode to set this value.  */

	uint8_t cpbValue;	/**< 'Cycles Per Bit' value. You MUST use @ref tcomp_params_setCpbValue to set this value. */
	uint32_t dmsValue;	/**< 'Decompression Memory Size' value. You MUST use @ref tcomp_params_setDmsValue to set this value. */
	uint32_t smsValue;	/**< 'State Memory Size' value You MUST use @ref tcomp_params_setSmsValue to set this value. */

	uint8_t SigComp_version;	/**< SigComp version. */
	tcomp_buffers_L_t* returnedStates; /**< List of the returned states. */
}
tcomp_params_t;

tcomp_params_t* tcomp_params_create();

tsk_bool_t tcomp_params_hasCpbDmsSms(tcomp_params_t*);
	
void tcomp_params_setCpbCode(tcomp_params_t*, uint8_t _cpbCode);
int tcomp_params_setCpbValue(tcomp_params_t*, uint8_t _cpbValue);

void tcomp_params_setDmsCode(tcomp_params_t*, uint8_t _dmsCode);
int tcomp_params_setDmsValue(tcomp_params_t*, uint32_t _dmsValue);

void tcomp_params_setSmsCode(tcomp_params_t*, uint8_t _smsCode);
int tcomp_params_setSmsValue(tcomp_params_t*, uint32_t _smsValue);

uint16_t tcomp_params_getParameters(tcomp_params_t*);
void tcomp_params_setParameters(tcomp_params_t*, uint16_t sigCompParameters);

void tcomp_params_reset(tcomp_params_t*);

TINYSIGCOMP_GEXTERN const tsk_object_def_t *tcomp_params_def_t;

TCOMP_END_DECLS

#endif /* TCOMP_PARAMS_H */
