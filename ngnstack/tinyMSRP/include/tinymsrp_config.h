
/* 2012-03-07 */


#ifndef _TINYMSRP_H_
#define _TINYMSRP_H_

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition.
*/
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define TMSRP_UNDER_WINDOWS	1
#endif

/* Used on Windows and Symbian systems to export/import public functions and global variables.
*/
#if !defined(__GNUC__) && defined(TINYMSRP_EXPORTS)
# 	define TINYMSRP_API		__declspec(dllexport)
#	define TINYMSRP_GEXTERN	__declspec(dllexport)
#elif !defined(__GNUC__) /*&& defined(TINYMSRP_IMPORTS)*/
# 	define TINYMSRP_API		__declspec(dllimport)
#	define TINYMSRP_GEXTERN	__declspec(dllimport)
#else
#	define TINYMSRP_API
#	define TINYMSRP_GEXTERN	extern
#endif

/* Guards against C++ name mangling 
*/
#ifdef __cplusplus
#	define TMSRP_BEGIN_DECLS extern "C" {
#	define TMSRP_END_DECLS }
#else
#	define TMSRP_BEGIN_DECLS 
#	define TMSRP_END_DECLS
#endif

/* Disable some well-known warnings
*/
#ifdef _MSC_VER
#	define _CRT_SECURE_NO_WARNINGS
#	pragma warning( disable : 4996 )
#endif

#include <stdint.h>
#include <stddef.h>


#if HAVE_CONFIG_H
	#include "../config.h"
#endif

#endif /* _TINYMSRP_H_ */

