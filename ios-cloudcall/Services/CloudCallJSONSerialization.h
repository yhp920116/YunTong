//
//  CloudCallJSONSerialization.h
//  CloudCall
//
//  Created by Sergio on 13-7-31.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONKit.h"

@interface CloudCallJSONSerialization : NSObject

+ (NSString *)JsonDataToNSString:(NSData *)jsonData;

+ (id)JsonStringToObject:(NSString *)jsonString;

+ (id)JsonDataToObject:(NSData *)jsonData;

//+ (NSData *)NSStringToJsonData:(NSString *)string;

+ (NSData *)ObjectToJsonData:(id)_object;

@end
