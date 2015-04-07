
/* Vincent, GZ, 2012-03-07 */


#ifndef TCOMP_NACKCODES_H
#define TCOMP_NACKCODES_H

/************************************************************************************
* Error								       code							details
*************************************************************************************/
#define NACK_STATE_NOT_FOUND				1				// State ID (6 - 20 bytes)
#define NACK_CYCLES_EXHAUSTED			    2				// Cycles Per Bit (1 byte)
#define NACK_USER_REQUESTED					3
#define NACK_SEGFAULT						4
#define NACK_TOO_MANY_STATE_REQUESTS		5
#define NACK_INVALID_STATE_ID_LENGTH		6
#define NACK_INVALID_STATE_PRIORITY			7
#define NACK_OUTPUT_OVERFLOW				8
#define NACK_STACK_UNDERFLOW				9
#define NACK_BAD_INPUT_BITORDER				10
#define NACK_DIV_BY_ZERO					11
#define NACK_SWITCH_VALUE_TOO_HIGH			12
#define NACK_TOO_MANY_BITS_REQUESTED		13
#define NACK_INVALID_OPERAND				14
#define NACK_HUFFMAN_NO_MATCH				15
#define NACK_MESSAGE_TOO_SHORT				16
#define NACK_INVALID_CODE_LOCATION			17
#define NACK_BYTECODES_TOO_LARGE			18				// Memory size (2 bytes)
#define NACK_INVALID_OPCODE					19
#define NACK_INVALID_STATE_PROBE			20
#define NACK_ID_NOT_UNIQUE					21				// State ID (6 - 20 bytes)
#define NACK_MULTILOAD_OVERWRITTEN			22
#define NACK_STATE_TOO_SHORT				23				// State ID (6 - 20 bytes)
#define NACK_INTERNAL_ERROR					24
#define NACK_FRAMING_ERROR					25

#endif /* TCOMP_NACKCODES_H */
