
/* 2012-03-07 */

#ifndef _TMSRP_HEADER_FAILURE_REPORT_H_
#define _TMSRP_HEADER_FAILURE_REPORT_H_

#include "tinymsrp_config.h"
#include "tinymsrp/headers/tmsrp_header.h"

TMSRP_BEGIN_DECLS

#define TMSRP_HEADER_FAILURE_REPORT_VA_ARGS(freport_type)		tmsrp_header_Failure_Report_def_t, (tmsrp_freport_type_t)freport_type

/** Failure report type;
*/
typedef enum tmsrp_freport_type_e
{
	freport_yes,
	freport_no,
	freport_partial
}
tmsrp_freport_type_t;

////////////////////////////////////////////////////////////////////////////////////////////////////
/// @struct	
///
/// @brief	MSRP 'Failure-Report' header.
///
/// @par ABNF :  "Failure-Report:" ( "yes" / "no" / "partial" ) 
///
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct tmsrp_header_Failure_Report_s
{	
	TMSRP_DECLARE_HEADER;
	tmsrp_freport_type_t type;
}
tmsrp_header_Failure_Report_t;

typedef tsk_list_t tmsrp_headers_Failure_Report_L_t;


TINYMSRP_API tmsrp_header_Failure_Report_t* tmsrp_header_Failure_Report_create(tmsrp_freport_type_t freport_type);
TINYMSRP_API tmsrp_header_Failure_Report_t* tmsrp_header_Failure_Report_create_null();

TINYMSRP_API tmsrp_header_Failure_Report_t *tmsrp_header_Failure_Report_parse(const char *data, tsk_size_t size);

TINYMSRP_GEXTERN const tsk_object_def_t *tmsrp_header_Failure_Report_def_t;

TMSRP_END_DECLS

#endif /* _TMSRP_HEADER_FAILURE_REPORT_H_ */

