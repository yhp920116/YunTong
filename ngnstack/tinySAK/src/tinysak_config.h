
/* 2012-03-07 */


#ifndef _TINYSAK_H_
#define _TINYSAK_H_

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition.
*/
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define TSK_UNDER_WINDOWS	1
#endif

/* Used on Windows and Symbian systems to export/import public functions and global variables.
*/
#if !defined(__GNUC__) && defined(TINYSAK_EXPORTS)
# 	define TINYSAK_API		__declspec(dllexport)
#	define TINYSAK_GEXTERN	__declspec(dllexport)
#elif !defined(__GNUC__) /*&& defined(TINYSAK_IMPORTS)*/
# 	define TINYSAK_API		__declspec(dllimport)
#	define TINYSAK_GEXTERN	__declspec(dllimport)
#else
#	define TINYSAK_API
#	define TINYSAK_GEXTERN	extern
#endif

/* Guards against C++ name mangling */
#ifdef __cplusplus
#	define TSK_BEGIN_DECLS extern "C" {
#	define TSK_END_DECLS }
#else
#	define TSK_BEGIN_DECLS 
#	define TSK_END_DECLS
#endif

#if defined(_MSC_VER)
#	define TSK_INLINE	__forceinline
#elif defined(__GNUC__) && !defined(__APPLE__)
#	define TSK_INLINE	__inline
#else
#	define TSK_INLINE	
#endif


/* Disable some well-known warnings for M$ Visual Studio*/
#ifdef _MSC_VER
#	define _CRT_SECURE_NO_WARNINGS
#	pragma warning( disable : 4996 )
#endif

/*	Features */
#if TSK_UNDER_WINDOWS
#	define HAVE_GETTIMEOFDAY				0
#else
#	define HAVE_GETTIMEOFDAY				1
#endif

#if defined(ANDROID)
#	define HAVE_CLOCK_GETTIME	1
#endif

#include <stdint.h>
#include <stddef.h>
#include <stdarg.h>

#include "tsk_common.h"


#if HAVE_CONFIG_H
#	include "../config.h"
#endif

#endif /* _TINYSAK_H_ */

