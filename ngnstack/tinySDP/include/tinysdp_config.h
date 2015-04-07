
/* 2012-03-07 */


#ifndef TINYSDP_CONFIG_H
#define TINYSDP_CONFIG_H

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition.
*/
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define TSDP_UNDER_WINDOWS	1
#endif

#if (TSDP_UNDER_WINDOWS || defined(__SYMBIAN32__)) && defined(TINYSDP_EXPORTS)
# 	define TINYSDP_API		__declspec(dllexport)
# 	define TINYSDP_GEXTERN __declspec(dllexport)
#elif (TSDP_UNDER_WINDOWS || defined(__SYMBIAN32__)) /*&& defined(TINYSDP_IMPORTS)*/
# 	define TINYSDP_API __declspec(dllimport)
# 	define TINYSDP_GEXTERN __declspec(dllimport)
#else
#	define TINYSDP_API
#	define TINYSDP_GEXTERN	extern
#endif

/* Guards against C++ name mangling 
*/
#ifdef __cplusplus
#	define TSDP_BEGIN_DECLS extern "C" {
#	define TSDP_END_DECLS }
#else
#	define TSDP_BEGIN_DECLS 
#	define TSDP_END_DECLS
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
	#include "../config.h"
#endif

#endif // TINYSDP_CONFIG_H
