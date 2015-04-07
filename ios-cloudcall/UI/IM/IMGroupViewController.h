//
//  IMGroupViewController.h
//

#import <UIKit/UIKit.h>

@interface IMGroupViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
	UITableView *tableView;
    UIButton *barButtonItemBack;
    
@private

    NSMutableArray *groupArray;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;

@end
