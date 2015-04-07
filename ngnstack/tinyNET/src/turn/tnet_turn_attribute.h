
/* 2012-03-07 */

#ifndef TNET_TURN_ATTRIBUTE_H
#define TNET_TURN_ATTRIBUTE_H

#include "tinynet_config.h"
#include "tnet_proto.h"
#include "stun/tnet_stun_attribute.h"

TNET_BEGIN_DECLS

typedef tnet_stun_attribute_t tnet_turn_attribute_t;

/*	draft-ietf-behave-turn-16 - 14.1.  CHANNEL-NUMBER
	0                   1                   2                   3
	0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	|        Channel Number         |         RFFU = 0              |
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
*/
/**@ingroup tnet_turn_group
*/
typedef struct tnet_turn_attribute_channelnum_s
{
	TNET_STUN_DECLARE_ATTRIBUTE;

	uint16_t number;
	uint16_t rffu;
}
tnet_turn_attribute_channelnum_t;
TINYNET_GEXTERN const tsk_object_def_t *tnet_turn_attribute_channelnum_def_t;


/**@ingroup tnet_turn_group
* draft-ietf-behave-turn-16 - 14.2.  LIFETIME
*/
typedef struct tnet_turn_attribute_lifetime_s
{
	TNET_STUN_DECLARE_ATTRIBUTE;

	uint32_t value;
}
tnet_turn_attribute_lifetime_t;
TINYNET_GEXTERN const tsk_object_def_t *tnet_turn_attribute_lifetime_def_t;


/**@ingroup tnet_turn_group
* draft-ietf-behave-turn-16 - 14.3.  XOR-PEER-ADDRESS
*/
typedef struct tnet_turn_attribute_xpeer_addr_s
{
	TNET_STUN_DECLARE_ATTRIBUTE;

	tnet_stun_addr_family_t family;
	uint16_t xport;
	uint8_t xaddress[16];
}
tnet_turn_attribute_xpeer_addr_t;
TINYNET_GEXTERN const tsk_object_def_t *tnet_turn_attribute_xpeer_addr_def_t;

/**@ingroup tnet_turn_group
* draft-ietf-behave-turn-16 - 14.4.  DATA
*/
typedef struct tnet_turn_attribute_data_s
{
	TNET_STUN_DECLARE_ATTRIBUTE;

	tsk_buffer_t* value;
}
tnet_turn_attribute_data_t;
TINYNET_GEXTERN const tsk_object_def_t *tnet_turn_attribute_data_def_t;

/**@ingroup tnet_turn_group
* draft-ietf-behave-turn-16 - 14.5.  XOR-RELAYED-ADDRESS
*/
typedef struct tnet_turn_attribute_xrelayed_addr_s
{
	TNET_STUN_DECLARE_ATTRIBUTE;

	tnet_stun_addr_family_t family;
	uint16_t xport;
	uint8_t xaddress[16];
}
tnet_turn_attribute_xrelayed_addr_t;
TINYNET_GEXTERN const tsk_object_def_t *tnet_turn_attribute_xrelayed_addr_def_t;

/**@ingroup tnet_turn_group
* draft-ietf-behave-turn-16 - 14.6.  EVEN-PORT
*/
typedef struct tnet_turn_attribute_even_port_s
{
	TNET_STUN_DECLARE_ATTRIBUTE;
	
/*
	0 1 2 3 4 5 6 7
	+-+-+-+-+-+-+-+-+
	|R|    RFFU     |
	+-+-+-+-+-+-+-+-+
*/
	unsigned R:1;
	unsigned rffu:7;
}
tnet_turn_attribute_even_port_t;
TINYNET_GEXTERN const tsk_object_def_t *tnet_turn_attribute_even_port_def_t;


/**@ingroup tnet_turn_group
*/
typedef struct tnet_turn_attribute_reqtrans_s
{
	TNET_STUN_DECLARE_ATTRIBUTE;
/*	
	draft-ietf-behave-turn-16 - 14.7.  REQUESTED-TRANSPORT
	0                   1                   2                   3
	0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	|    Protocol   |                    RFFU                       |
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
*/
	tnet_proto_t protocol;
	uint8_t rffu[3];
}
tnet_turn_attribute_reqtrans_t;
TINYNET_GEXTERN const tsk_object_def_t *tnet_turn_attribute_reqtrans_def_t;



/**@ingroup tnet_turn_group
* draft-ietf-behave-turn-16 - 14.8.  DONT-FRAGMENT
*/
typedef struct tnet_turn_attribute_dontfrag_s
{
	TNET_STUN_DECLARE_ATTRIBUTE;
}
tnet_turn_attribute_dontfrag_t;
TINYNET_GEXTERN const tsk_object_def_t *tnet_turn_attribute_dontfrag_def_t;


/**@ingroup tnet_turn_group
* draft-ietf-behave-turn-16 - 14.9.  RESERVATION-TOKEN
*/
typedef struct tnet_turn_attribute_restoken_s
{
	TNET_STUN_DECLARE_ATTRIBUTE;

	uint8_t value[8];
}
tnet_turn_attribute_restoken_t;
TINYNET_GEXTERN const tsk_object_def_t *tnet_turn_attribute_restoken_def_t;


tnet_stun_attribute_t* tnet_turn_attribute_deserialize(tnet_stun_attribute_type_t type, uint16_t length, const void* payload, tsk_size_t payload_size);
int tnet_turn_attribute_serialize(const tnet_stun_attribute_t* attribute, tsk_buffer_t *output);

tnet_turn_attribute_channelnum_t* tnet_turn_attribute_channelnum_create(uint16_t number);
tnet_turn_attribute_lifetime_t* tnet_turn_attribute_lifetime_create(uint32_t lifetime);
tnet_turn_attribute_xpeer_addr_t* tnet_turn_attribute_xpeer_addr_create(const void* payload, tsk_size_t payload_size);
tnet_turn_attribute_xpeer_addr_t* tnet_turn_attribute_xpeer_addr_create_null();
tnet_turn_attribute_data_t* tnet_turn_attribute_data_create(const void* payload, tsk_size_t payload_size);
tnet_turn_attribute_xrelayed_addr_t* tnet_turn_attribute_xrelayed_addr_create(const void* payload, tsk_size_t payload_size);
tnet_turn_attribute_even_port_t* tnet_turn_attribute_even_port_create(unsigned R);
tnet_turn_attribute_reqtrans_t* tnet_turn_attribute_reqtrans_create(tnet_proto_t protocol);
tnet_turn_attribute_dontfrag_t* tnet_turn_attribute_dontfrag_create();
tnet_turn_attribute_restoken_t* tnet_turn_attribute_restoken_create(const void* payload, tsk_size_t payload_size);

TNET_END_DECLS

#endif /* TNET_TURN_ATTRIBUTE_H */

