
/* 2012-03-07 */

#ifndef TINYXCAP_TXCAP_NODE_H
#define TINYXCAP_TXCAP_NODE_H

#include "tinyxcap_config.h"

#include "tsk_common.h"

#include <stdarg.h> /* va_list* */

TXCAP_BEGIN_DECLS

typedef enum txcap_selector_param_type_e
{
	xcapp_node_null = 0,

	xcapp_node_name,
	xcapp_node_pos,
	xcapp_node_attribute,
	xcapp_node_pos_n_attribute,
	xcapp_node_namespace
}
txcap_selector_param_type_t;

/**@ingroup txcap_selector_group
* @def TXCAP_SELECTOR_NODE_SET_NAME
* Node selection step. Selects by name as per <a href="http://tools.ietf.org/html/rfc4825#section-6.3">RFC 4825 subclause 6.3</a>.
* @param QNAME_STR The name of the node to select. The @a QName grammar is defined in the XML namespaces [<a href="http://tools.ietf.org/html/rfc4825#ref-3">3</a>] specification (<i>const char*</i>).
*/
/**@ingroup txcap_selector_group
* @def TXCAP_SELECTOR_NODE_SET_POS
* Node selection step. Selects by position as per <a href="http://tools.ietf.org/html/rfc4825#section-6.3">RFC 4825 subclause 6.3</a>.
* @param QNAME_STR The name of the node to select. The @a QName grammar is defined in the XML namespaces [<a href="http://tools.ietf.org/html/rfc4825#ref-3">3</a>] specification.
* @param POS_UINT The position of the node to select (1*DIGIT) (<i>unsigned int</i>).
*/
/**@ingroup txcap_selector_group
* @def TXCAP_SELECTOR_NODE_SET_ATTRIBUTE
* Node selection step. Selects by position and attribute as per <a href="http://tools.ietf.org/html/rfc4825#section-6.3">RFC 4825 subclause 6.3</a>.
* @param QNAME_STR The name of the node to select. The @a QName grammar is defined in the XML namespaces [<a href="http://tools.ietf.org/html/rfc4825#ref-3">3</a>] specification (<i>const char*</i>).
* @param ATT_QNAME_STR The name of the attribute (<i>const char*</i>).
* @param ATT_VALUE_STR The value of the attribute. @a AttValue grammar is defined in the XML specification XML 1.0 [<a href="http://tools.ietf.org/html/rfc4825#ref-1">1</a>] (<i>const char*</i>).
*/
/**@ingroup txcap_selector_group
* @def TXCAP_SELECTOR_NODE_SET_POS_ATTRIBUTE
* Node selection step. Selects by position and attribute as per <a href="http://tools.ietf.org/html/rfc4825#section-6.3">RFC 4825 subclause 6.3</a>.
* @param QNAME_STR The name of the node to select. The @a QName grammar is defined in the XML namespaces [<a href="http://tools.ietf.org/html/rfc4825#ref-3">3</a>] specification.
* @param POS_UINT The position of the node to select (1*DIGIT) (<i>unsigned int</i>).
* @param ATT_QNAME_STR The name of the attribute (<i>const char*</i>).
* @param ATT_VALUE_STR The value of the attribute. @a AttValue grammar is defined in the XML specification XML 1.0 [<a href="http://tools.ietf.org/html/rfc4825#ref-1">1</a>] (<i>const char*</i>).
*/
/**@ingroup txcap_selector_group
* @def TXCAP_SELECTOR_NODE_SET_NAMESPACE
* Node selection step. Appends XML namespace("namespace::*") as per <a href="http://tools.ietf.org/html/rfc4825#section-6.3">RFC 4825 subclause 6.3</a>.
* @param PREFIX_STR The prefix to use for this namespace (<i>const char*</i>).
* @param VALUE_STR The value of the namespace (<i>const char*</i>).
*/
/**@ingroup txcap_selector_group
* @def TXCAP_SELECTOR_NODE_SET_NULL
* Ends node selection steps. Must always be present and should be the last one.
*/
#define TXCAP_SELECTOR_NODE_SET_NAME(QNAME_STR)														xcapp_node_name, (const char*)QNAME_STR
#define TXCAP_SELECTOR_NODE_SET_POS(QNAME_STR, POS_UINT)											xcapp_node_pos, (const char*)QNAME_STR, (unsigned int)POS_UINT
#define TXCAP_SELECTOR_NODE_SET_ATTRIBUTE(QNAME_STR, ATT_QNAME_STR, ATT_VALUE_STR)					xcapp_node_attribute, (const char*)QNAME_STR, (const char*)ATT_QNAME_STR, (const char*)ATT_VALUE_STR
#define TXCAP_SELECTOR_NODE_SET_POS_ATTRIBUTE(QNAME_STR, POS_UINT, ATT_QNAME_STR, ATT_VALUE_STR)	xcapp_node_pos_n_attribute, (const char*)QNAME_STR, (unsigned int)POS_UINT, (const char*)ATT_QNAME_STR, (const char*)ATT_VALUE_STR
#define TXCAP_SELECTOR_NODE_SET_NAMESPACE(PREFIX_STR, VALUE_STR)									xcapp_node_namespace, (const char*)PREFIX_STR, (const char*)VALUE_STR
#define TXCAP_SELECTOR_NODE_SET_NULL()																xcapp_node_null

TINYXCAP_API char* txcap_selector_get_node(const char* auid_id, ...);
TINYXCAP_API char* txcap_selector_get_node_2(const char* auid_id, va_list* app);

TXCAP_END_DECLS

#endif /* TINYXCAP_TXCAP_NODE_H */
