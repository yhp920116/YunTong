
/* 2012-03-07 */


#ifndef TINYSIP_CONFIG_H
#define TINYSIP_CONFIG_H

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition */
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define TSIP_UNDER_WINDOWS	1
#elif __APPLE__
#	define TSIP_UNDER_APPLE		1
#endif

#if !defined(__GNUC__) && defined(TINYSIP_EXPORTS)
# 	define TINYSIP_API		__declspec(dllexport)
# 	define TINYSIP_GEXTERN	__declspec(dllexport)
#elif !defined(__GNUC__) /*&& defined(TINYSIP_IMPORTS)*/
# 	define TINYSIP_API		__declspec(dllimport)
# 	define TINYSIP_GEXTERN	__declspec(dllimport)
#else
#	define TINYSIP_API
#	define TINYSIP_GEXTERN	extern
#endif


/* Guards against C++ name mangling  */
#ifdef __cplusplus
#	define TSIP_BEGIN_DECLS extern "C" {
#	define TSIP_END_DECLS }
#else
#	define TSIP_BEGIN_DECLS 
#	define TSIP_END_DECLS
#endif

/* Disable some well-known warnings */
#ifdef _MSC_VER
#	define _CRT_SECURE_NO_WARNINGS
#endif

/* Detecting C99 compilers */
#if (__STDC_VERSION__ == 199901L) && !defined(__C99__)
#	define __C99__
#endif

/* Whether to use SIP Compact headers (RFC 3261 - 7.3.3 Compact Form) */
#define TSIP_COMPACT_HEADERS 0

#include <stdint.h>
#ifdef __SYMBIAN32__
#include <stdlib.h>
#endif

#if HAVE_CONFIG_H
	#include "../config.h"
#endif

#endif // TINYSIP_CONFIG_H
