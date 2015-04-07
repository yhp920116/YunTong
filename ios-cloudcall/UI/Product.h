//
//  Product.h
//  CloudCall
//
//  Created by Sergio on 13-6-28.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject
{
	float     price;
	NSString *subject;
	NSString *detail;
	NSString *typeId;
}

@property (nonatomic, assign) float price;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *detail;
@property (nonatomic, retain) NSString *typeId;

- (Product *)initWithPrice:(float)_price andSubject:(NSString *)_subject andDetail:(NSString *)_detail andTypeId:(NSString *)_typeId;

@end
