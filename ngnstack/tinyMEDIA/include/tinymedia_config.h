
/* 2012-03-07 */


#ifndef TINYMEDIA_CONFIG_H
#define TINYMEDIA_CONFIG_H

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition.
*/
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define TMEDIA_UNDER_WINDOWS	1
#endif

#if (TMEDIA_UNDER_WINDOWS || defined(__SYMBIAN32__)) && defined(TINYMEDIA_EXPORTS)
# 	define TINYMEDIA_API		__declspec(dllexport)
# 	define TINYMEDIA_GEXTERN __declspec(dllexport)
#elif (TMEDIA_UNDER_WINDOWS || defined(__SYMBIAN32__)) /*&& defined(TINYMEDIA_IMPORTS)*/
# 	define TINYMEDIA_API __declspec(dllimport)
# 	define TINYMEDIA_GEXTERN __declspec(dllimport)
#else
#	define TINYMEDIA_API
#	define TINYMEDIA_GEXTERN	extern
#endif

/* Guards against C++ name mangling 
*/
#ifdef __cplusplus
#	define TMEDIA_BEGIN_DECLS extern "C" {
#	define TMEDIA_END_DECLS }
#else
#	define TMEDIA_BEGIN_DECLS 
#	define TMEDIA_END_DECLS
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

#endif // TINYMEDIA_CONFIG_H
