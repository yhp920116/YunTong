
/* 2012-03-07 */

#ifndef TINYRTP_CONFIG_H
#define TINYRTP_CONFIG_H

#if HAVE_CONFIG_H
	#include "config.h"
#endif

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition.
*/
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define TRTP_UNDER_WINDOWS	1
#endif

#if (TRTP_UNDER_WINDOWS || defined(__SYMBIAN32__)) && defined(TINYRTP_EXPORTS)
# 	define TINYRTP_API		__declspec(dllexport)
# 	define TINYRTP_GEXTERN __declspec(dllexport)
#elif (TRTP_UNDER_WINDOWS || defined(__SYMBIAN32__)) /*&& defined(TINYRTP_IMPORTS)*/
# 	define TINYRTP_API __declspec(dllimport)
# 	define TINYRTP_GEXTERN __declspec(dllimport)
#else
#	define TINYRTP_API
#	define TINYRTP_GEXTERN	extern
#endif

/* Guards against C++ name mangling 
*/
#ifdef __cplusplus
#	define TRTP_BEGIN_DECLS extern "C" {
#	define TRTP_END_DECLS }
#else
#	define TRTP_BEGIN_DECLS 
#	define TRTP_END_DECLS
#endif

/* Disable some well-known warnings
*/
#ifdef _MSC_VER
#	define _CRT_SECURE_NO_WARNINGS
#endif

/* Detecting C99 compilers
 */
#if (__STDC_VERSION__ == 199901L) && !defined(__C99__)
#	define __C99__
#endif

#define TRTP_RTP_VERSION 2

#include <stdint.h>
#ifdef __SYMBIAN32__
#include <stdlib.h>
#endif

#if HAVE_CONFIG_H
	#include "../config.h"
#endif

#endif // TINYRTP_CONFIG_H
