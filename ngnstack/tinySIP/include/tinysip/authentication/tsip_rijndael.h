
/* 2012-03-07 */

/**@file tsip_rijndael.h
 * @brief Rijndael Implementation.
 *

 * @section DESCRIPTION
 *
 * @sa 3G Security
 * <a href="http://www.3gpp.org/ftp/Specs/html-info/35205.htm"> 3GPP TS 35.205 </a>
 * <a href="http://www.3gpp.org/ftp/Specs/html-info/35206.htm"> 3GPP TS 35.206 </a>
 * <a href="http://www.3gpp.org/ftp/Specs/html-info/35207.htm"> 3GPP TS 35.207 </a>
 * <a href="http://www.3gpp.org/ftp/Specs/html-info/35208.htm"> 3GPP TS 35.208 </a>
 * <a href="http://www.3gpp.org/ftp/Specs/html-info/35909.htm"> 3GPP TS 35.909 </a>
 *-------------------------------------------------------------------
 *                      Rijndael Implementation
 *-------------------------------------------------------------------
 *
 *  A sample 32-bit orientated implementation of Rijndael, the
 *  suggested kernel for the example 3GPP authentication and key
 *  agreement functions.
 *
 *  This implementation draws on the description in section 5.2 of
 *  the AES proposal and also on the implementation by
 *  Dr B. R. Gladman <brg@gladman.uk.net> 9th October 2000.
 *  It uses a number of large (4k) lookup tables to implement the
 *  algorithm in an efficient manner.
 *
 *  Note: in this implementation the State is stored in four 32-bit
 *  words, one per column of the State, with the top byte of the
 *  column being the _least_ significant byte of the word.
 *
 *-----------------------------------------------------------------
 */
#ifndef TINYSIP_AUTHENTICATION_RIJNDAEL_H
#define TINYSIP_AUTHENTICATION_RIJNDAEL_H

#include "tinysip_config.h"

TSIP_BEGIN_DECLS

void RijndaelKeySchedule( uint8_t key[16] );
void RijndaelEncrypt( uint8_t in[16], uint8_t out[16] );

TSIP_END_DECLS

#endif /*TINYSIP_AUTHENTICATION_RIJNDAEL_H*/
