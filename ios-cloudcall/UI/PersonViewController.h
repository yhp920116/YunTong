//
//  PersonViewController.h
//  WeiCall
//
//  Created by guobiao chen on 12-3-27.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/ABPersonViewController.h>

@interface PersonViewController : ABPersonViewController
{
    BOOL fromAddToExistContact;
    NSString *AddToExistContactNumber;
    
    long contactId;
}
@property (nonatomic, assign) BOOL fromAddToExistContact;
@property (nonatomic, retain) NSString *AddToExistContactNumber;

@property (nonatomic, assign) long contactId;

+(BOOL)switchValue;
+(void)setSwitchValue:(BOOL)value;
+(BOOL)didDeleteValue;
+(void)setDidDeleteValue:(BOOL)value;

@end
