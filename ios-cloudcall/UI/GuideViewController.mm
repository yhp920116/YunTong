//
//  EXTeachViewController.m
//  ZhuanPianYi
//
//  Created by chenqi on 12-7-11.
//  Copyright (c) 2012年 zhongxun music beijing LTD.,. All rights reserved.
//

#import "GuideViewController.h"
#import "CloudCall2AppDelegate.h"
#import "ValidationViewController.h"


/*@implementation UIScrollView(Extend)

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    //[super touchesBegan:touches withEvent:event];
    //if ( !self.dragging )
    //{
        [[self nextResponder] touchesBegan:touches withEvent:event];
    //}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[super touchesMoved:touches withEvent:event];
    //if ( !self.dragging )
    //{
        [[self nextResponder] touchesMoved:touches withEvent:event];
    //}
}

@end//*/


@implementation GuideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        m_nIndex = 0;
        //mIsFirstMove = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    totalPages = 3;
//    CloudCall2AppDelegate* appDelegate = ((CloudCall2AppDelegate*)[[UIApplication sharedApplication] delegate]);
//    if ([appDelegate ShowAllFeatures] == NO) {
//        totalPages = 5;
//    }
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    if (iPhone5)
    {
        mScrollView.frame = CGRectMake(mScrollView.frame.origin.x, mScrollView.frame.origin.y, mScrollView.frame.size.width, mScrollView.frame.size.height+88);
    }
    
    if (SystemVersion >= 7.0)
    {
        mScrollView.frame = CGRectMake(mScrollView.frame.origin.x, mScrollView.frame.origin.y, mScrollView.frame.size.width, mScrollView.frame.size.height+88);
    }
    
    mScrollView.contentSize = CGSizeMake(totalPages*320.0f, mScrollView.frame.size.height);
    mScrollView.pagingEnabled = YES;
    mScrollView.delegate = self;//(AppDelegate*)[[UIApplication sharedApplication] delegate];
    //mScrollView.canCancelContentTouches = NO;
    self.view.multipleTouchEnabled = YES;
    mScrollView.multipleTouchEnabled = YES;
    // Load in all the pages
    int pageControlHeight = 20;
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, mScrollView.frame.size.height - pageControlHeight, 320, pageControlHeight)];
    [pageControl setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:pageControl];
    int kNumberOfPages = totalPages;
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor clearColor];
    
	for (int i = 1; i <= totalPages; i++)
	{
        int n = i;
//        if (i == 5 && [appDelegate ShowAllFeatures] == NO) {
//            n = i+1;
//        }
        NSString *filename = [NSString stringWithFormat:@"yingdao%03d.png", n];
        
		UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filename]];
		iv.frame = CGRectMake((i-1) * 320.0f, (iPhone5 ? 0.0f : ((SystemVersion >= 7.0) ? - 24.0f : -44.0f)), 320.0f, mScrollView.frame.size.height);
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        if (i == totalPages)
        {
//            UIButton *enterYDTBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            if (iPhone5)
//                enterYDTBtn.frame = CGRectMake(108.0f, 350.0f+30, 104.0f, 35.0f);
//            else
//                enterYDTBtn.frame = CGRectMake(108.0f, 350.0f, 104.0f, 35.0f);
//            [enterYDTBtn setBackgroundImage:[UIImage imageNamed:@"Enter_Btn_normal"] forState:UIControlStateNormal];
//            [enterYDTBtn setBackgroundImage:[UIImage imageNamed:@"Enter_Btn_press"] forState:UIControlStateHighlighted];
//            [enterYDTBtn setTitle:NSLocalizedString(@"Enter CloudCall", @"Enter CloudCall") forState:UIControlStateNormal];
//            [enterYDTBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [enterYDTBtn addTarget:self action:@selector(onButtonClick:) forControlEvents: UIControlEventTouchUpInside];
            
            iv.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageViewSingleTap)];
            [iv addGestureRecognizer:singleTapGesture];
            [singleTapGesture release];
        }
        [mScrollView addSubview:iv];
        [iv release];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
//    if ((index == m_nIndex)&&(m_nIndex == (TEACH_PAGE-1)))
//    {        
//        
//    }
//    else
//    {
    m_nIndex = page;

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.x > (totalPages - 1) * 320 +70)
    {
        [self guideViewDismiss];
    }
}

- (void)onImageViewSingleTap
{
    [self guideViewDismiss];
}

- (void)dealloc
{
    [pageControl release];
    [super dealloc];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"scrollViewWillEndDragging:%f,%f",targetContentOffset->x, targetContentOffset->y);
    NSLog(@"velocity:%f,%f",velocity.x, velocity.y);
    if (velocity.x > 0) 
    {
        if (m_nIndex < (totalPages -1))
        {
            m_nIndex++;
            targetContentOffset->x = m_nIndex*mScrollView.frame.size.width;
        }
        else
        {
            [self guideViewDismiss];
        }
    }
    else
    {
        if (m_nIndex > 0) 
        {
            m_nIndex--;
            targetContentOffset->x = m_nIndex*mScrollView.frame.size.width;

        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    mStartPos = [[touches anyObject]locationInView:mScrollView];
    mIsFirstMove = YES;
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (mIsFirstMove) 
    {
        mIsFirstMove = NO;
        CGPoint pt = [[touches anyObject]locationInView:mScrollView];
        float xOff = pt.x - mStartPos.x;
        if (xOff < 0) 
        {
            if (m_nIndex < (totalPages -1))
            {
                m_nIndex++;
                [mScrollView setContentOffset:CGPointMake(m_nIndex*mScrollView.frame.size.width, 0)];
                //mScrollView. = m_nIndex*mScrollView.frame.size.width;
            }
            else
            {
                [self guideViewDismiss];
            }
        }
        else
        {
            if (m_nIndex > 0) 
            {
                m_nIndex--;
                mScrollView.contentOffset = CGPointMake(m_nIndex*mScrollView.frame.size.width, 0);
                
            }
        }

    }
}


- (void)guideViewDismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
