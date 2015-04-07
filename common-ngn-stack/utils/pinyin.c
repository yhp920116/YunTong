/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "pinyin.h"
#include "pinyindata.h"

const char* GetPinyinsByUnicode(wchar_t uni)
{
    if (!IsChinese(uni))
    {
        return 0;
    }
    
    int count = pinyin_count[uni - 19968];
    if (count == 0)
    {
        return NULL;
    }
    
    const char *indexs = pinyin_index[uni - 19968];
    
    // Only return the first one
    const char* r = 0;
    r = pinyin_all_pinyin[(unsigned char)indexs[0] + (unsigned char)indexs[0 + 1]];
    return r;
}

int pinyin_get_pinyins_by_unicode(wchar_t uni, const char ***pinyins_out)
{
    if (!IsChinese(uni))
    {
        *pinyins_out = NULL;
        return 0;
    }    
    
    int count = pinyin_count[uni - 19968];    
    if (count == 0)
    {
        *pinyins_out = NULL;
        return 0;
    }
    
    // 多音字会有多个拼音
    const char *indexs = pinyin_index[uni - 19968];
    const char **pinyins = (const char **)malloc(sizeof(const char *) * count);
    for (int i = 0; i < count; i++)
    {
        int start = i * 2;
        pinyins[i] = pinyin_all_pinyin[(unsigned char)indexs[start] + (unsigned char)indexs[start + 1]];
    }
    
    *pinyins_out = pinyins;
    return count;
}