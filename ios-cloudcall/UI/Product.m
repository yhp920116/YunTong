//
//  Product.m
//  CloudCall
//
//  Created by Sergio on 13-6-28.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "Product.h"

@implementation Product
@synthesize price;
@synthesize subject;
@synthesize detail;
@synthesize typeId;

- (Product *)initWithPrice:(float)_price andSubject:(NSString *)_subject andDetail:(NSString *)_detail andTypeId:(NSString *)_typeId
{
    if ((self = [super init])) {
        self->price      = _price;
        self->subject    = [_subject retain];
        self->detail    = [_detail retain];
        self->typeId       = [_typeId retain];
	}
	return self;
}

- (void)dealloc
{
    [subject release];
    [detail release];
    [typeId release];
    
    [super dealloc];
}

@end
