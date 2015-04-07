/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */
 
#import <UIKit/UIKit.h>


@protocol PickerViewControllerDelegate

@required
- (void)pickerViewControllerDidCancel: (UINavigationController *)pickerViewController;
- (void)pickerViewController:(UINavigationController *)pickerViewController didReturnWithResult:(NSObject*)result;

@end
