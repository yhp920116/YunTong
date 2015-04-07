//

#import <UIKit/UIKit.h>

@interface LogViewController : UIViewController {    
    UITextView *txtViewLog;
}

@property(nonatomic, retain) IBOutlet UITextView *txtViewLog;

-(void) startLog;

@end
