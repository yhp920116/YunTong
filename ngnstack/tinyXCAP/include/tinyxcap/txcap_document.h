
/* 2012-03-07 */

#ifndef TINYXCAP_TXCAP_DOCUMENT_H
#define TINYXCAP_TXCAP_DOCUMENT_H

#include "tinyxcap_config.h"

#include "txcap.h"

TXCAP_BEGIN_DECLS

TINYXCAP_API char* txcap_selector_get_document(const txcap_stack_handle_t* stack, const char* auid_id);
TINYXCAP_API char* txcap_selector_get_document_2(const char* xcap_root, const char* auid_id, const char* xui, const char* doc_name);

TXCAP_END_DECLS

#endif /* TINYXCAP_TXCAP_DOCUMENT_H */
