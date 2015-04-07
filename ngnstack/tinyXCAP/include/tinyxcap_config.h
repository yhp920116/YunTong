
/* 2012-03-07 */


#ifndef TINYXCAP_CONFIG_H
#define TINYXCAP_CONFIG_H

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition.
*/
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define TXCAP_UNDER_WINDOWS	1
#endif

#if (TXCAP_UNDER_WINDOWS || defined(__SYMBIAN32__)) && defined(TINYXCAP_EXPORTS)
# 	define TINYXCAP_API		__declspec(dllexport)
# 	define TINYXCAP_GEXTERN __declspec(dllexport)
#elif (TXCAP_UNDER_WINDOWS || defined(__SYMBIAN32__)) /*&& defined(TINYXCAP_IMPORTS)*/
# 	define TINYXCAP_API __declspec(dllimport)
# 	define TINYXCAP_GEXTERN __declspec(dllimport)
#else
#	define TINYXCAP_API
#	define TINYXCAP_GEXTERN	extern
#endif

/* Guards against C++ name mangling 
*/
#ifdef __cplusplus
#	define TXCAP_BEGIN_DECLS extern "C" {
#	define TXCAP_END_DECLS }
#else
#	define TXCAP_BEGIN_DECLS 
#	define TXCAP_END_DECLS
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

#include <stdint.h>
#ifdef __SYMBIAN32__
#include <stdlib.h>
#endif

#if HAVE_CONFIG_H
	#include "config.h"
#endif

#endif // TINYXCAP_CONFIG_H
