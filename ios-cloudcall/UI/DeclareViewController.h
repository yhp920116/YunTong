//
//  DeclareViewController.h
//  CloudCall
//
//  Created by CloudCall on 12-8-24.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeclareViewController : UIViewController
{
    UITextView *DeclareTextView;
}
@property(nonatomic, retain) IBOutlet UITextView *DeclareTextView;
- (NSString *)applicationDataFromFile:(NSString *)fileName;

- (void) backToSetting: (id)sender;
@end
