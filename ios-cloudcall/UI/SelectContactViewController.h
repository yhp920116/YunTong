/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import <AddressBookUI/ABPersonViewController.h>

#import "PersonViewController.h"

//@protocol ParticipantPickerDelegate <NSObject>
//-(void) shouldContinueAfterPickingContacts: (NSMutableArray*) contacts;
//@end


//@interface ParticipantInfo : NSObject {
//@public
//    NSString* Name;
//	NSString* Number;
//    NSString* Description;
//    NSData *picture;
//    
//    BOOL selected;
//}
//@property (nonatomic, retain) NSString *Name;
//@property (nonatomic, retain) NSString* Number;
//@property (nonatomic, retain) NSString* Description;
//@property (nonatomic, retain) NSData *picture;
//
//@end

@interface SelectContactViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ABPersonViewControllerDelegate>
{
    UISearchBar *searchBar;
    UITableView *tableView;    
    UIView      *viewToolbar;
    UIToolbar   *toolbar;
    UILabel     *labelTitle;
    
    UIButton *barButtonItemBack;
    UIButton *barButtonSelectAll;
    UIButton *barButtonDone;
    
    NSMutableDictionary* contacts;
    NSArray* orderedSections;
        
    BOOL IsSelectAll;
    BOOL searching;
    BOOL letUserSelectRow;
    
    NSString *strAddNumber;
}

@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIView *viewToolbar;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) NSString *strAddNumber;

- (IBAction)onButtonToolBarItemClick: (id)sender;

@end
