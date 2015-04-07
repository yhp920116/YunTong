//
//  SelectIMContactViewController.h
//  CloudCall
//
//  Created by CloudCall on 13-7-19.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudCallFriend : NSObject {
@public
    NSString* Name;
	NSString* Number;
}
@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSString* Number;

@end

@interface SelectIMContactViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    UITableView *tableView;
    UISearchBar *searchBar;
    
    NSMutableDictionary* contacts;
    NSArray* orderedSections;
    
    BOOL searching;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *searchView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@end
