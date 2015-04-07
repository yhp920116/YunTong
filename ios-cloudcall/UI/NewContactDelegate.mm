//
//  NewContactDelegate.m
//  WeiCall
//
//  Created by guobiao chen on 12-3-27.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import "NewContactDelegate.h"
#import "iOSNgnStack.h"


@implementation NewContactDelegate

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    if(person!=nil)
        [[NgnEngine sharedInstance].contactService load:YES];

    [newPersonViewController.navigationController popViewControllerAnimated:YES];
}

@end
