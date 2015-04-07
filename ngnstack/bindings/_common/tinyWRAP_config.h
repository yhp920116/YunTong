
/* 2012-03-07 */

#ifndef TINYWRAP_CONFIG_H
#define TINYWRAP_CONFIG_H

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition.
*/
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define TWRAP_UNDER_WINDOWS	1
#endif

#if (TWRAP_UNDER_WINDOWS || defined(__SYMBIAN32__)) && defined(TINYWRAP_EXPORTS)
# 	define TINYWRAP_API		__declspec(dllexport)
# 	define TINYWRAP_GEXTERN __declspec(dllexport)
#elif (TWRAP_UNDER_WINDOWS || defined(__SYMBIAN32__)) /*&& defined(TINYWRAP_IMPORTS)*/
# 	define TINYWRAP_API __declspec(dllimport)
# 	define TINYWRAP_GEXTERN __declspec(dllimport)
#else
#	define TINYWRAP_API
#	define TINYWRAP_GEXTERN	extern
#endif

/* Guards against C++ name mangling 
*/
#ifdef __cplusplus
#	define TWRAP_BEGIN_DECLS extern "C" {
#	define TWRAP_END_DECLS }
#else
#	define TWRAP_BEGIN_DECLS 
#	define TWRAP_END_DECLS
#endif

/* Disable some well-known warnings
*/
#ifdef _MSC_VER
#	define _CRT_SECURE_NO_WARNINGS
#endif

#include <stdint.h>


#if HAVE_CONFIG_H
	#include "../config.h"
#endif

#endif // TINYWRAP_CONFIG_H
