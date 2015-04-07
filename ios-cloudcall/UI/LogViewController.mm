//

#import "LogViewController.h"

#import "CloudCall2AppDelegate.h"

@implementation LogViewController

@synthesize txtViewLog;

- (void)redirectNotificationHandle:(NSNotification *)nf {
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    self.txtViewLog.text = [NSString stringWithFormat:@"%@\n%@",self.txtViewLog.text, str];
    NSRange range;
    range.location = [self.txtViewLog.text length] - 1;
    range.length = 0;
    [self.txtViewLog scrollRangeToVisible:range];
    
    [[nf object] readInBackgroundAndNotify];
}

- (void)redirectSTD:(int )fd{
    NSPipe * pipe = [NSPipe pipe];
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading];
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle];
    [pipeReadHandle readInBackgroundAndNotify];
}

-(void) startLog {
    [self redirectSTD:STDOUT_FILENO];
    [self redirectSTD:STDERR_FILENO];
}

- (void) backToSetting: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) clearAll
{
    self.txtViewLog.text = @"";
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc{
    [txtViewLog release];
    
    [super dealloc];
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{  
    [super viewDidLoad];
    
    self.navigationItem.title = @"Log View";
    
    self.txtViewLog.text = @"";
    self.txtViewLog.editable = NO;
    
    UIButton *toolBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBackBtn.frame = CGRectMake(260, 28, 44, 44);
    [toolBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBackBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_up.png"] forState:UIControlStateNormal];
    [toolBackBtn setBackgroundImage:[UIImage imageNamed:@"back_button_down.png"] forState:UIControlStateHighlighted];
    [toolBackBtn addTarget:self action:@selector(backToSetting:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBackBtn] autorelease];
    
    UIButton *toolBtnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBtnClear.frame = CGRectMake(135, 7, 72, 30);
    [toolBtnClear setTitle:@"Clear" forState:UIControlStateNormal];
    [toolBtnClear setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    toolBtnClear.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [toolBtnClear setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_up.png"] forState:UIControlStateNormal];
    [toolBtnClear setBackgroundImage:[UIImage imageNamed:@"toolbarbtn_down.png"] forState:UIControlStateHighlighted];
    [toolBtnClear addTarget:self action:@selector(clearAll) forControlEvents: UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBtnClear] autorelease];
}


- (void)viewDidUnload
{
    [super viewDidUnload];    

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
