//
//  CloudCallJSONSerialization.m
//  CloudCall
//
//  Created by Sergio on 13-7-31.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "CloudCallJSONSerialization.h"

@implementation CloudCallJSONSerialization

/**
 *	@brief	将JsonData 转换为 NSString
 *
 *	@param 	jsonData
 *
 *	@return	返回NSString
 */
+ (NSString *)JsonDataToNSString:(NSData *)jsonData
{
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    if (jsonString != nil)
    {
#if !__has_feature(objc_arc)
        return [jsonString autorelease];
#else
        return jsonString;
#endif
    }
    else
    {
        return nil;
    }
    
    return nil;
}

/**
 *	@brief	将jsonString 转换为 Object
 *
 *	@param 	jsonString
 *
 *	@return	返回id
 */
+ (id)JsonStringToObject:(NSString *)jsonString
{
    if (jsonString == nil)
        return nil;
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (SystemVersion >= 5.0)
    {
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&error];
        
        if (jsonObject != nil && error == nil)
        {
            return jsonObject;
        }
    }
    else
    {
        id jsonObject = [jsonData mutableObjectFromJSONData];
        
        if (jsonObject)
        {
            return jsonObject;
        }
    }
    
    return nil;
}

/**
 *	@brief	将JsonData 转换为 Object
 *
 *	@param 	jsonData
 *
 *	@return	返回id
 */
+ (id)JsonDataToObject:(NSData *)jsonData
{
    if (SystemVersion >= 5.0)
    {
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        if (jsonObject != nil && error == nil)
        {
            return jsonObject;
        }
    }
    else
    {
        id jsonObject = [jsonData mutableObjectFromJSONData];
        
        if (jsonObject)
        {
            return jsonObject;
        }
    }
    
    return nil;
}

///**
// *	@brief	将JsonData 转换为 JsonData
// *
// *	@param 	jsonData
// *
// *	@return	返回NSData
// */
//+ (NSData *)NSStringToJsonData:(NSString *)string
//{
//    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
//    
//    if (jsonData != nil)
//    {
//        return jsonData;
//    }
//    
//    return nil;
//}

/**
 *	@brief	将_object 转换为 JsonData
 *
 *	@param 	_object
 *
 *	@return	返回NSData
 */
+ (NSData *)ObjectToJsonData:(id)_object
{
    NSError *error = nil;
    
    if (SystemVersion >= 5.0)
    {
        if ([NSJSONSerialization isValidJSONObject:_object])
        {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_object options:NSJSONWritingPrettyPrinted error:&error];
            
            if (jsonData != nil && error == nil)
            {
                return jsonData;
            }
        }
    }
    else
    {
        NSData *jsonData = [_object JSONDataWithOptions:JKSerializeOptionNone error:&error];
        
        if (jsonData != nil && error == nil)
        {
            return jsonData;
        }
    }
    
    return nil;
}

@end
