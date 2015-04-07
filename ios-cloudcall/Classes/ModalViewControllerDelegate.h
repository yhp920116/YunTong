/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import <UIKit/UIKit.h>


@protocol ModalViewControllerDelegate <NSObject>

@required
- (void)modalViewControllerDidDismiss: (UIViewController *)modalViewController;
- (void)modalViewController:(UIViewController *)modalViewController didReturnWithResult:(NSObject*)result;

@end
