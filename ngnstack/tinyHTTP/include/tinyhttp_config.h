
/* 2012-03-07 */


#ifndef TINYHTTP_CONFIG_H
#define TINYHTTP_CONFIG_H

#if HAVE_CONFIG_H
	#include "config.h"
#endif

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition.
*/
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define THTTP_UNDER_WINDOWS	1
#endif

#if (THTTP_UNDER_WINDOWS || defined(__SYMBIAN32__)) && defined(TINYHTTP_EXPORTS)
# 	define TINYHTTP_API		__declspec(dllexport)
# 	define TINYHTTP_GEXTERN __declspec(dllexport)
#elif (THTTP_UNDER_WINDOWS || defined(__SYMBIAN32__)) /*&& defined(TINYHTTP_IMPORTS)*/
# 	define TINYHTTP_API __declspec(dllimport)
# 	define TINYHTTP_GEXTERN __declspec(dllimport)
#else
#	define TINYHTTP_API
#	define TINYHTTP_GEXTERN	extern
#endif

/* Guards against C++ name mangling 
*/
#ifdef __cplusplus
#	define THTTP_BEGIN_DECLS extern "C" {
#	define THTTP_END_DECLS }
#else
#	define THTTP_BEGIN_DECLS 
#	define THTTP_END_DECLS
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

#endif // TINYHTTP_CONFIG_H
