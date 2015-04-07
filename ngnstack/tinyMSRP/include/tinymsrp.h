
/* 2012-03-07 */

#ifndef TINYMEDIA_TINYMSRP_H
#define TINYMEDIA_TINYMSRP_H

/* === tinyNET (tinyNET/src) === */
#include "tnet.h"

/* === tinySAK (tinySAK/src)=== */
#include "tsk.h"

#include "tmsrp.h"

#include "tinymsrp/tmsrp_message.h"
#include "tinymsrp/tmsrp_event.h"
#include "tinymsrp/tmsrp_uri.h"

#include "tinymsrp/headers/tmsrp_header_Dummy.h"
#include "tinymsrp/headers/tmsrp_header_Authentication-Info.h"
#include "tinymsrp/headers/tmsrp_header_Authorization.h"
#include "tinymsrp/headers/tmsrp_header_Byte-Range.h"
#include "tinymsrp/headers/tmsrp_header_Expires.h"
#include "tinymsrp/headers/tmsrp_header_Failure-Report.h"
#include "tinymsrp/headers/tmsrp_header_From-Path.h"
#include "tinymsrp/headers/tmsrp_header_Max-Expires.h"
#include "tinymsrp/headers/tmsrp_header_Message-ID.h"
#include "tinymsrp/headers/tmsrp_header_Min-Expires.h"
#include "tinymsrp/headers/tmsrp_header_Status.h"
#include "tinymsrp/headers/tmsrp_header_Success-Report.h"
#include "tinymsrp/headers/tmsrp_header_To-Path.h"
#include "tinymsrp/headers/tmsrp_header_Use-Path.h"
#include "tinymsrp/headers/tmsrp_header_WWW-Authenticate.h"

#include "tinymsrp/parsers/tmsrp_parser_message.h"
#include "tinymsrp/parsers/tmsrp_parser_uri.h"

#include "tinymsrp/session/tmsrp_config.h"
#include "tinymsrp/session/tmsrp_data.h"
#include "tinymsrp/session/tmsrp_receiver.h"
#include "tinymsrp/session/tmsrp_sender.h"

#endif /* TINYMEDIA_TINYMSRP_H */
