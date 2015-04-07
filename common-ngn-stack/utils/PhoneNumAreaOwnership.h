//
//  PhoneNumAreaOwnership.h
//  WeiCall
//
//  Created by guobiao chen on 12-4-6.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

//#import <Foundation/Foundation.h>

@interface PhoneNumAreaOwnership : NSObject
{
    NSMutableArray *areaArray;
}


-(NSMutableArray *)subStringToSonSequence:(NSString *)operationString Separator:(NSString *)separatorString;

-(NSString *)clearOtherCharInString:(NSString *)phoneNumber symbols:(NSArray *) symbolsString;

-(NSArray *)writeTxtContentToArray:(NSString *)fileName;

-(NSString *)fileNameByNumberString:(NSString *)number currentDatabase:(NSArray *)current;

-(NSString *)operatorsByNumberString:(NSString *)number mobileDatabase:(NSArray *)mobile unicomDatabase:(NSArray *)unicom telecomDatabase:(NSArray *)telecom;

-(void)machineNumberAreaOwnership:(NSString *)phoneNumber;

-(void)mobileNumberAreaOwnership:(NSString *)phoneNumber;

-(void)enterpriseNumberAreaOwnership:(NSString *)phoneNumber;

-(NSMutableArray *)NumberAreaOwnership:(NSString *)phoneNumber;

-(int)search:(NSArray *)array searchValue:(NSString *)key frontIndex:(int)low endIndex:(int)hight;

-(void)searchAreaCode:(NSString *)phoneNumber;

@end
