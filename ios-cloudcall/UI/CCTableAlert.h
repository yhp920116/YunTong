//
//  --------------------------------------------
//  Copyright (C) 2011 by Simon Blommegård
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  --------------------------------------------
//
//  CCTableAlert.h
//  CCTableAlert
//
//  Created by Simon Blommegård on 2011-04-08.
//  Copyright 2011 Simon Blommegård. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTableCornerRadius 5.

typedef enum {
	CCTableAlertTypeSingleSelect, // dismiss alert with button index -1 and animated (default)
	CCTableAlertTypeMultipleSelct, // dismiss handled by user eg. [alert.view dismiss...];
} CCTableAlertType;

typedef enum {
	CCTableAlertStylePlain, // plain white BG and clear FG (default)
	CCTableAlertStyleApple, // same style as apple in the alertView for slecting wifi-network (Use CCTableAlertCell)
} CCTableAlertStyle;

// use this class if you would like to use the custom section headers by yourself
@interface CCTableViewSectionHeaderView : UIView {}
@property (nonatomic, copy) NSString *title;
@end

@interface CCTableAlertCell : UITableViewCell {}
- (void)drawCellBackgroundView:(CGRect)r;
@end

@class CCTableAlert;

@protocol CCTableAlertDelegate <NSObject>
@optional

- (CGFloat)tableAlert:(CCTableAlert *)tableAlert heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableAlert:(CCTableAlert *)tableAlert didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableAlertCancel:(CCTableAlert *)tableAlert;

- (void)tableAlert:(CCTableAlert *)tableAlert clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)willPresentTableAlert:(CCTableAlert *)tableAlert;
- (void)didPresentTableAlert:(CCTableAlert *)tableAlert;

- (void)tableAlert:(CCTableAlert *)tableAlert willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)tableAlert:(CCTableAlert *)tableAlert didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end

@protocol CCTableAlertDataSource <NSObject>
@required

- (UITableViewCell *)tableAlert:(CCTableAlert *)tableAlert cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableAlert:(CCTableAlert *)tableAlert numberOfRowsInSection:(NSInteger)section;

@optional

- (NSInteger)numberOfSectionsInTableAlert:(CCTableAlert *)tableAlert; // default 1
- (NSString *)tableAlert:(CCTableAlert *)tableAlert titleForHeaderInSection:(NSInteger)section;

@end

@interface CCTableAlert : NSObject <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {}

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, retain) UIAlertView *view;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic) CCTableAlertType type;
@property (nonatomic) CCTableAlertStyle style;
@property (nonatomic) NSInteger maximumVisibleRows; // default 4, (nice in both orientations w/ rowHeigh == 40), if -1 is passed it will display the whole table.
@property (nonatomic) CGFloat rowHeight; // default 40, (default in UITableView == 44)

@property (nonatomic, assign) id <CCTableAlertDelegate> delegate;
@property (nonatomic, assign) id <CCTableAlertDataSource> dataSource;

@property (nonatomic, assign) id <UITableViewDelegate> tableViewDelegate; // default self, (set other for more advanded use)
@property (nonatomic, assign) id <UITableViewDataSource> tableViewDataSource; // default self, (set other for more advanded use)
@property (nonatomic, assign) id <UIAlertViewDelegate> alertViewDelegate; // default self, (set other for more advanded use)

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle messageFormat:(NSString *)message, ...;
+ (id)alertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle messageFormat:(NSString *)message, ...;

- (void)show;

@end
