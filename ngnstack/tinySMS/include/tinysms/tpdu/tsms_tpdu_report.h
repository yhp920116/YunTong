
/* 2012-03-07 */

#ifndef TINYSMS_TSMS_TPDU_REPORT_H
#define TINYSMS_TSMS_TPDU_REPORT_H

#include "tinysms_config.h"

#include "tinysms/tsms_common.h"


TSMS_BEGIN_DECLS

/** SMS TPDU SMS-DELIVER-REPORT or SMS-SUBMIT-REPORT
* message as per 3GPP TS 23.040 section 9.2.2.1a or 9.2.2.2a.
*/
typedef struct tsms_tpdu_report_s
{
	TSMS_DECLARE_TPDU_MESSAGE;

	tsms_address_t* smsc;

	/** Indicates whether the Report is for RP-ERROR or not (RP-ACK).*/
	tsk_bool_t error;

	/** TP-User-Data-Header-Indication (O - 1b)
	* Parameter indicating that the TP-UD field contains a Header. */
	unsigned udhi:1;
	/** TP Failure Cause (M - I)
	* Parameter indicating the reason for SMS DELIVER/SUBMIT failure. 
	See clause 9.2.3.22 */
	uint8_t fcs;
	/** TP Parameter Indicator (M - o)
	* Parameter indicating the presence of any of the optional parameters which follow. */
	uint8_t pi;
	/** TP Service Centre Time Stamp (M - 7o)
	* Parameter identifying the time when the SC received the SMS DELIVER/SUBMIT.
	* See clause 9.2.3.11. */
	uint8_t scts[7];
	/** TP Protocol Identifier (O - o)
	* See clause 9.2.3.9. */
	//(base)uint8_t pid;
	/** TP Data Coding Scheme (O - o)
	* See clause 9.2.3.10. */
	//(base)uint8_t dcs;
	/** TP User Data Length (O- o)
	* See clause 9.2.3.16. */
	//(base)uint8_t udl;
	/** TP User Data (O - v)
	* User data. */
	//(base)tsk_buffer_t* ud;
}
tsms_tpdu_report_t;

/** cast any pointer to @ref tsms_tpdu_report_t* */
#define TSMS_TPDU_REPORT(self) ((tsms_tpdu_report_t*)(self))

TINYSMS_API tsms_tpdu_report_t* tsms_tpdu_report_create(const tsms_address_string_t smsc, tsk_bool_t submit, tsk_bool_t error);
TINYSMS_API int tsms_tpdu_report_set_fcs(tsms_tpdu_report_t* self, uint8_t code);

#define TSMS_TPDU_REPORT_IS_MO(self) (TSMS_TPDU_MESSAGE(self)->mti == tsms_tpdu_mti_deliver_report_mo)

/**@ingroup tsms_tpdu_group
* @def tsms_tpdu_report_serialize
* Serializes a @a SMS-DELIVER-REPORT or @a SMS-SUBMIT-REPORT message as binary content.
* @param self A pointer to the @a SMS-DELIVER-REPORT or @a SMS-SUBMIT-REPORT (@ref tsms_tpdu_report_t) message to serialize.
* @param output A pointer to the output buffer. Should be valid.
* @retval Zero if succeed and non-zero error code otherwise.
*/
/**@ingroup tsms_tpdu_group
* @def tsms_tpdu_report_tohexastring
* Serializes a @a SMS-DELIVER-REPORT or @a SMS-SUBMIT-REPORT message as hexa-string content.
* @param self A pointer to the @a SMS-DELIVER-REPORT or @a SMS-SUBMIT-REPORTT (@ref tsms_tpdu_report_t) message to serialize.
* @retval A pointer to the hexa-string if succeed and Null otherwise.
*/
/**@ingroup tsms_tpdu_group
* @def tsms_tpdu_report_set_userdata
* Sets the content of the @a SMS-DELIVER-REPORT or @a SMS-SUBMIT-REPORT message.
* @param self A pointer to the @a SMS-DELIVER-REPORT or @a SMS-SUBMIT-REPORT (@ref tsms_tpdu_report_t).
* @param udata A pointer to the content.
* @param alpha The alphabet used to encode the content.
* @retval Zero if succeed and non-zero error code otherwise.
*/
#define tsms_tpdu_report_serialize(self, output) tsms_tpdu_message_serialize(TSMS_TPDU_MESSAGE(self), output, TSMS_TPDU_REPORT_IS_MO(self))
#define tsms_tpdu_report_tostring(self) tsms_tpdu_message_tostring(TSMS_TPDU_MESSAGE(self), TSMS_TPDU_REPORT_IS_MO(self))
#define tsms_tpdu_report_tohexastring(self) tsms_tpdu_message_tohexastring(TSMS_TPDU_MESSAGE(self), TSMS_TPDU_REPORT_IS_MO(self))
#define tsms_tpdu_report_set_userdata(self, udata, alpha) tsms_tpdu_message_set_userdata(TSMS_TPDU_MESSAGE(self), udata, alpha)

TINYSMS_GEXTERN const tsk_object_def_t *tsms_tpdu_report_def_t;

TSMS_END_DECLS

#endif /* TINYSMS_TSMS_TPDU_REPORT_H */
