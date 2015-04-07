
/* 2012-03-07 */

#ifndef TINYSMS_CONFIG_H
#define TINYSMS_CONFIG_H

#if HAVE_CONFIG_H
	#include "config.h"
#endif

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition.
*/
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define TSMS_UNDER_WINDOWS	1
#endif

#if (TSMS_UNDER_WINDOWS || defined(__SYMBIAN32__)) && defined(TINYSMS_EXPORTS)
# 	define TINYSMS_API		__declspec(dllexport)
# 	define TINYSMS_GEXTERN __declspec(dllexport)
#elif (TSMS_UNDER_WINDOWS || defined(__SYMBIAN32__)) /*&& defined(TINYSMS_IMPORTS)*/
# 	define TINYSMS_API __declspec(dllimport)
# 	define TINYSMS_GEXTERN __declspec(dllimport)
#else
#	define TINYSMS_API
#	define TINYSMS_GEXTERN	extern
#endif

/* Guards against C++ name mangling 
*/
#ifdef __cplusplus
#	define TSMS_BEGIN_DECLS extern "C" {
#	define TSMS_END_DECLS }
#else
#	define TSMS_BEGIN_DECLS 
#	define TSMS_END_DECLS
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

#endif // TINYSMS_CONFIG_H
