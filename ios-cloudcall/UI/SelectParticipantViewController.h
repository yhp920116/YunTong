/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"

@protocol ParticipantPickerDelegate <NSObject>
-(void) shouldContinueAfterPickingContacts: (NSMutableArray*) contacts;
@end


@interface ParticipantInfo : NSObject {
@public
    NSString* Name;
	NSString* Number;
    NSString* Description;
    NSData *picture;
    
    BOOL selected;
}
@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSString* Number;
@property (nonatomic, retain) NSString* Description;
@property (nonatomic, retain) NSData *picture;

@end

@interface SelectParticipantViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UISearchBar *searchBar;
    UITableView *tableView;    
    UIView      *viewToolbar;
    UIToolbar   *toolbar;
    UILabel     *labelTitle;
    
    UIButton *barButtonItemBack;
    UIButton *barButtonSelectAll;
    UIButton *barButtonDone;
    NSString *uuid;
    
    NSMutableDictionary* contacts;
    NSArray* orderedSections;
    
    UIViewController<ParticipantPickerDelegate> *delegate;
    NgnConferenceFavorite *conffavorite;
    
    BOOL IsSelectAll;
    BOOL searching;
    BOOL letUserSelectRow;
    BOOL isNewGroup;

}
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, assign) BOOL isNewGroup;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *viewToolbar;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UILabel *labelTitle;
@property (nonatomic, retain) NgnConferenceFavorite *conffavorite;

-(void) SetDelegate:(UIViewController<ParticipantPickerDelegate> *)delegate;


- (IBAction)onButtonToolBarItemClick: (id)sender;

@end
