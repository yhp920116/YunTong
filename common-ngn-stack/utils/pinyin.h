/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#ifndef _PIN_YIN_H_
#define _PIN_YIN_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>

/* 判断unicode是否为汉字 (form 0x4E00 to 0x9FA5) */
#define IsChinese(uni) ((uni) >= 0x4E00 && (uni) <= 0x9FA5)
/* 是否为字母 */
#define IsAlphabet(uni) (((uni) >= 'A' && (uni) <= 'Z') || ((uni) >= 'a' && (uni) <= 'z'))
/* 转小写 */
#define Conver2Lowercase(uni) (((uni >= 'A') && (uni) <= 'Z') ? (uni) + 32 : (uni))
/* 转大写 */
#define Conver2Uppercase(uni) (((uni >= 'a') && (uni) <= 'z') ? (uni) - 32 : (uni))

const char* GetPinyinsByUnicode(wchar_t uni);
    
#ifdef __cplusplus
}
#endif

#endif
