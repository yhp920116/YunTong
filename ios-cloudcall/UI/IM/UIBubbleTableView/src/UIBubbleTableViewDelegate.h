//
//  UIBubbleTableViewDelegate.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <Foundation/Foundation.h>

@class NSBubbleData;
@class UIBubbleTableView;
@protocol UIBubbleTableViewDelegate<NSObject>

@optional
- (void)bubbleTableViewDidScrollTableView;
- (void)bubbleTableViewDidScrollToReloadTableView:(UIScrollView *)scrollView;
- (void)bubbleTableViewScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@required

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView;
- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row;

@end
